USING: accessors arrays assocs fry grouping growable kernel
locals make math math.order math.ranges sequences
sequences.deep sequences.private sorting splitting vectors ;
FROM: sequences => change-nth ;
IN: sequences.extras

: reduce1 ( seq quot -- result ) [ unclip ] dip reduce ; inline

:: reduce-r ( seq identity quot: ( obj1 obj2 -- obj ) -- result )
    seq [ identity ] [
        unclip [ identity quot reduce-r ] [ quot call ] bi*
    ] if-empty ; inline recursive

! Quot must have static stack effect, unlike "reduce"
:: reduce* ( seq identity quot: ( prev elt -- next ) -- result )
    seq [ identity ] [
        unclip identity swap quot call( prev elt -- next )
        quot reduce*
    ] if-empty ; inline recursive

:: combos ( list1 list2 -- result )
    list2 [ [ 2array ] curry list1 swap map ] map concat ;

: find-all ( seq quot -- elts )
    [ [ length iota ] keep ] dip
    [ dupd call( a -- ? ) [ 2array ] [ 2drop f ] if ] curry
    2map [ ] filter ; inline

: insert-sorted ( elt seq -- seq )
    2dup [ < ] with find drop over length or swap insert-nth ;

: reduce-from ( ... seq identity quot: ( ... prev elt -- ... next ) i -- ... result )
    [ swap ] 2dip each-from ; inline

: all-subseqs ( seq -- seqs )
    dup length [1,b] [ clump ] with map concat ;

:: each-subseq ( ... seq quot: ( ... x -- ... ) -- ... )
    seq length :> len
    len [0,b] [
        :> from
        from len (a,b] [
            :> to
            from to seq subseq quot call( x -- )
        ] each
    ] each ;

: subseq-as ( from to seq exemplar -- subseq )
    [ check-slice subseq>copy (copy) ] dip like ;

: map-like ( seq exemplar -- seq' )
    '[ _ like ] map ; inline

: filter-all-subseqs-range ( ... seq range quot: ( ... x -- ... ) -- seq )
    [
        '[ <clumps> _ filter ] with map concat
    ] 3keep 2drop map-like ; inline

: filter-all-subseqs ( ... seq quot: ( ... x -- ... ) -- seq )
    [ dup length [1,b] ] dip filter-all-subseqs-range ; inline

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

: even-indices ( seq -- seq' )
    [ length 1 + 2/ ] keep [
        [ [ 2 * ] dip nth-unsafe ] curry
    ] keep map-integers ;

: odd-indices ( seq -- seq' )
    [ length 2/ ] keep [
        [ [ 2 * 1 + ] dip nth-unsafe ] curry
    ] keep map-integers ;

: compact ( ... seq quot: ( ... elt -- ... ? ) elt -- ... seq' )
    [ split-when harvest ] dip join ; inline

: collapse ( ... seq quot: ( ... elt -- ... ? ) elt -- ... seq' )
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

: cut-slice* ( seq n -- before after )
    [ head-slice* ] [ tail-slice* ] 2bi ;

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
    [ length over [-] swap ] keep '[ _ + _ nth-unsafe ] ; inline

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
        [ longest length iota ] keep
        [ [ ?nth ] with map ] curry map concat sift
    ] if-empty ;

: sift-as ( seq exemplar -- newseq )
    [ ] swap filter-as ;

: sift! ( seq -- newseq )
    [ ] filter! ;

: harvest-as ( seq exemplar -- newseq )
    [ empty? not ] swap filter-as ;

: harvest! ( seq -- newseq )
    [ empty? not ] filter! ;

: contains? ( seq elts -- ? )
    [ member? ] curry any? ; inline

: head-as ( seq n exemplar -- seq' )
    [ head-slice ] [ like ] bi* ; inline

: head*-as ( seq n exemplar -- seq' )
    [ head-slice* ] [ like ] bi* ; inline

: tail-as ( seq n exemplar -- seq' )
    [ tail-slice ] [ like ] bi* ; inline

: tail*-as ( seq n exemplar -- seq' )
    [ tail-slice* ] [ like ] bi* ; inline

: trim-as ( ... seq quot: ( ... elt -- ... ? ) exemplar -- ... newseq )
    [ trim-slice ] [ like ] bi* ; inline

: ?trim ( seq quot: ( elt -- ? ) -- seq/newseq )
    over empty? [ drop ] [
        over [ first-unsafe ] [ last-unsafe ] bi pick bi@ or
        [ trim ] [ drop ] if
    ] if ; inline

: ?trim-head ( seq quot: ( elt -- ? ) -- seq/newseq )
    over empty? [ drop ] [
        over first-unsafe over call
        [ trim-head ] [ drop ] if
    ] if ; inline

: ?trim-tail ( seq quot: ( elt -- ? ) -- seq/newseq )
    over empty? [ drop ] [
        over last-unsafe over call
        [ trim-tail ] [ drop ] if
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
    <enum> [ second-unsafe ] supremum-by first ;

: arg-min ( seq -- n )
    <enum> [ second-unsafe ] infimum-by first ;

<PRIVATE

: push-index-if ( ..a elt i quot: ( ..a elt -- ..b ? ) accum -- ..b )
    [ dip ] dip rot [ push ] [ 2drop ] if ; inline

PRIVATE>

: arg-where ( ... seq quot: ( ... elt -- ... ? ) -- ... indices )
    over length <vector> [
        [ push-index-if ] 2curry each-index
    ] keep ; inline

: arg-sort ( seq -- indices )
    dup length iota zip sort-keys values ;

: first= ( seq elt -- ? ) [ first ] dip = ; inline
: second= ( seq elt -- ? ) [ second ] dip = ; inline
: third= ( seq elt -- ? ) [ third ] dip = ; inline
: fourth= ( seq elt -- ? ) [ fourth ] dip = ; inline
: last= ( seq elt -- ? ) [ last ] dip = ; inline
: nth= ( n seq elt -- ? ) [ nth ] dip = ; inline

: first? ( seq quot -- ? ) [ first ] dip call ; inline
: second? ( seq quot -- ? ) [ second ] dip call ; inline
: third? ( seq quot -- ? ) [ third ] dip call ; inline
: fourth? ( seq quot -- ? ) [ fourth ] dip call ; inline
: last? ( seq quot -- ? ) [ last ] dip call ; inline
: nth? ( n seq quot -- ? ) [ nth ] dip call ; inline

: loop>sequence ( quot exemplar -- seq )
   [ '[ [ @ [ [ , ] when* ] keep ] loop ] ] dip make ; inline

: loop>array ( quot -- seq )
   { } loop>sequence ; inline

<PRIVATE

: (reverse) ( seq -- newseq )
    dup [ length ] keep new-sequence
    [ 0 swap copy-unsafe ] keep reverse! ;

PRIVATE>

: reverse-as ( seq exemplar -- newseq )
    [ (reverse) ] [ like ] bi* ;

: map-product ( ... seq quot: ( ... elt -- ... n ) -- ... n )
    [ 1 ] 2dip [ dip * ] curry [ swap ] prepose each ; inline

: insert-nth! ( elt n seq -- )
    [ length ] keep ensure swap pick (a,b]
    over '[ [ 1 + ] keep _ move-unsafe ] each
    set-nth-unsafe ;

: set-nths ( value indices seq -- )
    swapd '[ [ _ ] dip _ set-nth ] each ; inline

: set-nths-unsafe ( value indices seq -- )
    swapd '[ [ _ ] dip _ set-nth-unsafe ] each ; inline

: flatten1 ( obj -- seq )
    [
        [
            dup branch? [
                [ dup branch? [ % ] [ , ] if ] each
            ] [ , ] if
        ]
    ] keep dup branch? [ drop f ] unless make ;

<PRIVATE

: (map-find-index) ( seq quot find-quot -- result elt index )
    [ [ f ] 2dip [ [ nip ] 2dip call dup ] curry ] dip call
    [ [ [ drop f ] unless ] keep ] dip ; inline

PRIVATE>

: map-find-index ( ... seq quot: ( ... elt index -- ... result/f ) -- ... result elt index )
    [ find-index ] (map-find-index) ; inline

: filter-length ( seq n -- seq' ) '[ length _ = ] filter ;

: all-shortest ( seqs -- seqs' ) dup shortest length filter-length ;

: all-longest ( seqs -- seqs' ) dup longest length filter-length ;

: remove-first ( obj seq -- seq' )
    [ index ] keep over [ remove-nth ] [ nip ] if ;

: remove-first! ( obj seq -- seq )
    [ index ] keep over [ remove-nth! ] [ nip ] if ;
