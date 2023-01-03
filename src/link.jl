##############
# Link Macro #
##############

# macro creates a constant with the given name that holds a reference to a linked function 
macro link(name::Symbol, fn1::Symbol, fn2::Symbol)
    esc(link(__module__, name, fn1, fn2))
end

link(__module__, name::Symbol, fn1::Symbol, fn2::Symbol) =  :(const $name = $( _link(__module__, fn1, fn2) ) )

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

    # return expression to create linked function
    :(LinkedFunction($global_ref_fn1, $global_ref_fn2, true, $empty_args, $empty_args))
end


# convenience initializer for empty kwargs

EmptyKwargs() = Base.Pairs{Symbol, Union{}, Tuple{}, NamedTuple{(), Tuple{}}}(NamedTuple(), Tuple{}()) 
    