module LinkedFunctions

##########
# Import #
##########

import Base: broadcasted, broadcasted_kwsyntax
import StructArrays: StructArray, components
import MacroTools: isdef, splitdef, combinedef

###########
# Include #
###########

include("LinkedFunction.jl")
include("link.jl")
include("linkconvert.jl")
include("broadcast.jl")
include("OtherFunction.jl")

###########
# Export #
###########

export AbstractLinkedFunction, LinkedFunction
export fn1, fn2, is_fn1, toggle, fn1_args, fn2_args, set_fn1_args!, set_fn2_args!, set_args!
export @link, @linkconvert
export AbstractOtherFunction, OtherFunction
export other, linked_function


##########
# Errors #
##########

macro_call_error() = throw( ArgumentError("The macro call has to preceed a method definition.") )

end
