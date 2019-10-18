
USING: kernel math math.parser random arrays hashtables assocs sequences
       vars strings.lib ;

IN: automata

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! set-rule
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: rule   VAR: rule-number

: init-rule ( -- ) 8 <hashtable> >rule ;

: rule-keys ( -- array )
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
dup >rule-number rule-values rule-keys [ rule> set-at ] 2each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! step-capped-line
! step-wrapped-line
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 3nth ( n seq -- slice ) >r dup 3 + r> <slice> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map3-i ( seq -- i ) length 2 - ;

: map3-quot ( seq quot -- quot ) >r [ 3nth ] curry r> compose ; inline

: map3 ( seq quot -- seq ) >r dup map3-i swap r> map3-quot map ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: pattern>state ( {_a_b_c_} -- state ) rule> at ;

: cap-line ( line -- 0-line-0 ) { 0 } swap append { 0 } append ;

: wrap-line ( a-line-z -- za-line-za )
dup peek 1array swap dup first 1array append append ;

: step-line ( line -- new-line ) [ >array pattern>state ] map3 ;

: step-capped-line ( line -- new-line ) cap-line step-line ;

: step-wrapped-line ( line -- new-line ) wrap-line step-line ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VARS: width height ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: random-line ( -- line ) width> [ drop 2 random ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: center-i ( -- i ) width> 2 / >fixnum ;

: center-line ( -- line ) center-i width> [ = 1 0 ? ] curry* map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: interesting ( -- seq )
{ 18 22 26 30 41 45 54 60 73 75 82 86 89 90 97 101 102 105 106 107 109
  110 120 121 122 124 126 129 137 146 147 149 150 151 153 154 161 165 } ;

: mild ( -- seq ) { 6 9 11 57 62 74 118 } ;

: set-interesting ( -- ) interesting random set-rule ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: bitmap

VAR: last-line

: run-rule ( -- )
last-line> height> [ drop step-capped-line dup ] map >bitmap >last-line ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start-random ( -- ) random-line >last-line run-rule ;

: start-center ( -- ) center-line >last-line run-rule ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! VAR: loop-flag

! DEFER: loop

! : (loop) ( -- ) run-rule 3000 sleep loop ;

! : loop ( -- ) loop-flag> [ (loop) ] [ ] if ;

! : start-loop ( -- ) t >loop-flag [ loop ] in-thread ;

! : stop-loop ( -- ) f >loop-flag ;