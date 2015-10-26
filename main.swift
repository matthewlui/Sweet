//
//  main.swift
//  SwiftTailor
//
//  Copyright (c) <2015> <Matthew Lui>
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software
//  is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

var bundle = NSBundle.mainBundle()
//let html = bundle.pathForResource("index", ofType: "html")!

typealias SampleHTTP = Sample<_SweetSocket_>

infix operator >>> { associativity left}

func >>> <T>(lhs:T->(),rhs:T->()) -> T->(){
    return { p -> () in
        lhs(p)
        rhs(p)
    }
}

func initingServerTest<T:SWTSocketService>(_: T.Type) -> Sample<T>{
    var server = Sample<T>()
    // Demo of use of simple(naive) ip blocker
    var indexFile = ""
    let bundle = NSBundle.mainBundle()
    if let indexFileURL = bundle.URLForResource("index", withExtension: "html"){
        do {
            indexFile = try NSString(contentsOfURL: indexFileURL, encoding: NSUTF8StringEncoding) as String
        }catch let err{
            print(err)
        }
    }
    
    /// handler chaining
    var blocker:SWTRouter.Handler = { connection in
        var blocklist:[String] = ["192.168.0.0","localhost"]
        guard let header = header(connection) else{
            return
        }
        guard let ip = header[HTTPHeaderKey.IP] else{
            return
        }
        if blocklist.filter({$0 == ip}).count > 0{
            write(connection, str: "You are not welcome")
            end(connection)
        }
    }
    var rootDirHandler:SWTRouter.Handler = { connection in
        if indexFile != ""{
            write(connection, str: indexFile)
        }else{
            write(connection, str: indexFile)
        }
        end(connection)
    }
    server["/checkIP"] = blocker >>> rootDirHandler
    
    /// define function
    func block<R:SWTRouting>(connection:(R,R.ClientID),blocklist:[String]) -> Bool {
        guard let header = header(connection) as? [String:String] else{
            return false
        }
        guard let ip = header[HTTPHeaderKey.IP] else{
            return false
        }
        return blocklist.filter({$0 == ip}).count > 0
    }
    
    server.router["/"] = {connection in
        if block(connection,blocklist: ["192.168.0.1"]){
            write(connection, str: "You are not welcome")
            return
        }
        if indexFile != ""{
            write(connection, str: indexFile)
        }else{
            write(connection, str: indexFile)
        }
        end(connection)
    }
    server.router["/😈"] = {connection in
        write(connection, str: "You are evil")
        end(connection)
    }
    server.start()
    return server
}

var server = initingServerTest(_SweetSocket_)

