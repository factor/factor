! Copyright (C) 2005, 2011 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel kernel.private math math.order
math.private slots.private ;
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

: lengthd ( seq obj -- n obj ) [ length ] dip ; inline

: new-sequence-like ( len-exemplar type-exemplar -- newseq )
    lengthd new-sequence ; inline

: new-resizable-like ( len-exemplar type-exemplar -- newseq )
    lengthd new-resizable ; inline

: new-like ( len exemplar quot -- seq )
    over [ [ new-sequence ] dip call ] dip like ; inline

M: sequence like drop ; inline

GENERIC: lengthen ( n seq -- )
GENERIC: shorten ( n seq -- )

M: sequence lengthen 2dup length > [ set-length ] [ 2drop ] if ; inline
M: sequence shorten 2dup length < [ set-length ] [ 2drop ] if ; inline

: 2length ( seq1 seq2 -- n1 n2 ) [ length ] bi@ ; inline
: 3length ( seq1 seq2 seq3 -- n1 n2 n3 ) [ length ] tri@ ; inline

: empty? ( seq -- ? ) length 0 = ; inline

: if-empty ( ..a seq quot1: ( ..a -- ..b ) quot2: ( ..a seq -- ..b ) -- ..b )
    [ dup empty? ] [ [ drop ] prepose ] [ ] tri* if ; inline

: when-empty ( ... seq quot: ( ... -- ... obj ) -- ... seq/obj ) [ ] if-empty ; inline
: unless-empty ( ... seq quot: ( ... seq -- ... ) -- ... ) [ ] swap if-empty ; inline

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

ERROR: bounds-error index seq ;

GENERIC#: bounds-check? 1 ( n seq -- ? )

M: integer bounds-check?
    dupd length < [ 0 >= ] [ drop f ] if ; inline

: bounds-check ( n seq -- n seq )
    2dup bounds-check? [ bounds-error ] unless ; inline

MIXIN: immutable-sequence

ERROR: immutable element index sequence ;

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

M: sequence nth bounds-check nth-unsafe ; inline
M: sequence set-nth bounds-check set-nth-unsafe ; inline

M: sequence nth-unsafe nth ; inline
M: sequence set-nth-unsafe set-nth ; inline

PRIVATE>

! The f object supports the sequence protocol trivially
M: f length drop 0 ; inline
M: f nth-unsafe nip ; inline
M: f like drop [ f ] when-empty ; inline

INSTANCE: f immutable-sequence

! Integer sequences
TUPLE: iota { n integer read-only } ;

: <iota> ( n -- iota )
    assert-non-negative iota boa ; inline

M: iota length n>> ; inline
M: iota nth-unsafe drop ; inline

INSTANCE: iota immutable-sequence

<PRIVATE

: first-unsafe ( seq -- first ) 0 swap nth-unsafe ; inline
: second-unsafe ( seq -- second ) 1 swap nth-unsafe ; inline
: third-unsafe ( seq -- third ) 2 swap nth-unsafe ; inline
: fourth-unsafe ( seq -- fourth ) 3 swap nth-unsafe ; inline

: first2-unsafe ( seq -- first second )
    [ first-unsafe ] [ second-unsafe ] bi ; inline

: first3-unsafe ( seq -- first second third )
    [ first2-unsafe ] [ third-unsafe ] bi ; inline

: first4-unsafe ( seq -- first second third fourth )
    [ first3-unsafe ] [ fourth-unsafe ] bi ; inline

: exchange-unsafe ( m n seq -- )
    [ [ nth-unsafe ] curry bi@ ]
    [ [ set-nth-unsafe ] curry bi@ ] 3bi ; inline

: (1sequence) ( obj seq -- seq )
    [ 0 swap set-nth-unsafe ] keep ; inline

: (2sequence) ( obj1 obj2 seq -- seq )
    [ 1 swap set-nth-unsafe ] keep (1sequence) ; inline

: (3sequence) ( obj1 obj2 obj3 seq -- seq )
    [ 2 swap set-nth-unsafe ] keep (2sequence) ; inline

: (4sequence) ( obj1 obj2 obj3 obj4 seq -- seq )
    [ 3 swap set-nth-unsafe ] keep (3sequence) ; inline

: head-to-index ( seq to -- zero to seq ) [ 0 ] 2dip swap ; inline

: index-to-tail ( seq from -- from length seq ) swap [ length ] keep ; inline

PRIVATE>

: from-tail ( seq n -- seq n' ) [ dup length ] dip - ; inline

: 1sequence ( obj exemplar -- seq )
    1 swap [ (1sequence) ] new-like ; inline

: 2sequence ( obj1 obj2 exemplar -- seq )
    2 swap [ (2sequence) ] new-like ; inline

: 3sequence ( obj1 obj2 obj3 exemplar -- seq )
    3 swap [ (3sequence) ] new-like ; inline

: 4sequence ( obj1 obj2 obj3 obj4 exemplar -- seq )
    4 swap [ (4sequence) ] new-like ; inline

: first2 ( seq -- first second )
    1 swap bounds-check nip first2-unsafe ; inline

: first3 ( seq -- first second third )
    2 swap bounds-check nip first3-unsafe ; inline

: first4 ( seq -- first second third fourth )
    3 swap bounds-check nip first4-unsafe ; inline

: ?nth ( n seq -- elt/f )
    2dup bounds-check? [ nth-unsafe ] [ 2drop f ] if ; inline

: ?set-nth ( elt n seq -- )
    2dup bounds-check? [ set-nth-unsafe ] [ 3drop ] if ; inline

: index-or-length ( seq n -- seq n' ) over length min ; inline

: index-of-last ( seq -- n seq ) [ length 1 - ] keep ; inline

: ?first ( seq -- elt/f ) 0 swap ?nth ; inline
: ?second ( seq -- elt/f ) 1 swap ?nth ; inline
: ?last ( seq -- elt/f )
    index-of-last over 0 <
    [ 2drop f ] [ nth-unsafe ] if ; inline

MIXIN: virtual-sequence
GENERIC: virtual-exemplar ( seq -- seq' )
GENERIC: virtual@ ( n seq -- n' seq' )

M: virtual-sequence nth virtual@ nth ; inline
M: virtual-sequence set-nth virtual@ set-nth ; inline
M: virtual-sequence nth-unsafe virtual@ nth-unsafe ; inline
M: virtual-sequence set-nth-unsafe virtual@ set-nth-unsafe ; inline
M: virtual-sequence like virtual-exemplar like ; inline
M: virtual-sequence new-sequence virtual-exemplar new-sequence ; inline

INSTANCE: virtual-sequence sequence

! A reversal of an underlying sequence.
TUPLE: reversed { seq read-only } ;

C: <reversed> reversed

M: reversed virtual-exemplar seq>> ; inline
M: reversed virtual@ seq>> [ length swap - 1 - ] keep ; inline
M: reversed length seq>> length ; inline

INSTANCE: reversed virtual-sequence

! A slice of another sequence.
TUPLE: slice
    { from integer read-only }
    { to integer read-only }
    { seq read-only } ;

: >slice< ( slice -- from to seq )
    [ from>> ] [ to>> ] [ seq>> ] tri ; inline

: collapse-slice ( m n slice -- m' n' seq )
    [ from>> ] [ seq>> ] bi [ [ + ] curry bi@ ] dip ; inline

ERROR: slice-error from to seq ;

: check-slice ( from to seq -- from to seq )
    pick 0 < [ slice-error ] when
    2dup length > [ slice-error ] when
    2over > [ slice-error ] when ; inline

<PRIVATE

: <slice-unsafe> ( from to seq -- slice )
    dup slice? [ collapse-slice ] when slice boa ; inline

PRIVATE>

: <slice> ( from to seq -- slice )
    check-slice <slice-unsafe> ; inline

M: slice virtual-exemplar seq>> ; inline

M: slice virtual@ [ from>> + ] [ seq>> ] bi ; inline

M: slice length [ to>> ] [ from>> ] bi - ; inline

: head-slice ( seq n -- slice ) head-to-index <slice> ; inline

: tail-slice ( seq n -- slice ) index-to-tail <slice> ; inline

: rest-slice ( seq -- slice ) 1 tail-slice ; inline

: head-slice* ( seq n -- slice ) from-tail head-slice ; inline

: tail-slice* ( seq n -- slice ) from-tail tail-slice ; inline

: but-last-slice ( seq -- slice ) 1 head-slice* ; inline

INSTANCE: slice virtual-sequence

! One element repeated many times
TUPLE: repetition
    { length integer read-only }
    { elt read-only } ;

: <repetition> ( len elt -- repetition )
    over 0 < [ non-negative-number-expected ] when
    repetition boa ; inline

M: repetition length length>> ; inline
M: repetition nth-unsafe nip elt>> ; inline

INSTANCE: repetition immutable-sequence

<PRIVATE

ERROR: integer-length-expected obj ;

! The check-length call forces partial dispatch
: check-length ( n -- n )
    dup integer? [ integer-length-expected ] unless ; inline

: >sequence< ( seq -- i n seq )
    [ drop 0 ] [ length check-length ] [ ] tri ; inline

: length-sequence ( seq -- n seq )
    [ length check-length ] [ ] bi ; inline

: >underlying< ( slice/seq -- from to slice/seq )
    dup slice? [ >slice< ] [ >sequence< ] if ; inline

TUPLE: copier
    { src-i integer read-only }
    { src read-only }
    { dst-i integer read-only }
    { dst read-only } ;

C: <copier> copier

: copy-nth-unsafe ( n copy -- )
    [ [ src-i>> + ] [ src>> ] bi nth-unsafe ]
    [ [ dst-i>> + ] [ dst>> ] bi set-nth-unsafe ] 2bi ; inline

: (copy) ( n copy -- dst )
    over 0 <= [ nip dst>> ] [
        [ 1 - ] dip [ copy-nth-unsafe ] [ (copy) ] 2bi
    ] if ; inline recursive

: subseq>copy ( from to seq -- n copy )
    [ over - check-length swap ] dip
    3dup nip new-sequence 0 swap <copier> ; inline

: bounds-check-head ( n seq -- n seq )
    over 0 < [ bounds-error ] when ; inline

: copy-unsafe ( src i dst -- )
    [ [ length check-length 0 ] keep ] 2dip <copier> (copy) drop ; inline

: subseq-unsafe-as ( from to seq exemplar -- subseq )
    [ subseq>copy (copy) ] dip like ; inline

: subseq-unsafe ( from to seq -- subseq )
    dup subseq-unsafe-as ; inline

: change-nth-unsafe ( i seq quot -- )
    [ [ nth-unsafe ] dip call ] 2keepd set-nth-unsafe ; inline

: nth-of-unsafe ( seq n -- elt ) swap nth-unsafe ; inline

: set-nth-of-unsafe ( seq n elt -- seq ) swap pick set-nth-unsafe ; inline

: copy-nth-of-unsafe ( dst dst-i src src-i -- )
    nth-of-unsafe set-nth-of-unsafe drop ; inline

: copy-loop ( dst dst-i src src-i src-stop -- dst )
    2dup >= [
        4drop
    ] [
        [
            [ copy-nth-of-unsafe ] 4keep
            [ 1 + ] 2dip 1 +
        ] dip copy-loop
    ] if ; inline recursive

PRIVATE>

: subseq-as ( from to seq exemplar -- subseq )
    [ check-slice ] dip subseq-unsafe-as ;

: subseq ( from to seq -- subseq )
    dup subseq-as ;

: head ( seq n -- headseq ) head-to-index subseq ;

: tail ( seq n -- tailseq ) index-to-tail subseq ;

: rest ( seq -- tailseq ) 1 tail ;

: head* ( seq n -- headseq ) from-tail head ;

: tail* ( seq n -- tailseq ) from-tail tail ;

: but-last ( seq -- headseq ) 1 head* ;

: copy ( src i dst -- )
    3dup bounds-check-head
    [ swap length + ] dip lengthen
    copy-unsafe ; inline

M: sequence clone-like
    dupd new-sequence-like [ 0 swap copy-unsafe ] keep ; inline

M: immutable-sequence clone-like like ; inline

: push-all ( src dst -- ) [ length ] [ copy ] bi ; inline

<PRIVATE

: (append) ( seq1 seq2 accum -- accum )
    [ [ over length ] dip copy-unsafe ]
    [ 0 swap copy-unsafe ]
    [ ] tri ; inline

PRIVATE>

: append-as ( seq1 seq2 exemplar -- newseq )
    [ 2dup 2length + ] dip
    [ (append) ] new-like ; inline

: append ( seq1 seq2 -- newseq ) over append-as ;

: prepend-as ( seq1 seq2 exemplar -- newseq ) swapd append-as ; inline

: prepend ( seq1 seq2 -- newseq ) over prepend-as ;

: 3append-as ( seq1 seq2 seq3 exemplar -- newseq )
    [ 3dup 3length + + ] dip [
        [ [ 2over 2length + ] dip copy-unsafe ]
        [ (append) ] bi
    ] new-like ; inline

: 3append ( seq1 seq2 seq3 -- newseq ) pick 3append-as ;

: surround-as ( seq1 seq2 seq3 exemplar -- newseq )
    [ swap ] 2dip 3append-as ; inline

: surround ( seq1 seq2 seq3 -- newseq ) over surround-as ; inline

: 1surround-as ( seq1 seq2 exemplar  -- newseq ) dupd surround-as ; inline

: 1surround ( seq1 seq2 -- newseq ) dup 1surround-as ; inline

: glue-as ( seq1 seq2 seq3 exemplar -- newseq ) swapd 3append-as ; inline

: glue ( seq1 seq2 seq3 -- newseq ) pick glue-as ; inline

: change-nth ( ..a i seq quot: ( ..a elt -- ..b newelt ) -- ..b )
    [ [ nth ] dip call ] 2keepd set-nth-unsafe ; inline

: min-length ( seq1 seq2 -- n ) 2length min ; inline

: max-length ( seq1 seq2 -- n ) 2length max ; inline

<PRIVATE

: sequence-operator ( seq quot -- i n quot' )
    [ >underlying< [ nth-unsafe ] curry ] dip compose ; inline

: length-iterator ( seq -- n quot' )
    length-sequence [ nth-unsafe ] curry ; inline

: length-operator ( seq quot -- n quot' )
    [ length-iterator ] dip compose ; inline

: collect-into ( quot into -- quot' )
    [ [ keep ] dip set-nth-unsafe ] 2curry ; inline

: collect-from ( i n quot into -- )
    collect-into each-integer-from ; inline

: collect ( n quot into -- )
    collect-into each-integer ; inline

: sequence-index-operator ( seq quot -- n quot' )
    [ length-iterator [ keep ] curry ] dip compose ; inline

: map-into ( seq quot into -- )
    [ length-operator ] dip collect ; inline

: 2nth-unsafe ( n seq1 seq2 -- elt1 elt2 )
    [ nth-unsafe ] bi-curry@ bi ; inline

: 2length-iterator ( seq1 seq2 -- n quot )
    [ min-length check-length ] 2keep [ 2nth-unsafe ] 2curry ; inline

: 2length-operator ( seq1 seq2 quot -- n quot' )
    [ 2length-iterator ] dip compose ; inline

: 3nth-unsafe ( n seq1 seq2 seq3 -- elt1 elt2 elt3 )
    [ nth-unsafe ] tri-curry@ tri ; inline

: 3length-iterator ( seq1 seq2 seq3 -- n quot )
    [ 3length min min check-length ]
    [ [ 3nth-unsafe ] 3curry ] 3bi ; inline

: 3length-operator ( seq1 seq2 seq3 quot -- n quot' )
    [ 3length-iterator ] dip compose ; inline

: element/index ( i/f seq -- elt/f i/f )
    '[ [ _ nth ] [ f ] if* ] keep ; inline

: index/element ( i/f seq -- i/f elt/f )
    dupd '[ _ nth ] [ f ] if* ; inline

: (accumulate) ( seq identity quot -- identity seq quot' )
    swapd [ keepd ] curry ; inline

: (accumulate*) ( seq identity quot -- identity seq quot' )
    swapd [ dup ] compose ; inline

PRIVATE>

: each ( ... seq quot: ( ... x -- ... ) -- ... )
    sequence-operator each-integer-from ; inline

: each-from ( ... seq quot: ( ... x -- ... ) i -- ... )
    -rot length-operator each-integer-from ; inline

: reduce ( ... seq identity quot: ( ... prev elt -- ... next ) -- ... result )
    swapd each ; inline

: map-integers-from-as ( ... from len quot: ( ... i -- ... elt ) exemplar -- ... newseq )
    overd [ [ collect-from ] keep ] new-like ; inline

: map-integers-as ( ... len quot: ( ... i -- ... elt ) exemplar -- ... newseq )
    overd [ [ collect ] keep ] new-like ; inline

: map-integers ( ... len quot: ( ... i -- ... elt ) -- ... newseq )
    { } map-integers-as ; inline

: map-as ( ... seq quot: ( ... elt -- ... newelt ) exemplar -- ... newseq )
    [ length-operator ] dip map-integers-as ; inline

: map ( ... seq quot: ( ... elt -- ... newelt ) -- ... newseq )
    over map-as ; inline

: replicate-as ( ... len quot: ( ... -- ... newelt ) exemplar -- ... newseq )
    [ [ drop ] prepose ] dip map-integers-as ; inline

: replicate ( ... len quot: ( ... -- ... newelt ) -- ... newseq )
    { } replicate-as ; inline

: map! ( ... seq quot: ( ... elt -- ... newelt ) -- ... seq )
    over [ map-into ] keep ; inline

: accumulate-as ( ... seq identity quot: ( ... prev elt -- ... next ) exemplar -- ... final newseq )
    [ (accumulate) ] dip map-as ; inline

: accumulate ( ... seq identity quot: ( ... prev elt -- ... next ) -- ... final newseq )
    pick accumulate-as ; inline

: accumulate! ( ... seq identity quot: ( ... prev elt -- ... next ) -- ... final seq )
    (accumulate) map! ; inline

: accumulate*-as ( ... seq identity quot: ( ... prev elt -- ... next ) exemplar -- ... newseq )
    [ (accumulate*) ] dip map-as nip ; inline

: accumulate* ( ... seq identity quot: ( ... prev elt -- ... next ) -- ... newseq )
    pick accumulate*-as ; inline

: accumulate*! ( ... seq identity quot: ( ... prev elt -- ... next ) -- ... seq )
    (accumulate*) map! nip ; inline

: 2each ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ) -- ... )
    2length-operator each-integer ; inline

: 2each-from ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ) from -- ... )
    -roll 2length-operator each-integer-from ; inline

: 2reduce ( ... seq1 seq2 identity quot: ( ... prev elt1 elt2 -- ... next ) -- ... result )
    -rotd 2each ; inline

: 2map-as ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... newelt ) exemplar -- ... newseq )
    [ 2length-operator ] dip map-integers-as ; inline

: 2map ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... newelt ) -- ... newseq )
    pick 2map-as ; inline

: 2all? ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ? ) -- ... ? )
    2length-operator all-integers? ; inline

: 2any? ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ? ) -- ... ? )
    negate 2all? not ; inline

: 3each ( ... seq1 seq2 seq3 quot: ( ... elt1 elt2 elt3 -- ... ) -- ... )
    3length-operator each-integer ; inline

: 3map-as ( ... seq1 seq2 seq3 quot: ( ... elt1 elt2 elt3 -- ... newelt ) exemplar -- ... newseq )
    [ 3length-operator ] dip map-integers-as ; inline

: 3map ( ... seq1 seq2 seq3 quot: ( ... elt1 elt2 elt3 -- ... newelt ) -- ... newseq )
    pickd swap 3map-as ; inline

<PRIVATE

: bounds-check-call ( n seq quot -- obj1 obj2 )
    2over bounds-check? [ call ] [ 3drop f f ] if ; inline

: do-find-from ( ... n seq quot: ( ... elt -- ... ? ) -- ... i/f seq )
    [ length-operator find-integer-from ] keepd ; inline

: find-last-from-unsafe ( ... n seq quot: ( ... elt -- ... ? ) -- ... i/f seq )
    [ length-operator nip find-last-integer ] keepd ; inline

PRIVATE>

: find-from ( ... n seq quot: ( ... elt -- ... ? ) -- ... i elt )
    '[ _ do-find-from index/element ] bounds-check-call ; inline

: find ( ... seq quot: ( ... elt -- ... ? ) -- ... i elt )
    [ 0 ] 2dip do-find-from index/element ; inline

: find-last-from ( ... n seq quot: ( ... elt -- ... ? ) -- ... i elt )
    '[ _ find-last-from-unsafe index/element ] bounds-check-call ; inline

: find-last ( ... seq quot: ( ... elt -- ... ? ) -- ... i elt )
    [ index-of-last ] dip find-last-from ; inline

: find-index-from ( ... n seq quot: ( ... elt i -- ... ? ) -- ... i elt )
    '[
        _ [ sequence-index-operator find-integer-from ] keepd
        index/element
    ] bounds-check-call ; inline

: find-index ( ... seq quot: ( ... elt i -- ... ? ) -- ... i elt )
    [ 0 ] 2dip find-index-from ; inline

: all? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? )
    sequence-operator all-integers-from? ; inline

: push-when ( ..a elt quot: ( ..a elt -- ..b ? ) accum -- ..b )
    [ keep ] dip rot [ push ] [ 2drop ] if ; inline

<PRIVATE

: (selector-as) ( quot length exemplar -- selector accum )
    new-resizable [ [ push-when ] 2curry ] keep ; inline

PRIVATE>

: selector-as ( quot exemplar -- selector accum )
    [ length ] keep (selector-as) ; inline

: selector ( quot -- selector accum )
    V{ } selector-as ; inline

: filter-as ( ... seq quot: ( ... elt -- ... ? ) exemplar -- ... subseq )
    pick length over [ (selector-as) [ each ] dip ] 2curry dip like ; inline

: filter ( ... seq quot: ( ... elt -- ... ? ) -- ... subseq )
    over filter-as ; inline

: reject-as ( ... seq quot: ( ... elt -- ... ? ) exemplar -- ... subseq )
    [ negate ] [ filter-as ] bi* ; inline

: reject ( ... seq quot: ( ... elt -- ... ? ) -- ... subseq )
    over reject-as ; inline

: push-either ( ..a elt quot: ( ..a elt -- ..b ? ) accum1 accum2 -- ..b )
    [ keep swap ] 2dip ? push ; inline

: 2selector ( quot -- selector accum1 accum2 )
    V{ } clone V{ } clone [ [ push-either ] 3curry ] 2keep ; inline

: partition ( ... seq quot: ( ... elt -- ... ? ) -- ... trueseq falseseq )
    over [ 2selector [ each ] 2dip ] dip [ like ] curry bi@ ; inline

: collector-as ( quot exemplar -- quot' vec )
    dup new-resizable-like [ [ push ] curry compose ] keep ; inline

: collector ( quot -- quot' vec )
    V{ } collector-as ; inline

: produce-as ( ..a pred: ( ..a -- ..b ? ) quot: ( ..b -- ..a obj ) exemplar -- ..b seq )
    dup [ collector-as [ while ] dip ] curry dip like ; inline

: produce ( ..a pred: ( ..a -- ..b ? ) quot: ( ..b -- ..a obj ) -- ..b seq )
    { } produce-as ; inline

: follow ( ... obj quot: ( ... prev -- ... result/f ) -- ... seq )
    [ dup ] swap [ keep ] curry produce nip ; inline

: each-index ( ... seq quot: ( ... elt index -- ... ) -- ... )
    sequence-index-operator each-integer ; inline

: map-index-as ( ... seq quot: ( ... elt index -- ... newelt ) exemplar -- ... newseq )
    [ dup length <iota> ] 2dip 2map-as ; inline

: map-index ( ... seq quot: ( ... elt index -- ... newelt ) -- ... newseq )
    over map-index-as ; inline

: interleave ( ... seq between quot: ( ... elt -- ... ) -- ... )
    pick empty? [ 3drop ] [
        [ [ drop first-unsafe ] dip call ]
        [ [ bi* ] 2curry 1 each-from ]
        3bi
    ] if ; inline

: reduce-index ( ... seq identity quot: ( ... prev elt index -- ... next ) -- ... result )
    swapd each-index ; inline

: index ( obj seq -- n )
    [ = ] with find drop ;

: index-from ( obj i seq -- n )
    rot [ = ] curry find-from drop ;

: last-index ( obj seq -- n )
    [ = ] with find-last drop ;

: last-index-from ( obj i seq -- n )
    rot [ = ] curry find-last-from drop ;

: indices ( obj seq -- indices )
    swap [ = ] curry [ swap ] prepose V{ } clone [
        [ push ] curry [ [ drop ] if ] curry compose each-index
    ] keep ;

<PRIVATE

: nths-unsafe ( indices seq -- seq' )
    [ [ nth-unsafe ] curry ] keep map-as ;

PRIVATE>

: nths ( indices seq -- seq' )
    [ [ nth ] curry ] keep map-as ;

: nths-of ( seq indices -- seq' )
    swap nths ; inline

: any? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? )
    find drop >boolean ; inline

: none? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? )
    any? not ; inline

: member? ( elt seq -- ? )
    [ = ] with any? ;

: member-eq? ( elt seq -- ? )
    [ eq? ] with any? ;

: remove ( elt seq -- newseq )
    [ = ] with reject ;

: remove-eq ( elt seq -- newseq )
    [ eq? ] with reject ;

: sift ( seq -- newseq )
    [ ] filter ;

: harvest ( seq -- newseq )
    [ empty? ] reject ;

<PRIVATE

: mismatch-unsafe ( n seq1 seq2 -- i )
    [ 2nth-unsafe = not ] 2curry find-integer ; inline

PRIVATE>

: mismatch ( seq1 seq2 -- i )
    [ min-length ] 2keep mismatch-unsafe ;

M: sequence <=>
    [ mismatch ] 2keep pick
    [ 2nth-unsafe <=> ] [ [ length ] compare nip ] if ;

: sequence= ( seq1 seq2 -- ? )
    2dup 2length dupd =
    [ -rot mismatch-unsafe not ] [ 3drop f ] if ; inline

ERROR: assert-sequence got expected ;

: assert-sequence= ( a b -- )
    2dup sequence= [ 2drop ] [ assert-sequence ] if ;

M: reversed equal? over reversed? [ sequence= ] [ 2drop f ] if ;

M: slice equal? over slice? [ sequence= ] [ 2drop f ] if ;

<PRIVATE

: sequence-hashcode-step ( oldhash newpart -- newhash )
    integer>fixnum swap [
        [ -2 fixnum-shift-fast ] [ 5 fixnum-shift-fast ] bi
        fixnum+fast fixnum+fast
    ] keep fixnum-bitxor ; inline

PRIVATE>

: sequence-hashcode ( n seq -- x )
    [ 0 ] 2dip [ hashcode* sequence-hashcode-step ] with each ; inline

M: sequence hashcode* [ sequence-hashcode ] recursive-hashcode ;

M: iota hashcode*
    over 0 <= [ 2drop 0 ] [
        nip length 0 swap [ sequence-hashcode-step ] each-integer
    ] if ;

M: reversed hashcode* [ sequence-hashcode ] recursive-hashcode ;

M: slice hashcode* [ sequence-hashcode ] recursive-hashcode ;

: move ( to from seq -- )
    2over =
    [ 3drop ] [ [ nth swap ] [ set-nth ] bi ] if ; inline

<PRIVATE

: move-unsafe* ( to from seq -- from-nth )
    2over =
    [ nth-unsafe nip ]
    [ [ nth-unsafe tuck swap ] [ set-nth-unsafe ] bi ] if ; inline

: filter-from! ( store from seq quot: ( ... elt -- ... ? ) -- seq )
    2over length < [
        [ [ move-unsafe* ] dip call ] 4keep
        [ swap [ 1 + ] when ] 3dip
        [ 1 + ] 2dip filter-from!
    ] [ drop [ nip set-length ] keep ] if ; inline recursive

: move-unsafe ( to from seq -- )
    2over =
    [ 3drop ] [ [ nth-unsafe swap ] [ set-nth-unsafe ] bi ] if ; inline

PRIVATE>

: filter! ( ... seq quot: ( ... elt -- ... ? ) -- ... seq )
    [ 0 0 ] 2dip filter-from! ; inline

: reject! ( ... seq quot: ( ... elt -- ... ? ) -- ... seq )
    negate filter! ; inline

: remove! ( elt seq -- seq )
    [ = ] with reject! ;

: remove-eq! ( elt seq -- seq )
    [ eq? ] with reject! ;

: prefix ( seq elt -- newseq )
    over [ over length 1 + ] dip [
        (1sequence) [ 1 swap copy-unsafe ] keep
    ] new-like ;

: suffix ( seq elt -- newseq )
    over [ over length 1 + ] dip [
        [ [ over length ] dip set-nth-unsafe ] keep
        [ 0 swap copy-unsafe ] keep
    ] new-like ;

: suffix! ( seq elt -- seq ) over push ; inline

: append! ( seq1 seq2 -- seq1 ) over push-all ; inline

: last ( seq -- elt )
    index-of-last
    over 0 < [ bounds-error ] [ nth-unsafe ] if ; inline

<PRIVATE

: last-unsafe ( seq -- elt )
    index-of-last nth-unsafe ; inline

PRIVATE>

: set-last ( elt seq -- )
    index-of-last
    over 0 < [ bounds-error ] [ set-nth-unsafe ] if ; inline

: pop* ( seq -- ) index-of-last shorten ;

<PRIVATE

: move-backward ( shift from to seq -- )
    2over = [
        4drop
    ] [
        [ [ 2over + pick ] dip move-unsafe [ 1 + ] dip ] keep
        move-backward
    ] if ;

: open-slice ( shift from seq -- )
    pick 0 = [
        3drop
    ] [
        [ ] [ nip length + ] [ 2nip ] 3tri
        [ [ length ] keep [ over - ] 2dip move-backward ] 2dip
        set-length
    ] if ;

PRIVATE>

: delete-slice ( from to seq -- )
    check-slice [ over [ - ] dip ] dip open-slice ;

: remove-nth! ( n seq -- seq )
    [ [ dup 1 + ] dip delete-slice ] keep ;

: snip ( from to seq -- head tail )
    [ swap head ] [ swap tail ] bi-curry bi* ; inline

: snip-slice ( from to seq -- head tail )
    [ swap head-slice ] [ swap tail-slice ] bi-curry bi* ; inline

: replace-slice ( new from to seq -- seq' )
    snip-slice surround ;

: remove-nth ( n seq -- seq' )
    [ [ dup 1 + ] dip snip-slice ] keep append-as ;

: pop ( seq -- elt )
    index-of-last over 0 >=
    [ [ nth-unsafe ] [ shorten ] 2bi ]
    [ bounds-error ] if ;

: exchange ( m n seq -- )
    [ nip bounds-check 2drop ]
    [ bounds-check 3drop ]
    [ exchange-unsafe ]
    3tri ;

: midpoint@ ( seq -- n ) length 2/ ; inline

: reverse! ( seq -- seq )
    [
        [ midpoint@ ] [ length ] [ ] tri
        [ [ over - 1 - ] dip exchange-unsafe ] 2curry
        each-integer
    ] keep ;

: reverse ( seq -- newseq )
    [
        dup [ length ] keep new-sequence
        [ 0 swap copy-unsafe ] keep reverse!
    ] keep like ;

GENERIC: sum-lengths ( seq -- n )

M: object sum-lengths
    0 [ length + ] reduce ;

M: repetition sum-lengths
    [ length>> ] [ elt>> length ] bi * ;

: concat-as ( seq exemplar -- newseq )
    [
        [ dup sum-lengths ] dip new-resizable
        [ [ push-all ] curry each ] keep
    ] keep like ; inline

: concat ( seq -- newseq )
    [ { } ] [ dup first concat-as ] if-empty ;

<PRIVATE

: joined-length ( seq glue -- n )
    [ [ sum-lengths ] [ length 1 [-] ] bi ] dip length * + ;

PRIVATE>

: join-as ( seq glue exemplar -- newseq )
    over empty? [ nip concat-as ] [
        [
            2dup joined-length over new-resizable [
                [ [ push-all ] 2curry ]
                [ nip [ push-all ] curry ] 2bi
                interleave
            ] keep
        ] dip like
    ] if ;

: join ( seq glue -- newseq )
    dup join-as ; inline

<PRIVATE

: padding ( ... seq n elt quot: ( ... seq1 seq2 -- ... newseq ) -- ... newseq )
    [
        [ over length [-] dup 0 = [ drop ] ] dip
        [ <repetition> ] curry
    ] dip compose if ; inline

PRIVATE>

: pad-head ( seq n elt -- padded )
    [ swap dup append-as ] padding ;

: pad-tail ( seq n elt -- padded )
    [ append ] padding ;

: shorter? ( seq1 seq2 -- ? ) 2length < ; inline
: longer? ( seq1 seq2 -- ? ) 2length > ; inline
: shorter ( seq1 seq2 -- seq ) [ 2length <= ] most ; inline
: longer ( seq1 seq2 -- seq ) [ 2length >= ] most ; inline

: head? ( seq begin -- ? )
    2dup shorter? [
        2drop f
    ] [
        [ length [ head-slice ] keep swap ] keep
        mismatch-unsafe not
    ] if ;

: tail? ( seq end -- ? )
    2dup shorter? [
        2drop f
    ] [
        [ length [ tail-slice* ] keep swap ] keep
        mismatch-unsafe not
    ] if ;

: cut-slice ( seq n -- before-slice after-slice )
    [ head-slice ] [ tail-slice ] 2bi ; inline

: cut-slice* ( seq n -- before-slice after-slice )
    [ head-slice* ] [ tail-slice* ] 2bi ;

: insert-nth ( elt n seq -- seq' )
    swap cut-slice [ swap suffix ] dip append ;

: halves ( seq -- first-slice second-slice )
    dup midpoint@ cut-slice ; inline

<PRIVATE

: nth2-unsafe ( n seq -- a b )
    [ nth-unsafe ] [ [ 1 + ] dip nth-unsafe ] 2bi ; inline

: nth3-unsafe ( n seq -- a b c )
    [ nth2-unsafe ] [ [ 2 + ] dip nth-unsafe ] 2bi ; inline

: (binary-reduce) ( seq start quot: ( elt1 elt2 -- newelt ) from length -- value )
    ! We can't use case here since combinators depends on
    ! sequences
    dup 4 < [
        integer>fixnum {
            [ 2drop nip ]
            [ 2nip swap nth-unsafe ]
            [ -rot [ drop swap nth2-unsafe ] dip call ]
            [ -rot [ drop swap nth3-unsafe ] dip bi@ ]
        } dispatch
    ] [
        [ 2/ ] [ over - ] bi [ 2dup + ] dip
        [ (binary-reduce) ] [ 2curry ] curry 2bi@
        pick [ 3bi ] dip call
    ] if ; inline recursive

PRIVATE>

: binary-reduce ( seq start quot: ( elt1 elt2 -- newelt ) -- value )
    pick dup slice? [
        [ seq>> ] 3dip [ from>> 0 max ] [ to>> 0 max over - ] bi
    ] [
        length 0 max 0 swap
    ] if (binary-reduce) ; inline

: cut ( seq n -- before after )
    [ head ] [ tail ] 2bi ;

: cut* ( seq n -- before after )
    [ head* ] [ tail* ] 2bi ;

: subseq-starts-at? ( i seq subseq -- ? )
    [ length swap ] keep
    '[
        [ + _ nth-unsafe ] keep _ nth-unsafe =
    ] with all-integers? ; inline

: subseq-index-from ( n seq subseq -- i/f )
    [ 2length - 1 + ] 2keep
    '[ _ _ subseq-starts-at? ] find-integer-from ; inline

: subseq-index ( seq subseq -- i/f ) [ 0 ] 2dip subseq-index-from ; inline

: subseq-of? ( seq subseq -- ? ) subseq-index >boolean ; inline

: subseq-start-from ( subseq seq n -- i/f )
    spin subseq-index-from ; inline deprecated

: subseq-start ( subseq seq -- i/f ) swap subseq-index ; inline deprecated

: subseq? ( subseq seq -- ? ) subseq-start >boolean ; inline deprecated

: drop-prefix ( seq1 seq2 -- slice1 slice2 )
    2dup mismatch [ 2dup min-length ] unless*
    [ tail-slice ] curry bi@ ;

: unclip ( seq -- rest first )
    [ rest ] [ first-unsafe ] bi ;

: unclip-last ( seq -- butlast last )
    [ but-last ] [ last-unsafe ] bi ;

: unclip-slice ( seq -- rest-slice first )
    [ rest-slice ] [ first-unsafe ] bi ; inline

: map-reduce ( ..a seq map-quot: ( ..a elt -- ..a intermediate ) reduce-quot: ( ..a prev intermediate -- ..a next ) -- ..a result )
    [ [ [ first ] keep ] dip [ dip ] keep ] dip
    '[ swap _ dip swap @ ] 1 each-from ; inline

: 2map-reduce ( ..a seq1 seq2 map-quot: ( ..a elt1 elt2 -- ..a intermediate ) reduce-quot: ( ..a prev intermediate -- ..a next ) -- ..a result )
    [ [ [ [ first ] bi@ ] 2keep ] dip [ 2dip ] keep ] dip
    '[ rot _ dip swap @ ] 1 2each-from ; inline

<PRIVATE

: (map-find) ( seq quot find-quot -- result elt )
    [ [ f ] 2dip [ nip ] prepose [ dup ] compose ] dip call nip ; inline

PRIVATE>

: map-find ( ... seq quot: ( ... elt -- ... result/f ) -- ... result elt )
    [ find ] (map-find) ; inline

: map-find-last ( ... seq quot: ( ... elt -- ... result/f ) -- ... result elt )
    [ find-last ] (map-find) ; inline

: unclip-last-slice ( seq -- butlast-slice last )
    [ but-last-slice ] [ last-unsafe ] bi ; inline

<PRIVATE

: (trim-head) ( seq quot -- seq n )
    over [ negate find drop ] dip swap
    [ dup length ] unless* ; inline

: (trim-tail) ( seq quot -- seq n )
    over [ negate find-last drop ?1+ ] dip
    swap ; inline

PRIVATE>

: trim-head-slice ( ... seq quot: ( ... elt -- ... ? ) -- ... slice )
    (trim-head) tail-slice ; inline

: trim-head ( ... seq quot: ( ... elt -- ... ? ) -- ... newseq )
    (trim-head) tail ; inline

: trim-tail-slice ( ... seq quot: ( ... elt -- ... ? ) -- ... slice )
    (trim-tail) head-slice ; inline

: trim-tail ( ... seq quot: ( ... elt -- ... ? ) -- ... newseq )
    (trim-tail) head ; inline

: trim-slice ( ... seq quot: ( ... elt -- ... ? ) -- ... slice )
    [ trim-head-slice ] [ trim-tail-slice ] bi ; inline

: trim ( ... seq quot: ( ... elt -- ... ? ) -- ... newseq )
    [ trim-slice ] [ drop ] 2bi like ; inline

GENERIC: sum ( seq -- n )
M: object sum 0 [ + ] binary-reduce ; inline
M: iota sum length dup 1 - * 2/ ; inline
M: repetition sum [ elt>> ] [ length>> ] bi * ; inline

: product ( seq -- n ) 1 [ * ] binary-reduce ;

GENERIC: infimum ( seq -- elt )
M: object infimum [ ] [ min ] map-reduce ;
M: iota infimum first ;
M: reversed infimum seq>> infimum ;

GENERIC: supremum ( seq -- elt )
M: object supremum [ ] [ max ] map-reduce ;
M: iota supremum last ;
M: reversed supremum seq>> supremum ;

: map-sum ( ... seq quot: ( ... elt -- ... n ) -- ... n )
    [ 0 ] 2dip [ dip + ] curry [ swap ] prepose each ; inline

: count ( ... seq quot: ( ... elt -- ... ? ) -- ... n )
    [ 1 0 ? ] compose map-sum ; inline

: cartesian-each ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ) -- ... )
    [ with each ] 2curry each ; inline

: cartesian-map ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... newelt ) -- ... newseq )
    [ with { } map-as ] 2curry { } map-as ; inline

: cartesian-product-as ( seq1 seq2 exemplar -- newseq )
    [ 2sequence ] curry cartesian-map ; inline

: cartesian-product ( seq1 seq2 -- newseq )
    dup cartesian-product-as ; inline

: cartesian-find ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ? ) -- ... elt1 elt2 )
    [ f ] 3dip [ with find swap ] 2curry [ nip ] prepose find nip swap ; inline

<PRIVATE

: select-by ( ... seq quot: ( ... elt -- ... x ) compare: ( obj1 obj2 -- ? ) -- ... elt )
    [
        [ keep swap ] curry [ [ first ] dip call ] 2keep
        [ curry 2dip pick over ] curry
    ] [
        [ [ 2drop ] [ 2nipd ] if ] compose
    ] bi* compose 1 each-from drop ; inline

PRIVATE>

: supremum-by ( ... seq quot: ( ... elt -- ... x ) -- ... elt )
    [ after? ] select-by ; inline

: infimum-by ( ... seq quot: ( ... elt -- ... x ) -- ... elt )
    [ before? ] select-by ; inline

: shortest ( seqs -- elt ) [ length ] infimum-by ;

: longest ( seqs -- elt ) [ length ] supremum-by ;

! We hand-optimize flip to such a degree because type hints
! cannot express that an array is an array of arrays yet, and
! this word happens to be performance-critical since the compiler
! itself uses it. Optimizing it like this reduced compile time.
<PRIVATE

: generic-flip ( matrix -- newmatrix )
    [ [ length ] [ min ] map-reduce ] keep
    '[ _ [ nth-unsafe ] with { } map-as ] map-integers ; inline

USE: arrays

: array-flip ( matrix -- newmatrix )
    { array } declare
    [ [ { array } declare length>> ] [ min ] map-reduce ] keep
    '[ _ [ { array } declare array-nth ] with { } map-as ] map-integers ;

PRIVATE>

: flip ( matrix -- newmatrix )
    dup empty? [
        dup array? [
            dup [ array? ] all?
            [ array-flip ] [ generic-flip ] if
        ] [ generic-flip ] if
    ] unless ;
