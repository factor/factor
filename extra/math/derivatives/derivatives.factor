! Copyright (C) 2009 Jason W. Merrill.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.derivatives.syntax ;
IN: math.derivatives

DERIVATIVE: + [ 2drop ] [ 2drop ]
DERIVATIVE: - [ 2drop ] [ 2drop neg ]
DERIVATIVE: * [ nip * ] [ drop * ]
DERIVATIVE: / [ nip / ] [ sq / neg * ]
! Conditional checks if the epsilon-part of the exponent is 
! 0 to avoid getting float answers for integer powers.
DERIVATIVE: ^ [ [ 1 - ^ ] keep * * ] 
    [ [ dup zero? ] 2dip [ 3drop 0 ] [ [ ^ ] keep log * * ] if ]

DERIVATIVE: sqrt [ sqrt 2 * / ]

DERIVATIVE: exp [ exp * ]
DERIVATIVE: log [ / ]

DERIVATIVE: sin [ cos * ]
DERIVATIVE: cos [ sin neg * ]
DERIVATIVE: tan [ sec sq * ]

DERIVATIVE: sinh [ cosh * ]
DERIVATIVE: cosh [ sinh * ]
DERIVATIVE: tanh [ sech sq * ]

DERIVATIVE: asin [ sq neg 1 + sqrt / ]
DERIVATIVE: acos [ sq neg 1 + sqrt neg / ]
DERIVATIVE: atan [ sq 1 + / ]

DERIVATIVE: asinh [ sq 1 + sqrt / ]
DERIVATIVE: acosh [ [ 1 + sqrt ] [ 1 - sqrt ] bi * / ]
DERIVATIVE: atanh [ sq neg 1 + / ]