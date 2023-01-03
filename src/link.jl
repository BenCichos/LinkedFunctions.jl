##############
# Link Macro #
##############

# macro creates a constant with the given name that holds a reference to a linked function 
macro link(name::Symbol, fn1::Symbol, fn2::Symbol)
    esc(link(__module__, name, fn1, fn2))
end

link(__module__, name::Symbol, fn1::Symbol, fn2::Symbol) =  :( const $name = $( _link(__module__, fn1, fn2) ) )

# macro returns a reference to a linked function 

macro link(fn1::Symbol, fn2::Symbol)   
    esc(link(__module__, fn1, fn2))
end

link(__module__, fn1::Symbol, fn2::Symbol) = _link(__module__, fn1, fn2)

# function creates an instance of a linked function and a macro for each function in the linked function

function _link(__module__, fn1::Symbol, fn2::Symbol)
    # create global reference of the both functions
    global_ref_fn1 = GlobalRef(__module__, fn1)
    global_ref_fn2 = GlobalRef(__module__, fn2)

    # tuple for args and kwargs of function
    empty_args = ((), EmptyKwargs())

    # expression to create linked function
    linked_fn = :(LinkedFunction($global_ref_fn1, $global_ref_fn2, true, $empty_args, $empty_args))
    
    # create a macro for each function
    fn1_macro = linked_function_macro(global_ref_fn1)
    fn2_macro = linked_function_macro(global_ref_fn2)
    
    Expr(:block, fn1_macro, fn2_macro, linked_fn)
end

# function that returns an expression for creating a macro

function linked_function_macro(global_ref_fn::GlobalRef; ref_fn::Ref=Ref(global_ref_fn))
    :(
        macro $(global_ref_fn.name)(expr::Expr)
            esc(LinkedFunctions.add_function_type(__module__, expr, $(ref_fn)[]))
        end
    )
end

# function that adds the type of the function to the beginning of an argument list in a method definition

function add_function_type(__module__, expr::Expr, global_ref_fn::GlobalRef)
    # expand any macros - to allow for macro chaining
    fn_ex = macroexpand(__module__, expr)
    # expression for the type of the function referred to by the global refernce
    fn_type = :(::typeof($global_ref_fn))

    # check that the expression is a method definition
    isdef(fn_ex) || macro_call_error()

    # add to the beginning of the argument list 
    fn_dict = splitdef(fn_ex)
    pushfirst!(fn_dict[:args], fn_type)

    combinedef(fn_dict)
end


# convenience initializer for empty kwargs

EmptyKwargs() = Base.Pairs{Symbol, Union{}, Tuple{}, NamedTuple{(), Tuple{}}}(NamedTuple(), Tuple{}()) 
    