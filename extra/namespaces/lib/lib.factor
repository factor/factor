
! USING: kernel quotations namespaces sequences assocs.lib ;

USING: kernel namespaces namespaces.private quotations sequences
       assocs.lib math.parser math sequences.lib ;

IN: namespaces.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: save-namestack ( quot -- ) namestack >r call r> set-namestack ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make* ( seq -- seq ) [ dup quotation? [ call ] [ ] if ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set* ( val var -- ) namestack* set-assoc-stack ;

SYMBOL: building-seq 
: get-building-seq ( n -- seq )
    building-seq get nth ;

: n, get-building-seq push ;
: n% get-building-seq push-all ;
: n# >r number>string r> n% ;

: 0, 0 n, ;
: 0% 0 n% ;
: 0# 0 n# ;
: 1, 1 n, ;
: 1% 1 n% ;
: 1# 1 n# ;
: 2, 2 n, ;
: 2% 2 n% ;
: 2# 2 n# ;

: nmake ( quot exemplars -- seqs )
    dup length dup zero? [ 1+ ] when
    [
        [
            [ drop 1024 swap new-resizable ] 2map
            [ building-seq set call ] keep
        ] 2keep >r [ like ] 2map r> firstn 
    ] with-scope ;
