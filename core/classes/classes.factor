! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: classes
USING: arrays definitions assocs kernel
kernel.private slots.private namespaces sequences strings words
vectors math quotations combinators sorting effects graphs ;

PREDICATE: word class ( obj -- ? ) "class" word-prop ;

SYMBOL: typemap
SYMBOL: class<map
SYMBOL: update-map
SYMBOL: builtins

PREDICATE: word builtin-class
    "metaclass" word-prop builtin-class eq? ;

PREDICATE: class tuple-class
    "metaclass" word-prop tuple-class eq? ;

: classes ( -- seq ) class<map get keys ;

: type>class ( n -- class ) builtins get nth ;

: predicate-word ( word -- predicate )
    [ word-name "?" append ] keep word-vocabulary create ;

: predicate-effect 1 { "?" } <effect> ;

PREDICATE: compound predicate
    "predicating" word-prop >boolean ;

: define-predicate ( class predicate quot -- )
    over [
        dupd predicate-effect define-declared
        2dup 1quotation "predicate" set-word-prop
        swap "predicating" set-word-prop
    ] [
        3drop
    ] if ;

: superclass ( class -- super )
    "superclass" word-prop ;

: members ( class -- seq ) "members" word-prop ;

: class-empty? ( class -- ? ) members dup [ empty? ] when ;

: (flatten-union-class) ( class -- )
    dup members [
        [ (flatten-union-class) ] each
    ] [
        dup set
    ] ?if ;

: flatten-union-class ( class -- assoc )
    [ (flatten-union-class) ] H{ } make-assoc ;

: (flatten-class) ( class -- )
    {
        { [ dup tuple-class? ] [ dup set ] }
        { [ dup builtin-class? ] [ dup set ] }
        { [ dup members ] [ members [ (flatten-class) ] each ] }
        { [ dup superclass ] [ superclass (flatten-class) ] }
    } cond ;

: flatten-class ( class -- assoc )
    [ (flatten-class) ] H{ } make-assoc ;

: class-hashes ( class -- seq )
    flatten-class keys [
        dup builtin-class?
        [ "type" word-prop ] [ hashcode ] if
    ] map ;

: (flatten-builtin-class) ( class -- )
    {
        { [ dup members ] [ members [ (flatten-builtin-class) ] each ] }
        { [ dup superclass ] [ superclass (flatten-builtin-class) ] }
        { [ t ] [ dup set ] }
    } cond ;

: flatten-builtin-class ( class -- assoc )
    [ (flatten-builtin-class) ] H{ } make-assoc ;

: types ( class -- seq )
    flatten-builtin-class keys
    [ "type" word-prop ] map natural-sort ;

: class< ( class1 class2 -- ? ) swap class<map get at key? ;

<PRIVATE

DEFER: (class<)

: superclass< ( cls1 cls2 -- ? )
    >r superclass r> 2dup and [ (class<) ] [ 2drop f ] if ;

: union-class< ( cls1 cls2 -- ? )
    [ flatten-union-class ] 2apply keys
    [ nip [ (class<) ] curry* contains? ] curry assoc-all? ;

: (class<) ( class1 class2 -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over class-empty? ] [ 2drop t ] }
        { [ 2dup superclass< ] [ 2drop t ] }
        { [ 2dup [ members not ] both? ] [ 2drop f ] }
        { [ t ] [ union-class< ] }
    } cond ;

: lookup-union ( classes -- class )
    typemap get at dup empty? [ drop object ] [ first ] if ;

: (class-or) ( class class -- class )
    [ flatten-builtin-class ] 2apply union lookup-union ;

: (class-and) ( class class -- class )
    [ flatten-builtin-class ] 2apply intersect lookup-union ;

: tuple-class-and ( class1 class2 -- class )
    dupd eq? [ drop null ] unless ;

: largest-class ( seq -- n elt )
    dup [
        [ 2dup class< >r swap class< not r> and ]
        curry* subset empty?
    ] curry find [ "Topological sort failed" throw ] unless* ;

PRIVATE>

: sort-classes ( seq -- newseq )
    >vector
    [ dup empty? not ]
    [ dup largest-class >r over delete-nth r> ]
    { } unfold ;

: class-or ( class1 class2 -- class )
    {
        { [ 2dup class< ] [ nip ] }
        { [ 2dup swap class< ] [ drop ] }
        { [ t ] [ (class-or) ] }
    } cond ;

: class-and ( class1 class2 -- class )
    {
        { [ 2dup class< ] [ drop ] }
        { [ 2dup swap class< ] [ nip ] }
        { [ 2dup [ tuple-class? ] both? ] [ tuple-class-and ] }
        { [ t ] [ (class-and) ] }
    } cond ;

: classes-intersect? ( class1 class2 -- ? )
    class-and class-empty? not ;

: min-class ( class seq -- class/f )
    [ dupd classes-intersect? ] subset dup empty? [
        2drop f
    ] [
        tuck [ class< ] curry* all? [ peek ] [ drop f ] if
    ] if ;

GENERIC: reset-class ( class -- )

M: word reset-class drop ;

<PRIVATE

! class<map
: bigger-classes ( class -- seq )
    classes [ (class<) ] curry* subset ;

: bigger-classes+ ( class -- )
    [ bigger-classes [ dup ] H{ } map>assoc ] keep
    class<map get set-at ;

: bigger-classes- ( class -- )
    class<map get delete-at ;

: smaller-classes ( class -- seq )
    classes swap [ (class<) ] curry subset ;

: smaller-classes+ ( class -- )
    dup smaller-classes class<map get add-vertex ;

: smaller-classes- ( class -- )
    dup smaller-classes class<map get remove-vertex ;

: class<map+ ( class -- )
    H{ } clone over class<map get set-at
    dup smaller-classes+ bigger-classes+ ;

: class<map- ( class -- )
    dup smaller-classes- bigger-classes- ;

! update-map
: class-uses ( class -- seq )
    [ dup members % superclass [ , ] when* ] { } make ;

: class-usages ( class -- assoc )
    [ update-map get at ] closure ;

: update-map+ ( class -- )
    dup class-uses update-map get add-vertex ;

: update-map- ( class -- )
    dup class-uses update-map get remove-vertex ;

! typemap
: push-at ( value key assoc -- )
    2dup at* [
        2nip push
    ] [
        drop >r >r 1vector r> r> set-at
    ] if ;

: typemap+ ( class -- )
    dup flatten-builtin-class typemap get push-at ;

: pop-at ( value key assoc -- )
    at* [ delete ] [ 2drop ] if ;

: typemap- ( class -- )
    dup flatten-builtin-class typemap get pop-at ;

! Class definition
: cache-class ( class -- )
    dup typemap+ dup class<map+ update-map+ ;

: cache-classes ( assoc -- )
    [ drop cache-class ] assoc-each ;

GENERIC: uncache-class ( class -- )

M: class uncache-class
    dup update-map- dup class<map- typemap- ;

M: word uncache-class drop ;

: uncache-classes ( assoc -- )
    [ drop uncache-class ] assoc-each ;

GENERIC: update-methods ( class -- )

PRIVATE>

: define-class-props ( members superclass metaclass -- assoc )
    [
        "metaclass" set
        dup [ bootstrap-word ] when "superclass" set
        [ bootstrap-word ] map "members" set
    ] H{ } make-assoc ;

: (define-class) ( word props -- )
    over reset-class
    >r dup word-props r> union over set-word-props
    dup intern-symbol
    t "class" set-word-prop ;

: define-class ( word members superclass metaclass -- )
    #! If it was already a class, update methods after.
    define-class-props
    over class? >r
    over class-usages [
        uncache-classes
        dupd (define-class)
    ] keep cache-classes
    r> [ update-methods ] [ drop ] if ;

GENERIC: class ( object -- class ) inline

M: object class type type>class ;

<PRIVATE

: class-of-tuple ( obj -- class )
    2 slot { word } declare ; inline

PRIVATE>
