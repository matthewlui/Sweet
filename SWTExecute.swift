//
//  SWTExecute.swift
//  Sweet
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

#if os(iOS) || os(OSX)
    typealias SWTExecuteQueue = dispatch_queue_t
#endif

func SWTExecute(queue:SWTExecuteQueue,closure:()->()){
    #if os(iOS) || os(OSX)
        dispatch_async(queue, closure)
    #endif
}


func SWTExecuteAsyn(closure:()->()){
    #if os(iOS) || os(OSX)
        dispatch_async(dispatch_queue_create("SWTGeneralAsyncQueue", DISPATCH_QUEUE_CONCURRENT), closure)
    #endif
}

func SWTIOExecute(data:[UInt8],closure:(Bool,dispatch_data_t!,Int32)->()){
        let ioqueue = dispatch_queue_create("SWTIOQueue", DISPATCH_QUEUE_CONCURRENT)
        let channel = dispatch_io_create(DISPATCH_IO_RANDOM, STDOUT_FILENO, ioqueue, { (i) -> Void in
        })
        let dataqueue = dispatch_queue_create("SWTDataQueue", DISPATCH_QUEUE_CONCURRENT)
        let data = dispatch_data_create(data, data.count, dataqueue, { () -> Void in
        })
        dispatch_io_write(channel, 0, data, ioqueue, closure)
}


//TODO: Check the support of lib_dispatch, remove and rewrite after test.

func writeAysnc<R:SWTRouting>(connection:(R,R.ClientID),str:String,completion:SuccessfulCompletion = nil){
    guard let client = client(connection) else{
        completion?(false)
        return
    }
    if str == ""{
        completion?(false)
        return
    }
    var stringWithHeader = "HTTP/1.1 200 OK\n Content-Type: text/html; charset=utf-8\n"
    stringWithHeader += "Content-Length:\(str.utf8.count)\n\n"
    stringWithHeader += str
    let dt = stringWithHeader.utf8.map { (c:UInt8) -> UInt8 in
        return c
    }
    
    SWTIOExecute(dt) { (f, d, e) -> () in
        var dataCache : [UInt8] = []
        dispatch_data_apply(d, { (region, offset, adata, size) -> Bool in
            do{
                let buffer = UnsafePointer<UInt8>(adata)
                for i in 0...size-1{
                    dataCache += [buffer[i]]
                }
                if dataCache.count < dt.count {
                    return true
                }
                guard let aString = NSString(bytes: dataCache, length: dataCache.count, encoding: NSUTF8StringEncoding) as? String else{
                    return true
                }
                try R.S.writeString(to: client, string: aString)
                return true
            }catch let err{
                print(err)
                completion?(false)
                return false
            }
        })
        if f {
            completion?(true)
        }
    }
}

