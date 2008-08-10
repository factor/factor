! Copyright (c) 2008 Reginald Ford
! Tools for approximating derivatives

USING: kernel math math.functions locals generalizations float-arrays sequences
math.constants namespaces math.function-tools math.points math.ranges math.order ;
IN: math.derivatives

! Ridders' method of a derivative, from the chapter
! "Accurate computation of F'(x) and F'(x)F''(x)",
! From "Advances in Engineering Software, Vol. 4, pp. 75-76
! \ fast-derivative has been factored out for use by children

: largest-float ( -- x ) HEX: 7fefffffffffffff bits>double ; foldable
: ntab 10 ;          ! max size of tableau (main accuracy setting)
: con 1.41 ;       ! stepsize is decreased by this per-iteration
: con2 1.9881 ;   ! con^2
: initial-h 0.02 ;  ! distance of the 2 points of the first secant line
: safe 2.0 ;        ! return when current err is SAFE worse than the best
                    ! \ safe probably should not be changed
SYMBOL: i
SYMBOL: j
SYMBOL: err
SYMBOL: errt
SYMBOL: fac
SYMBOL: h 
SYMBOL: ans
SYMBOL: matrix

: (derivative) ( x function -- m )
        [ [ h get + ] dip eval ]
        [ [ h get - ] dip eval ]
    2bi slope ; inline
: fast-derivative ( x function -- m )
    over epsilon sqrt * h set
    (derivative) ; inline
: init-matrix ( -- )
        ntab [ ntab <float-array> ] replicate
    matrix set ;
: m-set ( value j i -- ) matrix get nth set-nth ;
: m-get ( j i -- n ) matrix get nth nth ;
:: derivative ( x func -- m )
    init-matrix
    initial-h h set
    x func (derivative) 0 0 m-set
    largest-float err set
    ntab 1 - [1,b] [| i |
        h [ con / ] change
        x func (derivative) 0 i m-set
        con2 fac set
        i [1,b] [| j |
                    j 1 - i m-get fac get * 
                    j 1 - i 1 - m-get
                -
                fac get 1 -
            / j i m-set
            fac [ con2 * ] change
                j i m-get j 1 - i m-get - abs
                j i m-get j 1 - i 1 - m-get - abs
            max errt set
                errt get err get <=
                [
                    errt get err set
                    j i m-get ans set
                ] [ ]
            if
        ] each
            i i m-get i 1 - dup m-get - abs
            err get safe *
        <
    ] all? drop
    ans get ; inline
: derivative-func ( function -- function ) [ derivative ] curry ; inline
: fast-derivative-func ( function -- function ) [ fast-derivative ] curry ; inline

