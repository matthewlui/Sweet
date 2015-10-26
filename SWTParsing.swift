//
//  SWTParsing.swift
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

public protocol SWTSocketRequestHeaderParsing{
    static func parse(header:String) -> [String:String]
}

struct HTTPHeaderKey{
    static let URL              = "URL"
    static let Method           = "Method"
    static let IP               = "IP"
    static let Host             = "Host"
    static let Connection       = "Connection"
    static let CacheControl     = "Cache-Control"
    static let UserAgent        = "User-Agent"
    static let Accept           = "Accpet"
    static let DNT              = "DNT"
    static let AcceptEncoding   = "Accept-Encoding"
    static let AcceptLanguage   = "Accept-Language"
    //TODO: Add parsing function to impletement Params, and remove from URL
    static let Params           = "Params"
}

extension SWTSocketRequestHeaderParsing{
    static func parse(header:String) -> [String:String]{
        func noneColonSeperated(string:String) -> (String,String)?{
            if string == "" {
                return nil
            }
            var sep = string.componentsSeparatedByString(" ")
            if sep.count < 2{
                return nil
            }
            return (sep[0],sep[1])
        }
        
        let lines = header.componentsSeparatedByString("\r\n")
        let dict = lines.reduce([String:String]()) { (var aDict, line) -> [String:String] in
            var words = line.componentsSeparatedByString(":")
            guard let key = words.first else{
                return aDict
            }
            guard let value = words.last else{
                return aDict
            }
            if key == value {
                guard let (k,v) = noneColonSeperated(line) else{
                    return aDict
                }
                aDict[HTTPHeaderKey.Method] = k
                aDict[HTTPHeaderKey.URL] = v
                return aDict
            }
            //TODO: Write cleaner the parsing
            if words.count == 3{
                let middle = words[1]
                aDict[HTTPHeaderKey.IP] = middle.tighten()
                aDict[HTTPHeaderKey.Host] = value
                return aDict
            }
            aDict[key] = value.tighten()
            return aDict
        }
        return dict
    }
}

public protocol SWTParsing:SWTSocketRequestHeaderParsing{ }

struct SWTParser:SWTParsing{ }