! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math fry locals math.order alien.accessors ;
IN: classes.struct.bit-accessors

! Bitfield accessors are little-endian on all platforms
! Why not? It's platform-dependent in C

: ones-between ( start end -- n )
    [ 2^ 1 - ] bi@ swap bitnot bitand ;

:: read-bits ( offset bits -- quot: ( byte-array -- n ) shift-amount offset' bits' )
    offset 8 /mod :> start-bit :> i
    start-bit bits + 8 min :> end-bit
    start-bit end-bit ones-between :> mask
    end-bit start-bit - :> used-bits

    ! The code generated for this isn't optimal
    ! To improve the code, algebraic simplifications should
    ! have interval information available
    [ i alien-unsigned-1 mask bitand start-bit neg shift ]
    used-bits
    i 1 + 8 *
    bits used-bits - ;

: bit-reader ( offset bits -- quot: ( alien -- n ) )
    read-bits dup zero? [ 3drop ] [
        bit-reader swap '[ _ _ bi _ shift bitor ]
    ] if ;
