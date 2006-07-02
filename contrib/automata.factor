! Copyright (C) 2006 Eduardo Cavazos.

! Quick start:		USE: automata automata-gallery
!
! This will open a new window that will display a random automata rule
! every 10 seconds. Resize the window to make the display larger.

REQUIRES: math slate ;

USING: parser kernel hashtables namespaces sequences math io
math-contrib threads strings arrays prettyprint gadgets slate ;

IN: automata

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! set-rule
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: rule

: init-rule ( -- ) 8 <hashtable> rule set ;

: rule-keys ( -- { ... } )
{ { 1 1 1 }
  { 1 1 0 }
  { 1 0 1 }
  { 1 0 0 }
  { 0 1 1 }
  { 0 1 0 }
  { 0 0 1 }
  { 0 0 0 } } ;

: rule-values ( n -- { ... } ) >bin 8 CHAR: 0 pad-left >array [ 48 - ] map ;

: set-rule ( n -- ) rule-values rule-keys [ rule get set-hash ] 2each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! step
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 3nth ( n seq -- slice ) >r dup 3 + r> <slice> ;

: next-chunk ( << slice: a b c >> -- value ) >array rule get hash ;

: (step) ( line -- new-line )
dup length 2 - [ swap 3nth next-chunk ] map-with ;

: step-line ( line -- new-line ) >r { 0 } r> { 0 } append append (step) ;

: last ( seq -- item ) dup length 1 - swap nth ;

: step-line-wrapped ( line -- new-line )
dup last 1array swap dup first 1array append append (step) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Display the rule
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: run-rule

: test-automata ( -- )
<slate> dup self set open-window init-rule 150 set-rule run-rule ;

: random-line ( -- line ) window-width [ drop 2 random-int ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! show-line
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: show-point ( { x y } p -- ) 1 = [ draw-point ] [ drop ] if ;

: (show-line) ( { x y } line -- )
[ >r dup r> show-point { 1 0 } v+ ] each drop ;

: show-line ( y line -- ) >r >r 0 r> 2array r> (show-line) yield ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Go
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: last-line

! : run-rule ( -- last-line ) clear-window
! 0 random-line window-height [ drop 2dup show-line >r 1 + r> step-line ]
! each last-line set drop ;

: estimate-capacity ( -- ) window-width window-height * 1000 + capacity set ;

: check-capacity ( -- )
"capacity: " write capacity get number>string write terpri
"dlist length: " write dlist get length number>string write terpri ;

! : run-rule ( -- )
! [ ] set-action
! window-width window-height * 1000 + capacity set reset-dlist
! white set-clear-color black set-color clear-window
! 0 random-line window-height [ drop 2dup show-line >r 1 + r> step-line ] each
! last-line set drop
! "capacity: " print capacity get unparse print terpri
! "dlist length: " print dlist get length unparse print terpri
! flush-dlist slate-flush ;

: run-rule ( -- )
estimate-capacity reset-slate
white set-clear-color black set-color clear-window
0 random-line window-height [ drop 2dup show-line >r 1 + r> step-line ] each
last-line set drop check-capacity flush-dlist flush-slate ;

: run-rule-wrapped ( -- last-line )
clear-window 0 random-line 400
[ drop 2dup show-line >r 1 + r> step-line-wrapped ] each nip ;

: continue-rule ( first-line -- last-line ) clear-window
0 swap 400 [ drop 2dup show-line swap 1 + swap step-line ] each nip ;

: continue-rule-wrapped ( first-line -- last-line ) clear-window
0 swap 400 [ drop 2dup show-line swap 1 + swap step-line-wrapped ] each nip ;

: random-gallery ( -- )
255 random-int 1 + dup unparse print flush
set-rule run-rule 5000 sleep random-gallery ;

SYMBOL: interesting

: init-interesting ( -- ) { 26 150 193 165 146 144 86 104 } interesting set ;

: random-item ( seq -- item ) dup length random-int swap nth ;

: random-interesting-gallery ( -- )
interesting get random-item set-rule run-rule 10000 sleep
random-interesting-gallery ;

: automata ( -- )
<slate> dup self set open-window init-interesting init-rule
interesting get random-item set-rule 1000 sleep run-rule ;

: automata-gallery ( -- )
<slate> dup self set open-window 1000 sleep init-interesting init-rule
random-interesting-gallery ;

PROVIDE: automata ;