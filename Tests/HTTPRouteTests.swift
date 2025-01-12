//
//  HTTPRouteTests.swift
//  FlyingFox
//
//  Created by Simon Whitty on 13/02/2022.
//  Copyright © 2022 Simon Whitty. All rights reserved.
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/swhitty/FlyingFox
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

@testable import FlyingFox
import XCTest

final class HTTPRouteTests: XCTestCase {

    func testPathComponents() {
        XCTAssertEqual(
            HTTPRoute("hello/world").path,
            [.caseInsensitive("hello"), .caseInsensitive("world")]
        )

        XCTAssertEqual(
            HTTPRoute("hello/*").path,
            [.caseInsensitive("hello"), .wildcard]
        )
    }

    func testMethod() {
        XCTAssertEqual(
            HTTPRoute("hello/world").method,
            .wildcard
        )

        XCTAssertEqual(
            HTTPRoute("GET hello").method,
            .caseInsensitive("GET")
        )
    }

    func testWildcard_MatchesPath() {
        let route = HTTPRoute("/fish/*")

        XCTAssertTrue(
            route ~= "/fish/chips"
        )

        XCTAssertTrue(
            route ~= "/fish/chips/mushy/peas"
        )

        XCTAssertFalse(
            route ~= "/chips"
        )
    }

    func testMethod_Matches() {
        let route = HTTPRoute("POST /fish/chips")

        XCTAssertTrue(
            route ~= "POST /fish/chips"
        )

        XCTAssertTrue(
            route ~= "post  /fish/chips/"
        )

        XCTAssertFalse(
            route ~= "GET /fish/chips"
        )
    }

    func testWildcardMethod_Matches() {
        let route = HTTPRoute("/fish/chips")

        XCTAssertTrue(
            route ~= "/fish/chips/"
        )

        XCTAssertTrue(
            route ~= "GET /fish/chips"
        )

        XCTAssertTrue(
            route ~= "ANY /fish/chips"
        )

        XCTAssertFalse(
            route ~= "/chips"
        )
    }

    func testWildcardMethod_MatchesRoute() {
        let route = HTTPRoute("GET /mock")

        XCTAssertFalse(
            route ~= HTTPRequest.make(method: HTTPMethod("GET"),
                                      path: "/")
        )

        XCTAssertTrue(
            route ~= HTTPRequest.make(method: HTTPMethod("GET"),
                                      path: "/mock")
        )

        XCTAssertFalse(
            route ~= HTTPRequest.make(method: HTTPMethod("GET"),
                                      path: "/mock/fish")
        )
    }

    func testEmptyWildcard_MatchesAllRoutes() {
        let route = HTTPRoute("*")

        XCTAssertTrue(
            route ~= HTTPRequest.make(method: HTTPMethod("GET"),
                                      path: "/")
        )

        XCTAssertTrue(
            route ~= HTTPRequest.make(method: HTTPMethod("GET"),
                                      path: "/mock")
        )

        XCTAssertTrue(
            route ~= HTTPRequest.make(method: HTTPMethod("GET"),
                                      path: "/mock/fish")
        )
    }
}
