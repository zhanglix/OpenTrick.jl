using Logging
#global_logger(ConsoleLogger(stderr,Logging.Debug))
#disable_logging(Logging.LogLevel(-10000))

include("normal_cases.jl")
include("exception_cases.jl")