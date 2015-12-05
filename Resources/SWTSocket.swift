//
//  SWTSocket.swift
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


//MARK: Errors' declaration
enum SWTSocketCreateError:ErrorType{
    case PortError
    case BindError
    case SocketSettingError
}

enum SWTSocketWritingError:ErrorType{
    case SocketNotExist(CInt)
    case NoData(CInt)
}

enum SWTSocketListeningError:ErrorType{
    case RequestNotAccept
}

//MARK: SWTSocketWriting
public protocol SWTSocketWriting{
    /// Write string to client socket,
    /// may throw error:SWTSocketError
    static func writeString(to socket:CInt, string:String) throws
    /// Write Data (represented by [UInt8]) to client socket,
    /// may throw error:SWTSocketError
    static func writeData(to socket:CInt, data:UnsafePointer<Void>,size:Int) throws
}

extension SWTSocketWriting{
    //TODO: Error handle code there to prevent write on dead socket continuously.
    public static func writeString(to socket:CInt, string:String) throws {
        //TODO: Slice down the string into a write loop for future support.
        if string == ""{
            throw SWTSocketWritingError.NoData(socket)
        }
        write(socket, string, Int(string.utf8.count))
    }
    public static func writeData(to socket:CInt, data:UnsafePointer<Void>,size:Int) throws {
        write(socket, data, size)
    }
}

//MARK: SWTSocketListening
public protocol SWTSocketListening{
    /// Wait for client connection, may throw error:SWTSocketError
    static func acceptClient(socket:CInt) -> CInt?
}

extension SWTSocketListening{
    //TODO :Fix crash on 56000 call
    /// Pass in socket to listen.
    /// - Warning: Use Posix accept witch will block.
    /// throw SWTSocketListeningError
    public static func acceptClient(socket:CInt) -> CInt?{
        var addr = sockaddr(sa_len: 0, sa_family: 0, sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0))
        var len:socklen_t = 0
        let client = accept(socket, &addr, &len)
        if client < 0 {
            //TODO: throw
            return nil
        }
        return client
    }
}

//MARK: SWTSocketRequestHeader
public protocol SWTSocketRequestHeaderRecieving{
    static func recieve(socket:CInt) -> String
}

extension SWTSocketRequestHeaderRecieving{
    //TODO: fine tune for more concurrent calls
    /// Retrieve request header.
    /// Views
    public static func recieve(socket:CInt) -> String{
        var chars:Data
        var string = ""
        repeat{
            //TODO: Clean up after testing UTF-8 support
            chars = [UInt8](count: 128, repeatedValue: 0)
            read(socket, &chars, chars.count)
            var s2 = ""
            chars.forEach({ (char) -> () in
                s2.append(UnicodeScalar(char))
            })
            string.append(chars)
        }while chars.last! != 0
        chars = [UInt8](count: 256, repeatedValue: 0)
        return string
    }
}

//MARK: SWTSocketConnecting
public protocol SWTSocketConnection{
    static var max_connection:Int32 {get set}
    /// Create a socket for server to listen,
    /// may throw error:SWTSocketError
    static func createSocket(ip:String,port:Int) throws -> CInt
}

extension SWTSocketConnection{
    /// Create a socket bond to ip and port.
    /// - Returns: A socket represent by CInt or throw: SWTSocketCreateError
    public static func createSocket(ip:String = "0.0.0.0",port:Int = 8080) throws -> CInt{
        let s = socket(AF_INET, SOCK_STREAM, 0)
        if s < 0{
            throw SWTSocketCreateError.PortError
        }
        
        //TODO: fcntl(sockfd,F_SETFL,O_NONBLOCK) find instead in OSX
        var flag:Int32 = 1
        if setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &flag, socklen_t(sizeof(Int32))) == -1 {
            shutdown(s, SHUT_RDWR)
            close(s)
            throw SWTSocketCreateError.SocketSettingError
        }
        
        var addr = sockaddr_in()
        addr.sin_len = __uint8_t(sizeof(sockaddr_in))
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_addr.s_addr = inet_addr(ip)
        addr.sin_port = in_port_t(port).bigEndian
        addr.sin_zero = (0,0,0,0,0,0,0,0)
        var socketAddr = sockaddr()
        memcpy(&socketAddr, &addr, sizeof(sockaddr_in))
        let len = socklen_t(sizeof(sockaddr_in))
        if bind(s, &socketAddr, len) == -1 {
            shutdown(s, SHUT_RDWR)
            close(s)
            throw SWTSocketCreateError.BindError
        }
        if listen(s, max_connection) == -1{
            shutdown(s, SHUT_RDWR)
            close(s)
            throw SWTSocketCreateError.SocketSettingError
        }
        return s
        NSRunLoop.mainRunLoop().run()
    }
}

//MARK: SWTSocketEndSocket
public protocol SWTSocketReleasing{
    static func release(socket:CInt)
}
extension SWTSocketReleasing{
    public static func release(socket:CInt) {
        shutdown(socket, SHUT_RDWR)
        close(socket)
    }
}

//MARK: SWTSocketService
/// Protocol include all needed Socket services function.
/// Use to define Swift tailor HTTP service protocol.
/// Default extension are all writen by supporting of POSIX
public typealias SWTSocketService = protocol<SWTSocketConnection,SWTSocketListening,SWTSocketRequestHeaderRecieving,SWTSocketWriting,SWTSocketReleasing>





