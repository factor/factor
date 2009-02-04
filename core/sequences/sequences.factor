! Copyright (C) 2005, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private slots.private math
math.private math.order ;
IN: sequences

MIXIN: sequence

GENERIC: length ( seq -- n ) flushable
GENERIC: set-length ( n seq -- )
GENERIC: nth ( n seq -- elt ) flushable
GENERIC: set-nth ( elt n seq -- )
GENERIC: new-sequence ( len seq -- newseq ) flushable
GENERIC: new-resizable ( len seq -- newseq ) flushable
GENERIC: like ( seq exemplar -- newseq ) flushable
GENERIC: clone-like ( seq exemplar -- newseq ) flushable

: new-like ( len exemplar quot -- seq )
    over [ [ new-sequence ] dip call ] dip like ; inline

M: sequence like drop ;

GENERIC: lengthen ( n seq -- )
GENERIC: shorten ( n seq -- )

M: sequence lengthen 2dup length > [ set-length ] [ 2drop ] if ;

M: sequence shorten 2dup length < [ set-length ] [ 2drop ] if ;

: empty? ( seq -- ? ) length 0 = ; inline

: if-empty ( seq quot1 quot2 -- )
    [ dup empty? ] [ [ drop ] prepose ] [ ] tri* if ; inline

: when-empty ( seq quot -- ) [ ] if-empty ; inline

: unless-empty ( seq quot -- ) [ ] swap if-empty ; inline

: delete-all ( seq -- ) 0 swap set-length ;

: first ( seq -- first ) 0 swap nth ; inline
: second ( seq -- second ) 1 swap nth ; inline
: third ( seq -- third ) 2 swap nth ; inline
: fourth ( seq -- fourth ) 3 swap nth ; inline

: set-first ( first seq -- ) 0 swap set-nth ; inline
: set-second ( second seq -- ) 1 swap set-nth ; inline
: set-third ( third seq -- ) 2 swap set-nth ; inline
: set-fourth  ( fourth seq -- ) 3 swap set-nth ; inline

: push ( elt seq -- ) [ length ] [ set-nth ] bi ;

: bounds-check? ( n seq -- ? )
    dupd length < [ 0 >= ] [ drop f ] if ; inline

ERROR: bounds-error index seq ;

: bounds-check ( n seq -- n seq )
    2dup bounds-check? [ bounds-error ] unless ; inline

MIXIN: immutable-sequence

ERROR: immutable seq ;

M: immutable-sequence set-nth immutable ;

INSTANCE: immutable-sequence sequence

<PRIVATE

: array-nth ( n array -- elt )
    swap 2 fixnum+fast slot ; inline

: set-array-nth ( elt n array -- )
    swap 2 fixnum+fast set-slot ; inline

: dispatch ( n array -- ) array-nth call ;

GENERIC: resize ( n seq -- newseq ) flushable

! Unsafe sequence protocol for inner loops
GENERIC: nth-unsafe ( n seq -- elt ) flushable
GENERIC: set-nth-unsafe ( elt n seq -- )

M: sequence nth bounds-check nth-unsafe ;
M: sequence set-nth bounds-check set-nth-unsafe ;

M: sequence nth-unsafe nth ;
M: sequence set-nth-unsafe set-nth ;

! The f object supports the sequence protocol trivially
M: f length drop 0 ;
M: f nth-unsafe nip ;
M: f like drop [ f ] when-empty ;

INSTANCE: f immutable-sequence

! Integers support the sequence protocol
M: integer length ;
M: integer nth-unsafe drop ;

INSTANCE: integer immutable-sequence

PRIVATE>

! In the future, this will replace integer sequences
TUPLE: iota { n integer read-only } ;

: iota ( n -- iota ) \ iota boa ; inline

<PRIVATE

M: iota length n>> ;
M: iota nth-unsafe drop ;

INSTANCE: iota immutable-sequence

: first-unsafe ( seq -- first )
    0 swap nth-unsafe ; inline

: first2-unsafe ( seq -- first second )
    [ first-unsafe ] [ 1 swap nth-unsafe ] bi ; inline

: first3-unsafe ( seq -- first second third )
    [ first2-unsafe ] [ 2 swap nth-unsafe ] bi ; inline

: first4-unsafe ( seq -- first second third fourth )
    [ first3-unsafe ] [ 3 swap nth-unsafe ] bi ; inline

: exchange-unsafe ( m n seq -- )
    [ tuck [ nth-unsafe ] 2bi@ ]
    [ tuck [ set-nth-unsafe ] 2bi@ ] 3bi ; inline

: (head) ( seq n -- from to seq ) [ 0 ] 2dip swap ; inline

: (tail) ( seq n -- from to seq ) swap [ length ] keep ; inline

: from-end ( seq n -- seq n' ) [ dup length ] dip - ; inline

: (1sequence) ( obj seq -- seq )
    [ 0 swap set-nth-unsafe ] keep ; inline

: (2sequence) ( obj1 obj2 seq -- seq )
    [ 1 swap set-nth-unsafe ] keep
    (1sequence) ; inline

: (3sequence) ( obj1 obj2 obj3 seq -- seq )
    [ 2 swap set-nth-unsafe ] keep
    (2sequence) ; inline

: (4sequence) ( obj1 obj2 obj3 obj4 seq -- seq )
    [ 3 swap set-nth-unsafe ] keep
    (3sequence) ; inline

PRIVATE>

: 1sequence ( obj exemplar -- seq )
    1 swap [ (1sequence) ] new-like ; inline

: 2sequence ( obj1 obj2 exemplar -- seq )
    2 swap [ (2sequence) ] new-like ; inline

: 3sequence ( obj1 obj2 obj3 exemplar -- seq )
    3 swap [ (3sequence) ] new-like ; inline

: 4sequence ( obj1 obj2 obj3 obj4 exemplar -- seq )
    4 swap [ (4sequence) ] new-like ; inline

: first2 ( seq -- first second )
    1 swap bounds-check nip first2-unsafe ; flushable

: first3 ( seq -- first second third )
    2 swap bounds-check nip first3-unsafe ; flushable

: first4 ( seq -- first second third fourth )
    3 swap bounds-check nip first4-unsafe ; flushable

: ?nth ( n seq -- elt/f )
    2dup bounds-check? [ nth-unsafe ] [ 2drop f ] if ; flushable

MIXIN: virtual-sequence
GENERIC: virtual-seq ( seq -- seq' )
GENERIC: virtual@ ( n seq -- n' seq' )

M: virtual-sequence nth virtual@ nth ;
M: virtual-sequence set-nth virtual@ set-nth ;
M: virtual-sequence nth-unsafe virtual@ nth-unsafe ;
M: virtual-sequence set-nth-unsafe virtual@ set-nth-unsafe ;
M: virtual-sequence like virtual-seq like ;
M: virtual-sequence new-sequence virtual-seq new-sequence ;

INSTANCE: virtual-sequence sequence

! A reversal of an underlying sequence.
TUPLE: reversed { seq read-only } ;

C: <reversed> reversed

M: reversed virtual-seq seq>> ;

M: reversed virtual@ seq>> [ length swap - 1- ] keep ;

M: reversed length seq>> length ;

INSTANCE: reversed virtual-sequence

! A slice of another sequence.
TUPLE: slice
{ from read-only }
{ to read-only }
{ seq read-only } ;

: collapse-slice ( m n slice -- m' n' seq )
    [ from>> ] [ seq>> ] bi [ tuck [ + ] 2bi@ ] dip ; inline

ERROR: slice-error from to seq reason ;

: check-slice ( from to seq -- from to seq )
    pick 0 < [ "start < 0" slice-error ] when
    dup length pick < [ "end > sequence" slice-error ] when
    2over > [ "start > end" slice-error ] when ; inline

: <slice> ( from to seq -- slice )
    dup slice? [ collapse-slice ] when
    check-slice
    slice boa ; inline

M: slice virtual-seq seq>> ;

M: slice virtual@ [ from>> + ] [ seq>> ] bi ;

M: slice length [ to>> ] [ from>> ] bi - ;

: short ( seq n -- seq n' ) over length min ; inline

: head-slice ( seq n -- slice ) (head) <slice> ; inline

: tail-slice ( seq n -- slice ) (tail) <slice> ; inline

: rest-slice ( seq -- slice ) 1 tail-slice ; inline

: head-slice* ( seq n -- slice ) from-end head-slice ; inline

: tail-slice* ( seq n -- slice ) from-end tail-slice ; inline

: but-last-slice ( seq -- slice ) 1 head-slice* ; inline

INSTANCE: slice virtual-sequence

! One element repeated many times
TUPLE: repetition { len read-only } { elt read-only } ;

C: <repetition> repetition

M: repetition length len>> ;
M: repetition nth-unsafe nip elt>> ;

INSTANCE: repetition immutable-sequence

<PRIVATE

: check-length ( n -- n )
    #! Ricing.
    dup integer? [ "length not an integer" throw ] unless ; inline

: ((copy)) ( dst i src j n -- dst i src j n )
    dup -roll [
        + swap nth-unsafe -roll [
            + swap set-nth-unsafe
        ] 3keep drop
    ] 3keep ; inline

: (copy) ( dst i src j n -- dst )
    dup 0 <= [ 2drop 2drop ] [ 1- ((copy)) (copy) ] if ;
    inline recursive

: prepare-subseq ( from to seq -- dst i src j n )
    #! The check-length call forces partial dispatch
    [ [ swap - ] dip new-sequence dup 0 ] 3keep
    -rot drop roll length check-length ; inline

: check-copy ( src n dst -- )
    over 0 < [ bounds-error ] when
    [ swap length + ] dip lengthen ; inline

PRIVATE>

: subseq ( from to seq -- subseq )
    [ check-slice prepare-subseq (copy) ] [ like ] bi ;

: head ( seq n -- headseq ) (head) subseq ;

: tail ( seq n -- tailseq ) (tail) subseq ;

: rest ( seq -- tailseq ) 1 tail ;

: head* ( seq n -- headseq ) from-end head ;

: tail* ( seq n -- tailseq ) from-end tail ;

: but-last ( seq -- headseq ) 1 head* ;

: copy ( src i dst -- )
    #! The check-length call forces partial dispatch
    pick length check-length [ 3dup check-copy spin 0 ] dip
    (copy) drop ; inline

M: sequence clone-like
    [ dup length ] dip new-sequence [ 0 swap copy ] keep ;

M: immutable-sequence clone-like like ;

: push-all ( src dest -- ) [ length ] [ copy ] bi ;

<PRIVATE

: (append) ( seq1 seq2 accum -- accum )
    [ [ over length ] dip copy ]
    [ 0 swap copy ]
    [ ] tri ; inline

PRIVATE>

: append-as ( seq1 seq2 exemplar -- newseq )
    [ over length over length + ] dip
    [ (append) ] new-like ; inline

: 3append-as ( seq1 seq2 seq3 exemplar -- newseq )
    [ pick length pick length pick length + + ] dip [
        [ [ pick length pick length + ] dip copy ]
        [ (append) ] bi
    ] new-like ; inline

: append ( seq1 seq2 -- newseq ) over append-as ;

: prepend ( seq1 seq2 -- newseq ) swap append ; inline

: 3append ( seq1 seq2 seq3 -- newseq ) pick 3append-as ;

: surround ( seq1 seq2 seq3 -- newseq ) swapd 3append ; inline

: glue ( seq1 seq2 seq3 -- newseq ) swap 3append ; inline

: change-nth ( i seq quot -- )
    [ [ nth ] dip call ] 3keep drop set-nth ; inline

: min-length ( seq1 seq2 -- n ) [ length ] bi@ min ; inline

: max-length ( seq1 seq2 -- n ) [ length ] bi@ max ; inline

<PRIVATE

: (each) ( seq quot -- n quot' )
    [ [ length ] keep [ nth-unsafe ] curry ] dip compose ; inline

: (collect) ( quot into -- quot' )
    [ [ keep ] dip set-nth-unsafe ] 2curry ; inline

: collect ( n quot into -- )
    (collect) each-integer ; inline

: map-into ( seq quot into -- )
    [ (each) ] dip collect ; inline

: 2nth-unsafe ( n seq1 seq2 -- elt1 elt2 )
    [ over ] dip [ nth-unsafe ] 2bi@ ; inline

: (2each) ( seq1 seq2 quot -- n quot' )
    [
        [ min-length ] 2keep
        [ 2nth-unsafe ] 2curry
    ] dip compose ; inline

: 3nth-unsafe ( n seq1 seq2 seq3 -- elt1 elt2 elt3 )
    [ over ] 2dip [ over ] dip [ nth-unsafe ] 2tri@ ; inline

: (3each) ( seq1 seq2 seq3 quot -- n quot' )
    [
        [ [ length ] tri@ min min ] 3keep
        [ 3nth-unsafe ] 3curry
    ] dip compose ; inline

: finish-find ( i seq -- i elt )
    over [ dupd nth-unsafe ] [ drop f ] if ; inline

: (find) ( seq quot quot' -- i elt )
    pick [ [ (each) ] dip call ] dip finish-find ; inline

: (find-from) ( n seq quot quot' -- i elt )
    [ 2dup bounds-check? ] 2dip
    [ (find) ] 2curry
    [ 2drop f f ]
    if ; inline

: (interleave) ( n elt between quot -- )
    roll 0 = [ nip ] [ swapd 2slip ] if call ; inline

PRIVATE>

: each ( seq quot -- )
    (each) each-integer ; inline

: reduce ( seq identity quot -- result )
    swapd each ; inline

: map-as ( seq quot exemplar -- newseq )
    [ over length ] dip [ [ map-into ] keep ] new-like ; inline

: map ( seq quot -- newseq )
    over map-as ; inline

: replicate ( seq quot -- newseq )
    [ drop ] prepose map ; inline

: replicate-as ( seq quot exemplar -- newseq )
    [ [ drop ] prepose ] dip map-as ; inline

: change-each ( seq quot -- )
    over map-into ; inline

: accumulate ( seq identity quot -- final newseq )
    swapd [ pick slip ] curry map ; inline

: 2each ( seq1 seq2 quot -- )
    (2each) each-integer ; inline

: 2reverse-each ( seq1 seq2 quot -- )
    [ [ <reversed> ] bi@ ] dip 2each ; inline

: 2reduce ( seq1 seq2 identity quot -- result )
    [ -rot ] dip 2each ; inline

: 2map-as ( seq1 seq2 quot exemplar -- newseq )
    [ (2each) ] dip map-as ; inline

: 2map ( seq1 seq2 quot -- newseq )
    pick 2map-as ; inline

: 2all? ( seq1 seq2 quot -- ? )
    (2each) all-integers? ; inline

: 3each ( seq1 seq2 seq3 quot -- )
    (3each) each ; inline

: 3map-as ( seq1 seq2 seq3 quot exemplar -- newseq )
    [ (3each) ] dip map-as ; inline

: 3map ( seq1 seq2 seq3 quot -- newseq )
    [ pick ] dip swap 3map-as ; inline

: find-from ( n seq quot -- i elt )
    [ (find-integer) ] (find-from) ; inline

: find ( seq quot -- i elt )
    [ find-integer ] (find) ; inline

: find-last-from ( n seq quot -- i elt )
    [ nip find-last-integer ] (find-from) ; inline

: find-last ( seq quot -- i elt )
    [ [ 1- ] dip find-last-integer ] (find) ; inline

: all? ( seq quot -- ? )
    (each) all-integers? ; inline

: push-if ( elt quot accum -- )
    [ keep ] dip rot [ push ] [ 2drop ] if ; inline

: pusher ( quot -- quot accum )
    V{ } clone [ [ push-if ] 2curry ] keep ; inline

: filter ( seq quot -- subseq )
    over [ pusher [ each ] dip ] dip like ; inline

: push-either ( elt quot accum1 accum2 -- )
    [ keep swap ] 2dip ? push ; inline

: 2pusher ( quot -- quot accum1 accum2 )
    V{ } clone V{ } clone [ [ push-either ] 3curry ] 2keep ; inline

: partition ( seq quot -- trueseq falseseq )
    over [ 2pusher [ each ] 2dip ] dip tuck [ like ] 2bi@ ; inline

: interleave ( seq between quot -- )
    [ (interleave) ] 2curry [ [ length ] keep ] dip 2each ; inline

: accumulator ( quot -- quot' vec )
    V{ } clone [ [ push ] curry compose ] keep ; inline

: produce-as ( pred quot tail exemplar -- seq )
    [ swap accumulator [ swap while ] dip ] dip like ; inline

: produce ( pred quot tail -- seq )
    { } produce-as ; inline

: follow ( obj quot -- seq )
    [ dup ] swap [ keep ] curry [ ] produce nip ; inline

: prepare-index ( seq quot -- seq n quot )
    [ dup length ] dip ; inline

: each-index ( seq quot -- )
    prepare-index 2each ; inline

: map-index ( seq quot -- )
    prepare-index 2map ; inline

: reduce-index ( seq identity quot -- )
    swapd each-index ; inline

: index ( obj seq -- n )
    [ = ] with find drop ;

: index-from ( obj i seq -- n )
    rot [ = ] curry find-from drop ;

: last-index ( obj seq -- n )
    [ = ] with find-last drop ;

: last-index-from ( obj i seq -- n )
    rot [ = ] curry find-last-from drop ;

: (indices) ( elt i obj accum -- )
    [ swap [ = ] dip ] dip [ push ] 2curry when ; inline

: indices ( obj seq -- indices )
    swap V{ } clone
    [ [ (indices) ] 2curry each-index ] keep ;

: nths ( indices seq -- seq' )
    [ nth ] curry map ;

: any? ( seq quot -- ? )
    find drop >boolean ; inline

: member? ( elt seq -- ? )
    [ = ] with any? ;

: memq? ( elt seq -- ? )
    [ eq? ] with any? ;

: remove ( elt seq -- newseq )
    [ = not ] with filter ;

: remq ( elt seq -- newseq )
    [ eq? not ] with filter ;

: sift ( seq -- newseq )
    [ ] filter ;

: harvest ( seq -- newseq )
    [ empty? not ] filter ;

: mismatch ( seq1 seq2 -- i )
    [ min-length ] 2keep
    [ 2nth-unsafe = not ] 2curry
    find drop ; inline

M: sequence <=>
    2dup mismatch
    [ -rot 2nth-unsafe <=> ] [ [ length ] compare ] if* ;

: sequence= ( seq1 seq2 -- ? )
    2dup [ length ] bi@ =
    [ mismatch not ] [ 2drop f ] if ; inline

: sequence-hashcode-step ( oldhash newpart -- newhash )
    >fixnum swap [
        [ -2 fixnum-shift-fast ] [ 5 fixnum-shift-fast ] bi
        fixnum+fast fixnum+fast
    ] keep fixnum-bitxor ; inline

: sequence-hashcode ( n seq -- x )
    [ 0 ] 2dip [ hashcode* sequence-hashcode-step ] with each ; inline

M: reversed equal? over reversed? [ sequence= ] [ 2drop f ] if ;

M: slice equal? over slice? [ sequence= ] [ 2drop f ] if ;

: move ( to from seq -- )
    2over =
    [ 3drop ] [ [ nth swap ] [ set-nth ] bi ] if ; inline

<PRIVATE

: (filter-here) ( quot: ( elt -- ? ) store scan seq -- )
    2dup length < [
        [ move ] 3keep
        [ nth-unsafe pick call [ 1+ ] when ] 2keep
        [ 1+ ] dip
        (filter-here)
    ] [ nip set-length drop ] if ; inline recursive

PRIVATE>

: filter-here ( seq quot -- )
    swap [ 0 0 ] dip (filter-here) ; inline

: delete ( elt seq -- )
    [ = not ] with filter-here ;

: delq ( elt seq -- )
    [ eq? not ] with filter-here ;

: prefix ( seq elt -- newseq )
    over [ over length 1+ ] dip [
        [ 0 swap set-nth-unsafe ] keep
        [ 1 swap copy ] keep
    ] new-like ;

: suffix ( seq elt -- newseq )
    over [ over length 1+ ] dip [
        [ [ over length ] dip set-nth-unsafe ] keep
        [ 0 swap copy ] keep
    ] new-like ;

: peek ( seq -- elt ) [ length 1- ] [ nth ] bi ;

: pop* ( seq -- ) [ length 1- ] [ shorten ] bi ;

<PRIVATE

: move-backward ( shift from to seq -- )
    2over = [
        2drop 2drop
    ] [
        [ [ 2over + pick ] dip move [ 1+ ] dip ] keep
        move-backward
    ] if ;

: move-forward ( shift from to seq -- )
    2over = [
        2drop 2drop
    ] [
        [ [ pick [ dup dup ] dip + swap ] dip move 1- ] keep
        move-forward
    ] if ;

: (open-slice) ( shift from to seq ? -- )
    [
        [ [ 1- ] bi@ ] dip move-forward
    ] [
        [ over - ] 2dip move-backward
    ] if ;

PRIVATE>

: open-slice ( shift from seq -- )
    pick 0 = [
        3drop
    ] [
        pick over length + over
        [ pick 0 > [ [ length ] keep ] dip (open-slice) ] 2dip
        set-length
    ] if ;

: delete-slice ( from to seq -- )
    check-slice [ over [ - ] dip ] dip open-slice ;

: delete-nth ( n seq -- )
    [ dup 1+ ] dip delete-slice ;

: replace-slice ( new from to seq -- )
    [ [ [ dup pick length + ] dip - over ] dip open-slice ] keep
    copy ;

: remove-nth ( n seq -- seq' )
    [ swap head-slice ] [ swap 1+ tail-slice ] 2bi append ;

: pop ( seq -- elt )
    [ length 1- ] [ [ nth ] [ shorten ] 2bi ] bi ;

: exchange ( m n seq -- )
    pick over bounds-check 2drop 2dup bounds-check 2drop
    exchange-unsafe ;

: reverse-here ( seq -- )
    dup length dup 2/ [
        [ 2dup ] dip
        tuck - 1- rot exchange-unsafe
    ] each 2drop ;

: reverse ( seq -- newseq )
    [
        dup [ length ] keep new-sequence
        [ 0 swap copy ] keep
        [ reverse-here ] keep
    ] keep like ;

: sum-lengths ( seq -- n )
    0 [ length + ] reduce ;

: concat ( seq -- newseq )
    [ { } ] [
        [ sum-lengths ] keep
        [ first new-resizable ] keep
        [ [ over push-all ] each ] keep
        first like
    ] if-empty ;

<PRIVATE

: joined-length ( seq glue -- n )
    [ [ sum-lengths ] [ length 1 [-] ] bi ] dip length * + ;

PRIVATE>

: join ( seq glue -- newseq )
    [
        2dup joined-length over new-resizable spin
        [ dup pick push-all ] [ pick push-all ] interleave drop
    ] keep like ;

: padding ( seq n elt quot -- newseq )
    [
        [ over length [-] dup 0 = [ drop ] ] dip
        [ <repetition> ] curry
    ] dip compose if ; inline

: pad-head ( seq n elt -- padded )
    [ swap dup append-as ] padding ;

: pad-tail ( seq n elt -- padded )
    [ append ] padding ;

: shorter? ( seq1 seq2 -- ? ) [ length ] bi@ < ;

: head? ( seq begin -- ? )
    2dup shorter? [
        2drop f
    ] [
        [ nip ] [ length head-slice ] 2bi sequence=
    ] if ;

: tail? ( seq end -- ? )
    2dup shorter? [
        2drop f
    ] [
        [ nip ] [ length tail-slice* ] 2bi sequence=
    ] if ;

: cut-slice ( seq n -- before-slice after-slice )
    [ head-slice ] [ tail-slice ] 2bi ;

: insert-nth ( elt n seq -- seq' )
    swap cut-slice [ swap suffix ] dip append ;

: midpoint@ ( seq -- n ) length 2/ ; inline

: halves ( seq -- first-slice second-slice )
    dup midpoint@ cut-slice ;

: binary-reduce ( seq start quot: ( elt1 elt2 -- newelt ) -- value )
    #! We can't use case here since combinators depends on
    #! sequences
    pick length dup 0 3 between? [
        >fixnum {
            [ drop nip ]
            [ 2drop first ]
            [ [ drop first2 ] dip call ]
            [ [ drop first3 ] dip bi@ ]
        } dispatch
    ] [
        drop
        [ halves ] 2dip
        [ [ binary-reduce ] 2curry bi@ ] keep
        call
    ] if ; inline recursive

: cut ( seq n -- before after )
    [ head ] [ tail ] 2bi ;

: cut* ( seq n -- before after )
    [ head* ] [ tail* ] 2bi ;

<PRIVATE

: (start) ( subseq seq n -- subseq seq ? )
    pick length [
        [ 3dup ] dip [ + swap nth-unsafe ] keep rot nth-unsafe =
    ] all? nip ; inline

PRIVATE>

: start* ( subseq seq n -- i )
    pick length pick length swap - 1+
    [ (start) ] find-from
    swap [ 3drop ] dip ;

: start ( subseq seq -- i ) 0 start* ; inline

: subseq? ( subseq seq -- ? ) start >boolean ;

: drop-prefix ( seq1 seq2 -- slice1 slice2 )
    2dup mismatch [ 2dup min-length ] unless*
    tuck [ tail-slice ] 2bi@ ;

: unclip ( seq -- rest first )
    [ rest ] [ first-unsafe ] bi ;

: unclip-last ( seq -- butlast last )
    [ but-last ] [ peek ] bi ;

: unclip-slice ( seq -- rest-slice first )
    [ rest-slice ] [ first-unsafe ] bi ; inline

: 2unclip-slice ( seq1 seq2 -- rest-slice1 rest-slice2 first1 first2 )
    [ unclip-slice ] bi@ swapd ; inline

: map-reduce ( seq map-quot reduce-quot -- result )
    [ [ unclip-slice ] dip [ call ] keep ] dip
    compose reduce ; inline

: 2map-reduce ( seq1 seq2 map-quot reduce-quot -- result )
    [ [ 2unclip-slice ] dip [ call ] keep ] dip
    compose 2reduce ; inline

: unclip-last-slice ( seq -- butlast-slice last )
    [ but-last-slice ] [ peek ] bi ; inline

: <flat-slice> ( seq -- slice )
    dup slice? [ { } like ] when 0 over length rot <slice> ;
    inline

: trim-head-slice ( seq quot -- slice )
    over [ [ not ] compose find drop ] dip swap
    [ tail-slice ] [ dup length tail-slice ] if* ; inline
    
: trim-head ( seq quot -- newseq )
    over [ trim-head-slice ] dip like ; inline

: trim-tail-slice ( seq quot -- slice )
    over [ [ not ] compose find-last drop ] dip swap
    [ 1+ head-slice ] [ 0 head-slice ] if* ; inline

: trim-tail ( seq quot -- newseq )
    over [ trim-tail-slice ] dip like ; inline

: trim-slice ( seq quot -- slice )
    [ trim-head-slice ] [ trim-tail-slice ] bi ; inline

: trim ( seq quot -- newseq )
    over [ trim-slice ] dip like ; inline

: sum ( seq -- n ) 0 [ + ] binary-reduce ;

: product ( seq -- n ) 1 [ * ] binary-reduce ;

: infimum ( seq -- n ) dup first [ min ] reduce ;

: supremum ( seq -- n ) dup first [ max ] reduce ;

: sigma ( seq quot -- n ) [ 0 ] 2dip [ rot slip + ] curry each ; inline

: count ( seq quot -- n ) [ 1 0 ? ] compose sigma ; inline

! We hand-optimize flip to such a degree because type hints
! cannot express that an array is an array of arrays yet, and
! this word happens to be performance-critical since the compiler
! itself uses it. Optimizing it like this reduced compile time.
<PRIVATE

: generic-flip ( matrix -- newmatrix )
    [ dup first length [ length min ] reduce ] keep
    [ [ nth-unsafe ] with { } map-as ] curry { } map-as ; inline

USE: arrays

: array-length ( array -- len )
    { array } declare length>> ; inline

: array-flip ( matrix -- newmatrix )
    { array } declare
    [ dup first array-length [ array-length min ] reduce ] keep
    [ [ array-nth ] with { } map-as ] curry { } map-as ;

PRIVATE>

: flip ( matrix -- newmatrix )
    dup empty? [
        dup array? [
            dup [ array? ] all?
            [ array-flip ] [ generic-flip ] if
        ] [ generic-flip ] if
    ] unless ;
