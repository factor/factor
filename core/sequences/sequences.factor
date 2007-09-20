! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences
USING: kernel kernel.private slots.private math math.private ;

MIXIN: sequence

GENERIC: length ( seq -- n ) flushable
GENERIC: set-length ( n seq -- )
GENERIC: nth ( n seq -- elt ) flushable
GENERIC: set-nth ( elt n seq -- )
GENERIC: new ( len seq -- newseq ) flushable
GENERIC: new-resizable ( len seq -- newseq ) flushable
GENERIC: like ( seq exemplar -- newseq ) flushable
GENERIC: clone-like ( seq exemplar -- newseq ) flushable

: new-like ( len exemplar quot -- seq )
    over >r >r new r> call r> like ; inline

M: sequence like drop ;

GENERIC: lengthen ( n seq -- )

M: sequence lengthen 2dup length > [ set-length ] [ 2drop ] if ;

: empty? ( seq -- ? ) length zero? ; inline
: delete-all ( seq -- ) 0 swap set-length ;

: first ( seq -- first ) 0 swap nth ; inline
: second ( seq -- second ) 1 swap nth ; inline
: third ( seq -- third ) 2 swap nth ; inline
: fourth  ( seq -- fourth ) 3 swap nth ; inline

: set-first ( first seq -- ) 0 swap set-nth ; inline
: set-second ( second seq -- ) 1 swap set-nth ; inline
: set-third ( third seq -- ) 2 swap set-nth ; inline
: set-fourth  ( fourth seq -- ) 3 swap set-nth ; inline

: push ( elt seq -- ) dup length swap set-nth ;

: bounds-check? ( n seq -- ? )
    length 1- 0 swap between? ; inline

TUPLE: bounds-error index seq ;

: bounds-error ( n seq -- * )
    \ bounds-error construct-boa throw ;

: bounds-check ( n seq -- n seq )
    2dup bounds-check? [ bounds-error ] unless ; inline

MIXIN: immutable-sequence

TUPLE: immutable seq ;

: immutable ( seq -- * ) \ immutable construct-boa throw ;

M: immutable-sequence set-nth immutable ;

INSTANCE: immutable-sequence sequence

<PRIVATE

: max-array-capacity ( -- n )
    #! A bit of a pain; can't call cell-bits here
    7 getenv 8 * 5 - 2^ 1- ; foldable

PREDICATE: fixnum array-capacity
    0 max-array-capacity between? ;

: array-capacity ( array -- n )
    1 slot { array-capacity } declare ; inline

: array-nth ( n array -- elt )
    swap 2 fixnum+fast slot ; inline

: set-array-nth ( elt n array -- )
    swap 2 fixnum+fast set-slot ; inline

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
M: f like drop dup empty? [ drop f ] when ;

INSTANCE: f immutable-sequence

! Integers support the sequence protocol
M: integer length ;
M: integer nth-unsafe drop ;

INSTANCE: integer immutable-sequence

: first2-unsafe
    [ 0 swap nth-unsafe ] keep 1 swap nth-unsafe ; inline

: first3-unsafe
    [ first2-unsafe ] keep 2 swap nth-unsafe ; inline

: first4-unsafe
    [ first3-unsafe ] keep 3 swap nth-unsafe ; inline

: exchange-unsafe ( m n seq -- )
    [ tuck nth-unsafe >r nth-unsafe r> ] 3keep tuck
    >r >r set-nth-unsafe r> r> set-nth-unsafe ; inline

: (head) ( seq n -- from to seq ) 0 swap rot ; inline

: (tail) ( seq n -- from to seq ) over length rot ; inline

: from-end >r dup length r> - ; inline

: (2sequence)
    tuck 1 swap set-nth-unsafe
    tuck 0 swap set-nth-unsafe ; inline

: (3sequence)
    tuck 2 swap set-nth-unsafe
    (2sequence) ; inline

: (4sequence)
    tuck 3 swap set-nth-unsafe
    (3sequence) ; inline

PRIVATE>

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
M: virtual-sequence new virtual-seq new ;

INSTANCE: virtual-sequence sequence

! A reversal of an underlying sequence.
TUPLE: reversed seq ;

C: <reversed> reversed

M: reversed virtual-seq reversed-seq ;
M: reversed virtual@ reversed-seq [ length swap - 1- ] keep ;
M: reversed length reversed-seq length ;

INSTANCE: reversed virtual-sequence

: reverse ( seq -- newseq ) [ <reversed> ] keep like ;

! A slice of another sequence.
TUPLE: slice from to seq ;

: collapse-slice ( m n slice -- m' n' seq )
    dup slice-from swap slice-seq >r tuck + >r + r> r> ; inline

TUPLE: slice-error reason ;
: slice-error ( str -- * ) \ slice-error construct-boa throw ;

: check-slice ( from to seq -- )
    pick 0 < [ "start < 0" slice-error ] when
    length over < [ "end > sequence" slice-error ] when
    > [ "start > end" slice-error ] when ;

: <slice> ( from to seq -- slice )
    dup slice? [ collapse-slice ] when
    3dup check-slice
    slice construct-boa ;

M: slice virtual-seq slice-seq ;
M: slice virtual@ [ slice-from + ] keep slice-seq ;
M: slice length dup slice-to swap slice-from - ;

: head-slice ( seq n -- slice ) (head) <slice> ;

: tail-slice ( seq n -- slice ) (tail) <slice> ;

: head-slice* ( seq n -- slice ) from-end head-slice ;

: tail-slice* ( seq n -- slice ) from-end tail-slice ;

INSTANCE: slice virtual-sequence

! A column of a matrix
TUPLE: column seq col ;

C: <column> column

M: column virtual-seq column-seq ;
M: column virtual@ dup column-col -rot column-seq nth ;
M: column length column-seq length ;

INSTANCE: column virtual-sequence

! One element repeated many times
TUPLE: repetition len elt ;

C: <repetition> repetition

M: repetition length repetition-len ;
M: repetition nth-unsafe nip repetition-elt ;

INSTANCE: repetition immutable-sequence

<PRIVATE

: ((copy)) ( dst i src j n -- dst i src j n )
    dup -roll [
        + swap nth-unsafe -roll [
            + swap set-nth-unsafe
        ] 3keep drop
    ] 3keep ; inline

: (copy) ( dst i src j n -- dst )
    dup 0 <= [ 2drop 2drop ] [ 1- ((copy)) (copy) ] if ; inline

: prepare-subseq ( from to seq -- dst i src j n )
    [ >r swap - r> new dup 0 ] 3keep
    -rot drop roll length ; inline

: check-copy ( src n dst -- )
    over 0 < [ bounds-error ] when
    >r swap length + r> lengthen ;

PRIVATE>

: subseq ( from to seq -- subseq )
    [ 3dup check-slice prepare-subseq (copy) ] keep like ;

: head ( seq n -- headseq ) (head) subseq ;

: tail ( seq n -- tailseq ) (tail) subseq ;

: head* ( seq n -- headseq ) from-end head ;

: tail* ( seq n -- tailseq ) from-end tail ;

: copy ( src i dst -- )
    pick length >r 3dup check-copy swap rot 0 r>
    (copy) drop ; inline

M: sequence clone-like
    >r dup length r> new [ 0 swap copy ] keep ;

M: immutable-sequence clone-like like ;

: push-all ( src dest -- ) [ length ] keep copy ;

: ((append)) ( seq1 seq2 accum -- accum )
    [ >r over length r> copy ] keep
    [ 0 swap copy ] keep ; inline

: (append) ( seq1 seq2 exemplar -- newseq )
    >r over length over length + r>
    [ ((append)) ] new-like ; inline

: (3append) ( seq1 seq2 seq3 exemplar -- newseq )
    >r pick length pick length pick length + + r> [
        [ >r pick length pick length + r> copy ] keep
        ((append))
    ] new-like ; inline

: append ( seq1 seq2 -- newseq ) over (append) ;

: 3append ( seq1 seq2 seq3 -- newseq ) pick (3append) ;

: change-nth ( i seq quot -- )
    [ >r nth r> call ] 3keep drop set-nth ; inline

: min-length ( seq1 seq2 -- n ) [ length ] 2apply min ; inline

: max-length ( seq1 seq2 -- n ) [ length ] 2apply max ; inline

<PRIVATE

: iterate-seq >r dup length swap r> ; inline

: (each) ( seq quot -- n quot' )
    iterate-seq [ >r nth-unsafe r> call ] 2curry ; inline

: (collect) ( quot into -- quot' )
    [ >r over slip r> set-nth-unsafe ] 2curry ; inline

: collect ( n quot into -- )
    (collect) each-integer ; inline

: map-into ( seq quot into -- )
    >r (each) r> collect ; inline

: 2nth-unsafe ( n seq1 seq2 -- elt1 elt2 )
    >r over r> nth-unsafe >r nth-unsafe r> ; inline

: (2each) ( seq1 seq2 quot -- n quot' )
    >r [ min-length ] 2keep r>
    [ >r 2nth-unsafe r> call ] 3curry ; inline

: finish-find ( i seq -- i elt )
    over [ dupd nth-unsafe ] [ drop f ] if ; inline

: (find) ( seq quot quot' -- i elt )
    pick >r >r (each) r> call r> finish-find ; inline

: (find*) ( n seq quot quot' -- i elt )
    >r >r 2dup bounds-check? [
        r> r> (find)
    ] [
        r> r> 2drop 2drop f f
    ] if ; inline

: (monotonic) ( seq quot -- ? )
    [ 2dup nth-unsafe rot 1+ rot nth-unsafe ]
    swap compose curry ; inline

: (interleave) ( n elt between quot -- )
    roll zero? [ nip ] [ swapd 2slip ] if call ; inline

PRIVATE>

: each ( seq quot -- )
    (each) each-integer ; inline

: reduce ( seq identity quot -- result )
    swapd each ; inline

: map-as ( seq quot exemplar -- newseq )
    >r over length r> [ [ map-into ] keep ] new-like ; inline

: map ( seq quot -- newseq )
    over map-as ; inline

: change-each ( seq quot -- )
    over map-into ; inline

: accumulate ( seq identity quot -- final newseq )
    swapd [ pick slip ] curry map ; inline

: 2each ( seq1 seq2 quot -- )
    (2each) each-integer ; inline

: 2reverse-each ( seq1 seq2 quot -- )
    >r [ <reversed> ] 2apply r> 2each ; inline

: 2reduce ( seq1 seq2 identity quot -- result )
    >r -rot r> 2each ; inline

: 2map ( seq1 seq2 quot -- newseq )
    pick >r (2each) over r>
    [ [ collect ] keep ] new-like ; inline

: 2all? ( seq1 seq2 quot -- ? )
    (2each) all-integers? ; inline

: find* ( n seq quot -- i elt )
    [ (find-integer) ] (find*) ; inline

: find ( seq quot -- i elt )
    [ find-integer ] (find) ; inline

: find-last* ( n seq quot -- i elt )
    [ nip find-last-integer ] (find*) ; inline

: find-last ( seq quot -- i elt )
    [ >r 1- r> find-last-integer ] (find) ; inline

: all? ( seq quot -- ? )
    (each) all-integers? ; inline

: push-if ( elt quot accum -- )
    >r keep r> rot [ push ] [ 2drop ] if  ; inline

: pusher ( quot -- quot accum )
    V{ } clone [ [ push-if ] 2curry ] keep ; inline

: subset ( seq quot -- subseq )
    over >r pusher >r each r> r> like ; inline

: monotonic? ( seq quot -- ? )
    >r dup length 1- swap r> (monotonic) all? ; inline

: interleave ( seq between quot -- )
    [ (interleave) ] 2curry iterate-seq 2each ; inline

: index ( obj seq -- n )
    [ = ] curry* find drop ;

: index* ( obj i seq -- n )
    rot [ = ] curry find* drop ;

: last-index ( obj seq -- n )
    [ = ] curry* find-last drop ;

: last-index* ( obj i seq -- n )
    rot [ = ] curry find-last* drop ;

: contains? ( seq quot -- ? )
    find drop >boolean ; inline

: member? ( obj seq -- ? )
    [ = ] curry* contains? ;

: memq? ( obj seq -- ? )
    [ eq? ] curry* contains? ;

: remove ( obj seq -- newseq )
    [ = not ] curry* subset ;

: cache-nth ( i seq quot -- elt )
    pick pick ?nth dup [
        >r 3drop r>
    ] [
        drop swap >r over >r call dup r> r> set-nth
    ] if ; inline

: mismatch ( seq1 seq2 -- i )
    [ min-length ] 2keep
    [ 2nth-unsafe = not ] 2curry
    find drop ; inline

M: sequence <=>
    2dup mismatch
    [ -rot 2nth-unsafe <=> ] [ [ length ] compare ] if* ;

: sequence= ( seq1 seq2 -- ? )
    2dup [ length ] 2apply number=
    [ mismatch not ] [ 2drop f ] if ; inline

: move ( to from seq -- )
    pick pick number=
    [ 3drop ] [ [ nth swap ] keep set-nth ] if ; inline

: (delete) ( elt store scan seq -- elt store scan seq )
    2dup length < [
        3dup move
        [ nth pick = ] 2keep rot
        [ >r >r 1+ r> r> ] unless >r 1+ r> (delete)
    ] when ;

: delete ( elt seq -- ) 0 0 rot (delete) nip set-length drop ;

: push-new ( elt seq -- ) [ delete ] 2keep push ;

: add ( seq elt -- newseq )
    over >r over length 1+ r> [
        [ >r over length r> set-nth-unsafe ] keep
        [ 0 swap copy ] keep
    ] new-like ;

: add* ( seq elt -- newseq )
    over >r over length 1+ r> [
        [ 0 swap set-nth-unsafe ] keep
        [ 1 swap copy ] keep
    ] new-like ;

: seq-diff ( seq1 seq2 -- newseq )
    swap [ member? not ] curry subset ;

: peek ( seq -- elt ) dup length 1- swap nth ;

: pop* ( seq -- ) dup length 1- swap set-length ;

: move-backward ( shift from to seq -- )
    pick pick number= [
        2drop 2drop
    ] [
        [ >r pick pick + pick r> move >r 1+ r> ] keep
        move-backward
    ] if ;

: move-forward ( shift from to seq -- )
    pick pick number= [
        2drop 2drop
    ] [
        [ >r pick >r dup dup r> + swap r> move 1- ] keep
        move-forward
    ] if ;

: (open-slice) ( shift from to seq ? -- )
    [
        >r >r 1- r> 1- r> move-forward
    ] [
        >r >r over - r> r> move-backward
    ] if ;

: open-slice ( shift from seq -- )
    pick zero? [
        3drop
    ] [
        pick over length + over >r >r
        pick 0 > >r [ length ] keep r> (open-slice)
        r> r> set-length
    ] if ;

: delete-slice ( from to seq -- )
    3dup check-slice >r over >r - r> r> open-slice ;

: delete-nth ( n seq -- )
    >r dup 1+ r> delete-slice ;

: replace-slice ( new from to seq -- )
    [ >r >r dup pick length + r> - over r> open-slice ] keep
    copy ;

: pop ( seq -- elt )
    dup length 1- swap [ nth ] 2keep set-length ;

: all-equal? ( seq -- ? ) [ = ] monotonic? ;

: all-eq? ( seq -- ? ) [ eq? ] monotonic? ;

: flip ( matrix -- newmatrix )
    dup empty? [
        dup first length [ <column> dup like ] curry* map
    ] unless ;

: exchange ( m n seq -- )
    pick over bounds-check 2drop 2dup bounds-check 2drop
    exchange-unsafe ;

: reverse-here ( seq -- )
    dup length dup 2/ [
        >r 2dup r>
        tuck - 1- rot exchange-unsafe
    ] each 2drop ;

: sum-lengths ( seq -- n )
    0 [ length + ] reduce ;

: concat ( seq -- newseq )
    dup empty? [
        drop { }
    ] [
        [ sum-lengths ] keep
        [ first new-resizable ] keep
        [ [ over push-all ] each ] keep
        first like
    ] if ;

: joined-length ( seq glue -- n )
    >r dup sum-lengths swap length 1 [-] r> length * + ;

: join ( seq glue -- newseq )
    [
        2dup joined-length over new-resizable -rot swap
        [ dup pick push-all ] [ pick push-all ] interleave drop
    ] keep like ;

: padding ( seq n elt quot -- newseq )
    >r >r over length [-] dup zero?
    [ r> r> 3drop ] [ r> <repetition> r> call ] if ; inline

: pad-left ( seq n elt -- padded )
    [ swap dup (append) ] padding ;

: pad-right ( seq n elt -- padded )
    [ append ] padding ;

: shorter? ( seq1 seq2 -- ? ) >r length r> length < ;

: head? ( seq begin -- ? )
    2dup shorter? [
        2drop f
    ] [
        tuck length head-slice sequence=
    ] if ;

: tail? ( seq end -- ? )
    2dup shorter? [
        2drop f
    ] [
        tuck length tail-slice* sequence=
    ] if ;

: cut-slice ( n seq -- before after )
    swap [ head ] 2keep tail-slice ;

: cut ( n seq -- before after )
    swap [ head ] 2keep tail ;

: cut* ( n seq -- before after )
    swap [ head* ] 2keep tail* ;

<PRIVATE

: (start) ( subseq seq n -- subseq seq ? )
    pick length [
        >r 3dup r> [ + swap nth-unsafe ] keep rot nth-unsafe =
    ] all? nip ; inline

PRIVATE>

: start* ( subseq seq n -- i )
    pick length pick length swap - 1+
    [ (start) ] find*
    swap >r 3drop r> ;

: start ( subseq seq -- i ) 0 start* ; inline

: subseq? ( subseq seq -- ? ) start >boolean ;

: drop-prefix ( seq1 seq2 -- slice1 slice2 )
    2dup mismatch [ 2dup min-length ] unless*
    tuck tail-slice >r tail-slice r> ;

: unclip ( seq -- rest first )
    dup 1 tail swap first ;

: unclip-slice ( seq -- rest first )
    dup 1 tail-slice swap first ;

: <flat-slice> ( seq -- slice )
    dup slice? [ { } like ] when 0 over length rot <slice> ;
    inline

: ltrim ( seq quot -- newseq )
    over >r [ not ] compose find drop
    r> swap [ tail ] when* ; inline

: rtrim ( seq quot -- newseq )
    over >r [ not ] compose find-last drop
    r> swap [ 1+ head ] when* ; inline

: trim ( seq quot -- newseq )
    [ ltrim ] keep rtrim ; inline
