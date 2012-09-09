USING: accessors arrays assocs fry grouping kernel locals math
math.order math.ranges sequences sequences.private splitting ;
FROM: sequences => change-nth ;
IN: sequences.extras

: reduce1 ( seq quot -- result ) [ unclip ] dip reduce ; inline

:: reduce-r ( list identity quot: ( obj1 obj2 -- obj ) -- result )
    list empty?
    [ identity ]
    [ list rest identity quot reduce-r list first quot call ] if ;
    inline recursive

! Quot must have static stack effect, unlike "reduce"
:: reduce* ( seq id quot -- result ) seq
    [ id ]
    [ unclip id swap quot call( prev elt -- next ) quot reduce* ] if-empty ; inline recursive

:: combos ( list1 list2 -- result )
    list2 [ [ 2array ] curry list1 swap map ] map concat ;

: find-all ( seq quot -- elts )
    [ [ length iota ] keep ] dip
    [ dupd call( a -- ? ) [ 2array ] [ 2drop f ] if ] curry
    2map [ ] filter ; inline

: insert-sorted ( elt seq -- seq )
    2dup [ < ] with find drop over length or swap insert-nth ;

: each-from ( ... seq quot: ( ... x -- ... ) i -- ... )
    -rot (each) (each-integer) ; inline

: reduce-from ( ... seq identity quot: ( ... prev elt -- ... next ) i -- ... result )
    [ swap ] 2dip each-from ; inline

: supremum-by ( seq quot: ( ... elt -- ... x ) -- elt )
    [ [ first dup ] dip call ] 2keep [
        dupd call pick dupd after?
        [ [ 2drop ] 2dip ] [ 2drop ] if
    ] curry 1 each-from drop ; inline

: infimum-by ( seq quot: ( ... elt -- ... x ) -- elt )
    [ [ first dup ] dip call ] 2keep [
        dupd call pick dupd before?
        [ [ 2drop ] 2dip ] [ 2drop ] if
    ] curry 1 each-from drop ; inline

: all-subseqs ( seq -- seqs )
    dup length [1,b] [ <clumps> ] with map concat ;

:: each-subseq ( ... seq quot: ( ... x -- ... ) -- ... )
    seq length :> len
    len [0,b] [
        :> from
        from len (a,b] [
            :> to
            from to seq subseq quot call( x -- )
        ] each
    ] each ;

:: longest-subseq ( seq1 seq2 -- subseq )
    seq1 length :> len1
    seq2 length :> len2
    0 :> n!
    0 :> end!
    len1 1 + [ len2 1 + 0 <array> ] replicate :> table
    len1 [1,b] [| x |
        len2 [1,b] [| y |
            x 1 - seq1 nth-unsafe
            y 1 - seq2 nth-unsafe = [
                y 1 - x 1 - table nth-unsafe nth-unsafe 1 + :> len
                len y x table nth-unsafe set-nth-unsafe
                len n > [ len n! x end! ] when
            ] [ 0 y x table nth-unsafe set-nth-unsafe ] if
        ] each
    ] each end n - end seq1 subseq ;

: pad-longest ( seq1 seq2 elt -- seq1 seq2 )
    [ 2dup max-length ] dip [ pad-tail ] 2curry bi@ ;

: change-nths ( ... indices seq quot: ( ... elt -- ... elt' ) -- ... )
    [ change-nth ] 2curry each ; inline

: push-if-index ( ..a elt i quot: ( ..a elt i -- ..b ? ) accum -- ..b )
    [ 2keep drop ] dip rot [ push ] [ 2drop ] if ; inline

: index-selector-for ( quot exemplar -- selector accum )
    [ length ] keep new-resizable [ [ push-if-index ] 2curry ] keep ; inline

: filter-index-as ( ... seq quot: ( ... elt i -- ... ? ) exemplar -- ... seq' )
    dup [ index-selector-for [ each-index ] dip ] curry dip like ; inline

: filter-index ( ... seq quot: ( ... elt i -- ... ? ) -- ... seq' )
    over filter-index-as ; inline

: even-indices ( seq -- seq' ) [ nip even? ] filter-index ;

: odd-indices ( seq -- seq' ) [ nip odd? ] filter-index ;

: compact ( seq quot elt -- seq' )
    [ split-when harvest ] dip join ; inline

: collapse ( seq quot elt -- seq' )
    [ split-when ] dip
    [ [ harvest ] dip join ]
    [ [ first empty? ] dip [ prepend ] curry when ]
    [ [ last empty? ] dip [ append ] curry when ]
    2tri ; inline

:: slice-when ( seq quot: ( elt -- ? ) -- seq' )
    seq length :> len
    0 [ len dupd < ] [
        dup seq quot find-from drop
        [ 2dup = [ 1 + ] when ] [ len ] if*
        [ seq <slice> ] keep len or swap
    ] produce nip ; inline

: rotate ( seq n -- seq' )
    cut prepend ;

:: rotate! ( seq n -- )
    n seq bounds-check length :> end
    0 n [ 2dup = ] [
        [ seq exchange-unsafe ] [ [ 1 + ] bi@ ] 2bi
        dup end = [ drop over ] when
        2over = [ -rot nip over ] when
    ] until 3drop ;

: all-rotations ( seq -- seq' )
    dup length iota [ rotate ] with map ;

: appender-for ( quot exemplar -- quot' vec )
    [ length ] keep new-resizable
    [ [ push-all ] curry compose ] keep ; inline

: appender ( quot -- quot' vec )
    V{ } appender-for ; inline

: map-concat-as ( ... seq quot: ( ... elt -- ... newelt ) exemplar -- ... newseq )
    dup [ appender-for [ each ] dip ] curry dip like ; inline

: >resizable ( seq -- vec ) ! fixes map-concat "cannot apply call to run-time..."
    [ length ] keep [ new-resizable ] [ over push-all ] bi ;

: map-concat ( ... seq quot: ( ... elt -- ... newelt ) -- ... newseq )
    over [ 2drop { } ] [
        first over call dup [
            >resizable [ [ push-all ] curry compose ] keep
            [ 1 ] 3dip [ (each) (each-integer) ] dip
        ] curry dip like
    ] if-empty ; inline

: map-filter-as ( ... seq map-quot: ( ... elt -- ... newelt ) filter-quot: ( ... newelt -- ... ? ) exemplar -- ... subseq )
    dup [ selector-for [ compose each ] dip ] curry dip like ; inline

: map-filter ( ... seq map-quot: ( ... elt -- ... newelt ) filter-quot: ( ... newelt -- ... ? ) -- ... subseq )
    pick map-filter-as ; inline

: map-sift ( ... seq quot: ( ... elt -- ... newelt ) -- ... newseq )
    [ ] map-filter ; inline

: map-harvest ( ... seq quot: ( ... elt -- ... newelt ) -- ... newseq )
    [ empty? not ] map-filter ; inline

<PRIVATE

: ((each-from)) ( i seq -- n quot )
    [ length over - 0 max swap ] keep '[ _ + _ nth-unsafe ] ; inline

: (each-from) ( i seq quot -- n quot' ) [ ((each-from)) ] dip compose ;
    inline

PRIVATE>

: map-from-as ( ... seq quot: ( ... elt -- ... newelt ) i exemplar -- ... newseq )
    [ -rot (each-from) ] dip map-integers ; inline

: map-from ( ... seq quot: ( ... elt -- ... newelt ) i -- ... newseq )
    pick map-from-as ; inline

<PRIVATE

: push-map-if ( ..a elt filter-quot: ( ..a elt -- ..b ? ) map-quot: ( ..a elt -- ..b newelt ) accum -- ..b )
    [ keep over ] 2dip [ when ] dip rot [ push ] [ 2drop ] if ; inline

: filter-mapper-for ( filter-quot map-quot exemplar -- quot' vec )
    [ length ] keep new-resizable [ [ push-map-if ] 3curry ] keep ; inline

: filter-mapper ( filter-quot map-quot -- quot' vec )
    V{ } filter-mapper-for ; inline

PRIVATE>

: filter-map-as ( ... seq filter-quot: ( ... elt -- ... ? ) map-quot: ( ... elt -- ... newelt ) exemplar -- ... newseq )
    dup [ filter-mapper-for [ each ] dip ] curry dip like ; inline

: filter-map ( ... seq filter-quot: ( ... elt -- ... ? ) map-quot: ( ... elt -- ... newelt ) -- ... newseq )
    pick filter-map-as ; inline

: 2map-sum ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... n ) -- ... n )
    [ 0 ] 3dip [ dip + ] curry [ rot ] prepose 2each ; inline

: 2count ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ? ) -- ... n )
    [ 1 0 ? ] compose 2map-sum ; inline

: round-robin ( seq -- newseq )
    [ { } ] [
        [ [ length ] [ max ] map-reduce iota ] keep
        [ [ ?nth ] with map ] curry map concat sift
    ] if-empty ;

: sift-as ( seq exemplar -- newseq )
    [ ] swap filter-as ;

: harvest-as ( seq exemplar -- newseq )
    [ empty? not ] swap filter-as ;

: contains? ( seq elts -- ? )
    [ member? ] curry any? ; inline

: trim-as ( ... seq quot: ( ... elt -- ... ? ) exemplar -- ... newseq )
    [ trim-slice ] [ like ] bi* ; inline

: ?trim ( ... seq quot: ( ... elt -- ... ? ) -- ... seq/newseq )
    over empty? [ drop ] [
        over [ first-unsafe ] [ last-unsafe ] bi pick bi@ or
        [ trim ] [ drop ] if
    ] if ; inline

: unsurround ( newseq seq2 seq3 -- seq1 )
   [ ?head drop ] [ ?tail drop ] bi* ;

: none? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? )
    any? not ; inline

: one? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? )
    [ find ] 2keep rot [
        [ 1 + ] 2dip find-from drop not
    ] [ 3drop f ] if ; inline

: map-index! ( ... seq quot: ( ... elt index -- ... newelt ) -- ... seq )
    over [ [ (each-index) ] dip collect ] keep ; inline

<PRIVATE

: (2each-index) ( seq1 seq2 quot -- n quot' )
    [ ((2each)) [ keep ] curry ] dip compose ; inline

PRIVATE>

: 2each-index ( ... seq1 seq2 quot: ( ... elt1 elt2 index -- ... ) -- ... )
    (2each-index) each-integer ; inline

: 2map-into ( seq1 seq2 quot into -- )
    [ (2each) ] dip collect ; inline

: 2map! ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... newelt ) -- ... seq1 )
    pick [ 2map-into ] keep ; inline

: 2map-index ( ... seq1 seq2 quot: ( ... elt1 elt2 index -- ... newelt ) -- ... newseq )
    pick [ (2each-index) ] dip map-integers ; inline

TUPLE: evens seq length ;

: <evens> ( seq -- evens )
    dup length 1 + 2/ evens boa ; inline

M: evens length length>> ; inline

M: evens nth-unsafe [ 2 * ] [ seq>> nth-unsafe ] bi* ; inline

INSTANCE: evens immutable-sequence

TUPLE: odds seq length ;

: <odds> ( seq -- odds )
    dup length 2/ odds boa ; inline

M: odds length length>> ; inline

M: odds nth-unsafe [ 2 * 1 + ] [ seq>> nth-unsafe ] bi* ; inline

INSTANCE: odds immutable-sequence

: until-empty ( seq quot -- )
    [ dup empty? ] swap until drop ; inline

: arg-max ( seq -- n )
    dup length iota zip [ first-unsafe ] supremum-by second ;

: arg-min ( seq -- n )
    dup length iota zip [ first-unsafe ] infimum-by second ;

: arg-where ( ... seq quot: ( ... elt -- ... ? ) -- ... indices )
    [ dup length iota zip ] dip
    [ first-unsafe ] prepose filter values ; inline
