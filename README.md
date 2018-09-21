# OpenTrick

There are  `open` methods which only support the `open() do io ... end` conventions. This module provides a trick to enable  keeping `io` for later usage. This is convenient for interactive programming.

## Examples

using WebSockets as an example.

```julia
using OpenTrick
using WebSockets

io = opentrick(WebSockets.open, "ws://echo.websocket.org");
write(io, "Hello");
println(String(read(io)));

close(io)  # you can close io manually
wrapper = nothing; # or leave it to GC
unsafe_clear() # or you can clear all ios opened by opentrick manually
```



