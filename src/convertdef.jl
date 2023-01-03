####################
# Convertdef Macro #
####################

macro convertdef(expr::Expr)
    esc(convertdef(__module__, expr))
end

# function that replaces the name of a method with Base.convert and sets the return type to be Tuple{Tuple, Tuple}

function convertdef(__module__, expr::Expr)
    fn_ex = macroexpand(__module__, expr)
    base_convert = GlobalRef(Base, :convert)

    isdef(fn_ex) || macro_call_error()

    fn_dict = splitdef(fn_ex)
    fn_dict[:name] = :($base_convert)
    fn_dict[:rtype] = :(Tuple{Tuple, NamedTuple})
    
    combinedef(fn_dict)
end
