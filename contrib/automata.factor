REQUIRES: contrib/vars contrib/slate/slate contrib/lindenmayer/opengl ;

USING: kernel namespaces hashtables sequences math arrays opengl gadgets
       vars slate opengl-contrib ;

IN: automata

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! set-rule
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: char>digit ( c -- i ) 48 - ;

: string>digits ( s -- seq ) >array [ char>digit ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: rule   VAR: rule-number

: init-rule ( -- ) 8 <hashtable> >rule ;

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
dup >rule-number rule-values rule-keys [ rule> set-hash ] 2each ;

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

: pattern>state ( {_a_b_c_} -- state ) rule> hash ;

: cap-line ( line -- 0-line-0 ) { 0 } swap append { 0 } append ;

: wrap-line ( a-line-z -- za-line-za )
dup peek 1array swap dup first 1array append append ;

: step-line ( line -- new-line ) [ >array pattern>state ] map3 ;

: step-capped-line ( line -- new-line ) cap-line step-line ;

: step-wrapped-line ( line -- new-line ) wrap-line step-line ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: window-width ( -- width ) slate> rect-dim 0 swap nth ;

: window-height ( -- height ) slate> rect-dim 1 swap nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: random-line ( -- line ) window-width [ drop 2 random-int ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: center-i ( -- i ) window-width 2 / >fixnum ;

: center-line ( -- line ) center-i window-width [ = [ 1 ] [ 0 ] if ] map-with ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: random-item ( seq -- item ) dup length random-int swap nth ;

: interesting ( -- seq )
{ 18 22 26 30 41 45 54 60 73 75 82 86 89 90 97 101 102 105 106 107 109
  110 120 121 122 124 126 129 137 146 147 149 150 151 153 154 161 165 } ;

: mild ( -- seq )
{ 6 9 11 57 62 74 118 } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: bitmap

VAR: last-line

: run-rule ( -- )
last-line> window-height [ drop step-capped-line dup ] map >bitmap >last-line
.slate ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start-random ( -- ) random-line >last-line run-rule ;

: start-center ( -- ) center-line >last-line run-rule ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-point ( y x value -- ) 1 = [ swap glVertex2i ] [ 2drop ] if ;

: draw-line ( y line -- ) 0 swap [ >r 2dup r> draw-point 1+ ] each 2drop ;

: (draw-bitmap) ( bitmap -- ) 0 swap [ >r dup r> draw-line 1+ ] each drop ;

: draw-bitmap ( bitmap -- ) GL_POINTS glBegin (draw-bitmap) glEnd ;

: display ( -- )
GL_COLOR_BUFFER_BIT glClear black gl-color bitmap> draw-bitmap ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-slate ( -- )
<slate> >slate
namespace slate> set-slate-ns
[ display ] >action
slate> "Automata" open-titled-window ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- ) init-rule init-slate ;