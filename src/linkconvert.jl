####################
# Linkconvert Macro #
####################

macro linkconvert(from::Symbol, to::Symbol, expr::Expr)
    esc(linkconvert(__module__, from, to, expr))
end

# function that replaces the name of a method with Base.convert and sets the return type to be Tuple{Tuple, Tuple}

function linkconvert(__module__, from::Symbol, to::Symbol, expr::Expr)
    fn_ex = macroexpand(__module__, expr)
    base_convert = GlobalRef(Base, :convert)
    
    isfunction(__module__, from) || not_function_error(name)
    isfunction(__module__, to) || not_function_error(name)
    isdef(fn_ex) || macro_call_error()
    
    ref_from = GlobalRef(__module__, from)
    ref_to = GlobalRef(__module__, to)
    
    fn_dict = splitdef(fn_ex)
    fn_dict[:name] = :($base_convert)
    pushfirst!(fn_dict[:args], :(::typeof($ref_from)), :(::typeof($ref_to)))
    fn_dict[:rtype] = :(Tuple{Tuple, NamedTuple})
    
    combinedef(fn_dict)
end

function isfunction(__module__::Module, s::Symbol)
    getfield(__module__, s) isa Function
end

not_function_error(name) = throw(ArgumentError("$(name) is not of type Function"))

