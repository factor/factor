! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.private
combinators kernel make math math.order namespaces quotations 
sequences sets sorting vectors ;
IN: classes.algebra

DEFER: sort-classes

<PRIVATE

TUPLE: anonymous-union { members read-only } ;

INSTANCE: anonymous-union classoid

: <anonymous-union> ( members -- classoid )
    [ classoid check-instance ] map [ null eq? ] reject
    members dup length 1 =
    [ first ] [ sort-classes f like anonymous-union boa ] if ;

M: anonymous-union rank-class drop 6 ;

TUPLE: anonymous-intersection { participants read-only } ;

INSTANCE: anonymous-intersection classoid

: <anonymous-intersection> ( participants -- classoid )
    [ classoid check-instance ] map
    members dup length 1 =
    [ first ] [ sort-classes f like anonymous-intersection boa ] if ;

M: anonymous-intersection rank-class drop 4 ;

TUPLE: anonymous-complement { class read-only } ;

INSTANCE: anonymous-complement classoid

: <anonymous-complement> ( object -- classoid )
    classoid check-instance anonymous-complement boa ;

M: anonymous-complement rank-class drop 3 ;

M: anonymous-complement predicate-def
    class>> [ over [ instance? not ] [ 2drop t ] if ] curry ;

M: anonymous-complement instance?
    over [ class>> instance? not ] [ 2drop t ] if ;

M: anonymous-complement class-name
    class>> class-name ;


TUPLE: anonymous-predicate
    { class read-only }
    { predicate read-only } ;

INSTANCE: anonymous-predicate classoid

: <anonymous-predicate> ( class predicate -- classoid )
    [ classoid check-instance ] [ quotation check-instance ] bi*
    anonymous-predicate boa ;

! Used for ordering classes
M: anonymous-predicate rank-class drop 1.5 ;

DEFER: (class<=)

DEFER: (class-not)

GENERIC: (classes-intersect?) ( first second -- ? )

DEFER: (class-and)

DEFER: (class-or)

GENERIC: (flatten-class) ( class -- )

GENERIC: normalize-class ( class -- class' )

M: object normalize-class ;

: symmetric-class-op ( first second cache quot -- result )
    [ 2dup [ rank-class ] bi@ > [ swap ] when ] 2dip 2cache ; inline

PRIVATE>

: only-classoid? ( obj -- ? )
    dup classoid? [ class? not ] [ drop f ] if ;

: class<= ( first second -- ? )
    class<=-cache get [ (class<=) ] 2cache ;

: class< ( first second -- ? )
    {
        { [ 2dup class<= not ] [ 2drop f ] }
        { [ 2dup swap class<= not ] [ 2drop t ] }
        [ [ rank-class ] bi@ < ]
    } cond ;

: class= ( first second -- ? )
    2dup class<= [ swap class<= ] [ 2drop f ] if ;

: class-not ( class -- complement )
    class-not-cache get [ (class-not) ] cache ;

: classes-intersect? ( first second -- ? )
    [ normalize-class ] bi@
    classes-intersect-cache get [ (classes-intersect?) ] symmetric-class-op ;

: class-and ( first second -- class )
    class-and-cache get [ (class-and) ] symmetric-class-op ;

: class-or ( first second -- class )
    class-or-cache get [ (class-or) ] symmetric-class-op ;

SYMBOL: +incomparable+

: compare-classes ( first second -- <=> )
    [ swap class<= ] [ class<= ] 2bi
    [ +eq+ +lt+ ] [ +gt+ +incomparable+ ] if ? ;

: evaluate-class-predicate ( class1 class2 -- ? )
    {
        { [ 2dup class<= ] [ t ] }
        { [ 2dup classes-intersect? not ] [ f ] }
        [ +incomparable+ ]
    } cond 2nip ;

<PRIVATE

: superclass<= ( first second -- ? )
    swap superclass-of [ swap class<= ] [ drop f ] if* ;

: left-anonymous-union<= ( first second -- ? )
    [ members>> ] dip [ class<= ] curry all? ;

: right-union<= ( first second -- ? )
    class-members [ class<= ] with any? ;

: right-anonymous-union<= ( first second -- ? )
    members>> [ class<= ] with any? ;

: left-anonymous-intersection<= ( first second -- ? )
    [ participants>> ] dip [ class<= ] curry any? ;

PREDICATE: nontrivial-anonymous-intersection < anonymous-intersection
    participants>> empty? not ;

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
        [ drop object ]
    } cond ;

: left-anonymous-complement<= ( first second -- ? )
    [ normalize-complement ] dip class<= ;

PREDICATE: nontrivial-anonymous-complement < anonymous-complement
    class>> dup anonymous-union? [ drop t ] [
        dup anonymous-intersection? [ drop t ] [
            dup class-members [ drop t ] [
                class-participants
            ] if
        ] if
    ] if ;

PREDICATE: empty-union < anonymous-union members>> empty? ;

PREDICATE: empty-intersection < anonymous-intersection participants>> empty? ;

: (class<=) ( first second -- ? )
    2dup eq? [ 2drop t ] [
        [ normalize-class ] bi@
        2dup superclass<= [ 2drop t ] [
            {
                { [ 2dup eq? ] [ 2drop t ] }
                { [ dup empty-intersection? ] [ 2drop t ] }
                { [ over empty-union? ] [ 2drop t ] }
                { [ 2dup [ anonymous-complement? ] both? ] [ anonymous-complement<= ] }
                { [ over anonymous-union? ] [ left-anonymous-union<= ] }
                { [ over anonymous-predicate? ] [ [ class>> ] dip class<= ] }
                { [ over nontrivial-anonymous-intersection? ] [ left-anonymous-intersection<= ] }
                { [ over nontrivial-anonymous-complement? ] [ left-anonymous-complement<= ] }
                { [ dup class-members ] [ right-union<= ] }
                { [ dup anonymous-union? ] [ right-anonymous-union<= ] }
                { [ dup anonymous-intersection? ] [ right-anonymous-intersection<= ] }
                { [ dup anonymous-complement? ] [ class>> classes-intersect? not ] }
                { [ dup anonymous-predicate? ] [ class>> class<= ] }
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

M: anonymous-predicate (classes-intersect?)
    class>> classes-intersect? ;

: anonymous-union-and ( first second -- class )
    members>> [ class-and ] with map <anonymous-union> ;

: anonymous-intersection-and ( first second -- class )
    participants>> swap suffix <anonymous-intersection> ;

: (class-and) ( first second -- class )
    2dup compare-classes {
        { +lt+ [ drop ] }
        { +gt+ [ nip ] }
        { +eq+ [ nip ] }
        { +incomparable+ [
            2dup classes-intersect? [
                [ normalize-class ] bi@ {
                    { [ dup anonymous-union? ] [ anonymous-union-and ] }
                    { [ dup anonymous-intersection? ] [ anonymous-intersection-and ] }
                    { [ over anonymous-union? ] [ swap anonymous-union-and ] }
                    { [ over anonymous-intersection? ] [ swap anonymous-intersection-and ] }
                    [ 2array <anonymous-intersection> ]
                } cond
            ] [ 2drop null ] if
        ] }
    } case ;

: anonymous-union-or ( first second -- class )
    members>> swap suffix <anonymous-union> ;

: classes>anonymous-union ( first second -- class )
    [ normalize-class ] bi@ {
        { [ dup anonymous-union? ] [ anonymous-union-or ] }
        { [ over anonymous-union? ] [ swap anonymous-union-or ] }
        [ 2array <anonymous-union> ]
    } cond ;

: anonymous-complement-or ( first second -- class )
    2dup class>> swap class<= [ 2drop object ] [ classes>anonymous-union ] if ;

: (class-or) ( first second -- class )
    2dup compare-classes {
        { +lt+ [ nip ] }
        { +gt+ [ drop ] }
        { +eq+ [ nip ] }
        { +incomparable+ [
            {
                { [ dup anonymous-complement? ] [ anonymous-complement-or ] }
                { [ over anonymous-complement? ] [ swap anonymous-complement-or ] }
                [ classes>anonymous-union ]
            } cond
        ] }
    } case ;

: (class-not) ( class -- complement )
    {
        { [ dup anonymous-complement? ] [ class>> ] }
        { [ dup object eq? ] [ drop null ] }
        { [ dup null eq? ] [ drop object ] }
        [ <anonymous-complement> ]
    } cond ;

M: anonymous-union (flatten-class)
    members>> [ (flatten-class) ] each ;

M: anonymous-predicate (flatten-class)
    class>> (flatten-class) ;

PRIVATE>

ERROR: topological-sort-failed ;

: largest-class ( seq -- n elt )
    dup [ [ class< ] with none? ] curry find-last
    [ topological-sort-failed ] unless* ;

: sort-classes ( seq -- newseq )
    [ class-name ] sort-by >vector
    [ dup empty? not ]
    [ dup largest-class [ swap remove-nth! ] dip ]
    produce nip ;

: smallest-class ( classes -- class/f )
    [ f ] [
        inv-sort [ ] [ [ class<= ] most ] map-reduce
    ] if-empty ;

: flatten-class ( class -- seq )
    [ (flatten-class) ] { } make members ;
