//
//  CatViewerTests.swift
//  CatViewerTests
//
//  Created by Boolky Bear on 4/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit
import XCTest

class CatViewerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }

	func testCatRequest()
	{
		var isXMLDownloaded = false
		
		let expectation = expectationWithDescription("http://thecatapi.com/api/images/get")
		
		request(Method.GET, "http://thecatapi.com/api/images/get", parameters: [ "format" : "xml" ])
			.validate()
			.responseString { (request, _, xmlData, error) in
				if let xmlData = xmlData
				{
					if countElements(xmlData) > 0 && error == nil
					{
						isXMLDownloaded = true
					}
				}
				
				expectation.fulfill()
		}
		
		waitForExpectationsWithTimeout(10) { (error) in
			XCTAssertNil(error, "\(error)")
		}
		
		XCTAssert(isXMLDownloaded, "XML has not been downloaded")
	}
	
	func testCatParse()
	{
		var isXMLParsed = false
		
		let expectation = expectationWithDescription("http://thecatapi.com/api/images/get")
		
		request(Method.GET, "http://thecatapi.com/api/images/get", parameters: [ "format" : "xml" ])
			.validate()
			.response { (request, _, xmlData, error) in
				if let xmlData = xmlData as? NSData
				{
					if xmlData.length > 0 && error == nil
					{
						let parser = NSXMLParser(data: xmlData)
						let catDelegate = CatParserDelegate()
						
						parser.delegate = catDelegate
						XCTAssert(parser.parse(), "XML has not been parsed")
						XCTAssert(catDelegate.isParsed(), "XML has not been parsed")
						XCTAssert(catDelegate.count() == 1, "XML is not correct")
						
						let cat = catDelegate[0]
						
						XCTAssert(countElements(cat.url ?? "") > 0, "URL should not be empty")
						XCTAssert(countElements(cat.identifier ?? "") > 0, "Identifier should not be empty")
						XCTAssert(countElements(cat.url ?? "") > 0, "Source Url should not be empty")
						
						isXMLParsed = true
					}
				}
				
				expectation.fulfill()
		}
		
		waitForExpectationsWithTimeout(10) { (error) in
			XCTAssertNil(error, "\(error)")
		}
		
		XCTAssert(isXMLParsed, "XML has not been parsed correctly")
	}
}
