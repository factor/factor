! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic kernel lists namespaces sequences unparser words ;

GENERIC: value= ( literal value -- ? )

TUPLE: value recursion safe? ;

C: value ( recursion -- value )
    [ t swap set-value-safe? ] keep
    [ set-value-recursion ] keep ;

TUPLE: computed ;

C: computed ( -- value )
    recursive-state get <value> over set-delegate ;

M: computed value= ( literal value -- ? )
    2drop f ;

TUPLE: literal value ;

C: literal ( obj rstate -- value )
    [ >r <value> r> set-delegate ] keep
    [ set-literal-value ] keep ;

M: literal value= ( literal value -- ? )
    literal-value = ;

: >literal< ( literal -- rstate obj )
    dup value-recursion swap literal-value ;

M: value literal-value ( value -- )
    "A literal value was expected where a computed value was found"
    inference-error ;

TUPLE: meet values ;

C: meet ( values -- value )
    [ set-meet-values ] keep f <value> over set-delegate ;

PREDICATE: tuple safe-literal ( obj -- ? )
    dup literal? [ value-safe? ] [ drop f ] ifte ;
