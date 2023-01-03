using LinkedFunctions
using Test

function test_rect end
function test_sinc end

test_rect(x::Float64; width::Float64=1.0) = abs(x) < width/2 ? 1 : 0
test_sinc(x::Float64; width::Float64=1.0) =sinc(x / width)

linked_rect = @link test_rect test_sinc

@linkconvert test_rect test_sinc convert(x::Float64; width::Float64) = (x,), (width = 1 / width,)
@test hasmethod(convert, (typeof(test_rect), typeof(test_sinc), Float64), (:width, ))

@linkconvert test_sinc test_rect convert(x::Float64; width::Float64) =(x,), (width = 1 / width,)
@test hasmethod(convert, (typeof(test_sinc), typeof(test_rect), Float64), (:width, ))

@test linked_rect(2.0; width=1.0) == 0
@test linked_rect() == 0 
@test linked_rect(1.0; width=3.0) == 1
@test linked_rect() == 1
@test toggle(linked_rect) == false
@test linked_rect() != 1
@test linked_rect(0.0; width=1.0) == 1.0
@test linked_rect() == 1.0
@test linked_rect(0.5; width=1.0) == sinc(0.5)
@test linked_rect() == sinc(0.5)

