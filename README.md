# OpenTrick

- [Examples](#examples)
- [Supported Interfaces in Base](#supported-interfaces-in-base)
- [OpenTrick.jl Documentation](#opentrickjl-documentation)

There are some `open` methods which only support the `open() do io ... end` conventions. This module provides a trick to enable keeping `io` for later usage. This is convenient for interactive programming.

## Examples

using WebSockets as an example.

```julia
using OpenTrick
using WebSockets

io = opentrick(WebSockets.open, "ws//echo.websocket.org");
write(io, "Hello");
println(String(read(io)));

close(io)  # you can close io manually
io = nothing; # or leave it to GC
unsafe_clear() # or you can clear all ios opened by opentrick manually
```

## Supported Interfaces in Base

- read, read!, readbytes!, unsafe_read, readavailable,    readline, readlines, eachline, readchomp, readuntil, bytesavailable
- write, unsafe_write, truncate, flush,    print, println, printstyled, showerror
- seek, seekstart, seekend, skip, skipchars, position
- mark, unmark, reset, ismarked
- isreadonly, iswritable, isreadable, isopen, eof
- countlines, displaysize

## OpenTrick.jl Documentation

- opentrick
- rawio
- blockingtask
- unsafe_clear
