IN: sequences-internals
USING: arrays kernel math sequences ;

: midpoint@ length 2 /i ; inline

: midpoint [ midpoint@ ] keep nth-unsafe ; inline

TUPLE: sorter seq start end mid ;

C: sorter ( seq start end -- sorter )
    [ >r 1+ rot <slice> r> set-sorter-seq ] keep
    dup sorter-seq midpoint over set-sorter-mid
    dup sorter-seq length 1- over set-sorter-end
    0 over set-sorter-start ; inline

: exchange ( n n seq -- )
    [ tuck nth-unsafe >r nth r> ] 3keep tuck
    >r >r set-nth-unsafe r> r> set-nth-unsafe ;

: s*/e* dup sorter-start swap sorter-end ; inline
: s*/e dup sorter-start swap sorter-seq length 1- ; inline
: s/e* 0 swap sorter-end ; inline
: sorter-exchange dup s*/e* rot sorter-seq exchange ; inline
: compare over sorter-seq nth-unsafe swap sorter-mid rot call ; inline
: >start> dup sorter-start 1+ swap set-sorter-start ; inline
: <end< dup sorter-end 1- swap set-sorter-end ; inline

: sort-up ( quot sorter -- quot sorter )
    dup s*/e < [
        [ dup sorter-start compare 0 < ] 2keep rot
        [ dup >start> sort-up ] when 
    ] when ; inline

: sort-down ( quot sorter -- quot sorter )
    dup s/e* <= [
        [ dup sorter-end compare 0 > ] 2keep rot
        [ dup <end< sort-down ] when
    ] when ; inline

: sort-step ( quot sorter -- quot sorter )
    dup s*/e* <= [
        sort-up sort-down dup s*/e* <= [
            dup sorter-exchange dup >start> dup <end< sort-step
        ] when
    ] when ; inline

DEFER: (nsort)

: (nsort) ( quot seq start end -- )
    2dup < [
        <sorter> sort-step
        [ dup sorter-seq swap s/e* (nsort) ] 2keep
        [ dup sorter-seq swap s*/e (nsort) ] 2keep
    ] [
        2drop
    ] if 2drop ; inline

: partition ( -1/1 seq -- seq )
    dup midpoint@ swap rot 1 <
    [ head-slice ] [ tail-slice ] if ; inline

: (binsearch) ( elt quot seq -- i )
    dup length 1 <= [
        2nip slice-from
    ] [
        3dup >r >r >r midpoint swap call dup 0 = [
            r> r> 3drop r> dup slice-from swap slice-to + 2 /i
        ] [
            r> swap r> swap r> partition (binsearch)
        ] if
    ] if ; inline

: flatten-slice ( seq -- slice )
    #! Binsearch returns an index relative to the sequence
    #! being sliced, so if we are given a slice as input,
    #! unexpected behavior will result.
    dup slice? [ >array ] when 0 over length rot <slice> ;
    inline

IN: sequences

: nsort ( seq quot -- | quot: elt elt -- -1/0/1 )
    swap dup length 1 <=
    [ 2drop ] [ 0 over length 1- (nsort) ] if ; inline

: sort ( seq quot -- seq | quot: elt elt -- -1/0/1 )
    swap [ swap nsort ] immutable ; inline

: number-sort ( seq -- seq ) [ - ] sort ;

: string-sort ( seq -- seq ) [ lexi ] sort ;

: binsearch ( elt seq quot -- i | quot: elt elt -- -1/0/1 )
    swap dup empty?
    [ 3drop -1 ] [ flatten-slice (binsearch) ] if ;
    inline

: binsearch* ( elt seq quot -- elt | quot: elt elt -- -1/0/1 )
    over >r binsearch dup -1 = [ r> 2drop f ] [ r> nth ] if ;
    inline
