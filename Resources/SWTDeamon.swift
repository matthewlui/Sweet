//
//  SWTDeamon.swift
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

//MARK: Finish it!!

let bin = "/bin"

#if os(OSX)
import Foundation
#endif

#if os(OSX)
let SWEETCoreTask:NSTask = {
    let task = NSTask()
    let pipe = NSPipe()
    task.standardOutput = pipe
    return task
}()
#endif

func echo(str:String...){
    #if os(OSX)
    SWEETCoreTask.launchPath = bin + "/echo"
    SWEETCoreTask.arguments = str
    SWEETCoreTask.launch()
    #endif
}


