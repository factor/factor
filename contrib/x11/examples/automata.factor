! Ed Cavazos - wayo.cavazos@gmail.com

! Load, compile and then save your image:
!   "load.factor" run-file save
! To run the program:
!   USE: automata setup-window random-gallery

USING: parser kernel hashtables namespaces sequences lists math io
math-contrib threads strings arrays prettyprint x11 x ;

IN: automata

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! set-rule
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: rule   8 <hashtable> rule set-global

: rule-keys ( -- { ... } )
{ { 0 0 0 }
  { 0 0 1 }
  { 0 1 0 }
  { 0 1 1 }
  { 1 0 0 }
  { 1 0 1 }
  { 1 1 0 }
  { 1 1 1 } } ;

: rule-values ( n -- { ... } ) >bin 8 CHAR: 0 pad-left >array [ 48 - ] map ;

: set-rule ( n -- ) rule-values rule-keys [ rule get set-hash ] 2each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! step
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 3nth ( n seq -- slice ) >r dup 3 + r> <slice> ;

: next-chunk ( << slice: a b c >>  - value ) >array rule get hash ;

: (step) ( line -- new-line ) dup length 2 - [ swap 3nth next-chunk ] map-with ;

: step-line ( line -- new-line ) >r { 0 } r> { 0 } append append (step) ;

: last ( seq -- item ) dup length 1 - swap nth ;

: step-line-wrapped ( line -- new-line )
dup last 1array swap dup first 1array append append (step) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Display the rule
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: setup-window ( -- )
f initialize-x create-window win set
{ 400 400 } resize-window map-window flush-dpy ;

: random-line ( -- line ) window-width [ drop 2 random-int ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! show-line
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: show-point ( { x y } p -- ) 1 = [ draw-point ] [ drop ] if ;

: (show-line) ( { x y } line -- )
[ >r dup r> show-point { 1 0 } v+ ] each drop ;

: show-line ( y line -- ) >r >r 0 r> 2array r> (show-line) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Go
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run-rule ( -- last-line ) clear-window
0 random-line window-height [ drop 2dup show-line >r 1 + r> step-line ]
each nip flush-dpy ;

: run-rule-wrapped ( -- last-line ) clear-window
0 random-line 400 [ drop 2dup show-line >r 1 + r> step-line-wrapped ] each nip
flush-dpy ;

: continue-rule ( first-line -- last-line ) clear-window
0 swap 400 [ drop 2dup show-line swap 1 + swap step-line ] each nip
flush-dpy ;

: continue-rule-wrapped ( first-line -- last-line ) clear-window
0 swap 400 [ drop 2dup show-line swap 1 + swap step-line-wrapped ] each nip
flush-dpy ;

: random-gallery ( -- )
255 random-int 1 + dup unparse print flush
set-rule run-rule 5000 sleep random-gallery ;

SYMBOL: interesting

{ 150 193 165 146 144 86 104 } interesting set-global

: random-item ( seq -- item ) dup length random-int swap nth ;

: random-interesting-gallery ( -- )
interesting get random-item set-rule run-rule drop 10000 sleep
random-interesting-gallery ;
