! Copyright (C) 2005, 2011 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
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

: new-like ( len exemplar quot -- seq )
    over [ [ new-sequence ] dip call ] dip like ; inline

M: sequence like drop ; inline

GENERIC: lengthen ( n seq -- )
GENERIC: shorten ( n seq -- )

M: sequence lengthen 2dup length > [ set-length ] [ 2drop ] if ; inline
M: sequence shorten 2dup length < [ set-length ] [ 2drop ] if ; inline

: empty? ( seq -- ? ) length 0 = ; inline

: if-empty ( ..a seq quot1: ( ..a -- ..b ) quot2: ( ..a seq -- ..b ) -- ..b )
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

ERROR: bounds-error index seq ;

GENERIC# bounds-check? 1 ( n seq -- ? )

M: integer bounds-check? ( n seq -- ? )
    dupd length < [ 0 >= ] [ drop f ] if ; inline

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

M: sequence nth bounds-check nth-unsafe ; inline
M: sequence set-nth bounds-check set-nth-unsafe ; inline

M: sequence nth-unsafe nth ; inline
M: sequence set-nth-unsafe set-nth ; inline

: change-nth-unsafe ( i seq quot -- )
    [ [ nth-unsafe ] dip call ] 3keep drop set-nth-unsafe ; inline

PRIVATE>

! The f object supports the sequence protocol trivially
M: f length drop 0 ; inline
M: f nth-unsafe nip ; inline
M: f like drop [ f ] when-empty ; inline

INSTANCE: f immutable-sequence

! Integer sequences
TUPLE: iota { n integer read-only } ;

: iota ( n -- iota ) \ iota boa ; inline

M: iota length n>> ; inline
M: iota nth-unsafe drop ; inline

INSTANCE: iota immutable-sequence

<PRIVATE

: first-unsafe ( seq -- first )
    0 swap nth-unsafe ; inline

: first2-unsafe ( seq -- first second )
    [ first-unsafe ] [ 1 swap nth-unsafe ] bi ; inline

: first3-unsafe ( seq -- first second third )
    [ first2-unsafe ] [ 2 swap nth-unsafe ] bi ; inline

: first4-unsafe ( seq -- first second third fourth )
    [ first3-unsafe ] [ 3 swap nth-unsafe ] bi ; inline

: exchange-unsafe ( m n seq -- )
    [ [ nth-unsafe ] curry bi@ ]
    [ [ set-nth-unsafe ] curry bi@ ] 3bi ; inline

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
    1 swap bounds-check nip first2-unsafe ; inline

: first3 ( seq -- first second third )
    2 swap bounds-check nip first3-unsafe ; inline

: first4 ( seq -- first second third fourth )
    3 swap bounds-check nip first4-unsafe ; inline

: ?nth ( n seq -- elt/f )
    2dup bounds-check? [ nth-unsafe ] [ 2drop f ] if ; inline

: ?first ( seq -- elt/f ) 0 swap ?nth ; inline
: ?second ( seq -- elt/f ) 1 swap ?nth ; inline
: ?last ( seq -- elt/f )
    [ length 1 - ] keep over 0 <
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
{ from read-only }
{ to read-only }
{ seq read-only } ;

: collapse-slice ( m n slice -- m' n' seq )
    [ from>> ] [ seq>> ] bi [ [ + ] curry bi@ ] dip ; inline

TUPLE: slice-error from to seq reason ;

: slice-error ( from to seq ? string -- from to seq )
    [ \ slice-error boa throw ] curry when ; inline

: check-slice ( from to seq -- from to seq )
    3dup
    [ 2drop 0 < "start < 0" slice-error ]
    [ [ drop ] 2dip length > "end > sequence" slice-error ]
    [ drop > "start > end" slice-error ]
    3tri ; inline

<PRIVATE

: <slice-unsafe> ( from to seq -- slice )
    slice boa ; inline

PRIVATE>

: <slice> ( from to seq -- slice )
    check-slice
    dup slice? [ collapse-slice ] when
    <slice-unsafe> ; inline

M: slice virtual-exemplar seq>> ; inline

M: slice virtual@ [ from>> + ] [ seq>> ] bi ; inline

M: slice length [ to>> ] [ from>> ] bi - ; inline

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

M: repetition length len>> ; inline
M: repetition nth-unsafe nip elt>> ; inline

INSTANCE: repetition immutable-sequence

<PRIVATE

ERROR: integer-length-expected obj ;

: check-length ( n -- n )
    dup integer? [ integer-length-expected ] unless ; inline

TUPLE: copy-state
    { src-i read-only }
    { src read-only }
    { dst-i read-only }
    { dst read-only } ;

C: <copy> copy-state

: ((copy)) ( n copy -- )
    [ [ src-i>> + ] [ src>> ] bi nth-unsafe ]
    [ [ dst-i>> + ] [ dst>> ] bi set-nth-unsafe ] 2bi ; inline

: (copy) ( n copy -- dst )
    over 0 <= [ nip dst>> ] [ [ 1 - ] dip [ ((copy)) ] [ (copy) ] 2bi ] if ;
    inline recursive

: subseq>copy ( from to seq -- n copy )
    [ over - check-length swap ] dip
    3dup nip new-sequence 0 swap <copy> ; inline

: bounds-check-head ( n seq -- n seq )
    over 0 < [ bounds-error ] when ; inline

: check-copy ( src n dst -- src n dst )
    3dup bounds-check-head
    [ swap length + ] dip lengthen ; inline

PRIVATE>

: subseq ( from to seq -- subseq )
    [ check-slice subseq>copy (copy) ] keep like ;

: head ( seq n -- headseq ) (head) subseq ;

: tail ( seq n -- tailseq ) (tail) subseq ;

: rest ( seq -- tailseq ) 1 tail ;

: head* ( seq n -- headseq ) from-end head ;

: tail* ( seq n -- tailseq ) from-end tail ;

: but-last ( seq -- headseq ) 1 head* ;

: copy ( src i dst -- )
    #! The check-length call forces partial dispatch
    [ [ length check-length 0 ] keep ] 2dip
    check-copy <copy> (copy) drop ; inline

M: sequence clone-like
    [ dup length ] dip new-sequence [ 0 swap copy ] keep ; inline

M: immutable-sequence clone-like like ; inline

: push-all ( src dest -- ) [ length ] [ copy ] bi ; inline

<PRIVATE

: (append) ( seq1 seq2 accum -- accum )
    [ [ over length ] dip copy ]
    [ 0 swap copy ]
    [ ] tri ; inline

PRIVATE>

: append-as ( seq1 seq2 exemplar -- newseq )
    [ 2dup [ length ] bi@ + ] dip
    [ (append) ] new-like ; inline

: 3append-as ( seq1 seq2 seq3 exemplar -- newseq )
    [ 3dup [ length ] tri@ + + ] dip [
        [ [ 2over [ length ] bi@ + ] dip copy ]
        [ (append) ] bi
    ] new-like ; inline

: append ( seq1 seq2 -- newseq ) over append-as ;

: prepend-as ( seq1 seq2 exemplar -- newseq ) swapd append-as ; inline

: prepend ( seq1 seq2 -- newseq ) over prepend-as ;

: 3append ( seq1 seq2 seq3 -- newseq ) pick 3append-as ;

: surround ( seq1 seq2 seq3 -- newseq ) swapd 3append ; inline

: glue ( seq1 seq2 seq3 -- newseq ) swap 3append ; inline

: change-nth ( ..a i seq quot: ( ..a elt -- ..b newelt ) -- ..b )
    [ [ nth ] dip call ] 3keep drop set-nth-unsafe ; inline

: min-length ( seq1 seq2 -- n ) [ length ] bi@ min ; inline

: max-length ( seq1 seq2 -- n ) [ length ] bi@ max ; inline

<PRIVATE

: ((each)) ( seq -- n quot )
    [ length ] keep [ nth-unsafe ] curry ; inline

: (each) ( seq quot -- n quot' )
    [ ((each)) ] dip compose ; inline

: (each-index) ( seq quot -- n quot' )
    [ ((each)) [ keep ] curry ] dip compose ; inline

: (collect) ( quot into -- quot' )
    [ [ keep ] dip set-nth-unsafe ] 2curry ; inline

: collect ( n quot into -- )
    (collect) each-integer ; inline

: map-into ( seq quot into -- )
    [ (each) ] dip collect ; inline

: 2nth-unsafe ( n seq1 seq2 -- elt1 elt2 )
    [ nth-unsafe ] bi-curry@ bi ; inline

: ((2each)) ( seq1 seq2 -- n quot )
    [ min-length ] 2keep [ 2nth-unsafe ] 2curry ; inline

: (2each) ( seq1 seq2 quot -- n quot' )
    [ ((2each)) ] dip compose ; inline

: 3nth-unsafe ( n seq1 seq2 seq3 -- elt1 elt2 elt3 )
    [ nth-unsafe ] tri-curry@ tri ; inline

: (3each) ( seq1 seq2 seq3 quot -- n quot' )
    [
        [ [ length ] tri@ min min ]
        [ [ 3nth-unsafe ] 3curry ] 3bi
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

: (find-index) ( seq quot quot' -- i elt )
    pick [ [ (each-index) ] dip call ] dip finish-find ; inline

: (find-index-from) ( n seq quot quot' -- i elt )
    [ 2dup bounds-check? ] 2dip
    [ (find-index) ] 2curry
    [ 2drop f f ]
    if ; inline

: (accumulate) ( seq identity quot -- identity seq quot )
    swapd [ curry keep ] curry ; inline

PRIVATE>

: each ( ... seq quot: ( ... x -- ... ) -- ... )
    (each) each-integer ; inline

: reduce ( ... seq identity quot: ( ... prev elt -- ... next ) -- ... result )
    swapd each ; inline

: map-integers ( ... len quot: ( ... i -- ... elt ) exemplar -- ... newseq )
    [ over ] dip [ [ collect ] keep ] new-like ; inline

: map-as ( ... seq quot: ( ... elt -- ... newelt ) exemplar -- ... newseq )
    [ (each) ] dip map-integers ; inline

: map ( ... seq quot: ( ... elt -- ... newelt ) -- ... newseq )
    over map-as ; inline

: replicate-as ( ... len quot: ( ... -- ... newelt ) exemplar -- ... newseq )
    [ [ drop ] prepose ] dip map-integers ; inline

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

: 2each ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ) -- ... )
    (2each) each-integer ; inline

: 2reduce ( ... seq1 seq2 identity quot: ( ... prev elt1 elt2 -- ... next ) -- ... result )
    [ -rot ] dip 2each ; inline

: 2map-as ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... newelt ) exemplar -- ... newseq )
    [ (2each) ] dip map-integers ; inline

: 2map ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... newelt ) -- ... newseq )
    pick 2map-as ; inline

: 2all? ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ? ) -- ... ? )
    (2each) all-integers? ; inline

: 3each ( ... seq1 seq2 seq3 quot: ( ... elt1 elt2 elt3 -- ... ) -- ... )
    (3each) each-integer ; inline

: 3map-as ( ... seq1 seq2 seq3 quot: ( ... elt1 elt2 elt3 -- ... newelt ) exemplar -- ... newseq )
    [ (3each) ] dip map-integers ; inline

: 3map ( ... seq1 seq2 seq3 quot: ( ... elt1 elt2 elt3 -- ... newelt ) -- ... newseq )
    [ pick ] dip swap 3map-as ; inline

: find-from ( ... n seq quot: ( ... elt -- ... ? ) -- ... i elt )
    [ (find-integer) ] (find-from) ; inline

: find ( ... seq quot: ( ... elt -- ... ? ) -- ... i elt )
    [ find-integer ] (find) ; inline

: find-last-from ( ... n seq quot: ( ... elt -- ... ? ) -- ... i elt )
    [ nip find-last-integer ] (find-from) ; inline

: find-last ( ... seq quot: ( ... elt -- ... ? ) -- ... i elt )
    [ [ 1 - ] dip find-last-integer ] (find) ; inline

: find-index-from ( ... n seq quot: ( ... elt i -- ... ? ) -- ... i elt )
    [ (find-integer) ] (find-index-from) ; inline

: find-index ( ... seq quot: ( ... elt i -- ... ? ) -- ... i elt )
    [ find-integer ] (find-index) ; inline

: all? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? )
    (each) all-integers? ; inline

: push-if ( ..a elt quot: ( ..a elt -- ..b ? ) accum -- ..b )
    [ keep ] dip rot [ push ] [ 2drop ] if ; inline

: selector-for ( quot exemplar -- selector accum )
    [ length ] keep new-resizable [ [ push-if ] 2curry ] keep ; inline

: selector ( quot -- selector accum )
    V{ } selector-for ; inline

: filter-as ( ... seq quot: ( ... elt -- ... ? ) exemplar -- ... subseq )
    dup [ selector-for [ each ] dip ] curry dip like ; inline

: filter ( ... seq quot: ( ... elt -- ... ? ) -- ... subseq )
    over filter-as ; inline

: push-either ( ..a elt quot: ( ..a elt -- ..b ? ) accum1 accum2 -- ..b )
    [ keep swap ] 2dip ? push ; inline

: 2selector ( quot -- selector accum1 accum2 )
    V{ } clone V{ } clone [ [ push-either ] 3curry ] 2keep ; inline

: partition ( ... seq quot: ( ... elt -- ... ? ) -- ... trueseq falseseq )
    over [ 2selector [ each ] 2dip ] dip [ like ] curry bi@ ; inline

: collector-for ( quot exemplar -- quot' vec )
    [ length ] keep new-resizable [ [ push ] curry compose ] keep ; inline

: collector ( quot -- quot' vec )
    V{ } collector-for ; inline

: produce-as ( ..a pred: ( ..a -- ..b ? ) quot: ( ..b -- ..a obj ) exemplar -- ..b seq )
    dup [ collector-for [ while ] dip ] curry dip like ; inline

: produce ( ..a pred: ( ..a -- ..b ? ) quot: ( ..b -- ..a obj ) -- ..b seq )
    { } produce-as ; inline

: follow ( ... obj quot: ( ... prev -- ... result/f ) -- ... seq )
    [ dup ] swap [ keep ] curry produce nip ; inline

: each-index ( ... seq quot: ( ... elt index -- ... ) -- ... )
    (each-index) each-integer ; inline

: interleave ( ... seq between quot: ( ... elt -- ... ) -- ... )
    pick empty? [ 3drop ] [
        [ [ drop first-unsafe ] dip call ]
        [ [ rest-slice ] 2dip [ bi* ] 2curry each ]
        3bi
    ] if ; inline

: map-index ( ... seq quot: ( ... elt index -- ... newelt ) -- ... newseq )
    [ dup length iota ] dip 2map ; inline

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

<PRIVATE

: (indices) ( elt i obj accum -- )
    [ swap [ = ] dip ] dip [ push ] 2curry when ; inline

PRIVATE>

: indices ( obj seq -- indices )
    swap V{ } clone
    [ [ (indices) ] 2curry each-index ] keep ;

: nths ( indices seq -- seq' )
    [ [ nth ] curry ] keep map-as ;

: any? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? )
    find drop >boolean ; inline

: member? ( elt seq -- ? )
    [ = ] with any? ;

: member-eq? ( elt seq -- ? )
    [ eq? ] with any? ;

: remove ( elt seq -- newseq )
    [ = not ] with filter ;

: remove-eq ( elt seq -- newseq )
    [ eq? not ] with filter ;

: sift ( seq -- newseq )
    [ ] filter ;

: harvest ( seq -- newseq )
    [ empty? not ] filter ;

<PRIVATE

: mismatch-unsafe ( n seq1 seq2 -- i )
    [ 2nth-unsafe = not ] 2curry find-integer ; inline

PRIVATE>

: mismatch ( seq1 seq2 -- i )
    [ min-length ] 2keep mismatch-unsafe ; inline

M: sequence <=>
    [ mismatch ] 2keep pick
    [ 2nth-unsafe <=> ] [ [ length ] compare nip ] if ;

: sequence= ( seq1 seq2 -- ? )
    2dup [ length ] bi@ dupd =
    [ -rot mismatch-unsafe not ] [ 3drop f ] if ; inline

ERROR: assert-sequence got expected ;

: assert-sequence= ( a b -- )
    2dup sequence= [ 2drop ] [ assert-sequence ] if ;

<PRIVATE

: sequence-hashcode-step ( oldhash newpart -- newhash )
    integer>fixnum swap [
        [ -2 fixnum-shift-fast ] [ 5 fixnum-shift-fast ] bi
        fixnum+fast fixnum+fast
    ] keep fixnum-bitxor ; inline

PRIVATE>

: sequence-hashcode ( n seq -- x )
    [ 0 ] 2dip [ hashcode* sequence-hashcode-step ] with each ; inline

M: reversed equal? over reversed? [ sequence= ] [ 2drop f ] if ;

M: slice equal? over slice? [ sequence= ] [ 2drop f ] if ;

: move ( to from seq -- )
    2over =
    [ 3drop ] [ [ nth swap ] [ set-nth ] bi ] if ; inline

<PRIVATE

: move-unsafe ( to from seq -- )
    2over =
    [ 3drop ] [ [ nth-unsafe swap ] [ set-nth-unsafe ] bi ] if ; inline

: (filter!) ( ... quot: ( ... elt -- ... ? ) store scan seq -- ... )
    2dup length < [
        [ move-unsafe ] 3keep
        [ nth-unsafe pick call [ 1 + ] when ] 2keep
        [ 1 + ] dip
        (filter!)
    ] [ nip set-length drop ] if ; inline recursive

PRIVATE>

: filter! ( ... seq quot: ( ... elt -- ... ? ) -- ... seq )
    swap [ [ 0 0 ] dip (filter!) ] keep ; inline

: remove! ( elt seq -- seq )
    [ = not ] with filter! ;

: remove-eq! ( elt seq -- seq )
    [ eq? not ] with filter! ;

: prefix ( seq elt -- newseq )
    over [ over length 1 + ] dip [
        (1sequence) [ 1 swap copy ] keep
    ] new-like ;

: suffix ( seq elt -- newseq )
    over [ over length 1 + ] dip [
        [ [ over length ] dip set-nth-unsafe ] keep
        [ 0 swap copy ] keep
    ] new-like ;

: suffix! ( seq elt -- seq ) over push ; inline

: append! ( seq1 seq2 -- seq1 ) over push-all ; inline

: last ( seq -- elt )
    [ length 1 - ] keep
    over 0 < [ bounds-error ] [ nth-unsafe ] if ; inline

<PRIVATE

: last-unsafe ( seq -- elt ) [ length 1 - ] [ nth-unsafe ] bi ;

PRIVATE>

: set-last ( elt seq -- )
    [ length 1 - ] keep
    over 0 < [ bounds-error ] [ set-nth-unsafe ] if ; inline

: pop* ( seq -- ) [ length 1 - ] [ shorten ] bi ;

<PRIVATE

: move-backward ( shift from to seq -- )
    2over = [
        2drop 2drop
    ] [
        [ [ 2over + pick ] dip move-unsafe [ 1 + ] dip ] keep
        move-backward
    ] if ;

: move-forward ( shift from to seq -- )
    2over = [
        2drop 2drop
    ] [
        [ [ pick [ dup dup ] dip + swap ] dip move-unsafe 1 - ] keep
        move-forward
    ] if ;

: (open-slice) ( shift from to seq ? -- )
    [
        [ [ 1 - ] bi@ ] dip move-forward
    ] [
        [ over - ] 2dip move-backward
    ] if ;

: open-slice ( shift from seq -- )
    pick 0 = [
        3drop
    ] [
        pick over length + over
        [ pick 0 > [ [ length ] keep ] dip (open-slice) ] 2dip
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
    [ [ { } ] dip dup 1 + ] dip replace-slice ;

: pop ( seq -- elt )
    [ length 1 - ] keep over 0 >=
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
        [ midpoint@ iota ] [ length ] [ ] tri
        [ [ over - 1 - ] dip exchange-unsafe ] 2curry each
    ] keep ;

: reverse ( seq -- newseq )
    [
        dup [ length ] keep new-sequence
        [ 0 swap copy ] keep reverse!
    ] keep like ;

: sum-lengths ( seq -- n )
    0 [ length + ] reduce ;

: concat-as ( seq exemplar -- newseq )
    swap [ { } ] [
        [ sum-lengths over new-resizable ] keep
        [ append! ] each
    ] if-empty swap like ;

: concat ( seq -- newseq )
    [ { } ] [ dup first concat-as ] if-empty ;

<PRIVATE

: joined-length ( seq glue -- n )
    [ [ sum-lengths ] [ length 1 [-] ] bi ] dip length * + ;

PRIVATE>

: join ( seq glue -- newseq )
    dup empty? [ concat-as ] [
        [
            2dup joined-length over new-resizable [
                [ [ push-all ] 2curry ] [ [ nip push-all ] 2curry ] 2bi
                interleave
            ] keep
        ] keep like
    ] if ;

: padding ( ... seq n elt quot: ( ... seq1 seq2 -- ... newseq ) -- ... newseq )
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

: halves ( seq -- first-slice second-slice )
    dup midpoint@ cut-slice ;

: binary-reduce ( ... seq start quot: ( ... elt1 elt2 -- ... newelt ) -- ... value )
    #! We can't use case here since combinators depends on
    #! sequences
    pick length dup 0 3 between? [
        integer>fixnum {
            [ drop nip ]
            [ 2drop first-unsafe ]
            [ [ drop first2-unsafe ] dip call ]
            [ [ drop first3-unsafe ] dip bi@ ]
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
    pick length iota [
        [ 3dup ] dip [ + swap nth-unsafe ] keep rot nth-unsafe =
    ] all? nip ; inline

PRIVATE>

: start* ( subseq seq n -- i )
    pick length pick length swap - 1 + iota
    [ (start) ] find-from
    swap [ 3drop ] dip ;

: start ( subseq seq -- i ) 0 start* ; inline

: subseq? ( subseq seq -- ? ) start >boolean ;

: drop-prefix ( seq1 seq2 -- slice1 slice2 )
    2dup mismatch [ 2dup min-length ] unless*
    [ tail-slice ] curry bi@ ;

: unclip ( seq -- rest first )
    [ rest ] [ first-unsafe ] bi ;

: unclip-last ( seq -- butlast last )
    [ but-last ] [ last-unsafe ] bi ;

: unclip-slice ( seq -- rest-slice first )
    [ rest-slice ] [ first-unsafe ] bi ; inline

: map-reduce ( ..a seq map-quot: ( ..a x -- ..b elt ) reduce-quot: ( ..b prev elt -- ..a next ) -- ..a result )
    [ [ dup first ] dip [ call ] keep ] dip compose
    swapd [ 1 ] 2dip (each) (each-integer) ; inline

: 2map-reduce ( ..a seq1 seq2 map-quot: ( ..a elt1 elt2 -- ..b intermediate ) reduce-quot: ( ..b prev intermediate -- ..a next ) -- ..a result )
    [ [ 2dup [ first ] bi@ ] dip [ call ] keep ] dip compose
    [ -rot ] dip [ 1 ] 3dip (2each) (each-integer) ; inline

<PRIVATE

: (map-find) ( seq quot find-quot -- result elt )
    [ [ f ] 2dip [ [ nip ] dip call dup ] curry ] dip call
    [ [ drop f ] unless ] dip ; inline

PRIVATE>

: map-find ( ... seq quot: ( ... elt -- ... result/f ) -- ... result elt )
    [ find ] (map-find) ; inline

: map-find-last ( ... seq quot: ( ... elt -- ... result/f ) -- ... result elt )
    [ find-last ] (map-find) ; inline

: unclip-last-slice ( seq -- butlast-slice last )
    [ but-last-slice ] [ last-unsafe ] bi ; inline

<PRIVATE

: (trim-head) ( seq quot -- seq n )
    over [ [ not ] compose find drop ] dip
    [ length or ] keep swap ; inline

: (trim-tail) ( seq quot -- seq n )
    over [ [ not ] compose find-last drop ?1+ ] dip
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

: product ( seq -- n ) 1 [ * ] binary-reduce ;

: infimum ( seq -- n ) [ ] [ min ] map-reduce ;

: supremum ( seq -- n ) [ ] [ max ] map-reduce ;

: map-sum ( ... seq quot: ( ... elt -- ... n ) -- ... n )
    [ 0 ] 2dip [ dip + ] curry [ swap ] prepose each ; inline

: count ( ... seq quot: ( ... elt -- ... ? ) -- ... n ) [ 1 0 ? ] compose map-sum ; inline

: cartesian-each ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... ) -- ... )
    [ with each ] 2curry each ; inline

: cartesian-map ( ... seq1 seq2 quot: ( ... elt1 elt2 -- ... newelt ) -- ... newseq )
    [ with map ] 2curry map ; inline

: cartesian-product ( seq1 seq2 -- newseq )
    [ { } 2sequence ] cartesian-map ;

! We hand-optimize flip to such a degree because type hints
! cannot express that an array is an array of arrays yet, and
! this word happens to be performance-critical since the compiler
! itself uses it. Optimizing it like this reduced compile time.
<PRIVATE

: generic-flip ( matrix -- newmatrix )
    [ dup first length [ length min ] reduce iota ] keep
    [ [ nth-unsafe ] with { } map-as ] curry { } map-as ; inline

USE: arrays

: array-length ( array -- len )
    { array } declare length>> ; inline

: array-flip ( matrix -- newmatrix )
    { array } declare
    [ dup first array-length [ array-length min ] reduce iota ] keep
    [ [ { array } declare array-nth ] with { } map-as ] curry { } map-as ;

PRIVATE>

: flip ( matrix -- newmatrix )
    dup empty? [
        dup array? [
            dup [ array? ] all?
            [ array-flip ] [ generic-flip ] if
        ] [ generic-flip ] if
    ] unless ;
