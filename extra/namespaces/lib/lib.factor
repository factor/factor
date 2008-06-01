
! USING: kernel quotations namespaces sequences assocs.lib ;

USING: kernel namespaces namespaces.private quotations sequences
       assocs.lib math.parser math sequences.lib locals mirrors ;

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
: 3, 3 n, ;
: 3% 3 n% ;
: 3# 3 n# ;
: 4, 4 n, ;
: 4% 4 n% ;
: 4# 4 n# ;

MACRO:: nmake ( quot exemplars -- )
    [let | n [ exemplars length ] |
        [
            [
                exemplars
                [ 0 swap new-resizable ] map
                building-seq set

                quot call

                building-seq get
                exemplars [ like ] 2map
                n firstn
            ] with-scope
        ]
    ] ;

: make-object ( quot class -- object )
    new [ <mirror> swap bind ] keep ; inline

: with-object ( object quot -- )
    [ <mirror> ] dip bind ; inline
