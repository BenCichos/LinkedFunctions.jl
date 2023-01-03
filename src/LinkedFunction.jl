##################
# LinkedFunction #
##################

abstract type AbstractLinkedFunction <: Function end

mutable struct LinkedFunction <: AbstractLinkedFunction
    fn1::Function
    fn2::Function
    is_fn1::Bool 
    fn1_args::Tuple{Tuple, Base.Pairs}
    fn2_args::Tuple{Tuple, Base.Pairs}
end

function (l::LinkedFunction)(args...; other::Bool=false, kwargs...)
    fn = xor(is_fn1(l), other) ? fn1(l) : fn2(l)
    fn_results = fn(args...; kwargs...)
    set_args!(l, args...; other=other, kwargs...)
    fn_results
end

function (l::LinkedFunction)(; other::Bool=false)
    fn, (fn_args, fn_kwargs) = xor(is_fn1(l), other) ? (fn1(l), fn1_args(l)) : (fn2(l), fn2_args(l))
    fn(fn_args...; fn_kwargs...)
end

fn1(l::LinkedFunction) = l.fn1
fn2(l::LinkedFunction) = l.fn2
is_fn1(l::LinkedFunction) = l.is_fn1
toggle(l::LinkedFunction) = (l.is_fn1 = !l.is_fn1)
fn1_args(l::LinkedFunction) = l.fn1_args
fn2_args(l::LinkedFunction) = l.fn2_args
set_fn1_args!(l::LinkedFunction, args...; kwargs...) = (l.fn1_args =  (args, kwargs))
set_fn2_args!(l::LinkedFunction, args...; kwargs...) = (l.fn2_args = (args, kwargs))

function set_args!(l::LinkedFunction, args...; other::Bool=false, broadcast::Bool=false, kwargs...)
    fn_1, fn_2, set_fn1!, set_fn2! =  xor(is_fn1(l), other) ? (fn1(l), fn2(l), set_fn1_args!, set_fn2_args!) : (fn2(l), fn1(l), set_fn2_args!, set_fn1_args!) 
    set_fn1!(l, args...; kwargs...)
    fn2_args, fn2_kwargs = broadcast ? broadcast_convert(fn_1, fn_2, args...; kwargs...) : convert(fn_1, fn_2, args...; kwargs...)
    set_fn2!(l, fn2_args...; fn2_kwargs...)
end

# broadcasting over convert method
#
# Assumptions: 
#   convert method returns the same number of args and kwargs when broadcasted
#   convert method returns the same kwargs when broadcasted

function broadcast_convert(fn1::Function, fn2::Function, args...; kwargs...)
    result = convert.(fn1, fn2, args...; kwargs...)

    # get first result
    first_result = first(result)
    
    # unpack fn args if fn args is not vector of empty tuples
    fn_args = first(first_result) isa Tuple{} ? () : components(StructArray(map(first, result)))

    # get converted fn kwargs
    fn_kwargs = last(first_result)

    fn_args, fn_kwargs
end