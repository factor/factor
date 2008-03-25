! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel classes combinators accessors sequences arrays
vectors assocs namespaces words sorting layouts math hashtables
;
IN: classes.algebra

: 2cache ( key1 key2 assoc quot -- value )
    >r >r 2array r> [ first2 ] r> compose cache ; inline

DEFER: (class<)

: class< ( first second -- ? )
    class<-cache get [ (class<) ] 2cache ;

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

TUPLE: anonymous-intersection members ;

C: <anonymous-intersection> anonymous-intersection

TUPLE: anonymous-complement class ;

C: <anonymous-complement> anonymous-complement

: superclass< ( first second -- ? )
    >r superclass r> class< ;

: left-union-class< ( first second -- ? )
    >r members r> [ class< ] curry all? ;

: right-union-class< ( first second -- ? )
    members [ class< ] with contains? ;

: left-anonymous-union< ( first second -- ? )
    >r members>> r> [ class< ] curry all? ;

: right-anonymous-union< ( first second -- ? )
    members>> [ class< ] with contains? ;

: left-anonymous-intersection< ( first second -- ? )
    >r members>> r> [ class< ] curry contains? ;

: right-anonymous-intersection< ( first second -- ? )
    members>> [ class< ] with all? ;

: anonymous-complement< ( first second -- ? )
    [ class>> ] 2apply swap class< ;

: (class<) ( first second -- -1/0/1 )  
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ dup object eq? ] [ 2drop t ] }
        { [ over null eq? ] [ 2drop t ] }
        { [ 2dup [ anonymous-complement? ] both? ] [ anonymous-complement< ] }
        { [ over anonymous-union? ] [ left-anonymous-union< ] }
        { [ over anonymous-intersection? ] [ left-anonymous-intersection< ] }
        { [ over anonymous-complement? ] [ 2drop f ] }
        { [ over members ] [ left-union-class< ] }
        { [ dup anonymous-union? ] [ right-anonymous-union< ] }
        { [ dup anonymous-intersection? ] [ right-anonymous-intersection< ] }
        { [ dup anonymous-complement? ] [ class>> classes-intersect? not ] }
        { [ dup members ] [ right-union-class< ] }
        { [ over superclass ] [ superclass< ] }
        { [ t ] [ 2drop f ] }
    } cond ;

: anonymous-union-intersect? ( first second -- ? )
    members>> [ classes-intersect? ] with contains? ;

: anonymous-intersection-intersect? ( first second -- ? )
    members>> [ classes-intersect? ] with all? ;

: anonymous-complement-intersect? ( first second -- ? )
    class>> class< not ;

: union-class-intersect? ( first second -- ? )
    members [ classes-intersect? ] with contains? ;

: tuple-class-intersect? ( first second -- ? )
    {
        { [ over tuple eq? ] [ 2drop t ] }
        { [ over builtin-class? ] [ 2drop f ] }
        { [ over tuple-class? ] [ [ class< ] 2keep swap class< or ] }
        { [ t ] [ swap classes-intersect? ] }
    } cond ;

: builtin-class-intersect? ( first second -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over builtin-class? ] [ 2drop f ] }
        { [ t ] [ swap classes-intersect? ] }
    } cond ;

: (classes-intersect?) ( first second -- ? )
    {
        { [ dup anonymous-union? ] [ anonymous-union-intersect? ] }
        { [ dup anonymous-intersection? ] [ anonymous-intersection-intersect? ] }
        { [ dup anonymous-complement? ] [ anonymous-complement-intersect? ] }
        { [ dup tuple-class? ] [ tuple-class-intersect? ] }
        { [ dup builtin-class? ] [ builtin-class-intersect? ] }
        { [ dup superclass ] [ superclass classes-intersect? ] }
        { [ dup members ] [ union-class-intersect? ] }
    } cond ;

: left-union-and ( first second -- class )
    >r members r> [ class-and ] curry map <anonymous-union> ;

: right-union-and ( first second -- class )
    members [ class-and ] with map <anonymous-union> ;

: left-anonymous-union-and ( first second -- class )
    >r members>> r> [ class-and ] curry map <anonymous-union> ;

: right-anonymous-union-and ( first second -- class )
    members>> [ class-and ] with map <anonymous-union> ;

: left-anonymous-intersection-and ( first second -- class )
    >r members>> r> add <anonymous-intersection> ;

: right-anonymous-intersection-and ( first second -- class )
    members>> swap add <anonymous-intersection> ;

: (class-and) ( first second -- class )
    {
        { [ 2dup class< ] [ drop ] }
        { [ 2dup swap class< ] [ nip ] }
        { [ 2dup classes-intersect? not ] [ 2drop null ] }
        { [ dup members ] [ right-union-and ] }
        { [ dup anonymous-union? ] [ right-anonymous-union-and ] }
        { [ dup anonymous-intersection? ] [ right-anonymous-intersection-and ] }
        { [ over members ] [ left-union-and ] }
        { [ over anonymous-union? ] [ left-anonymous-union-and ] }
        { [ over anonymous-intersection? ] [ left-anonymous-intersection-and ] }
        { [ t ] [ 2array <anonymous-intersection> ] }
    } cond ;

: left-anonymous-union-or ( first second -- class )
    >r members>> r> add <anonymous-union> ;

: right-anonymous-union-or ( first second -- class )
    members>> swap add <anonymous-union> ;

: (class-or) ( first second -- class )
    {
        { [ 2dup class< ] [ nip ] }
        { [ 2dup swap class< ] [ drop ] }
        { [ dup anonymous-union? ] [ right-anonymous-union-or ] }
        { [ over anonymous-union? ] [ left-anonymous-union-or ] }
        { [ t ] [ 2array <anonymous-union> ] }
    } cond ;

: (class-not) ( class -- complement )
    {
        { [ dup anonymous-complement? ] [ class>> ] }
        { [ dup object eq? ] [ drop null ] }
        { [ dup null eq? ] [ drop object ] }
        { [ t ] [ <anonymous-complement> ] }
    } cond ;

: largest-class ( seq -- n elt )
    dup [
        [ 2dup class< >r swap class< not r> and ]
        with subset empty?
    ] curry find [ "Topological sort failed" throw ] unless* ;

: sort-classes ( seq -- newseq )
    >vector
    [ dup empty? not ]
    [ dup largest-class >r over delete-nth r> ]
    [ ] unfold nip ;

: min-class ( class seq -- class/f )
    [ dupd classes-intersect? ] subset dup empty? [
        2drop f
    ] [
        tuck [ class< ] with all? [ peek ] [ drop f ] if
    ] if ;

: (flatten-class) ( class -- )
    {
        { [ dup tuple-class? ] [ dup set ] }
        { [ dup builtin-class? ] [ dup set ] }
        { [ dup members ] [ members [ (flatten-class) ] each ] }
        { [ dup superclass ] [ superclass (flatten-class) ] }
        { [ t ] [ drop ] }
    } cond ;

: flatten-class ( class -- assoc )
    [ (flatten-class) ] H{ } make-assoc ;

: class-hashes ( class -- seq )
    flatten-class keys [
        dup builtin-class?
        [ "type" word-prop ] [ hashcode ] if
    ] map ;

: flatten-builtin-class ( class -- assoc )
    flatten-class [
        dup tuple class< [ 2drop tuple tuple ] when
    ] assoc-map ;

: class-types ( class -- seq )
    flatten-builtin-class keys
    [ "type" word-prop ] map natural-sort ;

: class-tags ( class -- tag/f )
    class-types [
        dup num-tags get >=
        [ drop object tag-number ] when
    ] map prune ;
