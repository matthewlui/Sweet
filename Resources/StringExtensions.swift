//
//  StringExtensions.swift
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

extension String {
    ///convenience method to append characters
    mutating func append(chars:Data){
        for c in chars{
            let char = UnicodeScalar(c)
            if char.isASCII(){
                append(char)
            }
        }
    }
    
    //TODO: Rewrite
    func tighten() -> String {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
}

extension String{
    /// Convenience method for unwrapping JSON strings from "EXAMPLESTRING" to EXAMPLESTRING .
    func unwrapJSONString() -> String{
        if self.isEmpty || self.startIndex.successor() >= self.endIndex.predecessor().predecessor() {
            return self
        }
        if hasPrefix("'") || hasSuffix("'")
            && hasPrefix("\"") || hasSuffix("\"") {
                return self[self.startIndex.successor()...self.endIndex.predecessor().predecessor()]
        }
        return self
    }
    
    /// Convenience method for unwrapping Strings from defined prefix and suffix.
    func unwrapSymblo(symblo:(preifx:String,suffix:String)) -> String{
        if self.isEmpty || self.startIndex.successor() >= self.endIndex.predecessor().predecessor() {
            return self
        }
        if hasPrefix(symblo.0) && hasSuffix(symblo.1) {
            return self[self.startIndex.successor()...self.endIndex.predecessor().predecessor()]
        }
        return self
    }
    
    /// Convenience method by trimming header sapce.
    func trimHeadSpace() -> String{
        var trimIndex = startIndex
        while self[trimIndex] == Character("\n") || self[trimIndex] == Character(" ")
            && trimIndex < endIndex{
                trimIndex = trimIndex.successor()
        }
        return self[trimIndex...endIndex.predecessor()]
    }
    
    /// Convenience method by trimming tailer sapce.
    func trimTailSpace() -> String{
        var trimIndex = endIndex.predecessor()
        while self[trimIndex] == Character("\n") || self[trimIndex] == Character(" ")
            && trimIndex > startIndex{
                trimIndex = trimIndex.predecessor()
        }
        return self[startIndex...trimIndex]
    }
    
    /// Convenience method by trimming header and tailer sapce.
    func trimHeadAndTailSapce() -> String{
        return self.trimHeadSpace().trimTailSpace()
    }
    
    /// return the index of next none empty Character or the original value if not find.
    func nextNoneEmptyIndex(start:Index) -> Index{
        if endIndex < start.successor(){
            return start
        }
        if self[start] != " " && self[start] != "\n" {
            return start
        }
        let space2Hash = "  ".hashValue
        let spaceReturnHash = " \n".hashValue
        let returnSpaceHash = "\n ".hashValue
        let returnReturnHash = "\n\n".hashValue
        var current = start
        
        repeat{
            var first2 = self[current...current.advancedBy(1)]
            let first2hash = first2.hashValue
            switch first2hash{
                case space2Hash,spaceReturnHash,returnSpaceHash,returnReturnHash:
                    current = current.advancedBy(2)
                break
            default:
                if self[current] != " " && self[current] != "\n"{
                    return current
                }
                return current.advancedBy(1)
            }
        }while true
    }
    
    /// Convenience method to get range of current string.
    var range:Range<String.Index>{
        return startIndex...endIndex.predecessor()
    }
    
}

extension Character{
    func containedInString(str:String) -> Bool{
        for c in str.characters{
            if c == self{
                return true
            }
        }
        return false
    }
}
