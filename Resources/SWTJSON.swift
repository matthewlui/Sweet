//
//  SWTJSON.swift
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

enum Either<T>{
    case Some(T)
    case Err(ErrorType?)
}

class SWTSONCore {
    private var rawValue    :String
    init (str:String){
        self.rawValue = str
    }
    subscript (range:Range<String.Index>) -> String?{
        get{
            if range.endIndex < rawValue.endIndex{
                return rawValue[range]
            }
            return nil
        }
    }
}

class SWTJSON{
    
    private var range:Range<String.Index>
    
    private var json:SWTSONCore
    
    enum JSONValue{
        case StringValue
        case NumberValue
        case DictionaryValue([SWTJSON:SWTJSON])
        case ArrayValue([SWTJSON])
        case BoolenValue
        case Null
        case Undefined
    }
    
    lazy var value              : JSONValue = {
        .Undefined
        }()
    
    lazy var stringValue        : String?   = {
        if case .StringValue = self.value{
            return self.json.rawValue[self.range]
        }
        return nil
        }()
    
    lazy var dictionaryValue    : [SWTJSON:SWTJSON]? = {
        if case let .DictionaryValue ( dict ) = self.value{
            return dict
        }
        return nil
        }()
    
    lazy var arrayValue         : [SWTJSON]?  = {
        if case let .ArrayValue ( array ) = self.value{
            return array
        }
        return nil
        }()
    
    lazy var boolenValue        : Bool?     = {
        if case .BoolenValue = self.value{
            return self.range.startIndex.distanceTo(self.range.endIndex) == 4
        }
        return false
        }()
    
    lazy var intValue           : Int?      = {
        if case .NumberValue = self.value {
            return Int(self.json.rawValue[self.range])
        }
        return nil
        }()
    
    lazy var doubleValue        : Double?   = {
        if case .NumberValue = self.value {
            return Double(self.json.rawValue[self.range])
        }
        return nil
        }()
    
    init (str:String) {
        self.json = SWTSONCore(str: str.trimHeadAndTailSapce())
        self.range = str.startIndex...str.endIndex.predecessor()
    }
    
    init (json:SWTJSON,range:Range<String.Index>,value:JSONValue){
        self.json = json.json
        self.range = range
        self.value = value
    }
    
    func forward(){
        range = range.startIndex.advancedBy(1)...range.endIndex.advancedBy(1)
    }
    
}

extension SWTJSON : Hashable {
    var hashValue : Int {
        return json.rawValue[range].unwrapSymblo(("\"","\"")).hashValue
    }
}

func == (lhs:SWTJSON,rhs:SWTJSON) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct JSONBlockIdentifier {
    static let Dictionary   = "{}"
    static let Array        = "[]"
    static let String       = "\""
    static let Number       = ".0123456789"
    static let Boolen       = "TFE"
    static let NULL         = "NULL"
    static let null         = "null"
}

extension SWTJSON:CustomDebugStringConvertible{
    var debugDescription:String {
        switch self.value{
        case .StringValue:
            return "String:" + json.rawValue[range] + "\n"
        case .DictionaryValue(let dict):
            var str = "Dictionary:\n"
            
            if dict.isEmpty {
                return str + "{ }"
            }
            str     += "{"
            for (k,v) in dict {
                switch v.value{
                case .ArrayValue(_):
                    str += "  key:\(k.debugDescription)\n ," + "  value:Array \n"
                    break
                case .DictionaryValue(_):
                    str += "  key:\(k.debugDescription)\n ," + "  value: Dictionary \n"
                    break
                    
                default:
                    str += "  key:\(k.debugDescription)\n ," + "  value:\(v.debugDescription)\n"
                }
            }
            return str + "}"
        case .NumberValue:
            return "Number:" + json.rawValue[range] + "\n"
        case .ArrayValue(let array):
            var str = "Array:\n [ "
            ///TODO: decription may limit to first & last 10?
            //str     = "Original:" + json.rawValue[range] + "\n"
            if array.isEmpty {
                return str + " empty ]"
            }
            for (i,v) in array.enumerate() {
                switch v.value {
                case .ArrayValue(_):
                    str += "[\(i)] =  Array \n"
                    break
                case .DictionaryValue(_):
                    str += "[\(i)] = Dictionary \n"
                    break
                default:
                    str += "[\(i)] = " + v.debugDescription + "\n"
                }
                
            }
            return str + "]"
        case .Null:
            return "Null:" + json.rawValue[range] + "\n"
        case .BoolenValue:
            return "Boolen:" + json.rawValue[range] + "\n"
        default:
            return "Undefined"
        }
    }
}

enum xJSONParsingError:ErrorType {
    case ParsingFail(reason:String,areaRange:Range<String.Index>)
}

extension Range {
    mutating func expand(){
        self = self.startIndex...self.endIndex
    }
}

func parse(str:String) throws ->  SWTJSON? {
    var parsingString       = str //.trimHeadAndTailSapce()
    var json                = SWTJSON(str: parsingString)
    
    func parse(from:String.Index,stringToParse:String) throws ->  SWTJSON?{
        var workingRange        = from...from
        var firstSymblo         = stringToParse[from]
        var cache               = [SWTJSON]()
        while workingRange.endIndex < stringToParse.endIndex{
            
            switch (firstSymblo,stringToParse[workingRange.endIndex]) {
            case ("{", let currentChar ):
                if currentChar.containedInString(" \n"){
                    workingRange = workingRange.startIndex...stringToParse.nextNoneEmptyIndex(workingRange.endIndex).predecessor()
                    break
                }else if currentChar.containedInString(":,"){
                    workingRange = workingRange.startIndex...stringToParse.nextNoneEmptyIndex(workingRange.endIndex.successor()).predecessor()
                }
                if currentChar == "}"{
                    var dict = [SWTJSON:SWTJSON]()
                    while let first = cache.first {
                        cache.removeFirst()
                        guard let second = cache.first else{
                            return SWTJSON(json: json, range: workingRange, value: .DictionaryValue(dict))
                        }
                        dict[first] = second
                        cache.removeFirst()
                    }
                    workingRange.expand()
                    return SWTJSON(json: json, range: workingRange, value: .DictionaryValue(dict))
                }
                do{
                    guard let jObject = try parse(workingRange.endIndex, stringToParse: stringToParse) else {
                        return nil
                    }
                    workingRange.endIndex = jObject.range.endIndex
                    cache.append(jObject)
                    parsingString[workingRange.endIndex]
                }catch let err{
                    throw err
                }
                break
                
            case ("[",let currentChar):
                if currentChar.containedInString(" \n"){
                    workingRange = workingRange.startIndex...stringToParse.nextNoneEmptyIndex(workingRange.endIndex).predecessor()
                    break
                }else if currentChar == ","{
                    workingRange = workingRange.startIndex...stringToParse.nextNoneEmptyIndex(workingRange.endIndex.successor()).predecessor()
                }
                if currentChar == "]"{
                    workingRange.expand()
                    return SWTJSON(json: json, range: workingRange, value: .ArrayValue(cache))
                }
                do {
                    guard let jObject = try parse(workingRange.endIndex, stringToParse: stringToParse) else{
                        return nil
                    }
                    workingRange.endIndex = jObject.range.endIndex
                    cache.append(jObject)
                }catch let err{
                    throw err
                }
                break
                
            case ("\"", let currentChar):
                workingRange.expand()
                if currentChar == "\\"{
                    // Skip next char
                    workingRange.expand()
                    break
                }
                if currentChar == "\""{
                    // packing back cache and return
                    return SWTJSON(json: json, range: workingRange, value: .StringValue)
                }
                
            case let ( beginChar , b ) where beginChar.containedInString("+-.0123456789") :
                //MARK: move backward if test fail
                workingRange.expand()
                if b.containedInString(",}] "){
                    return SWTJSON(json: json, range: workingRange, value: .NumberValue)
                }
                break
                
            case let ( beginChar, _ ) where beginChar.containedInString("nN") :
                let assumingRange = workingRange.startIndex...workingRange.startIndex.advancedBy(3)
                return SWTJSON(json: json, range: assumingRange, value: .Null)
                
            case let ( beginChar, _ ) where beginChar.containedInString("tT") :
                let assumingRange = workingRange.startIndex...workingRange.startIndex.advancedBy(3)
                return SWTJSON(json: json, range: assumingRange, value: .BoolenValue)
                
            case let ( beginChar, _ ) where beginChar.containedInString("fF"):
                let assumingRange = workingRange.startIndex...workingRange.startIndex.advancedBy(4)
                return SWTJSON(json: json, range: assumingRange, value: .BoolenValue)
                
            case let ( beginChar, _ ) where beginChar.containedInString(" \n"):
                let nextNoneEmpty = stringToParse.nextNoneEmptyIndex(workingRange.startIndex)
                if nextNoneEmpty < workingRange.endIndex{
                    workingRange = nextNoneEmpty...workingRange.endIndex.predecessor()
                    firstSymblo = stringToParse[workingRange.startIndex]
                }else{
                    workingRange = nextNoneEmpty...nextNoneEmpty
                }
                
                break
                
            default:
                if workingRange.startIndex.successor() < workingRange.endIndex.predecessor(){
                    workingRange = workingRange.startIndex.successor()...workingRange.endIndex.predecessor()
                    break
                }
                throw xJSONParsingError.ParsingFail(reason: "Undefined : (\(stringToParse[workingRange])) \n", areaRange: workingRange)
            }
        }
        return nil
    }
    do {
        return try parse(parsingString.startIndex, stringToParse: parsingString)
    }catch let err{
        throw err
    }
}
