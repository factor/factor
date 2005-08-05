! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic kernel lists namespaces sequences unparser words ;

TUPLE: value recursion safe? ;

C: value ( recursion -- value )
    [ t swap set-value-safe? ] keep
    [ set-value-recursion ] keep ;

M: value = eq? ;

TUPLE: computed ;

C: computed ( -- value )
    recursive-state get <value> over set-delegate ;

TUPLE: literal value ;

C: literal ( obj rstate -- value )
    [ >r <value> r> set-delegate ] keep
    [ set-literal-value ] keep ;

M: value literal-value ( value -- )
    {
        "A literal value was expected where a computed value was found.\n"
        "This means that an attempt was made to compile a word that\n"
        "applies 'call' or 'execute' to a value that is not known\n"
        "at compile time. The value might become known if the word\n"
        "is marked 'inline'. See the handbook for details."
    } concat inference-error ;

TUPLE: meet values ;

C: meet ( values -- value )
    [ set-meet-values ] keep f <value> over set-delegate ;

PREDICATE: tuple safe-literal ( obj -- ? )
    dup literal? [ value-safe? ] [ drop f ] ifte ;
