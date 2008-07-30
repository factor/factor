
USING: kernel combinators opengl.gl
       ui.render ui.gadgets ui.gadgets.slate
       accessors ;

IN: ui.gadgets.cartesian

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-slate ( slate -- slate )
  init-gadget
  [ ]         >>action
  { 200 200 } >>pdim
  [ ]         >>graft
  [ ]         >>ungraft ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: cartesian < slate x-min x-max y-min y-max z-min z-max perspective ;

: init-cartesian ( cartesian -- cartesian )
  init-slate
  -10 >>x-min
   10 >>x-max
  -10 >>y-min
   10 >>y-max
   -1 >>z-min
    1 >>z-max ;

: <cartesian> ( -- cartesian ) cartesian new init-cartesian ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: cartesian draw-gadget* ( cartesian -- )
   GL_PROJECTION glMatrixMode
   glLoadIdentity
   dup
       {
         [ x-min>> ] [ x-max>> ]
         [ y-min>> ] [ y-max>> ]
         [ z-min>> ] [ z-max>> ]
       }
     cleave
     glOrtho
   GL_MODELVIEW glMatrixMode
   glLoadIdentity
   call-next-method ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

