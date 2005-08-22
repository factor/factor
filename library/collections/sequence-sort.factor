IN: sorting-internals
USING: kernel math sequences ;

: midpoint ( seq -- elt ) dup length 2 /i swap nth ; inline

TUPLE: sorter seq start end mid ;

C: sorter ( seq start end -- sorter )
    [ >r 1 + rot <slice> r> set-sorter-seq ] keep
    dup sorter-seq midpoint over set-sorter-mid
    dup sorter-seq length 1 - over set-sorter-end
    0 over set-sorter-start ;

: s*/e* dup sorter-start swap sorter-end ;
: s*/e dup sorter-start swap sorter-seq length 1 - ;
: s/e* 0 swap sorter-end ;
: sorter-exchange dup s*/e* rot sorter-seq exchange ;
: compare over sorter-seq nth swap sorter-mid rot call ; inline
: >start> dup sorter-start 1 + swap set-sorter-start ;
: <end< dup sorter-end 1 - swap set-sorter-end ;

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
    ] ifte 2drop ; inline

IN: sequences

: nsort ( seq quot -- | quot: elt elt -- -1/0/1 )
    swap dup empty?
    [ 2drop ] [ 0 over length 1 - (nsort) ] ifte ; inline

: sort ( seq quot -- seq | quot: elt elt -- -1/0/1 )
    swap [ swap nsort ] immutable ; inline
