! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays definitions assocs kernel kernel.private
slots.private namespaces make sequences strings words words.symbol
vectors math quotations combinators sorting effects graphs
vocabs sets ;
FROM: namespaces => set ;
IN: classes

ERROR: bad-inheritance class superclass ;

PREDICATE: class < word "class" word-prop ;

<PRIVATE

SYMBOL: class<=-cache
SYMBOL: class-not-cache
SYMBOL: classes-intersect-cache
SYMBOL: class-and-cache
SYMBOL: class-or-cache
SYMBOL: next-method-quot-cache

: init-caches ( -- )
    H{ } clone class<=-cache set
    H{ } clone class-not-cache set
    H{ } clone classes-intersect-cache set
    H{ } clone class-and-cache set
    H{ } clone class-or-cache set
    H{ } clone next-method-quot-cache set ;

: reset-caches ( -- )
    class<=-cache get clear-assoc
    class-not-cache get clear-assoc
    classes-intersect-cache get clear-assoc
    class-and-cache get clear-assoc
    class-or-cache get clear-assoc
    next-method-quot-cache get clear-assoc ;

SYMBOL: update-map

SYMBOL: implementors-map

GENERIC: rank-class ( class -- n )

GENERIC: reset-class ( class -- )

M: class reset-class
    {
        "class"
        "metaclass"
        "superclass"
        "members"
        "participants"
        "predicate"
    } reset-props ;

M: word reset-class drop ;

PRIVATE>

: classes ( -- seq ) implementors-map get keys ;

PREDICATE: predicate < word "predicating" word-prop >boolean ;

: create-predicate-word ( word -- predicate )
    [ name>> "?" append ] [ vocabulary>> ] bi create
    dup predicate? [ dup reset-generic ] unless ;

: predicate-word ( word -- predicate )
    "predicate" word-prop first ;

M: predicate flushable? drop t ;

M: predicate forget*
    [ call-next-method ] [ f "predicating" set-word-prop ] bi ;

M: predicate reset-word
    [ call-next-method ] [ f "predicating" set-word-prop ] bi ;

: define-predicate ( class quot -- )
    [ predicate-word ] dip (( object -- ? )) define-declared ;

: superclass ( class -- super )
    #! Output f for non-classes to work with algebra code
    dup class? [ "superclass" word-prop ] [ drop f ] if ;

: superclasses ( class -- supers )
    [ superclass ] follow reverse ;

: superclass-of? ( class superclass -- ? )
    superclasses member-eq? ;

: subclass-of? ( class superclass -- ? )
    swap superclass-of? ;

: members ( class -- seq )
    #! Output f for non-classes to work with algebra code
    dup class? [ "members" word-prop ] [ drop f ] if ;

: participants ( class -- seq )
    #! Output f for non-classes to work with algebra code
    dup class? [ "participants" word-prop ] [ drop f ] if ;

GENERIC: implementors ( class/classes -- seq )

! update-map
: class-uses ( class -- seq )
    [
        [ members % ]
        [ participants % ]
        [ superclass [ , ] when* ]
        tri
    ] { } make ;

: class-usage ( class -- seq ) update-map get at ;

: class-usages ( class -- seq ) [ class-usage ] closure keys ;

M: class implementors implementors-map get at keys ;

M: sequence implementors [ implementors ] gather ;

<PRIVATE

: update-map+ ( class -- )
    dup class-uses update-map get add-vertex ;

: update-map- ( class -- )
    dup class-uses update-map get remove-vertex ;

: implementors-map+ ( class -- )
    [ H{ } clone ] dip implementors-map get set-at ;

: implementors-map- ( class -- )
    implementors-map get delete-at ;

: make-class-props ( superclass members participants metaclass -- assoc )
    [
        {
            [ dup [ bootstrap-word ] when "superclass" set ]
            [ [ bootstrap-word ] map "members" set ]
            [ [ bootstrap-word ] map "participants" set ]
            [ "metaclass" set ]
        } spread
    ] H{ } make-assoc ;

GENERIC: metaclass-changed ( use class -- )

: ?metaclass-changed ( class usages/f -- )
    dup [ [ metaclass-changed ] with each ] [ 2drop ] if ;

: check-metaclass ( class metaclass -- usages/f )
    over class? [
        over "metaclass" word-prop eq?
        [ drop f ] [ class-usage keys ] if
    ] [ 2drop f ] if ;

: ?define-symbol ( word -- )
    dup deferred? [ define-symbol ] [ drop ] if ;

: (define-class) ( word props -- )
    reset-caches
    2dup "metaclass" swap at check-metaclass
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
        [ 2drop update-map+ ]
        [ nip ?metaclass-changed ]
    } 3cleave ;

GENERIC: update-class ( class -- )

M: class update-class drop ;

GENERIC: update-methods ( class seq -- )

: update-classes ( class -- )
    dup class-usages
    [ nip [ update-class ] each ] [ update-methods ] 2bi ;

: check-inheritance ( subclass superclass -- )
    2dup superclass-of? [ bad-inheritance ] [ 2drop ] if ;

: define-class ( word superclass members participants metaclass -- )
    [ 2dup check-inheritance ] 3dip
    make-class-props [ (define-class) ] [ drop changed-definition ] 2bi ;

: forget-predicate ( class -- )
    dup "predicate" word-prop
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

M: class forget* ( class -- )
    [ call-next-method ] [ forget-class ] bi ;

GENERIC: class ( object -- class )

GENERIC: instance? ( object class -- ? ) flushable
