! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays definitions assocs kernel kernel.private
slots.private namespaces make sequences strings words words.symbol
vectors math quotations combinators sorting effects graphs
vocabs sets ;
IN: classes

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

PREDICATE: class < word "class" word-prop ;

: classes ( -- seq ) implementors-map get keys ;

: predicate-word ( word -- predicate )
    [ name>> "?" append ] [ vocabulary>> ] bi create ;

PREDICATE: predicate < word "predicating" word-prop >boolean ;

M: predicate forget*
    [ call-next-method ] [ f "predicating" set-word-prop ] bi ;

M: predicate reset-word
    [ call-next-method ] [ f "predicating" set-word-prop ] bi ;

: define-predicate ( class quot -- )
    [ "predicate" word-prop first ] dip
    (( object -- ? )) define-declared ;

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

<PRIVATE

: update-map+ ( class -- )
    dup class-uses update-map get add-vertex ;

: update-map- ( class -- )
    dup class-uses update-map get remove-vertex ;

M: class implementors implementors-map get at keys ;

M: sequence implementors [ implementors ] gather ;

: implementors-map+ ( class -- )
    H{ } clone swap implementors-map get set-at ;

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

: ?define-symbol ( word -- )
    dup deferred? [ define-symbol ] [ drop ] if ;

: (define-class) ( word props -- )
    [
        {
            [ dup class? [ drop ] [ [ implementors-map+ ] [ new-class ] bi ] if ]
            [ reset-class ]
            [ ?define-symbol ]
            [ redefined ]
            [ ]
        } cleave
    ] dip [ assoc-union ] curry change-props
    dup predicate-word
    [ 1quotation "predicate" set-word-prop ]
    [ swap "predicating" set-word-prop ]
    [ drop t "class" set-word-prop ]
    2tri ;

PRIVATE>

GENERIC: update-class ( class -- )

M: class update-class drop ;

GENERIC: update-methods ( class seq -- )

: update-classes ( class -- )
    dup class-usages
    [ nip [ update-class ] each ] [ update-methods ] 2bi ;

: define-class ( word superclass members participants metaclass -- )
    #! If it was already a class, update methods after.
    reset-caches
    make-class-props
    [ drop update-map- ]
    [ (define-class) ]
    [ drop update-map+ ]
    2tri ;

: forget-predicate ( class -- )
    dup "predicate" word-prop
    dup length 1 = [
        first
        [ nip ] [ "predicating" word-prop = ] 2bi
        [ forget ] [ drop ] if
    ] [ 2drop ] if ;

: forget-methods ( class -- )
    [ implementors ] [ [ swap 2array ] curry ] bi map forget-all ;

GENERIC: class-forgotten ( use class -- )

: forget-class ( class -- )
    {
        [ dup class-usage keys [ class-forgotten ] with each ]
        [ forget-predicate ]
        [ forget-methods ]
        [ implementors-map- ]
        [ update-map- ]
        [ reset-class ]
    } cleave
    reset-caches ;

M: class class-forgotten
    nip forget-class ;

M: class forget* ( class -- )
    [ call-next-method ] [ forget-class ] bi ;

GENERIC: class ( object -- class )

GENERIC: instance? ( object class -- ? ) flushable
