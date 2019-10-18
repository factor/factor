! Compiler tests

"Checking compiler." print

[ 1 2 3 ] [ 4 5 6 ] [ t [ drop drop drop 1 2 3 ] when ] test-word
[ 4 5 6 ] [ 4 5 6 ] [ f [ drop drop drop 1 2 3 ] when ] test-word

[ t ] [ t ] [ [ t ] [ f ] rot [ drop call ] [ nip call ] ifte ] test-word
[ f ] [ f ] [ [ t ] [ f ] rot [ drop call ] [ nip call ] ifte ] test-word
[ 4 ] [ 2 ] [ t [ 2 ] [ 3 ] ifte + ] test-word
[ 5 ] [ 2 ] [ f [ 2 ] [ 3 ] ifte + ] test-word

: stack-frame-test ( x -- x )
    >r t [ r> ] [ rdrop 11 ] ifte ;

[ 10          ] [ 10         ] [ stack-frame-test ] test-word

: balance>list ( quotation -- list )
    balance effect>list ;

[ [ 1 1 0 0 ] ] [ [ sq     ] ] [ balance>list ] test-word
[ [ 2 1 0 0 ] ] [ [ mag2   ] ] [ balance>list ] test-word
[ [ 2 1 0 0 ] ] [ [ append ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ fac    ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ fib    ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ dup [ sq ] when ] ] [ balance>list ] test-word

: test-null-rec ( -- )
    [ [ 0 0 0 0 ] ] [ [ null-rec ] ] [ balance>list ] test-word ;

: null-rec ( -- )
    t [ null-rec ] when ; compile-maybe test-null-rec

: null-rec ( -- )
    t [ null-rec ] unless ; compile-maybe test-null-rec

: null-rec ( -- )
    t [ drop null-rec ] when* ; compile-maybe test-null-rec

!: null-rec ( -- )
!    t [ t null-rec ] unless* drop ; compile-maybe test-null-rec

[ f 1 2 3 ] [ [ [ 2 , 1 ] ] 3 ] [ [ unswons unswons ] dip ] test-word

[ [ 2 1 0 0 ] ] [ [ >r [ ] [ ] ? call r> ] ] [ balance>list ] test-word

: nested-rec ( -- )
    t [ nested-rec ] when ; compile-maybe

: nested-rec-test ( -- )
    5 nested-rec drop ; compile-maybe

[ [ 0 0 0 0 ] ] [ [ nested-rec-test ] ] [ balance>list ] test-word
"All compiler checks passed." print
