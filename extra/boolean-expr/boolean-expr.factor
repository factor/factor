! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes kernel sequences sets
io prettyprint ;
FROM: multi-methods => GENERIC: METHOD: ;
IN: boolean-expr

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

GENERIC: (dnf) ( expr -- dnf )

METHOD: (dnf) { ⋀ } [ x>> (dnf) ] [ y>> (dnf) ] bi append ;
METHOD: (dnf) { □ } 1array ;

GENERIC: dnf ( expr -- dnf )

METHOD: dnf { ⋁ } [ x>> dnf ] [ y>> dnf ] bi append ;
METHOD: dnf { □ } (dnf) 1array ;

GENERIC: satisfiable? ( expr -- ? )

METHOD: satisfiable? { ⊤ } drop t ;
METHOD: satisfiable? { ⊥ } drop f ;

! See if there is a term along with its negation in the conjunction seq.
: (satisfiable?) ( seq -- ? )
    [ ¬? ] partition swap [ x>> ] map intersect empty? ;

METHOD: satisfiable? { □ }
    dnf [ (satisfiable?) ] any? ;

GENERIC: (expr.) ( expr -- )

METHOD: (expr.) { □ } pprint ;

: op. ( expr -- )
    "(" write
    [ x>> (expr.) ]
    [ bl class-of pprint bl ]
    [ y>> (expr.) ]
    tri
    ")" write ;

METHOD: (expr.) { ⋀ } op. ;
METHOD: (expr.) { ⋁ } op. ;
METHOD: (expr.) { ¬ } [ class-of pprint ] [ x>> (expr.) ] bi ;

: expr. ( expr -- ) (expr.) nl ;
