! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel classes classes.builtin combinators accessors
sequences arrays vectors assocs namespaces words sorting layouts
math hashtables kernel.private sets math.order ;
IN: classes.algebra

: 2cache ( key1 key2 assoc quot -- value )
    >r >r 2array r> [ first2 ] r> compose cache ; inline

DEFER: (class<=)

: class<= ( first second -- ? )
    class<=-cache get [ (class<=) ] 2cache ;

DEFER: (class-not)

: class-not ( class -- complement )
    class-not-cache get [ (class-not) ] cache ;

DEFER: (classes-intersect?) ( first second -- ? )

: classes-intersect? ( first second -- ? )
    classes-intersect-cache get [ (classes-intersect?) ] 2cache ;

DEFER: (class-and)

: class-and ( first second -- class )
    class-and-cache get [ (class-and) ] 2cache ;

DEFER: (class-or)

: class-or ( first second -- class )
    class-or-cache get [ (class-or) ] 2cache ;

TUPLE: anonymous-union members ;

C: <anonymous-union> anonymous-union

TUPLE: anonymous-intersection participants ;

C: <anonymous-intersection> anonymous-intersection

TUPLE: anonymous-complement class ;

C: <anonymous-complement> anonymous-complement

: superclass<= ( first second -- ? )
    >r superclass r> class<= ;

: left-anonymous-union<= ( first second -- ? )
    >r members>> r> [ class<= ] curry all? ;

: right-anonymous-union<= ( first second -- ? )
    members>> [ class<= ] with contains? ;

: left-anonymous-intersection<= ( first second -- ? )
    >r participants>> r> [ class<= ] curry contains? ;

: right-anonymous-intersection<= ( first second -- ? )
    participants>> [ class<= ] with all? ;

: anonymous-complement<= ( first second -- ? )
    [ class>> ] bi@ swap class<= ;

: normalize-class ( class -- class' )
    {
        { [ dup members ] [ members <anonymous-union> ] }
        { [ dup participants ] [ participants <anonymous-intersection> ] }
        [ ]
    } cond ;

: normalize-complement ( class -- class' )
    class>> normalize-class {
        { [ dup anonymous-union? ] [
            members>>
            [ class-not normalize-class ] map
            <anonymous-intersection> 
        ] }
        { [ dup anonymous-intersection? ] [
            participants>>
            [ class-not normalize-class ] map
            <anonymous-union>
        ] }
    } cond ;

: left-anonymous-complement<= ( first second -- ? )
    >r normalize-complement r> class<= ;

PREDICATE: nontrivial-anonymous-complement < anonymous-complement
    class>> {
        [ anonymous-union? ]
        [ anonymous-intersection? ]
        [ members ]
        [ participants ]
    } cleave or or or ;

: (class<=) ( first second -- -1/0/1 )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ dup object eq? ] [ 2drop t ] }
        { [ over null eq? ] [ 2drop t ] }
        [
            [ normalize-class ] bi@ {
                { [ 2dup [ anonymous-complement? ] both? ] [ anonymous-complement<= ] }
                { [ over anonymous-union? ] [ left-anonymous-union<= ] }
                { [ over anonymous-intersection? ] [ left-anonymous-intersection<= ] }
                { [ over nontrivial-anonymous-complement? ] [ left-anonymous-complement<= ] }
                { [ dup anonymous-union? ] [ right-anonymous-union<= ] }
                { [ dup anonymous-intersection? ] [ right-anonymous-intersection<= ] }
                { [ dup anonymous-complement? ] [ class>> classes-intersect? not ] }
                { [ over superclass ] [ superclass<= ] }
                [ 2drop f ]
            } cond
        ]
    } cond ;

: anonymous-union-intersect? ( first second -- ? )
    members>> [ classes-intersect? ] with contains? ;

: anonymous-intersection-intersect? ( first second -- ? )
    participants>> [ classes-intersect? ] with all? ;

: anonymous-complement-intersect? ( first second -- ? )
    class>> class<= not ;

: tuple-class-intersect? ( first second -- ? )
    {
        { [ over tuple eq? ] [ 2drop t ] }
        { [ over builtin-class? ] [ 2drop f ] }
        { [ over tuple-class? ] [ [ class<= ] [ swap class<= ] 2bi or ] }
        [ swap classes-intersect? ]
    } cond ;

: builtin-class-intersect? ( first second -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over builtin-class? ] [ 2drop f ] }
        [ swap classes-intersect? ]
    } cond ;

: (classes-intersect?) ( first second -- ? )
    normalize-class {
        { [ dup anonymous-union? ] [ anonymous-union-intersect? ] }
        { [ dup anonymous-intersection? ] [ anonymous-intersection-intersect? ] }
        { [ dup anonymous-complement? ] [ anonymous-complement-intersect? ] }
        { [ dup tuple-class? ] [ tuple-class-intersect? ] }
        { [ dup builtin-class? ] [ builtin-class-intersect? ] }
        { [ dup superclass ] [ superclass classes-intersect? ] }
    } cond ;

: anonymous-union-and ( first second -- class )
    members>> [ class-and ] with map <anonymous-union> ;

: anonymous-intersection-and ( first second -- class )
    participants>> swap suffix <anonymous-intersection> ;

: (class-and) ( first second -- class )
    {
        { [ 2dup class<= ] [ drop ] }
        { [ 2dup swap class<= ] [ nip ] }
        { [ 2dup classes-intersect? not ] [ 2drop null ] }
        [
            [ normalize-class ] bi@ {
                { [ dup anonymous-union? ] [ anonymous-union-and ] }
                { [ dup anonymous-intersection? ] [ anonymous-intersection-and ] }
                { [ over anonymous-union? ] [ swap anonymous-union-and ] }
                { [ over anonymous-intersection? ] [ swap anonymous-intersection-and ] }
                [ 2array <anonymous-intersection> ]
            } cond
        ]
    } cond ;

: anonymous-union-or ( first second -- class )
    members>> swap suffix <anonymous-union> ;

: ((class-or)) ( first second -- class )
    [ normalize-class ] bi@ {
        { [ dup anonymous-union? ] [ anonymous-union-or ] }
        { [ over anonymous-union? ] [ swap anonymous-union-or ] }
        [ 2array <anonymous-union> ]
    } cond ;

: anonymous-complement-or ( first second -- class )
    2dup class>> swap class<= [ 2drop object ] [ ((class-or)) ] if ;

: (class-or) ( first second -- class )
    {
        { [ 2dup class<= ] [ nip ] }
        { [ 2dup swap class<= ] [ drop ] }
        { [ dup anonymous-complement? ] [ anonymous-complement-or ] }
        { [ over anonymous-complement? ] [ swap anonymous-complement-or ] }
        [ ((class-or)) ]
    } cond ;

: (class-not) ( class -- complement )
    {
        { [ dup anonymous-complement? ] [ class>> ] }
        { [ dup object eq? ] [ drop null ] }
        { [ dup null eq? ] [ drop object ] }
        [ <anonymous-complement> ]
    } cond ;

: class< ( first second -- ? )
    {
        { [ 2dup class<= not ] [ 2drop f ] }
        { [ 2dup swap class<= not ] [ 2drop t ] }
        [ [ rank-class ] bi@ < ]
    } cond ;

: largest-class ( seq -- n elt )
    dup [ [ class< ] with contains? not ] curry find-last
    [ "Topological sort failed" throw ] unless* ;

: sort-classes ( seq -- newseq )
    [ [ word-name ] compare ] sort >vector
    [ dup empty? not ]
    [ dup largest-class >r over delete-nth r> ]
    [ ] unfold nip ;

: min-class ( class seq -- class/f )
    over [ classes-intersect? ] curry filter
    dup empty? [ 2drop f ] [
        tuck [ class<= ] with all? [ peek ] [ drop f ] if
    ] if ;

DEFER: (flatten-class)
DEFER: flatten-builtin-class

: flatten-intersection-class ( class -- )
    participants [ flatten-builtin-class ] map
    dup empty? [
        drop object (flatten-class)
    ] [
        unclip [ assoc-intersect ] reduce [ swap set ] assoc-each
    ] if ;

: (flatten-class) ( class -- )
    {
        { [ dup tuple-class? ] [ dup set ] }
        { [ dup builtin-class? ] [ dup set ] }
        { [ dup members ] [ members [ (flatten-class) ] each ] }
        { [ dup participants ] [ flatten-intersection-class ] }
        { [ dup superclass ] [ superclass (flatten-class) ] }
        [ drop ]
    } cond ;

: flatten-class ( class -- assoc )
    [ (flatten-class) ] H{ } make-assoc ;

: flatten-builtin-class ( class -- assoc )
    flatten-class [
        dup tuple class<= [ 2drop tuple tuple ] when
    ] assoc-map ;

: class-types ( class -- seq )
    flatten-builtin-class keys
    [ "type" word-prop ] map natural-sort ;

: class-tags ( class -- tag/f )
    class-types [
        dup num-tags get >=
        [ drop \ hi-tag tag-number ] when
    ] map prune ;
