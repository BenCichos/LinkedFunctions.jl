# LinkedFunctions

LinkedFunctions.jl is a Julia Package for linking two functions together. In the future the package might be extended to allow the linking of any arbitrary number of functions

## Linking Functions

You can link to functions by using a macro that is defined inside the package. This makes linking to functions really simple. The macro creates a struct of type LinkedFunction that holds a reference to both functions.

```julia
# first create two functions
function one end
function two end

# link function 'one' and 'two'; assign the linked function to 'linked'
const linked = @link one two

# this achieves the same thing 
@link linked one two
```

LinkedFunction is a subtype of Function. This means that an instance of LinkedFunction is callable just like a normal function in Julia.

## Linking Methods

In this section we will discover how to link the methods of the two linked functions, which unlocks the power of LinkedFunctions. To show this we first define two methods for the functions that we linked above.

```julia
# define methods for linked functions
function one(x::Float64)
    x
end

function two(x::Float64; w::Float64)
    x/w
end
```
Before we can use the linked functions we will first need to define convert methods. We will later find out the reason for these convert methods.

```julia
# define method to convert method arguments of one to method arguments of two 
@linkconvert one two function convert(x::Float64)
    (x), (w=2.0) 
end

# define method to convert method arguments of two to method arguments of one 
@linkconvert two one function convert(x::Float64; w::Float64)
    (x/w), () 
end
```
Every convert method has to return a tuple of type ```Type{Tuple{Tuple, NamedTuple}}```. The ```@linkconvert``` macro enforces that the method definition overloads the ```Base.convert``` function. The macro also works on anonymous methods, however, it is advised to only used anonymous methods when having more than two method arguments or keyword arguments. The general guidance how to use the macro is given below.
```julia
    @linkconvert $(from) $(to) function $(name || nothing)(args...; kwargs...)
        return Tuple(Tuple(), NamedTuple())
    end
```
The macro modifies the method expression to the following method definition.
```julia
    function Base.convert(::typeof($from), ::typeof($to), args...; kwargs...)::Tuple{Tuple, NamedTuple}
        return Tuple(Tuple(), NamedTuple())
    end
```
Once we have defined the convert methods we can call the LinkedFunction like we would call the method of the function one that we just defined. By default the LinkedFunction selects the first function that was given when linking the functions. The LinkedFunction will then use the defined convert methods to compute the equivalent arguments for the linked function. LinkedFunction then stores the arguments to both functions.
```julia
# call linked with arguments - automatically converts arguments
result = linked(1.0) # one(1.0) - returns 1.0

# call linked without arguments to call with previous arguments
linked() # one(1.0 ) - returns 1.0

# switch to other function
toggle(linked)

# call linked without arguments to call linked function with convert arguments
linked() # two(1.0; w=2.0) - returns 0.5

# call linked with arguments - automatically convert arguments
linked(2.0; w=1.0) # two(2.0; w=1.0) - returns 2.0

# switch to other function
toggle(linked)

# call linked without arguments to call linked function with convert arguments
linked() # one(2.0) - returns 2.0 
```

## Broadcasting

Broadcasting is defined for a LinkedFunction. The broadcasting call is passed on to the function that is currently selected by the LinkedFunction. When broadcasting over a linked function, it will first attempt to find a convert method for the arguments of the broadcasting call, otherwise, it will broadcast over the convert method. 

```julia
vector = 1.0:0.1:2.0

# broadcast over vector
linked.(vector) # one.(vector)
```
There is no convert method defined for ```typeof(vector)```, hence, the arguments will be converted by broadcasting over the convert method.
```julia
# broadcast without arguments to call function with previous arguments
linked.()

# switch to other function
toggle(linked)

# broacast without argument to call function with convert arguments
linked.() # two.()
```

It is advised to define convert methods for the arguments of the broadcasting calls. Broadcasting over convert methods slows performance, since extracting the arguments requires the construction of StructArrays.

## OtherFunction

OtherFunction is a wrapper around a LinkedFunction and always refers to the function of a LinkedFunction that is currently not selected.

```julia
other_linked = other(linked)
```

## Bugs

* **Default Value of Keyword Arguments** - The convert methods do not have access to the default values of keyword arguments, hence, they are currently not supported.