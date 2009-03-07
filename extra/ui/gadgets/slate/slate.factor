! Copyright (C) 2009 Eduardo Cavazos
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces opengl ui.render ui.gadgets accessors ;

IN: ui.gadgets.slate

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: slate < gadget action pdim graft ungraft ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-slate ( slate -- slate )
  [ ]         >>action
  { 200 200 } >>pdim
  [ ]         >>graft
  [ ]         >>ungraft ;

: <slate> ( action -- slate )
  slate new
    init-slate
    swap >>action ;

M: slate pref-dim* ( slate -- dim ) pdim>> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: combinators arrays sequences math
       opengl.gl ui.gadgets.worlds ;

: width ( rect -- w ) dim>> first ;
: height ( rect -- h ) dim>> second ;

: screen-y* ( gadget -- loc )
  {
    [ find-world height ]
    [ screen-loc second ]
    [ height ]
  }
  cleave
  + - ;

: screen-loc* ( gadget -- loc )
  {
    [ screen-loc first ]
    [ screen-y* ]
  }
  cleave
  2array ;

: setup-viewport ( gadget -- gadget )
  dup
  {
    [ screen-loc* ]
    [ dim>>       ]
  }
  cleave
  gl-viewport ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: default-coordinate-system ( gadget -- gadget )
  dup
  {
    [ drop 0 ]
    [ width 1 - ]
    [ height 1 - ]
    [ drop 0 ]
  }
  cleave
  -1 1
  glOrtho ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: slate graft*   ( slate -- ) graft>>   call ;
M: slate ungraft* ( slate -- ) ungraft>> call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: establish-coordinate-system ( gadget -- gadget )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: slate establish-coordinate-system ( slate -- slate )
   default-coordinate-system ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: draw-slate ( slate -- slate )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: slate draw-slate ( slate -- slate ) dup action>> call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: slate draw-gadget* ( slate -- )

   GL_PROJECTION glMatrixMode glPushMatrix glLoadIdentity

   establish-coordinate-system

   GL_MODELVIEW glMatrixMode glPushMatrix glLoadIdentity 

   setup-viewport

   draw-slate

   GL_PROJECTION glMatrixMode glPopMatrix glLoadIdentity
   GL_MODELVIEW  glMatrixMode glPopMatrix glLoadIdentity

   dup
   find-world
   ! The world coordinate system is a little wacky:
   dup { [ drop 0 ] [ width ] [ height ] [ drop 0 ] } cleave -1 1 glOrtho
   setup-viewport
   drop
   drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
