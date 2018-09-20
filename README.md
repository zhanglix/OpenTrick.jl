# OpenTrick

There are  `open` methods which only support the `open() do io ... end` conventions. This module provides a trick to enable  keeping `io` for later usage. This is convenient for interactive programming.

## Examples

using WebSockets as an example.

```julia
using OpenTrick
using WebSockets

wrapper = opentrick(WebSockets.open, "ws://echo.websocket.org");
write(wrapper.value, "Hello");
@test "Hello" == String(read(wrapper.value));

wrapper = nothing; # resource  will be cleaned automatically with GC

unsafe_clear() # or you can clear all wrappers manually

```



