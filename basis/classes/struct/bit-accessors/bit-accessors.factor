! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math fry locals math.order alien.accessors ;
IN: classes.struct.bit-accessors

! Bitfield accessors are little-endian on all platforms
! Why not? It's unspecified in C

: ones-between ( start end -- n )
    [ 2^ 1 - ] bi@ swap bitnot bitand ;

:: manipulate-bits ( offset bits step-quot -- quot shift-amount offset' bits' )
    offset 8 /mod :> start-bit :> i
    start-bit bits + 8 min :> end-bit
    start-bit end-bit ones-between :> mask
    end-bit start-bit - :> used-bits

    i mask start-bit step-quot call( i mask start-bit -- quot )
    used-bits
    i 1 + 8 *
    bits used-bits - ; inline

:: bit-manipulator ( offset bits
                    step-quot: ( i mask start-bit -- quot )
                    combine-quot: ( prev-quot shift-amount next-quot -- quot )
                    -- quot )
    offset bits step-quot manipulate-bits
    dup zero? [ 3drop ] [
        step-quot combine-quot bit-manipulator
        combine-quot call( prev shift next -- quot )
    ] if ; inline recursive

: bit-reader ( offset bits -- quot: ( alien -- n ) )
    [ neg '[ _ alien-unsigned-1 _ bitand _ shift ] ]
    [ swap '[ _ _ bi _ shift bitor ] ]
    bit-manipulator ;

:: write-bits ( n alien i mask start-bit -- )
    n start-bit shift mask bitand
    alien i alien-unsigned-1 mask bitnot bitand
    bitor alien i set-alien-unsigned-1 ; inline

: bit-writer ( offset bits -- quot: ( n alien -- ) )
    [ '[ _ _ _ write-bits ] ]
    [ '[ _ [ [ _ neg shift ] dip @ ] 2bi ] ]
    bit-manipulator ;
