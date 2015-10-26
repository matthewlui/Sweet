#SWEET - swift HTTP server with sugar
!! SWEET is in construct stage, please do not use it in any production envoirment
!! SWEET may face many more significant change in short future, all functionality are't stable.

SWEET is a HTTP server written in pure Swift with wrap-up of POSIX C. We target on a highly customize and extendable way to bootstrap the write of a modern typesafe server.
All pre-defined structure are mainly define as a adoption of protocols with default extension methods.
For example, if you need a re-write HTTP level structure and would like to reuse our pre-defined socket struct type, you can simply write this : 

----
class YOURHTTP:SWTHTTPServer{

    //...
    //write func you would like to override the protocol extension

}

var server = YOURHTTP<_SwiftSocket>

...
----

SWEET also try to make everything as functional as it need,

we define connection as a light weight tuple type, make response by passing through functions to satisfy the needs of pool managing but still easy to chain up.

A TODO list:


* .htaccess support
* if request handler not found, asume its a resources request. or use . to confirm by regular expr
* Consider rewrite socket module with intel DPDK http://dpdk.org in the future
* Pool session management
* Module system
* HTML module etc:
    var html = SWHTML("html")
    var container = SWHTML("div")
    container.class = "container"
    container.id = "bodyContainer"
    let button = html("button")
    button.class("button")
    button.attr += ["height = 50"] // over write property if already exist
    button.body = "Push Me"
    let heading = SWHTML("p")
    container <- button
    container <- p
    container.move(button,behine:p)
    html <- container

