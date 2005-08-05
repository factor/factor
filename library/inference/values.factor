! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic kernel lists namespaces sequences unparser words ;

TUPLE: value recursion safe? ;

C: value ( rstate -- value )
    t over set-value-safe?
    recursive-state get over set-value-recursion ;

M: value = eq? ;

TUPLE: computed ;

C: computed ( -- value ) <value> over set-delegate ;

TUPLE: literal value ;

C: literal ( obj -- value )
    <value> over set-delegate
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
    <value> over set-delegate [ set-meet-values ] keep ;

PREDICATE: tuple safe-literal ( obj -- ? )
    dup literal? [ value-safe? ] [ drop f ] ifte ;
