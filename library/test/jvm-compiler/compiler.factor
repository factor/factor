IN: scratchpad
USE: arithmetic
USE: combinators
USE: compiler
USE: inspector
USE: kernel
USE: lists
USE: logic
USE: math
USE: stack
USE: stdio
USE: test
USE: words

"Checking compiler." print

[ 1 2 3 ] [ 4 5 6 ] [ t [ 3drop 1 2 3 ] when ] test-word
[ 4 5 6 ] [ 4 5 6 ] [ f [ 3drop 1 2 3 ] when ] test-word

[ t ] [ t ] [ [ t ] [ f ] rot [ drop call ] [ nip call ] ifte ] test-word
[ f ] [ f ] [ [ t ] [ f ] rot [ drop call ] [ nip call ] ifte ] test-word
[ 4 ] [ 2 ] [ t [ 2 ] [ 3 ] ifte + ] test-word
[ 5 ] [ 2 ] [ f [ 2 ] [ 3 ] ifte + ] test-word

: stack-frame-test ( x -- x )
    >r t [ r> ] [ r> drop 11 ] ifte ; word must-compile

[ 10          ] [ 10         ] [ stack-frame-test ] test-word

[ [ 1 1 0 0 ] ] [ [ sq       ] ] [ balance>list ] test-word
[ [ 2 1 0 0 ] ] [ [ mag2     ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ fac      ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ fib      ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ balance  ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ dup [ sq ] when ] ] [ balance>list ] test-word

: null-rec ( -- )
    t [ null-rec ] when ; word must-compile

[ [ 0 0 0 0 ] ] [ [ null-rec ] ] [ balance>list ] test-word

: null-rec ( -- )
    t [ null-rec ] unless ; word must-compile

[ [ 0 0 0 0 ] ] [ [ null-rec ] ] [ balance>list ] test-word

: null-rec ( -- )
    t [ drop null-rec ] when* ; word must-compile

[ [ 0 0 0 0 ] ] [ [ null-rec ] ] [ balance>list ] test-word

!: null-rec ( -- )
!    t [ t null-rec ] unless* drop ; word must-compile test-null-rec

[ f 1 2 3 ] [ [ [ 2 | 1 ] ] 3 ] [ [ unswons unswons ] dip ] test-word

[ [ 2 1 0 0 ] ] [ [ >r [ ] [ ] ifte r> ] ] [ balance>list ] test-word

: nested-rec ( -- )
    t [ nested-rec ] when ; word must-compile

: nested-rec-test ( -- )
    5 nested-rec drop ; word must-compile

[ [ 0 0 0 0 ] ] [ [ nested-rec-test ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ relative>absolute-object-path ] ] [ balance>list ] test-word

! We had a problem with JVM stack overflow...

: null-map [ ] map ; word must-compile

! And a problem with stack normalization after ifte if both
! datastack and callstack were in use...

: map-test [ dup [ ] when ] map ; word must-compile

[ [ 1 2 3 ] ] [ [ 1 2 3 ] ] [ map-test ] test-word

: nested-test-iter f [ nested-test-iter ] when ;
: nested-test f nested-test-iter drop ; word must-compile

! Attempts at making setFields() lazy exposed some bugs with
! recursive compilations.

"car" decompile
"cdr" decompile
: nested-test-inline dup cdr swap car ; inline
: nested-test nested-test-inline ;
: nested-test-2 nested-test ; word must-compile

! Not all words that we compile calls do are from a
! FactorClassLoader; eg, primitives.

: calling-primitive-core define ; word must-compile

! Making sure compilation of these never breaks again for
! various reasons
"balance" must-compile
"decompile" must-compile

: 3-recurse ( -- )
    t [ t [ 3-recurse ] when ] [ 3-recurse ] ifte ;
    word must-compile

"All compiler checks passed." print
