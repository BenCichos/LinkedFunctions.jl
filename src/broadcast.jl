################
# Broadcasting #
################

# broadcasting behaviour for linked function

function broadcasted(l::LinkedFunction)
    fn, (fn_args, fn_kwargs) = is_fn1(l) ? (fn1(l), fn1_args(l)) : (fn2(l), fn2_args(l))
    fn.(fn_args...; fn_kwargs...)
end

function broadcasted(l::LinkedFunction, args...)
    fn = is_fn1(l) ? fn1(l) : fn2(l)
    fn_result = fn.(args...)
    set_args!.(l, args...)
    fn_result
end

function broadcasted_kwsyntax(l::LinkedFunction; other::Bool=false)
    fn, (fn_args, fn_kwargs) = xor(is_fn1(l), other) ? (fn1(l), fn1_args(l)) : (fn2(l), fn2_args(l))
    fn.(fn_args...; fn_kwargs...)
end

function broadcasted_kwsyntax(l::LinkedFunction, args...; other::Bool=false, kwargs...)
    fn = xor(is_fn1(l), other) ? fn1(l) : fn2(l)
    fn_result = fn.(args...; kwargs...)
    other ? set_args!.(l, args...; other=other, kwargs...) : set_args!.(l, args...; kwargs...)
    fn_result
end

# broadcasting behaviour for set_args!
#
# broadcasts over convert method if there does not exist a convert method for the given args and kwargs 

function broadcasted(::typeof(set_args!), l::LinkedFunction, args...)
    hasmethod(convert, types_n_symbols(fn1(l), fn2(l), args...)...) ? set_args!(l, args...) : set_args!(l, args...; broadcast=true)
end

function Base.broadcasted_kwsyntax(::typeof(set_args!), l::LinkedFunction, args...; other::Bool=false, kwargs...)
    args_types, kwargs_symbols = types_n_symbols(fn1(l), fn2(l), args...; kwargs...)
    hasmethod(convert, args_types, kwargs_symbols) ? set_args!(l, args...; other=other, kwargs...) : set_args!(l, args...; other=other, broadcast=true, kwargs...)
end

# types of args and symbols of kwargs

function types_n_symbols(args...; kwargs...)
    map(typeof, args), keys(kwargs)
end