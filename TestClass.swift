//
//  TestClass.swift
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

//MARK: Testing class here

//MARK: _SweetSocket_
/// Built-in socket service conform to SWTSocket related protocols with pre-impletment func by protocol extension. If you want to custome, there is no need to subclassing it. You can make your own socket service by confirming to the SWTSocketXXX protocols. Over write your own version from it.
public struct _SweetSocket_ {
    public static var max_connection:Int32 = 500
}

extension _SweetSocket_:SWTSocketService{}


class Sample<T where T:SWTSocketService>:SWTHTTPServer,SWTFileService{
    
    var rootDir:String = ""
    var router = SWTRouter()
    
    typealias S = T
    
    var socket:CInt = -1
    
    let ip                      :String
    let port                    :Int
    let options                 :[String:String]
    
    ///default initializer to setup socket service.
    ///* -ip : ip to bind.
    ///* -port : port to bind.
    ///* -options : options for service provide.
    ///
    ///default setting: 0.0.0.0:8080 with no options
    required init(ip:String = "0.0.0.0", port:Int = 8080 ,options:[String:String] = [String:String]()){
        self.ip = ip
        self.port = port
        self.options = options
    }
    
    //
    func listen(socket: CInt) {
        print("start listening")
        while let client = S.acceptClient(socket){
            if socket < 0{
                return
            }
            //print("socket\(client)")
            self.router.route(client)
        }
        print("end")
    }
    
    subscript (path:String) -> (SWTRouter.Connection->())?{
        get {
            return router[path]
        }
        set{
            router[path] = newValue
        }
    }
    
}

class FunctionalSample<T:SWTSocketService>:SWTHTTPServer,SWTFileService {
    var rootDir:String = ""
    var router = SWTRouter()
    
    typealias S = T
    
    var socket:CInt = -1
    
    let ip                      :String
    let port                    :Int
    let options                 :[String:String]
    
    ///default initializer to setup socket service.
    ///* -ip : ip to bind.
    ///* -port : port to bind.
    ///* -options : options for service provide.
    ///
    ///default setting: 0.0.0.0:8080 with no options
    required init(ip:String = "0.0.0.0", port:Int = 8080 ,options:[String:String] = [String:String]()){
        self.ip = ip
        self.port = port
        self.options = options
    }
    //
    func listen(socket: CInt) {
        print("start listening")
        while let client = S.acceptClient(socket){
            if socket < 0{
                return
            }
            //print("socket\(client)")
            self.router.route(client)
        }
        print("end")
    }
}
