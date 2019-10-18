! Copyright (C) 2006 Eduardo Cavazos.

! To run:
!     USE: automata
!     automata-window

REQUIRES: math slate vars ;

USING: parser kernel hashtables namespaces sequences math io
math-contrib threads strings arrays prettyprint
gadgets gadgets-editors gadgets-frames gadgets-buttons gadgets-grids
vars slate ;

IN: automata

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! set-rule
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: char>digit ( c -- i ) 48 - ;

: string>digits ( s -- seq ) >array [ char>digit ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: rule   SYMBOL: rule-number

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

: rule-values ( n -- seq ) >bin 8 CHAR: 0 pad-left string>digits ;

: set-rule ( n -- )
dup rule-number set
rule-values rule-keys [ rule get set-hash ] 2each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! step-capped-line
! step-wrapped-line
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 3nth ( n seq -- slice ) >r dup 3 + r> <slice> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map3-i ( seq -- i ) length 2 - ;

: map3-quot ( quot -- quot ) [ swap 3nth ] swap append ;

: map3 ( seq quot -- seq ) over map3-i swap map3-quot map-with ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: last ( seq -- elt ) dup length 1- swap nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: pattern>state ( { a b c } -- state ) rule get hash ;

: cap-line ( line -- 0-line-0 ) { 0 } swap append { 0 } append ;

: wrap-line ( a-line-z -- za-line-za )
dup last 1array swap dup first 1array append append ;

: step-line ( line -- new-line ) [ >array pattern>state ] map3 ;

: step-capped-line ( line -- new-line ) cap-line step-line ;

: step-wrapped-line ( line -- new-line ) wrap-line step-line ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Display the rule
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: random-line ( -- line ) window-width [ drop 2 random-int ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: center-i ( -- i ) window-width dup 2 / >fixnum ;

: center-line ( -- line ) center-i window-width [ = [ 1 ] [ 0 ] if ] map-with ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! show-line
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: show-point ( { x y } p -- ) 1 = [ draw-point ] [ drop ] if ;

: (show-line) ( { x y } line -- ) [ dupd show-point { 1 0 } v+ ] each drop ;

: show-line ( y line -- ) 0 rot 2array swap (show-line) yield ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! run-rule
! start-random
! start-center
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: last-line

: estimate-capacity ( -- ) window-width window-height * 2 * capacity set ;

: check-capacity ( -- )
"capacity: " write capacity get number>string write terpri
"dlist length: " write dlist get length number>string write terpri ;

: start-slate ( -- )
estimate-capacity reset-slate
white set-clear-color black set-color clear-window ;

: finish-slate ( -- ) check-capacity flush-dlist flush-slate ;

: run-line ( line y -- line ) swap tuck show-line step-capped-line ;

: run-lines ( -- ) last-line> window-height [ run-line ] each >last-line ;

: run-rule ( -- ) start-slate run-lines finish-slate ;

: start-random ( -- ) random-line >last-line run-rule ;

: start-center ( -- ) center-line >last-line run-rule ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: random-item ( seq -- item ) dup length random-int swap nth ;

: interesting ( -- seq )
{ 18 22 26 30 41 45 54 60 73 75 82 86 89 90 97 101 102 105 106 107 109
  110 120 121 122 124 126 129 137 146 147 149 150 151 153 154 161 165 } ;


: mild ( -- seq )
{ 6 9 11 57 62 74 118 } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : automata ( -- )
! <slate> dup self set "Cellular Automata" open-titled-window
! init-rule interesting random-item set-rule 1000 sleep start-random ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! automata-window
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bind-button ( ns button -- )
tuck button-quot \ bind 3array >quotation swap set-button-quot ;

VARS: ns editor frame ;

: init-slate ( -- ) <slate> t over set-gadget-clipped? self set ;

: init-editor ( -- ) "" <editor> >editor ;

: set-editor-rule ( n -- ) number>string editor> set-editor-text ;

: open-rule ( -- ) editor> editor-text string>number set-rule start-center ;

: automata-window ( -- )
<frame> >frame
[ ] make-hash >ns
ns> [ init-rule init-slate init-editor ] bind
ns> [ editor> ] bind 1array
ns>
{ { "Open"     [ open-rule ]  }
  { "Center"   [ start-center ] }
  { "Random"   [ start-random ] }
  { "Continue" [ run-rule ] } }
[ first2 <bevel-button> tuck bind-button ]
map-with append make-pile 1 over set-pack-fill
frame> @left grid-add
ns> [ self get ] bind
frame> @center grid-add
frame> "Cellular Automata" open-titled-window
1000 sleep
ns> [ interesting random-item set-editor-rule open-rule ] bind ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

PROVIDE: automata ;