IN: scratchpad
USE: arithmetic
USE: combinators
USE: compiler
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: stack
USE: stdio
USE: strings
USE: test

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
[ [ 1 2 3 4 ] ] [ [ 3 4 ] [ 1 2 ] ] [ "x" set "x" append@ "x" get ] test-word

[ [ 1 1 0 0 ] ] [ [ array>list ] ] [ balance>list ] test-word
[ [ ]         ] [ [ ]             ] [ array>list        ] test-word
[ [ 1 2 3 ]   ] [ [ 1 2 3 ]       ] [ array>list        ] test-word

[ [ 2 0 0 0 ] ] [ [ add@ ] ] [ balance>list ] test-word
[ [ 1 2 3 4 ] ] [ 4 [ 1 2 3 ]     ] [ "x" set "x" add@ "x" get    ] test-word

[ [ 1 1 0 0 ] ] [ [ car ] ] [ balance>list ] test-word
[ 1           ] [ [ 1 | 2 ]       ] [ car               ] test-word
[ [ 1 1 0 0 ] ] [ [ cdr ] ] [ balance>list ] test-word
[ 2           ] [ [ 1 | 2 ]       ] [ cdr               ] test-word

[ [ 1 1 0 0 ] ] [ [ clone-list ] ] [ balance>list ] test-word
[ [ ]         ] [ [ ]             ] [ clone-list        ] test-word
[ [ 1 2 | 3 ] ] [ [ 1 2 | 3 ]     ] [ clone-list        ] test-word
[ [ 1 2 3 4 ] ] [ [ 1 2 3 4 ]     ] [ clone-list        ] test-word

: clone-list-actually-clones? ( list1 list2 -- )
    [ clone-list ] dip ! we don't want to mutate literals
    [ dup clone-list ] dip nappend = not ;

[ t ] [ [ 1 2 ] [ 3 4 ] ] [ clone-list-actually-clones? ] test-word

[ [ 2 1 0 0 ] ] [ [ cons ] ] [ balance>list ] test-word
[ [ 1 | 2 ]   ] [ 1 2             ] [ cons              ] test-word
[ [ 1 ]       ] [ 1 f             ] [ cons              ] test-word

[ [ 2 1 0 0 ] ] [ [ contains ] ] [ balance>list ] test-word
[ f           ] [ 3 [ ]           ] [ contains          ] test-word
[ f           ] [ 3 [ 1 2 ]       ] [ contains          ] test-word
[ [ 1 2 ]     ] [ 1 [ 1 2 ]       ] [ contains          ] test-word
[ [ 2 ]       ] [ 2 [ 1 2 ]       ] [ contains          ] test-word
[ [ 2 | 3 ]   ] [ 3 [ 1 2 | 3 ]   ] [ contains          ] do-not-test-word

[ [ 2 0 0 0 ] ] [ [ cons@ ] ] [ balance>list ] test-word
[ [ 1 ]       ] [ 1 f             ] [ "x" set "x" cons@ "x" get   ] test-word
[ [ 1 | 2 ]   ] [ 1 2             ] [ "x" set "x" cons@ "x" get   ] test-word
[ [ 1 2 ]     ] [ 1 [ 2 ]         ] [ "x" set "x" cons@ "x" get   ] test-word

[ [ 1 1 0 0 ] ] [ [ count ] ] [ balance>list ] do-not-test-word
[ [ ]         ] [ 0               ] [ count             ] test-word
[ [ ]         ] [ -10             ] [ count             ] test-word
[ [ ]         ] [ -inf            ] [ count             ] test-word
[ [ 0 1 2 3 ] ] [ 4               ] [ count             ] test-word

[ [ 2 1 0 0 ] ] [ [ nth ] ] [ balance>list ] test-word
[ 1           ] [  -1 [ 1 2 ]      ] [ nth               ] test-word
[ 1           ] [  0  [ 1 2 ]      ] [ nth               ] test-word
[ 2           ] [  1  [ 1 2 ]      ] [ nth               ] test-word

[ [ 1 1 0 0 ] ] [ [ last* ] ] [ balance>list ] test-word
[ [ 3 ]       ] [ [ 3 ]           ] [ last*             ] test-word
[ [ 3 ]       ] [ [ 1 2 3 ]       ] [ last*             ] test-word
[ [ 3 | 4 ]   ] [ [ 1 2 3 | 4 ]   ] [ last*             ] test-word

[ [ 1 1 0 0 ] ] [ [ last ] ] [ balance>list ] test-word
[ 3           ] [ [ 3 ]           ] [ last              ] test-word
[ 3           ] [ [ 1 2 3 ]       ] [ last              ] test-word
[ 3           ] [ [ 1 2 3 | 4 ]   ] [ last              ] test-word

[ [ 1 1 0 0 ] ] [ [ length ] ] [ balance>list ] test-word
[ 0           ] [ [ ]             ] [ length            ] test-word
[ 3           ] [ [ 1 2 3 ]       ] [ length            ] test-word

! CMU CL bombs on (length '(1 2 3 . 4))
![ 3           ] [ [ 1 2 3 | 4 ]   ] [ length            ] test-word

[ [ 1 1 0 0 ] ] [ [ list? ] ] [ balance>list ] test-word
[ t           ] [ f               ] [ list?             ] test-word
[ f           ] [ t               ] [ list?             ] test-word
[ t           ] [ [ 1 2 ]         ] [ list?             ] test-word
[ f           ] [ [ 1 | 2 ]       ] [ list?             ] test-word

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

[ 1 2 3 ] clone-list "x" set [ 4 5 6 ] clone-list "y" set

[ [ 2 1 0 0 ] ] [ [ nappend ] ] [ balance>list ] test-word
[ [ 4 5 6 ]   ] [ "x" get "y" get           ] [ nappend drop "y" get   ] test-word

[ 1 2 3 ] clone-list "x" set [ 4 5 6 ] clone-list "y" set

[ [ 1 2 3 4 5 6 ] ] [ "x" get "y" get       ] [ nappend drop "x" get   ] test-word

[ 2 ] [ 1 [ 1 2 3 ] ] [ next ] test-word
[ 1 ] [ 3 [ 1 2 3 ] ] [ next ] test-word
[ 1 ] [ 4 [ 1 2 3 ] ] [ next ] test-word

[ [ 1 1 0 0 ] ] [ [ cons? ] ] [ balance>list ] test-word
[ f           ] [ f               ] [ cons?             ] test-word
[ f           ] [ t               ] [ cons?             ] test-word
[ t           ] [ [ t | f ]       ] [ cons?             ] test-word

[ [ 2 1 0 0 ] ] [ [ remove ] ] [ balance>list ] test-word
[ [ ]       ] [ 1 [ ]               ] [ remove            ] test-word
[ [ ]       ] [ 1 [ 1 ]             ] [ remove            ] test-word
[ [ 3 1 1 ] ] [ 2 [ 3 2 1 2 1 ]     ] [ remove            ] test-word

[ [ 1 1 0 0 ] ] [ [ reverse ] ] [ balance>list ] test-word
[ [ ]         ] [ [ ]             ] [ reverse           ] test-word
[ [ 1 ]       ] [ [ 1 ]           ] [ reverse           ] test-word
[ [ 3 2 1 ]   ] [ [ 1 2 3 ]       ] [ reverse           ] test-word

[ [ 2 0 0 0 ] ] [ [ set-car ] ] [ balance>list ] test-word
[ "a" | "b" ] clone-list "x" set
[ [ 1 | "b" ]   ] [ 1 "x" get            ] [ set-car "x" get         ] test-word

[ [ 2 0 0 0 ] ] [ [ set-cdr ] ] [ balance>list ] test-word
[ "a" | "b" ] clone-list "x" set                                         
[ [ "a" | 2 ]   ] [ 2 "x" get            ] [ set-cdr "x" get         ] test-word

[ [ 2 2 0 0 ] ] [ [ [ < ] partition ] ] [ balance>list ] test-word
[ [ -5 3 1 ] [ -2 4 4 -2 ] ]
[ 2 [ 1 -2 3 4 -5 4 -2 ] ]
[ [ swap / ratio? ] partition ] test-word

[ [ 2 2 0 0 ] ] [ [ [ nip string? ] partition ] ] [ balance>list ] test-word
[ [ "d" "c" ] [ 2 1 ] ]
[ f [ 1 2 "c" "d" ] ]
[ [ nip string? ] partition ] test-word

[ [ 1 1 0 0 ] ] [ [ num-sort ] ] [ balance>list ] test-word
[ [ 1 1 0 0 ] ] [ [ str-sort ] ] [ balance>list ] test-word

[ [ 2 1 0 0 ] ] [ [ swons ] ] [ balance>list ] test-word                                                     
[ [ 1 | 2 ]   ] [ 2 1             ] [ swons             ] test-word
[ [ 1 ]       ] [ f 1             ] [ swons             ] test-word

[ [ 2 1 0 0 ] ] [ [ tree-contains?   ] ] [ balance>list ] test-word
[ f ] [ 3 [ ]             ] [ tree-contains?     ] test-word
[ f ] [ 3 [ 1 [ 3 ] 2 ]   ] [ tree-contains? not ] test-word
[ f ] [ 1 [ [ [ 1 ] ] 2 ] ] [ tree-contains? not ] test-word
[ f ] [ 2 [ 1 2 ]         ] [ tree-contains? not ] test-word
[ f ] [ 3 [ 1 2 | 3 ]     ] [ tree-contains? not ] test-word

[ [ 1 2 0 0 ] ] [ [ uncons ] ] [ balance>list ] test-word
[ 1 2         ] [ [ 1 | 2 ]   ] [ uncons                ] test-word
[ 1 [ 2 ]     ] [ [ 1 2 ]     ] [ uncons                ] test-word

[ [ 2 1 0 0 ] ] [ [ unique ] ] [ balance>list ] test-word
[ [ 1 2 3 ]   ] [ 1 [ 2 3 ]   ] [ unique                ] test-word
[ [ 1 2 3 ]   ] [ 1 [ 1 2 3 ] ] [ unique                ] test-word
[ [ 1 2 3 ]   ] [ 2 [ 1 2 3 ] ] [ unique                ] test-word

[ [ 1 1 0 0 ] ] [ [ unit ] ] [ balance>list ] test-word
[ [ [ [ ] ] ] ] [ [ ]         ] [ unit unit             ] test-word

[ [ 1 2 0 0 ] ] [ [ unswons ] ] [ balance>list ] test-word
[ 1 2         ] [ [ 2 | 1 ]   ] [ unswons               ] test-word
[ [ 2 ] 1     ] [ [ 1 2 ]     ] [ unswons               ] test-word


[ [ 1 1 0 0 ] ] [ [ deep-clone ] ] [ balance>list ] test-word

: deep-clone-test ( x -- x y )
    dup deep-clone dup car 5 swap set-car ;

[ [ [ 1 | 2 ] ] [ [ 5 | 2 ] ] ] [ [ [ 1 | 2 ] ] ] 
[ deep-clone-test ] test-word

"List checks passed." print
