! Tests the list words.

"Checking list words." print

! OUTPUT          INPUT               WORD
[ [ 2 1 0 0 ] ] [ [ 2list ] ] [ balance>list ] test-word
[ [ 1 2 ]     ] [ 1 2             ] [ 2list             ] test-word
[ [ 3 1 0 0 ] ] [ [ 3list ] ] [ balance>list ] test-word
[ [ 1 2 3 ]   ] [ 1 2 3           ] [ 3list             ] test-word
[ [ 2 1 0 0 ] ] [ [ 2rlist ] ] [ balance>list ] test-word
[ [ 2 1 ]     ] [ 1 2             ] [ 2rlist            ] test-word

[ [ 2 1 0 0 ] ] [ [ append ] ] [ balance>list ] test-word
[ [ ]         ] [ [ ]   [ ]       ] [ append            ] test-word
[ [ 1 ]       ] [ [ 1 ] [ ]       ] [ append            ] test-word
[ [ 2 ]       ] [ [ ] [ 2 ]       ] [ append            ] test-word
[ [ 1 2 3 4 ] ] [ [ 1 2 3 ] [ 4 ] ] [ append            ] test-word

[ [ 2 0 0 0 ] ] [ [ append@ ] ] [ balance>list ] test-word
[ [ 1 2 3 4 ] ] [ [ 3 4 ] [ 1 2 ] ] [ @x "x" append@ $x ] test-word

[ [ 1 1 0 0 ] ] [ [ array>list ] ] [ balance>list ] test-word
[ [ ]         ] [ [ ]             ] [ array>list        ] test-word
[ [ 1 2 3 ]   ] [ [ 1 2 3 ]       ] [ array>list        ] test-word

[ [ 2 0 0 0 ] ] [ [ add@ ] ] [ balance>list ] test-word
[ [ 1 2 3 4 ] ] [ 4 [ 1 2 3 ]     ] [ @x "x" add@ $x    ] test-word

[
    [ "monkey" , 1       ]
    [ "banana" , 2       ]
    [ "Java"   , 3       ]
    [ t        , "true"  ]
    [ f        , "false" ]
    [ [ 1 2 ]  , [ 2 1 ] ]
] @assoc

[ [ 2 1 0 0 ] ] [ [ assoc ] ] [ balance>list ] test-word
[ f           ] [ "monkey" f      ] [ assoc             ] test-word
[ f           ] [ "donkey" $assoc ] [ assoc             ] test-word
[ 1           ] [ "monkey" $assoc ] [ assoc             ] test-word
[ "false"     ] [ f        $assoc ] [ assoc             ] test-word
[ [ 2 1 ]     ] [ [ 1 2 ]  $assoc ] [ assoc             ] test-word

f @monkey
t @donkey
[ 1 2 ] @lisp

[
    [ "monkey" , 1       ]
    [ "donkey" , 2       ]
    [ "lisp"   , [ 2 1 ] ]
] @assoc

[ [ 2 1 0 0 ] ] [ [ assoc$ ] ] [ balance>list ] test-word
[ 1           ] [ f        $assoc ] [ assoc$            ] test-word
[ [ 2 1 ]     ] [ [ 1 2 ]  $assoc ] [ assoc$            ] test-word

[ [ 1 1 0 0 ] ] [ [ car ] ] [ balance>list ] test-word
[ 1           ] [ [ 1 , 2 ]       ] [ car               ] test-word
[ [ 1 1 0 0 ] ] [ [ cdr ] ] [ balance>list ] test-word
[ 2           ] [ [ 1 , 2 ]       ] [ cdr               ] test-word

[ [ 1 1 0 0 ] ] [ [ clone-list ] ] [ balance>list ] test-word
[ [ ]         ] [ [ ]             ] [ clone-list        ] test-word
[ [ 1 2 , 3 ] ] [ [ 1 2 , 3 ]     ] [ clone-list        ] test-word
[ [ 1 2 3 4 ] ] [ [ 1 2 3 4 ]     ] [ clone-list        ] test-word

: clone-list-actually-clones? ( list1 list2 -- )
    [ clone-list ] dip ! we don't want to mutate literals
    [ dup clone-list ] dip nappend = not ;

[ t ] [ [ 1 2 ] [ 3 4 ] ] [ clone-list-actually-clones? ] test-word

[ [ 2 1 0 0 ] ] [ [ cons ] ] [ balance>list ] test-word
[ [ 1 , 2 ]   ] [ 1 2             ] [ cons              ] test-word
[ [ 1 ]       ] [ 1 f             ] [ cons              ] test-word

[ [ 2 1 0 0 ] ] [ [ contains ] ] [ balance>list ] test-word
[ f           ] [ 3 [ ]           ] [ contains          ] test-word
[ f           ] [ 3 [ 1 2 ]       ] [ contains          ] test-word
[ [ 1 2 ]     ] [ 1 [ 1 2 ]       ] [ contains          ] test-word
[ [ 2 ]       ] [ 2 [ 1 2 ]       ] [ contains          ] test-word
[ [ 2 , 3 ]   ] [ 3 [ 1 2 , 3 ]   ] [ contains          ] do-not-test-word

[ [ 2 0 0 0 ] ] [ [ cons@ ] ] [ balance>list ] test-word
[ [ 1 ]       ] [ 1 f             ] [ @x "x" cons@ $x   ] test-word
[ [ 1 , 2 ]   ] [ 1 2             ] [ @x "x" cons@ $x   ] test-word
[ [ 1 2 ]     ] [ 1 [ 2 ]         ] [ @x "x" cons@ $x   ] test-word

[ [ 1 1 0 0 ] ] [ [ count ] ] [ balance>list ] do-not-test-word
[ [ ]         ] [ 0               ] [ count             ] test-word
[ [ ]         ] [ -10             ] [ count             ] test-word
[ [ ]         ] [ $-inf           ] [ count             ] test-word
[ [ 0 1 2 ]   ] [ $e              ] [ count             ] test-word
[ [ 0 1 2 3 ] ] [ 4               ] [ count             ] test-word

[ [ 2 1 0 0 ] ] [ [ get ] ] [ balance>list ] test-word
[ 1           ] [ [ 1 2 ] -1      ] [ get               ] test-word
[ 1           ] [ [ 1 2 ] 0       ] [ get               ] test-word
[ 2           ] [ [ 1 2 ] 1       ] [ get               ] test-word

[ [ 1 1 0 0 ] ] [ [ last* ] ] [ balance>list ] test-word
[ [ 3 ]       ] [ [ 3 ]           ] [ last*             ] test-word
[ [ 3 ]       ] [ [ 1 2 3 ]       ] [ last*             ] test-word
[ [ 3 , 4 ]   ] [ [ 1 2 3 , 4 ]   ] [ last*             ] test-word

[ [ 1 1 0 0 ] ] [ [ last ] ] [ balance>list ] test-word
[ 3           ] [ [ 3 ]           ] [ last              ] test-word
[ 3           ] [ [ 1 2 3 ]       ] [ last              ] test-word
[ 3           ] [ [ 1 2 3 , 4 ]   ] [ last              ] test-word

[ [ 1 1 0 0 ] ] [ [ length ] ] [ balance>list ] test-word
[ 0           ] [ [ ]             ] [ length            ] test-word
[ 3           ] [ [ 1 2 3 ]       ] [ length            ] test-word

! CMU CL bombs on (length '(1 2 3 . 4))
![ 3           ] [ [ 1 2 3 , 4 ]   ] [ length            ] test-word

[ [ 1 1 0 0 ] ] [ [ list? ] ] [ balance>list ] test-word
[ t           ] [ f               ] [ list?             ] test-word
[ f           ] [ t               ] [ list?             ] test-word
[ t           ] [ [ 1 2 ]         ] [ list?             ] test-word
[ f           ] [ [ 1 , 2 ]       ] [ list?             ] test-word

: clone-and-nappend ( list list -- list )
    [ clone-list ] 2apply nappend ;

[ [ ]         ] [ [ ]   [ ]       ] [ clone-and-nappend ] test-word
[ [ 1 ]       ] [ [ 1 ] [ ]       ] [ clone-and-nappend ] test-word
[ [ 2 ]       ] [ [ ] [ 2 ]       ] [ clone-and-nappend ] test-word
[ [ 1 2 3 4 ] ] [ [ 1 2 3 ] [ 4 ] ] [ clone-and-nappend ] test-word

: clone-and-nreverse ( list -- list )
    clone-list nreverse ;

[ [ 1 1 0 0 ] ] [ [ nreverse ] ] [ balance>list ] test-word
[ [ ]         ] [ [ ]             ] [ clone-and-nreverse ] test-word
[ [ 1 ]       ] [ [ 1 ]           ] [ clone-and-nreverse ] test-word
[ [ 3 2 1 ]   ] [ [ 1 2 3 ]       ] [ clone-and-nreverse ] test-word

[ 1 2 3 ] clone-list @x [ 4 5 6 ] clone-list @y

[ [ 2 1 0 0 ] ] [ [ nappend ] ] [ balance>list ] test-word
[ [ 4 5 6 ]   ] [ $x $y           ] [ nappend drop $y   ] test-word

[ 1 2 3 ] clone-list @x [ 4 5 6 ] clone-list @y

[ [ 1 2 3 4 5 6 ] ] [ $x $y       ] [ nappend drop $x   ] test-word

[ 2 ] [ 1 [ 1 2 3 ] ] [ next ] test-word
[ 1 ] [ 3 [ 1 2 3 ] ] [ next ] test-word
[ 1 ] [ 4 [ 1 2 3 ] ] [ next ] test-word

[ [ 1 1 0 0 ] ] [ [ cons? ] ] [ balance>list ] test-word
[ f           ] [ f               ] [ cons?             ] test-word
[ f           ] [ t               ] [ cons?             ] test-word
[ t           ] [ [ t , f ]       ] [ cons?             ] test-word

[ [ 2 1 0 0 ] ] [ [ remove ] ] [ balance>list ] test-word
[ [ ]       ] [ 1 [ ]               ] [ remove            ] test-word
[ [ ]       ] [ 1 [ 1 ]             ] [ remove            ] test-word
[ [ 3 1 1 ] ] [ 2 [ 3 2 1 2 1 ]     ] [ remove            ] test-word

[ [ 1 1 0 0 ] ] [ [ reverse ] ] [ balance>list ] test-word
[ [ ]         ] [ [ ]             ] [ reverse           ] test-word
[ [ 1 ]       ] [ [ 1 ]           ] [ reverse           ] test-word
[ [ 3 2 1 ]   ] [ [ 1 2 3 ]       ] [ reverse           ] test-word

[ [ 2 0 0 0 ] ] [ [ rplaca ] ] [ balance>list ] test-word
[ a , b ] clone-list @x
[ [ 1 , b ]   ] [ 1 $x            ] [ rplaca $x         ] test-word

[ [ 2 0 0 0 ] ] [ [ rplacd ] ] [ balance>list ] test-word
[ a , b ] clone-list @x                                         
[ [ a , 2 ]   ] [ 2 $x            ] [ rplacd $x         ] test-word

[ [ 2 2 0 0 ] ] [ [ [ < ] partition ] ] [ balance>list ] test-word
[ [ -5 3 1 ] [ -2 4 4 -2 ] ]
[ 2 [ 1 -2 3 4 -5 4 -2 ] ]
[ [ swap / ratio? ] partition ] test-word

[ [ 2 2 0 0 ] ] [ [ [ nip string? ] partition ] ] [ balance>list ] test-word
[ [ "d" "c" ] [ b a ] ]
[ f [ a b "c" "d" ] ]
[ [ nip string? ] partition ] test-word

[ [ 1 1 0 0 ] ] [ [ num-sort ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ str-sort ] ] [ balance>list ] test-word

[ [ 2 1 0 0 ] ] [ [ swons ] ] [ balance>list ] test-word                                                     
[ [ 1 , 2 ]   ] [ 2 1             ] [ swons             ] test-word
[ [ 1 ]       ] [ f 1             ] [ swons             ] test-word

[ [ 2 0 0 0 ] ] [ [ swons@ ] ] [ balance>list ] test-word
[ [ 1 ]       ] [ 1 f         ] [ @x "x" swap swons@ $x ] test-word
[ [ 1 , 2 ]   ] [ 1 2         ] [ @x "x" swap swons@ $x ] test-word
[ [ 1 2 ]     ] [ 1 [ 2 ]     ] [ @x "x" swap swons@ $x ] test-word

[ [ 2 1 0 0 ] ] [ [ tree-contains   ] ] [ balance>list ] test-word
[ f ] [ 3 [ ]             ] [ tree-contains     ] test-word
[ f ] [ 3 [ 1 [ 3 ] 2 ]   ] [ tree-contains not ] test-word
[ f ] [ 1 [ [ [ 1 ] ] 2 ] ] [ tree-contains not ] test-word
[ f ] [ 2 [ 1 2 ]         ] [ tree-contains not ] test-word
[ f ] [ 3 [ 1 2 , 3 ]     ] [ tree-contains not ] test-word

[ [ 1 2 0 0 ] ] [ [ uncons ] ] [ balance>list ] test-word
[ 1 2         ] [ [ 1 , 2 ]   ] [ uncons                ] test-word
[ 1 [ 2 ]     ] [ [ 1 2 ]     ] [ uncons                ] test-word

[ [ 2 1 0 0 ] ] [ [ unique ] ] [ balance>list ] test-word
[ [ 1 2 3 ]   ] [ 1 [ 2 3 ]   ] [ unique                ] test-word
[ [ 1 2 3 ]   ] [ 1 [ 1 2 3 ] ] [ unique                ] test-word
[ [ 1 2 3 ]   ] [ 2 [ 1 2 3 ] ] [ unique                ] test-word

[ [ 1 1 0 0 ] ] [ [ unit ] ] [ balance>list ] test-word
[ [ [ [ ] ] ] ] [ [ ]         ] [ unit unit             ] test-word

[ [ 1 2 0 0 ] ] [ [ unswons ] ] [ balance>list ] test-word
[ 1 2         ] [ [ 2 , 1 ]   ] [ unswons               ] test-word
[ [ 2 ] 1     ] [ [ 1 2 ]     ] [ unswons               ] test-word

"List checks passed." print
