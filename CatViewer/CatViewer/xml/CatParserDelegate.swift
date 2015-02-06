//
//  CatParserDelegate.swift
//  CatViewer
//
//  Created by José Servet Font on 6/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit

class CatParserDelegate: NSObject
{
	private enum Tag: String {
		case Response = "response"
		case Data = "data"
		case Images = "images"
		case Image = "image"
		case Url = "url"
		case Identifier = "id"
		case SourceUrl = "source_url"
	}
	
	private enum ParseStatus {
		case NotParsed
		case ParsedResponse
		case ParsedData
		case ParsedImages
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
				
			case .Images:
				return self == .ParsedData ? .ParsedImages : .Error
				
			case .Image:
				switch self
				{
				case .ParsedImages:
					return .Ok
					
				case .Ok:
					return .Ok
					
				case .NotParsed: fallthrough
				case .ParsedResponse: fallthrough
				case .ParsedData: fallthrough
				case .Error:
					return .Error
				}
				
			case .Url: fallthrough
			case .Identifier: fallthrough
			case .SourceUrl:
				return self == .Ok ? .Ok : .Error
			}
		}
	}
	
	private var cats: [CatModel]
	
	// temporary
	private var temporaryCat: CatModel!
	private var tagStack: Stack<Tag>
	private var status: ParseStatus
	
	override init() {
		self.tagStack = Stack<Tag>()
		
		self.cats = [CatModel]()
		
		self.status = .NotParsed
	}
	
	func isParsed() -> Bool
	{
		return self.status == .Ok
	}
	
	func count() -> Int
	{
		return self.cats.count
	}
	
	subscript(index: Int) -> CatModel
	{
		return self.cats[index]
	}
}

extension CatParserDelegate: NSXMLParserDelegate
{
	func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
		if let tag = Tag(rawValue: elementName)
		{
			self.tagStack.push(tag)
			self.status = self.status.nextStatus(tag)
			
			switch tag
			{
			case .Image:
				self.temporaryCat = CatModel()
				
			case .Url:
				self.temporaryCat.url = ""
				
			case .Identifier:
				self.temporaryCat.identifier = ""
				
			case .SourceUrl:
				self.temporaryCat.sourceUrl = ""
				
			case .Response: fallthrough
			case .Data: fallthrough
			case .Images:
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
			if tag == .Image
			{
				self.cats.append(temporaryCat)
				self.temporaryCat = nil
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
			case .Url:
				self.temporaryCat.url?.extend(string)
				
			case .Identifier:
				self.temporaryCat.identifier?.extend(string)
				
			case .SourceUrl:
				self.temporaryCat.sourceUrl?.extend(string)
				
			case .Response: fallthrough
			case .Data: fallthrough
			case .Images: fallthrough
			case .Image:
				break
			}
		}
	}
	
	func parser(parser: NSXMLParser!, foundCDATA CDATABlock: NSData!) {
		
		if let currentTag = self.tagStack.top()
		{
			switch currentTag
			{
			case .Url: fallthrough
			case .Identifier: fallthrough
			case .SourceUrl:
				if let string = NSString(data: CDATABlock, encoding: NSUTF8StringEncoding)
				{
					self.parser(parser, foundCharacters: string)
				}
				
			case .Response: fallthrough
			case .Data: fallthrough
			case .Images: fallthrough
			case .Image:
				break
			}
		}
	}
}