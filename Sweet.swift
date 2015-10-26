//
//  Sweet.swift
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

//MARK: Protocols

/// place holder , for future support.


//MARK: SWTServerSetup
public protocol SWTServerSetup{
    var ip      :String         {get}
    var port    :Int            {get}
    var options :[String:String]{get}
}

//MARK: SWTSocketServing
public protocol SWTSocketServing{
    /// The Socket this server interact with
    typealias S :SWTSocketService
}

//MARK: SWTServerRun
public protocol SWTHTTPServer:SWTSocketServing,SWTServerSetup{
    init(ip:String, port:Int,options:[String:String])
    
    /// A scoket assigned to server after setting up
    var socket  :CInt           {get set}
    
    /// Create socket service and call listen(_) by default
    mutating func start()
    /// stop and release current socket
    mutating func stop()
    
    /// Handle the listen event of socket created
    func listen(socket:CInt)
}

extension SWTHTTPServer{
    mutating func start(){
        do {
            self.socket = try S.createSocket()
            self.listen(self.socket)
        }catch{
            //TODO: Error handling code here...
            print("error")
        }
    }
    mutating func stop(){
        S.release(socket)
        self.socket = -1
    }
}

//MARK: SWTFileService
public protocol SWTFileService{
    var rootDir     : String {get}
}



