! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions assocs kernel kernel.private
slots.private namespaces sequences strings words vectors math
quotations combinators sorting effects graphs vocabs ;
IN: classes

SYMBOL: class<=-cache
SYMBOL: class-not-cache
SYMBOL: classes-intersect-cache
SYMBOL: class-and-cache
SYMBOL: class-or-cache

: init-caches ( -- )
    H{ } clone class<=-cache set
    H{ } clone class-not-cache set
    H{ } clone classes-intersect-cache set
    H{ } clone class-and-cache set
    H{ } clone class-or-cache set ;

: reset-caches ( -- )
    class<=-cache get clear-assoc
    class-not-cache get clear-assoc
    classes-intersect-cache get clear-assoc
    class-and-cache get clear-assoc
    class-or-cache get clear-assoc ;

SYMBOL: update-map

PREDICATE: class < word
    "class" word-prop ;

PREDICATE: tuple-class < class
    "metaclass" word-prop tuple-class eq? ;

: classes ( -- seq ) all-words [ class? ] filter ;

: predicate-word ( word -- predicate )
    [ word-name "?" append ] keep word-vocabulary create ;

: predicate-effect T{ effect f 1 { "?" } } ;

PREDICATE: predicate < word "predicating" word-prop >boolean ;

: define-predicate ( class quot -- )
    >r "predicate" word-prop first
    r> predicate-effect define-declared ;

: superclass ( class -- super )
    #! Output f for non-classes to work with algebra code
    dup class? [ "superclass" word-prop ] [ drop f ] if ;

: superclasses ( class -- supers )
    [ superclass ] follow reverse ;

: members ( class -- seq )
    #! Output f for non-classes to work with algebra code
    dup class? [ "members" word-prop ] [ drop f ] if ;

: participants ( class -- seq )
    #! Output f for non-classes to work with algebra code
    dup class? [ "participants" word-prop ] [ drop f ] if ;

GENERIC: rank-class ( class -- n )

GENERIC: reset-class ( class -- )

M: word reset-class drop ;

<PRIVATE

! update-map
: class-uses ( class -- seq )
    [
        [ members % ]
        [ participants % ]
        [ superclass [ , ] when* ]
        tri
    ] { } make ;

: class-usages ( class -- assoc )
    [ update-map get at ] closure ;

: update-map+ ( class -- )
    dup class-uses update-map get add-vertex ;

: update-map- ( class -- )
    dup class-uses update-map get remove-vertex ;

: make-class-props ( superclass members participants metaclass -- assoc )
    [
        {
            [ dup [ bootstrap-word ] when "superclass" set ]
            [ [ bootstrap-word ] map "members" set ]
            [ [ bootstrap-word ] map "participants" set ]
            [ "metaclass" set ]
        } spread
    ] H{ } make-assoc ;

: (define-class) ( word props -- )
    >r
    dup reset-class
    dup deferred? [ dup define-symbol ] when
    dup word-props
    r> assoc-union over set-word-props
    dup predicate-word
    [ 1quotation "predicate" set-word-prop ]
    [ swap "predicating" set-word-prop ]
    [ drop t "class" set-word-prop ]
    2tri ;

PRIVATE>

GENERIC: update-class ( class -- )

M: class update-class drop ;

GENERIC: update-methods ( assoc -- )

: update-classes ( class -- )
    class-usages
    [ [ drop update-class ] assoc-each ]
    [ update-methods ]
    bi ;

: define-class ( word superclass members participants metaclass -- )
    #! If it was already a class, update methods after.
    reset-caches
    make-class-props
    [ drop update-map- ]
    [ (define-class) ]
    [ drop update-map+ ]
    2tri ;

GENERIC: class ( object -- class )

: instance? ( obj class -- ? )
    "predicate" word-prop call ;
