//
//  AsyncSocket.swift
//  FlyingFox
//
//  Created by Simon Whitty on 13/02/2022.
//  Copyright © 2022 Simon Whitty. All rights reserved.
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/swhitty/Awaiting
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

import Foundation

protocol AsyncSocketPool {
    func run() async throws
    func suspend(untilReady socket: Socket) async
}

struct AsyncSocket {

    let socket: Socket
    let pool: AsyncSocketPool

    init(socket: Socket, pool: AsyncSocketPool) throws {
        self.socket = socket
        self.pool = pool
        try socket.setFlags(.nonBlocking)
    }

    func accept() async throws -> AsyncSocket {
        var file = try socket.accept()?.file

        while file == nil {
            await pool.suspend(untilReady: socket)
            file = try socket.accept()?.file
        }

        let socket = Socket(file: file!)
        return try AsyncSocket(socket: socket, pool: pool)
    }

    func read() async throws -> UInt8 {
        var byte = try socket.read()

        while byte == nil {
            await pool.suspend(untilReady: socket)
            byte = try socket.read()
        }

        return byte!
    }

    func write(_ data: Data) throws {
        // can actually block
        try socket.writeData(data)
    }

    func close() throws {
        // can actually block
        try socket.close()
    }

    var bytes: ClosureSequence<UInt8> {
        ClosureSequence(closure: read)
    }

    var sockets: ClosureSequence<AsyncSocket> {
        ClosureSequence(closure: accept)
    }
}
