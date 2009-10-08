! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math fry locals math.order alien.accessors ;
IN: classes.struct.bit-accessors

! Bitfield accessors are little-endian on all platforms
! Why not? It's platform-dependent in C

: ones-between ( start end -- n )
    [ 2^ 1 - ] bi@ swap bitnot bitand ;

:: manipulate-bits ( offset bits step-quot -- quot shift-amount offset' bits' )
    offset 8 /mod :> start-bit :> i
    start-bit bits + 8 min :> end-bit
    start-bit end-bit ones-between :> mask
    end-bit start-bit - :> used-bits

    start-bit i end-bit mask step-quot call( a b c d -- quot )
    used-bits
    i 1 + 8 *
    bits used-bits - ; inline

:: bit-manipulator ( offset bits
                    step-quot: ( start-bit i end-bit mask -- quot )
                    combine-quot: ( prev-quot shift-amount next-quot -- quot )
                    -- quot )
    offset bits step-quot manipulate-bits
    dup zero? [ 3drop ] [
        step-quot combine-quot bit-manipulator
        combine-quot call( prev shift next -- quot )
    ] if ; inline recursive

: bit-reader ( offset bits -- quot: ( alien -- n ) )
    [| start-bit i end-bit mask |
        [ i alien-unsigned-1 mask bitand start-bit neg shift ]
    ]
    [ swap '[ _ _ bi _ shift bitor ] ]
    bit-manipulator ;

: bit-writer ( offset bits -- quot: ( n alien -- ) )
    [| start-bit i end-bit mask |
        [
            [
                [ start-bit shift mask bitand ]
                [ i alien-unsigned-1 mask bitnot bitand ]
                bi* bitor
            ] keep i set-alien-unsigned-1
        ]
    ]
    [ '[ _ [ [ _ neg shift ] dip @ ] 2bi ] ]
    bit-manipulator ;
