//  SWTConnection
//
//  Copyright (c) <2015> <Matthew Lui>
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software
//  is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
//  THE SOFTWARE.
//

// Connection is define as (SWTRouting,SWTRouting.ClientID)

func client<R:SWTRouting>(connection:(R,R.ClientID)) -> CInt?{
    return connection.0.decode(connection.1)
}

func header<R:SWTRouting>(connection:(R,R.ClientID)) -> R.Header?{
    return connection.0[connection.1]
}

func write<R:SWTRouting>(connection:(R,R.ClientID),str:String,completion:SuccessfulCompletion = nil){
    guard let client = client(connection) else{
        completion?(false)
        return
    }
    if str == ""{
        completion?(false)
        return
    }
    do {
        try R.S.writeString(to: client, string: str)
        completion?(true)
    }catch _{
        completion?(false)
    }
}

func end<R:SWTRouting>(connetion:(R,R.ClientID),completion:SuccessfulCompletion = nil){
    connetion.0.end(connetion.1)
}


//////////////Test Line//////

func router()(handler:(socket:CInt)->Any){
    var set = Set<CInt>()
}

func valid(client:CInt) -> Bool{
    if client == 0 {
        return false
    }
    return true
}

func route(client:CInt){
    
}



