! Tests the list words.

"Checking list words." print

! OUTPUT          INPUT               WORD
[ [ 1 2 ]     ] [ 1 2             ] [ 2list             ] test-word
[ [ 1 2 3 ]   ] [ 1 2 3           ] [ 3list             ] test-word
[ [ 2 1 ]     ] [ 1 2             ] [ 2rlist            ] test-word

[ [ ]         ] [ [ ]   [ ]       ] [ append            ] test-word
[ [ 1 ]       ] [ [ 1 ] [ ]       ] [ append            ] test-word
[ [ 2 ]       ] [ [ ] [ 2 ]       ] [ append            ] test-word
[ [ 1 2 3 4 ] ] [ [ 1 2 3 ] [ 4 ] ] [ append            ] test-word

[ [ 1 2 3 4 ] ] [ [ 3 4 ] [ 1 2 ] ] [ @x "x" append@ $x ] test-word

[ [ ]         ] [ [ ]             ] [ array>list        ] test-word
[ [ 1 2 3 ]   ] [ [ 1 2 3 ]       ] [ array>list        ] test-word

[ [ 1 2 3 4 ] ] [ 4 [ 1 2 3 ]     ] [ @x "x" add@ $x    ] test-word

[
    [ "monkey" , 1       ]
    [ "banana" , 2       ]
    [ "Java"   , 3       ]
    [ t        , "true"  ]
    [ f        , "false" ]
    [ [ 1 2 ]  , [ 2 1 ] ]
] @assoc

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

[ 1           ] [ f        $assoc ] [ assoc$            ] test-word
[ [ 2 1 ]     ] [ [ 1 2 ]  $assoc ] [ assoc$            ] test-word

[ 1           ] [ [ 1 , 2 ]       ] [ car               ] test-word
[ 2           ] [ [ 1 , 2 ]       ] [ cdr               ] test-word

[ [ ]         ] [ [ ]             ] [ clone-list        ] test-word
[ [ 1 2 , 3 ] ] [ [ 1 2 , 3 ]     ] [ clone-list        ] test-word
[ [ 1 2 3 4 ] ] [ [ 1 2 3 4 ]     ] [ clone-list        ] test-word

: clone-list-actually-clones? ( list1 list2 -- )
    [ clone-list ] dip ! we don't want to mutate literals
    [ dup clone-list ] dip nappend = not ;

[ t ] [ [ 1 2 ] [ 3 4 ] ] [ clone-list-actually-clones? ] test-word

[ [ 1 , 2 ]   ] [ 1 2             ] [ cons              ] test-word
[ [ 1 ]       ] [ 1 f             ] [ cons              ] test-word

[ f           ] [ 3 [ ]           ] [ contains          ] test-word
[ f           ] [ 3 [ 1 2 ]       ] [ contains          ] test-word
[ [ 1 2 ]     ] [ 1 [ 1 2 ]       ] [ contains          ] test-word
[ [ 2 ]       ] [ 2 [ 1 2 ]       ] [ contains          ] test-word

[ [ 1 ]       ] [ 1 f             ] [ @x "x" cons@ $x   ] test-word
[ [ 1 , 2 ]   ] [ 1 2             ] [ @x "x" cons@ $x   ] test-word
[ [ 1 2 ]     ] [ 1 [ 2 ]         ] [ @x "x" cons@ $x   ] test-word

[ [ ]         ] [ 0               ] [ count             ] test-word
[ [ ]         ] [ -10             ] [ count             ] test-word
[ [ ]         ] [ $-inf           ] [ count             ] test-word
[ [ 0 1 2 ]   ] [ $e              ] [ count             ] test-word
[ [ 0 1 2 3 ] ] [ 4               ] [ count             ] test-word

[ 1           ] [ [ 1 2 ] -1      ] [ get               ] test-word
[ 1           ] [ [ 1 2 ] 0       ] [ get               ] test-word
[ 2           ] [ [ 1 2 ] 1       ] [ get               ] test-word

[ [ 3 ]       ] [ [ 3 ]           ] [ last*             ] test-word
[ [ 3 ]       ] [ [ 1 2 3 ]       ] [ last*             ] test-word
[ [ 3 , 4 ]   ] [ [ 1 2 3 , 4 ]   ] [ last*             ] test-word

[ 3           ] [ [ 3 ]           ] [ last              ] test-word
[ 3           ] [ [ 1 2 3 ]       ] [ last              ] test-word
[ 3           ] [ [ 1 2 3 , 4 ]   ] [ last              ] test-word

[ 0           ] [ [ ]             ] [ length            ] test-word
[ 3           ] [ [ 1 2 3 ]       ] [ length            ] test-word

! CMU CL bombs on (length '(1 2 3 . 4))
![ 3           ] [ [ 1 2 3 , 4 ]   ] [ length            ] test-word

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

[ 1 2 3 ] clone-list @x [ 4 5 6 ] clone-list @y

[ [ 4 5 6 ]   ] [ $x $y           ] [ nappend drop $y   ] test-word

[ 1 2 3 ] clone-list @x [ 4 5 6 ] clone-list @y

[ [ 1 2 3 4 5 6 ] ] [ $x $y       ] [ nappend drop $x   ] test-word

[ f           ] [ f               ] [ cons?             ] test-word
[ f           ] [ t               ] [ cons?             ] test-word
[ t           ] [ [ t , f ]       ] [ cons?             ] test-word

[ [ ]         ] [ [ ]             ] [ reverse           ] test-word
[ [ 1 ]       ] [ [ 1 ]           ] [ reverse           ] test-word
[ [ 3 2 1 ]   ] [ [ 1 2 3 ]       ] [ reverse           ] test-word

[ a , b ] clone-list @x
[ [ 1 , b ]   ] [ 1 $x            ] [ rplaca $x         ] test-word
                                                     
[ a , b ] clone-list @x                                         
[ [ a , 2 ]   ] [ 2 $x            ] [ rplacd $x         ] test-word
                                                     
[ [ 1 , 2 ]   ] [ 2 1             ] [ swons             ] test-word
[ [ 1 ]       ] [ f 1             ] [ swons             ] test-word

[ [ 1 ]       ] [ 1 f         ] [ @x "x" swap swons@ $x ] test-word
[ [ 1 , 2 ]   ] [ 1 2         ] [ @x "x" swap swons@ $x ] test-word
[ [ 1 2 ]     ] [ 1 [ 2 ]     ] [ @x "x" swap swons@ $x ] test-word

[ 1 2         ] [ [ 1 , 2 ]   ] [ uncons                ] test-word
[ 1 [ 2 ]     ] [ [ 1 2 ]     ] [ uncons                ] test-word

[ [ 1 2 3 ]   ] [ 1 [ 2 3 ]   ] [ unique                ] test-word
[ [ 1 2 3 ]   ] [ 1 [ 1 2 3 ] ] [ unique                ] test-word
[ [ 1 2 3 ]   ] [ 2 [ 1 2 3 ] ] [ unique                ] test-word

[ [ [ [ ] ] ] ] [ [ ]         ] [ unit unit             ] test-word

[ 1 2         ] [ [ 2 , 1 ]   ] [ unswons               ] test-word
[ [ 2 ] 1     ] [ [ 1 2 ]     ] [ unswons               ] test-word

"List checks passed." print
