//
//  SWTRouting.swift
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

/// Route client socket once is accepted
public protocol SWTClientSocketRouting:SWTSocketServing{
    mutating func route(client:CInt)
}

/// SWTClientHandling: Define Handler and storing mechanism
public protocol SWTClientHandling{
    typealias Handler
    subscript                               (path:String) -> Handler? {get set}
}

/// SWTConnectionPool: Mechanism that manage connections
public protocol SWTConnectionPool{
    /// A unique ID for each valid connection created by encode(_) .
    /// Invoke once connection is drop.
    typealias ClientID                      : Hashable
    /// Create a anique client ID for a socket connection.
    /// Should be decoded and return the same socket connection in any time.
    func encode(client:CInt) -> ClientID
    /// return the client connection if valid.
    func decode(id:ClientID) -> CInt?
    /// A Type provide header service to each client connection
    typealias Header
    
    ///A safe method to end a connection manage by connection pool.
    func end(id:ClientID)
}

/// Protocol hold all required protocols to impletment custome router
public protocol SWTRouting:SWTClientSocketRouting,SWTClientHandling,SWTConnectionPool{
    subscript                               (clientID:ClientID) -> Header? {get}
}

typealias SuccessfulCompletion = ((Bool)->())?

public class SWTRouter:SWTRouting{
    
    public typealias Header = [String:String]
    public typealias S                      = _SweetSocket_
    
    ///A Connection is a service that provide when only it's valid by who manage it.
    ///Typically a type which is adopt to SWTConnectionPool
    public typealias Connection             = (SWTRouter,ClientID)
    
    public typealias ClientID               = String
    public var clientPool                   = [ClientID:[String:String]]()
    
    public typealias Handler                = (Connection) -> ()
    public var handlers                     = [String:Handler]()
    
    public subscript (client:ClientID) -> Header?{
        get{
            return clientPool[client]
        }
        set{
            if let header = newValue{
                clientPool[client] = header
            }else{
                clientPool.removeValueForKey(client)
            }
        }
    }
    public subscript (path:String) -> Handler?{
        get{
            return handlers[path]
        }
        set{
            if let handler = newValue{
                handlers[path] = handler
            }else{
                handlers.removeValueForKey(path)
            }
        }
    }
    
    public func route(client:CInt){
        let clientID        = self.encode(client)
        let headerString    = S.recieve(client)
        let header          = SWTParser.parse(headerString)
        
        clientPool[clientID] = header
        guard let url = header[HTTPHeaderKey.URL] else{
            return
        }
        guard let handler = handlers[url] else{
            end(clientID)
            return
        }
        handler((self,clientID))
    }
    
    public func end(id:ClientID){
        guard let _ = clientPool[id] else{
            return
        }
        clientPool.removeValueForKey(id)
        guard let client = decode(id) else{
            return
        }
        S.release(client)
    }
    //TODO: finish connection ID Generating and resolving.
    public func encode(client:CInt) -> ClientID {
        return "Demo\(client)"
    }
    
    public func decode(id:ClientID) -> CInt?{
        return CInt(id.stringByReplacingOccurrencesOfString("Demo", withString: ""))
    }
    
}


