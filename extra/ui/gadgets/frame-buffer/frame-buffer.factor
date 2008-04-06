
USING: kernel alien.c-types combinators sequences splitting
       opengl.gl ui.gadgets ui.render
       math math.vectors accessors ;

IN: ui.gadgets.frame-buffer

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: frame-buffer action dim last-dim graft ungraft pixels ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-frame-buffer-pixels ( frame-buffer -- frame-buffer )
  dup
    rect-dim product "uint[4]" <c-array>
  >>pixels ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: <frame-buffer> ( -- frame-buffer )
  frame-buffer construct-gadget
    [ ]         >>action
    { 100 100 } >>dim
    [ ]         >>graft
    [ ]         >>ungraft ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-pixels ( fb -- fb )
  dup >r
  dup >r
  rect-dim first2 GL_RGBA GL_UNSIGNED_INT r> pixels>> glDrawPixels
  r> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: read-pixels ( fb -- fb )
  dup >r
  dup >r
      >r
  0 0 r> rect-dim first2 GL_RGBA GL_UNSIGNED_INT r> pixels>> glReadPixels
  r> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: frame-buffer pref-dim* dim>> ;
M: frame-buffer graft*    graft>>   call ;
M: frame-buffer ungraft*  ungraft>> call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: copy-row ( old new -- )
  2dup min-length swap >r head-slice 0 r> copy ;

! : copy-pixels ( old-pixels old-width new-pixels new-width -- )
!   [ group ] 2bi@
!   [ copy-row ] 2each ;

! : copy-pixels ( old-pixels old-width new-pixels new-width -- )
!   [ 16 * group ] 2bi@
!   [ copy-row ] 2each ;

: copy-pixels ( old-pixels old-width new-pixels new-width -- )
  [ 16 * <sliced-groups> ] 2bi@
  [ copy-row ] 2each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: frame-buffer layout* ( fb -- )
   {
     {
       [ dup last-dim>> f = ]
       [
         init-frame-buffer-pixels
         dup
           rect-dim >>last-dim
         drop
       ]
     }
     {
       [ dup [ rect-dim ] [ last-dim>> ] bi = not ]
       [
         dup [ pixels>> ] [ last-dim>> first ] bi

         rot init-frame-buffer-pixels
         dup rect-dim >>last-dim

         [ pixels>> ] [ rect-dim first ] bi

         copy-pixels
       ]
     }
     { [ t ] [ drop ] }
   }
   cond ;
   
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: frame-buffer draw-gadget* ( fb -- )

   dup rect-dim { 0 1 } v* first2 glRasterPos2i

   draw-pixels

   dup action>> call

   glFlush

   read-pixels

   drop ;

