
USING: kernel combinators arrays sequences math ;

IN: cfdg.hsv

<PRIVATE

: H ( hsv -- H ) first ;

: S ( hsv -- S ) second ;

: V ( hsv -- V ) third ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Hi ( hsv -- Hi ) H 60 / floor 6 mod ;

: f ( hsv -- f ) dup H 60 / swap Hi - ;

: p ( hsv -- p ) 1 over S - swap V * ;

: q ( hsv -- q ) dup f over S * 1 swap - swap V * ;

: t ( hsv -- t ) 1 over f - over S * 1 swap - swap V * ;

PRIVATE>

! h [0,360)
! s [0,1]
! v [0,1]

: hsv>rgb ( hsv -- rgb )
dup Hi
{ { 0 [ dup V swap dup t swap p ] }
  { 1 [ dup q over V rot p ] }
  { 2 [ dup p over V rot t ] }
  { 3 [ dup p over q rot V ] }
  { 4 [ dup t over p rot V ] }
  { 5 [ dup V over p rot q ] } } case 3array ;