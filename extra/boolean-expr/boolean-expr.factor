! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes kernel sequences sets
io prettyprint multi-methods ;
IN: boolean-expr

! Demonstrates the use of Unicode symbols in source files, and
! multi-method dispatch.

TUPLE: ⋀ x y ;
TUPLE: ⋁ x y ;
TUPLE: ¬ x ;

SINGLETONS: ⊤ ⊥ ;

SINGLETONS: P Q R S T U V W X Y Z ;

UNION: □ ⋀ ⋁ ¬ ⊤ ⊥ P Q R S T U V W X Y Z ;

GENERIC: ⋀ ( x y -- expr )

METHOD: ⋀ { ⊤ □ } nip ;
METHOD: ⋀ { □ ⊤ } drop ;
METHOD: ⋀ { ⊥ □ } drop ;
METHOD: ⋀ { □ ⊥ } nip ;

METHOD: ⋀ { ⋁ □ } [ [ x>> ] dip ⋀ ] [ [ y>> ] dip ⋀ ] 2bi ⋁ ;
METHOD: ⋀ { □ ⋁ } [ x>> ⋀ ] [ y>> ⋀ ] 2bi ⋁ ;

METHOD: ⋀ { □ □ } \ ⋀ boa ;

GENERIC: ⋁ ( x y -- expr )

METHOD: ⋁ { ⊤ □ } drop ;
METHOD: ⋁ { □ ⊤ } nip ;
METHOD: ⋁ { ⊥ □ } nip ;
METHOD: ⋁ { □ ⊥ } drop ;

METHOD: ⋁ { □ □ } \ ⋁ boa ;

GENERIC: ¬ ( x -- expr )

METHOD: ¬ { ⊤ } drop ⊥ ;
METHOD: ¬ { ⊥ } drop ⊤ ;

METHOD: ¬ { ⋀ } [ x>> ¬ ] [ y>> ¬ ] bi ⋁ ;
METHOD: ¬ { ⋁ } [ x>> ¬ ] [ y>> ¬ ] bi ⋀ ;

METHOD: ¬ { □ } \ ¬ boa ;

: → ( x y -- expr ) ¬ ⋀ ;
: ⊕ ( x y -- expr ) [ ⋁ ] [ ⋀ ¬ ] 2bi ⋀ ;
: ≣ ( x y -- expr ) [ ⋀ ] [ [ ¬ ] bi@ ⋀ ] 2bi ⋁ ;

GENERIC: (cnf) ( expr -- cnf )

METHOD: (cnf) { ⋀ } [ x>> (cnf) ] [ y>> (cnf) ] bi append ;
METHOD: (cnf) { □ } 1array ;

GENERIC: cnf ( expr -- cnf )

METHOD: cnf { ⋁ } [ x>> cnf ] [ y>> cnf ] bi append ;
METHOD: cnf { □ } (cnf) 1array ;

GENERIC: satisfiable? ( expr -- ? )

METHOD: satisfiable? { ⊤ } drop t ;
METHOD: satisfiable? { ⊥ } drop f ;

: partition ( seq quot -- left right )
    [ [ not ] compose filter ] [ filter ] 2bi ; inline

: (satisfiable?) ( seq -- ? )
    [ \ ¬ instance? ] partition [ x>> ] map intersect empty? ;

METHOD: satisfiable? { □ }
    cnf [ (satisfiable?) ] any? ;

GENERIC: (expr.) ( expr -- )

METHOD: (expr.) { □ } pprint ;

: op. ( expr -- )
    "(" write
    [ x>> (expr.) ]
    [ bl class pprint bl ]
    [ y>> (expr.) ]
    tri
    ")" write ;

METHOD: (expr.) { ⋀ } op. ;
METHOD: (expr.) { ⋁ } op. ;
METHOD: (expr.) { ¬ } [ class pprint ] [ x>> (expr.) ] bi ;

: expr. ( expr -- ) (expr.) nl ;
