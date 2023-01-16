#################
# OtherFunction #
#################

abstract type AbstractOtherFunction end

# Other Function always refers to the other function of a LinkedFunction 

struct OtherFunction <: AbstractOtherFunction
    linked_function::LinkedFunction
end

other(l::LinkedFunction) = OtherFunction(l)
other(o::OtherFunction) = o.linked_function
linked_function(o::OtherFunction) = o.linked_function
(o::OtherFunction)() = linked_function(o)(; other=true)
(o::OtherFunction)(args...; kwargs...) = linked_function(o)(args...; other=true, kwargs...)

################
# Broadcasting #
################

# define broadcasting beahviour for OtherFunction

broadcasted(o::OtherFunction) = linked_function(o).(; other=true)

broadcasted(o::OtherFunction, args...) = linked_function(o).(args...; other=true)

broadcasted_kwsyntax(o::OtherFunction, args...; kwargs...) = linked_function(o).(args...; other=true, kwargs...)

