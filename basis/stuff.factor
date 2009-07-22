
: spill-integer-base ( -- n )
    stack-frame get spill-counts>> double-float-regs swap at
    double-float-regs reg-size * ;

: spill-integer@ ( n -- offset )
    cells spill-integer-base + param@ ;

: spill-float@ ( n -- offset )
    double-float-regs reg-size * param@ ;

: (stack-frame-size) ( stack-frame -- n )
    [
        {
            [ spill-counts>> [ swap reg-size * ] { } assoc>map sum ]
            [ gc-roots>> cells ]
            [ params>> ]
            [ return>> ]
        } cleave
    ] sum-outputs ;