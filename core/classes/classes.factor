! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators definitions graphs kernel
make namespaces quotations sequences sets words words.symbol ;
IN: classes

ERROR: bad-inheritance class superclass ;

PREDICATE: class < word "class" word-prop ;

PREDICATE: defining-class < word "defining-class" word-prop ;

MIXIN: classoid
INSTANCE: class classoid
INSTANCE: defining-class classoid

<PRIVATE

SYMBOL: class<=-cache
SYMBOL: class-not-cache
SYMBOL: classes-intersect-cache
SYMBOL: class-and-cache
SYMBOL: class-or-cache
SYMBOL: next-method-quot-cache

: init-caches ( -- )
    H{ } clone class<=-cache namespaces:set
    H{ } clone class-not-cache namespaces:set
    H{ } clone classes-intersect-cache namespaces:set
    H{ } clone class-and-cache namespaces:set
    H{ } clone class-or-cache namespaces:set
    H{ } clone next-method-quot-cache namespaces:set ;

: reset-caches ( -- )
    class<=-cache get clear-assoc
    class-not-cache get clear-assoc
    classes-intersect-cache get clear-assoc
    class-and-cache get clear-assoc
    class-or-cache get clear-assoc
    next-method-quot-cache get clear-assoc ;

SYMBOL: update-map

SYMBOL: implementors-map

GENERIC: class-name ( class -- string )

M: class class-name name>> ;

GENERIC: rank-class ( class -- n )

GENERIC: reset-class ( class -- )

M: class reset-class
    {
        "defining-class"
        "class"
        "metaclass"
        "superclass"
        "members"
        "participants"
        "predicate"
    } remove-word-props ;

M: word reset-class drop ;

PRIVATE>

: classes ( -- seq ) implementors-map get keys ;

PREDICATE: predicate < word "predicating" word-prop >boolean ;

: create-predicate-word ( word -- predicate )
    [ name>> "?" append ] [ vocabulary>> ] bi create-word
    dup predicate? [ dup reset-generic ] unless ;

GENERIC: class-of ( object -- class )

GENERIC: instance? ( object class -- ? ) flushable

GENERIC: predicate-def ( obj -- quot )

M: word predicate-def
    "predicate" word-prop ;

M: object predicate-def
    [ instance? ] curry ;

: predicate-word ( word -- predicate )
    predicate-def first ;

M: predicate flushable? drop t ;

M: predicate forget*
    [ call-next-method ] [ "predicating" remove-word-prop ] bi ;

M: predicate reset-word
    [ call-next-method ] [ "predicating" remove-word-prop ] bi ;

: define-predicate ( class quot -- )
    [ predicate-word ] dip ( object -- ? ) define-declared ;

: superclass-of ( class -- super )
    ! Output f for non-classes to work with algebra code
    dup class? [ "superclass" word-prop ] [ drop f ] if ;

: superclasses-of ( class -- supers )
    [ superclass-of ] follow reverse! ;

: superclass-of? ( class superclass -- ? )
    superclasses-of member-eq? ;

: subclass-of? ( class superclass -- ? )
    swap superclass-of? ;

: class-members ( class -- seq )
    ! Output f for non-classes to work with algebra code
    dup class? [ "members" word-prop ] [ drop f ] if ;

: class-participants ( class -- seq )
    ! Output f for non-classes to work with algebra code
    dup class? [ "participants" word-prop ] [ drop f ] if ;

GENERIC: contained-classes ( obj -- members )

M: object contained-classes
    "members" word-prop ;

: all-contained-classes ( members -- members' )
    dup dup [ contained-classes ] map concat sift append
    2dup set= [ drop members ] [ nip all-contained-classes ] if ;

GENERIC: implementors ( class/classes -- seq )

! update-map
: class-uses ( class -- seq )
    [
        [ class-members % ]
        [ class-participants % ]
        [ superclass-of [ , ] when* ]
        tri
    ] { } make ;

: class-usage ( class -- seq )
    update-map get at members ;

: class-usages ( class -- seq )
    [ class-usage ] closure members ;

M: class implementors implementors-map get at members ;

M: sequence implementors [ implementors ] gather ;

<PRIVATE

: update-map+ ( class -- )
    dup class-uses update-map get add-vertex ;

: update-map- ( class -- )
    dup class-uses update-map get remove-vertex ;

: implementors-map+ ( class -- )
    [ HS{ } clone ] dip implementors-map get set-at ;

: implementors-map- ( class -- )
    implementors-map get delete-at ;

: make-class-props ( superclass members participants metaclass -- assoc )
    [
        {
            [ dup [ bootstrap-word ] when "superclass" ,, ]
            [ [ bootstrap-word ] map "members" ,, ]
            [ [ bootstrap-word ] map "participants" ,, ]
            [ "metaclass" ,, ]
        } spread
    ] H{ } make ;

GENERIC: metaclass-changed ( use class -- )

: ?metaclass-changed ( class usages/f -- )
    [ [ metaclass-changed ] with each ] [ drop ] if* ;

: check-metaclass ( class metaclass -- usages/f )
    over class? [
        over "metaclass" word-prop eq?
        [ drop f ] [ class-usage ] if
    ] [ 2drop f ] if ;

: ?define-symbol ( word -- )
    dup deferred? [ define-symbol ] [ drop ] if ;

: (define-class) ( word props -- )
    reset-caches
    2dup "metaclass" of check-metaclass
    {
        [ 2drop update-map- ]
        [ 2drop dup class? [ reset-class ] [ implementors-map+ ] if ]
        [ 2drop ?define-symbol ]
        [ drop [ assoc-union ] curry change-props drop ]
        [
            2drop
            dup create-predicate-word
            [ 1quotation "predicate" set-word-prop ]
            [ swap "predicating" set-word-prop ]
            2bi
        ]
        [ 2drop t "class" set-word-prop ]
        [ 2drop f "defining-class" set-word-prop ]
        [ 2drop update-map+ ]
        [ nip ?metaclass-changed ]
    } 3cleave ;

GENERIC: update-class ( class -- )

M: class update-class drop ;

GENERIC: update-methods ( class seq -- )

: update-classes ( class -- )
    dup class-usages
    [ nip [ update-class ] each ] [ update-methods ] 2bi ;

: check-inheritance ( subclass superclass -- subclass superclass )
    2dup superclass-of? [ bad-inheritance ] when ;

: define-class ( word superclass members participants metaclass -- )
    [ check-inheritance ] 3dip
    make-class-props [ (define-class) ] [ drop changed-definition ] 2bi ;

: forget-predicate ( class -- )
    dup predicate-def
    dup length 1 = [
        first
        [ nip ] [ "predicating" word-prop = ] 2bi
        [ forget ] [ drop ] if
    ] [ 2drop ] if ;

GENERIC: forget-methods ( class -- )

PRIVATE>

: forget-class ( class -- )
    dup f check-metaclass {
        [ drop forget-predicate ]
        [ drop forget-methods ]
        [ drop implementors-map- ]
        [ drop update-map- ]
        [ drop reset-class ]
        [ 2drop reset-caches ]
        [ ?metaclass-changed ]
    } 2cleave ;

M: class metaclass-changed
    swap class? [ drop ] [ forget-class ] if ;

M: class forget*
    [ call-next-method ] [ forget-class ] bi ;

ERROR: not-an-instance obj class ;

: check-instance ( obj class -- obj )
    [ dupd instance? ] keep [ not-an-instance ] curry unless ; inline
