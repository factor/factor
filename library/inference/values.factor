! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic kernel namespaces sequences unparser words ;

GENERIC: value= ( literal value -- ? )
GENERIC: value-class-and ( class value -- )
GENERIC: safe-literal? ( value -- ? )

TUPLE: value class recursion class-ties literal-ties safe? ;

C: value ( recursion -- value )
    [ t swap set-value-safe? ] keep
    [ set-value-recursion ] keep ;

TUPLE: computed ;

C: computed ( class -- value )
    swap recursive-state get <value> [ set-value-class ] keep
    over set-delegate ;

M: computed value= ( literal value -- ? )
    2drop f ;

: failing-class-and ( class class -- class )
    2dup class-and dup null = [
        -rot [
            word-name , " and " , word-name ,
            " do not intersect" ,
        ] make-string inference-warning
    ] [
        2nip
    ] ifte ;

M: computed value-class-and ( class value -- )
    [
        value-class  failing-class-and
    ] keep set-value-class ;

TUPLE: literal value ;

C: literal ( obj rstate -- value )
    [
        >r <value> [ >r dup class r> set-value-class ] keep
        r> set-delegate
    ] keep
    [ set-literal-value ] keep ;

M: literal value= ( literal value -- ? )
    literal-value = ;

M: literal value-class-and ( class value -- )
    value-class class-and drop ;

M: literal set-value-class ( class value -- )
    2drop ;

M: literal safe-literal? ( value -- ? ) value-safe? ;

M: computed safe-literal? drop f ;

M: computed literal-value ( value -- )
    "A literal value was expected where a computed value was"
    " found: " rot unparse append3 inference-error ;

: value-types ( value -- list )
    value-class builtin-supertypes ;

: >literal< ( literal -- rstate obj )
    dup value-recursion swap literal-value ;
