! Copyright (C) 2009 Jason W. Merrill.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.derivatives.syntax
    math.order math.parser summary accessors make combinators ;
IN: math.derivatives

ERROR: undefined-derivative point word ;
M: undefined-derivative summary
    [ dup "Derivative of " % word>> name>> %
    " is undefined at " % point>> # "." % ]
    "" make ;

DERIVATIVE: + [ 2drop ] [ 2drop ] ;
DERIVATIVE: - [ 2drop ] [ 2drop neg ] ;
DERIVATIVE: * [ nip * ] [ drop * ] ;
DERIVATIVE: / [ nip / ] [ sq / neg * ] ;
! Conditional checks if the epsilon-part of the exponent is
! 0 to avoid getting float answers for integer powers.
DERIVATIVE: ^ [ [ 1 - ^ ] keep * * ]
    [ [ dup zero? ] 2dip [ 3drop 0 ] [ [ ^ ] keep log * * ] if ] ;

DERIVATIVE: abs
    [ 0 <=>
        {
            { +lt+ [ neg ] }
            { +eq+ [ 0 \ abs undefined-derivative ] }
            { +gt+ [ ] }
        } case
    ] ;

DERIVATIVE: sqrt [ sqrt 2 * / ] ;

DERIVATIVE: e^ [ e^ * ] ;
DERIVATIVE: log [ / ] ;

DERIVATIVE: sin [ cos * ] ;
DERIVATIVE: cos [ sin neg * ] ;
DERIVATIVE: tan [ sec sq * ] ;

DERIVATIVE: sinh [ cosh * ] ;
DERIVATIVE: cosh [ sinh * ] ;
DERIVATIVE: tanh [ sech sq * ] ;

DERIVATIVE: asin [ sq neg 1 + sqrt / ] ;
DERIVATIVE: acos [ sq neg 1 + sqrt neg / ] ;
DERIVATIVE: atan [ sq 1 + / ] ;

DERIVATIVE: asinh [ sq 1 + sqrt / ] ;
DERIVATIVE: acosh [ [ 1 + sqrt ] [ 1 - sqrt ] bi * / ] ;
DERIVATIVE: atanh [ sq neg 1 + / ] ;

DERIVATIVE: neg [ drop neg ] ;
DERIVATIVE: recip [ sq recip neg * ] ;
