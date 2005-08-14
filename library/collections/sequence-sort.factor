IN: sorting-internals
USING: kernel math sequences ;

TUPLE: iterator n seq ;

: >iterator< dup iterator-n swap iterator-seq ;

: forward ( iterator -- ) dup iterator-n 1 + swap set-iterator-n ;

: backward ( iterator -- ) dup iterator-n 1 - swap set-iterator-n ;

: current ( iterator -- elt ) >iterator< nth ;

: set-current ( elt iterator -- ) >iterator< set-nth ;

: exchange ( iterator iterator -- )
    #! Exchange elements pointed at by two iterators.
    over current over current
    >r swap set-current r> swap set-current ;

: iterators ( iterator iterator -- n n )
    >r iterator-n r> iterator-n ;

: midpoint ( iterator iterator -- elt )
    #! Both iterators must point at the same collection.
    [ iterators + 2 /i ] keep iterator-seq nth ;

TUPLE: partition start start* end end* mid ;

C: partition ( start end -- partition )
    >r 2dup 2dup r>
    [ >r midpoint r> set-partition-mid ] keep
    [ set-partition-end ] keep
    [ set-partition-start ] keep
    [ >r clone r> set-partition-end* ] keep
    [ >r clone r> set-partition-start* ] keep ; inline

: s/e dup partition-start swap partition-end ; inline
: s*/e dup partition-start* swap partition-end ; inline
: s/e* dup partition-start swap partition-end* ; inline
: s*/e* dup partition-start* swap partition-end* ; inline

: seq-partition ( seq -- partition )
    0 over <iterator> swap dup length 1 - swap <iterator>
    <partition> ; inline

: compare-step ( quot partition iter -- n )
    current swap partition-mid rot call ; inline

: partition< ( quot partition -- ? )
    dup s*/e iterators <
    [ dup partition-start* compare-step 0 < ]
    [ 2drop f ] ifte ; inline

: partition> ( quot partition -- ? )
    dup s/e* iterators <=
    [ dup partition-end* compare-step 0 > ]
    [ 2drop f ] ifte ; inline

: sort-up ( quot partition -- )
    [ partition< ] 2keep rot
    [ dup partition-start* forward sort-up ] [ 2drop ] ifte ;
    inline

: sort-down ( quot partition -- )
    [ partition> ] 2keep rot
    [ dup partition-end* backward sort-down ] [ 2drop ] ifte ;
    inline

: keep-sorting? ( partition -- ? ) s*/e* iterators <= ; inline

: sort-step ( quot partition -- )
    dup keep-sorting? [
        2dup sort-up 2dup sort-down dup keep-sorting?
        [ dup s*/e* 2dup exchange backward forward sort-step ]
        [ 2drop ] ifte
    ] [
        2drop
    ] ifte ; inline

: left ( partition -- partition )
    dup s/e* iterators < [ s/e* <partition> ] [ drop f ] ifte ;
    inline

: right ( partition -- partition )
    dup s*/e iterators < [ s*/e <partition> ] [ drop f ] ifte ;
    inline

: (nsort) ( quot partition -- )
    dup keep-sorting? [
        [ sort-step ] 2keep
        [ left dup [ (nsort) ] [ 2drop ] ifte ] 2keep
        right dup [ (nsort) ] [ 2drop ] ifte
    ] [
        2drop
    ] ifte ; inline

IN: sequences

: nsort ( seq quot -- | quot: elt elt -- -1/0/1 )
    over empty?
    [ 2drop ] [ swap seq-partition (nsort) ] ifte ; inline

: sort ( seq quot -- seq | quot: elt elt -- -1/0/1 )
    swap [ swap nsort ] immutable ; inline
