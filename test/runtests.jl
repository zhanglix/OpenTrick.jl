using Logging
#global_logger(ConsoleLogger(stderr,Logging.Debug))

include("normal_cases.jl")
include("exception_cases.jl")