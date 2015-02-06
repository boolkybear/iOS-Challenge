//
//  CategoryParserDelegate.swift
//  CatViewer
//
//  Created by Boolky Bear on 6/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit

class CategoryParserDelegate: NSObject {
	
	private enum Tag: String {
		case Response = "response"
		case Data = "data"
		case Categories = "categories"
		case Category = "category"
		case Identifier = "id"
		case Name = "name"
	}
	
	private enum ParseStatus {
		case NotParsed
		case ParsedResponse
		case ParsedData
		case ParsedCategories
		case Ok
		case Error
		
		func nextStatus(tag: Tag) -> ParseStatus
		{
			switch tag
			{
			case .Response:
				return self == .NotParsed ? .ParsedResponse : .Error
				
			case .Data:
				return self == .ParsedResponse ? .ParsedData : .Error
				
			case .Categories:
				return self == .ParsedData ? .ParsedCategories : .Error
				
			case .Category:
				switch self
				{
				case .ParsedCategories:
					return .Ok
					
				case .Ok:
					return .Ok
					
				case .NotParsed: fallthrough
				case .ParsedResponse: fallthrough
				case .ParsedData: fallthrough
				case .Error:
					return .Error
				}
				
			case .Identifier: fallthrough
			case .Name:
				return self == .Ok ? .Ok : .Error
			}
		}
	}
	
	private var categories: [CategoryModel]
	
	// temporary
	private var temporaryCategory: CategoryModel!
	private var tagStack: Stack<Tag>
	private var status: ParseStatus
	
	override init() {
		self.tagStack = Stack<Tag>()
		
		self.categories = [CategoryModel]()
		
		self.status = .NotParsed
	}
	
	func isParsed() -> Bool
	{
		return self.status == .Ok
	}
	
	func count() -> Int
	{
		return self.categories.count
	}
	
	subscript(index: Int) -> CategoryModel
	{
		return self.categories[index]
	}
}

extension CategoryParserDelegate: NSXMLParserDelegate
{
	func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
		if let tag = Tag(rawValue: elementName)
		{
			self.tagStack.push(tag)
			self.status = self.status.nextStatus(tag)
			
			switch tag
			{
			case .Category:
				self.temporaryCategory = CategoryModel()
				
			case .Identifier:
				self.temporaryCategory.identifier = ""
				
			case .Name:
				self.temporaryCategory.name = ""
				
			case .Response: fallthrough
			case .Data: fallthrough
			case .Categories:
				break
			}
		}
		else
		{
			// TODO: log parser error
			parser.abortParsing()
		}
	}
	
	func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
		if let tag = Tag(rawValue: elementName)
		{
			if tag == .Category
			{
				self.categories.append(self.temporaryCategory)
				self.temporaryCategory = nil
			}
			
			self.tagStack.pop()
		}
		else
		{
			// TODO: log parser error
			parser.abortParsing()
		}
	}
	
	func parser(parser: NSXMLParser!, foundCharacters string: String!) {
		
		if let currentTag = self.tagStack.top()
		{
			switch currentTag
			{
			case .Identifier:
				self.temporaryCategory.identifier?.extend(string)
				
			case .Name:
				self.temporaryCategory.name?.extend(string)
				
			case .Response: fallthrough
			case .Data: fallthrough
			case .Categories: fallthrough
			case .Category:
				break
			}
		}
	}
	
	func parser(parser: NSXMLParser!, foundCDATA CDATABlock: NSData!) {
		
		if let currentTag = self.tagStack.top()
		{
			switch currentTag
			{
			case .Identifier: fallthrough
			case .Name:
				if let string = NSString(data: CDATABlock, encoding: NSUTF8StringEncoding)
				{
					self.parser(parser, foundCharacters: string)
				}
				
			case .Response: fallthrough
			case .Data: fallthrough
			case .Categories: fallthrough
			case .Category:
				break
			}
		}
	}
}