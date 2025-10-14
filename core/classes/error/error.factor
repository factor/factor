! Copyright (C) 2015 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: classes classes.private classes.tuple
classes.tuple.private combinators kernel words ;
IN: classes.error

PREDICATE: error-class < tuple-class
    "error-class" word-prop ;

M: error-class reset-class
    [ call-next-method ] [ "error-class" remove-word-prop ] bi ;

: define-error-class ( class superclass slots -- )
    error-slots {
        [ define-tuple-class ]
        [ 2drop reset-generic ]
        [ 2drop t "error-class" set-word-prop ]
        [
            2drop
            [ ]
            [ [ boa throw ] curry ]
            [ all-slots thrower-effect ]
            tri define-declared
        ]
    } 3cleave ;

PREDICATE: error-tuple < tuple class-of error-class? ;
