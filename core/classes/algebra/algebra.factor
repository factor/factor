! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel classes combinators accessors sequences arrays
vectors assocs namespaces words sorting layouts math hashtables
kernel.private sets math.order ;
IN: classes.algebra

TUPLE: anonymous-union members ;

C: <anonymous-union> anonymous-union

TUPLE: anonymous-intersection participants ;

C: <anonymous-intersection> anonymous-intersection

TUPLE: anonymous-complement class ;

C: <anonymous-complement> anonymous-complement

GENERIC: valid-class? ( obj -- ? )

M: class valid-class? drop t ;
M: anonymous-union valid-class? members>> [ valid-class? ] all? ;
M: anonymous-intersection valid-class? participants>> [ valid-class? ] all? ;
M: anonymous-complement valid-class? class>> valid-class? ;
M: word valid-class? drop f ;

DEFER: (class<=)

: class<= ( first second -- ? )
    class<=-cache get [ (class<=) ] 2cache ;

DEFER: (class-not)

: class-not ( class -- complement )
    class-not-cache get [ (class-not) ] cache ;

GENERIC: (classes-intersect?) ( first second -- ? )

: normalize-class ( class -- class' )
    {
        { [ dup members ] [ members <anonymous-union> ] }
        { [ dup participants ] [ participants <anonymous-intersection> ] }
        [ ]
    } cond ;

: classes-intersect? ( first second -- ? )
    classes-intersect-cache get [
        normalize-class (classes-intersect?)
    ] 2cache ;

DEFER: (class-and)

: class-and ( first second -- class )
    class-and-cache get [ (class-and) ] 2cache ;

DEFER: (class-or)

: class-or ( first second -- class )
    class-or-cache get [ (class-or) ] 2cache ;

: superclass<= ( first second -- ? )
    swap superclass dup [ swap class<= ] [ 2drop f ] if ;

: left-anonymous-union<= ( first second -- ? )
    [ members>> ] dip [ class<= ] curry all? ;

: right-anonymous-union<= ( first second -- ? )
    members>> [ class<= ] with any? ;

: left-anonymous-intersection<= ( first second -- ? )
    [ participants>> ] dip [ class<= ] curry any? ;

: right-anonymous-intersection<= ( first second -- ? )
    participants>> [ class<= ] with all? ;

: anonymous-complement<= ( first second -- ? )
    [ class>> ] bi@ swap class<= ;

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
    [ normalize-complement ] dip class<= ;

PREDICATE: nontrivial-anonymous-complement < anonymous-complement
    class>> {
        [ anonymous-union? ]
        [ anonymous-intersection? ]
        [ members ]
        [ participants ]
    } cleave or or or ;

PREDICATE: empty-union < anonymous-union members>> empty? ;

PREDICATE: empty-intersection < anonymous-intersection participants>> empty? ;

: (class<=) ( first second -- -1/0/1 )
    2dup eq? [ 2drop t ] [
        2dup superclass<= [ 2drop t ] [
            [ normalize-class ] bi@ {
                { [ dup empty-intersection? ] [ 2drop t ] }
                { [ over empty-union? ] [ 2drop t ] }
                { [ 2dup [ anonymous-complement? ] both? ] [ anonymous-complement<= ] }
                { [ over anonymous-union? ] [ left-anonymous-union<= ] }
                { [ over anonymous-intersection? ] [ left-anonymous-intersection<= ] }
                { [ over nontrivial-anonymous-complement? ] [ left-anonymous-complement<= ] }
                { [ dup anonymous-union? ] [ right-anonymous-union<= ] }
                { [ dup anonymous-intersection? ] [ right-anonymous-intersection<= ] }
                { [ dup anonymous-complement? ] [ class>> classes-intersect? not ] }
                [ 2drop f ]
            } cond
        ] if
    ] if ;

M: anonymous-union (classes-intersect?)
    members>> [ classes-intersect? ] with any? ;

M: anonymous-intersection (classes-intersect?)
    participants>> [ classes-intersect? ] with all? ;

M: anonymous-complement (classes-intersect?)
    class>> class<= not ;

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

: class<=> ( first second -- ? )
    {
        { [ 2dup class<= not ] [ 2drop +gt+ ] }
        { [ 2dup swap class<= not ] [ 2drop +lt+ ] }
        [ [ rank-class ] bi@ <=> ]
    } cond ;

: class= ( first second -- ? )
    [ class<= ] [ swap class<= ] 2bi and ;

: largest-class ( seq -- n elt )
    dup [ [ class< ] with any? not ] curry find-last
    [ "Topological sort failed" throw ] unless* ;

: sort-classes ( seq -- newseq )
    [ [ name>> ] compare ] sort >vector
    [ dup empty? not ]
    [ dup largest-class [ over delete-nth ] dip ]
    produce nip ;

: min-class ( class seq -- class/f )
    over [ classes-intersect? ] curry filter
    [ drop f ] [
        [ nip ] [ [ class<= ] with all? ] 2bi [ peek ] [ drop f ] if
    ] if-empty ;

GENERIC: (flatten-class) ( class -- )

M: anonymous-union (flatten-class)
    members>> [ (flatten-class) ] each ;

: flatten-class ( class -- assoc )
    [ (flatten-class) ] H{ } make-assoc ;

: flatten-builtin-class ( class -- assoc )
    flatten-class [
        dup tuple class<= [ 2drop tuple tuple ] when
    ] assoc-map ;

: class-types ( class -- seq )
    flatten-builtin-class keys
    [ "type" word-prop ] map natural-sort ;

: class-tags ( class -- seq )
    class-types [
        dup num-tags get >=
        [ drop \ hi-tag tag-number ] when
    ] map prune ;

: class-tag ( class -- tag/f )
    class-tags dup length 1 = [ first ] [ drop f ] if ;
