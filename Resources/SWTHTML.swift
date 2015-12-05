//
//  SWTHTML.swift
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

/*
var html = SWTHTML("html")

html["class"] = "defalut"
*/
//MARK: Not usable at all!

//TODO: finish Return
public protocol SWEETHTMLSearch{
    typealias T:SWEETHTML
    func tag(HTMLClass aClass:String) -> [T]
    func tag(HTMLID anID:String) -> [T]
}

public protocol SWEETHTML{
    
    var tag:String {get set}
    var htmlClass:String {get set}
    var htmlID:String {get set}
    var elements:[Self] {get set}
    var css:[String:String] {get set}
    
    func styles() -> String
    func scipts() -> String
}

protocol SWEETHTMLAnimatable{
    var context:String { get }
}

protocol SWEETHTMLValueBondable{
    var bondJS:String {get} ///
}

protocol SWEETHTMLInputType{
    subscript (attribute:String) -> String { get }
}

protocol SWEETOnEvent{}

//typealiase DIV = SWEETHTMLTag("div")
//var body = SWEETHTML(tag:"body")
//body[0] = DIV["width":"20%"]

struct SWTHTML{
    
    var tag:String
    var attrs:[String:String]
    var children:[SWTHTML]
    init (element:String){
        tag = element
        attrs = [String:String]()
        children = [SWTHTML]()
    }
    
    subscript (attr:String) -> String?{    
        get{
            return attrs[attr]
        }
        set{
            attrs[attr] = newValue
        }
    }
    
    subscript (index:Int) -> SWTHTML{
        get{
            return children[index]
        }
        set {
            children[index] = newValue
        }
    }
    
}

extension SWTHTML:SequenceType{
    typealias Generator = AnyGenerator<SWTHTML>
    func generate() -> SWTHTML.Generator {
        var index = 0
        return anyGenerator({ () -> SWTHTML? in
            if index < self.children.count{
                return self.children[index++]
            }
            return nil
        })
    }
}


func += (inout lhs:SWTHTML,rhs:SWTHTML){

}

struct SWTHtmlNode<T>{
    private var contents:[T] = []
}

extension SWTHtmlNode:SequenceType{
    
    typealias Generator = AnyGenerator<T>

    func generate() -> Generator {
        var index = 0
        return anyGenerator({ () -> T? in
            if index < self.contents.count {
                return self.contents[index++]
            }
            return nil
        })
    }
}

