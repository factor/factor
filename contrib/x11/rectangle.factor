USING: kernel math sequences arrays ; IN: rectangle

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: rect corner size ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: top-left
GENERIC: top-right
GENERIC: bottom-left
GENERIC: bottom-right

GENERIC: move-top-left
GENERIC: move-top-right
GENERIC: move-bottom-left
GENERIC: move-bottom-right

GENERIC: move-middle-center

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rect-width ( rect -- width ) rect-size 0 swap nth ;

: rect-height ( rect -- height ) rect-size 1 swap nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: rect top-left ( rect -- point ) rect-corner ;

M: rect top-right ( rect -- point )
dup rect-corner swap rect-width 1 - 0 2array v+ ;

M: rect bottom-left ( rect -- point )
dup rect-corner swap rect-height 1 - 0 swap 2array v+ ;

M: rect bottom-right ( rect -- point )
dup rect-corner swap rect-size { -1 -1 } v+ v+ ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-top-left:new-corner ( point rect -- corner )
  drop ;

M: rect move-top-left ( point rect -- corner )
  tuck move-top-left:new-corner swap rect-size <rect> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-bottom-right:new-corner ( point rect -- corner )
  rect-size { -1 -1 } v+ v- ;

M: rect move-bottom-right ( point rect -- rect )
  tuck move-bottom-right:new-corner swap rect-size <rect> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-top-right:new-corner ( point rect -- corner )
  rect-size { -1 -1 } v+ { 1 0 } v* v- ;

M: rect move-top-right ( point rect -- rect )
  tuck move-top-right:new-corner swap rect-size <rect> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-bottom-left:new-corner ( point rect -- corner )
  rect-size { -1 -1 } v+ { 0 1 } v* v- ;

M: rect move-bottom-left ( point rect -- rect )
  tuck move-bottom-left:new-corner swap rect-size <rect> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-middle-center:new-corner ( point rect -- coener )
  rect-size { 1/2 1/2 } v* { -1 -1 } v+ v- ;

M: rect move-middle-center ( point rect -- rect )
  tuck move-middle-center:new-corner swap rect-size <rect> ;
