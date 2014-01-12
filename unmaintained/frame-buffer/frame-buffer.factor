
USING: accessors alien.c-types combinators grouping kernel
       locals math math.geometry.rect math.vectors opengl.gl sequences
       ui.gadgets ui.render ;

IN: frame-buffer

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <frame-buffer> < gadget pixels last-dim ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: update-frame-buffer ( <frame-buffer> -- )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-frame-buffer-pixels ( frame-buffer -- )
  dup
    rect-dim product "uint[4]" <c-array>
  >>pixels
  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: frame-buffer ( -- <frame-buffer> ) <frame-buffer> new-gadget ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: draw-pixels ( FRAME-BUFFER -- )

  FRAME-BUFFER rect-dim first2
  GL_RGBA
  GL_UNSIGNED_INT
  FRAME-BUFFER pixels>>
  glDrawPixels ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: read-pixels ( FRAME-BUFFER -- )

  0
  0
  FRAME-BUFFER rect-dim first2
  GL_RGBA
  GL_UNSIGNED_INT
  FRAME-BUFFER pixels>>
  glReadPixels ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: copy-row ( OLD NEW -- )
  
  [let | LEN [ OLD NEW min-length ] |

    OLD LEN head-slice 0 NEW copy ] ;

: copy-pixels ( old-pixels old-width new-pixels new-width -- )
  [ 16 * <groups> ] 2bi@ [ copy-row ] 2each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: update-last-dim ( frame-buffer -- ) dup rect-dim >>last-dim drop ;

M:: <frame-buffer> layout* ( FRAME-BUFFER -- )

  {
    {
      [ FRAME-BUFFER last-dim>> f = ]
      [
        FRAME-BUFFER init-frame-buffer-pixels

        FRAME-BUFFER update-last-dim
      ]
    }
    {
      [ FRAME-BUFFER [ rect-dim ] [ last-dim>> ] bi = not ]
      [
        [let | OLD-PIXELS [ FRAME-BUFFER pixels>>         ]
               OLD-WIDTH  [ FRAME-BUFFER last-dim>> first ] |

          FRAME-BUFFER init-frame-buffer-pixels

          FRAME-BUFFER update-last-dim

          [let | NEW-PIXELS [ FRAME-BUFFER pixels>>         ]
                 NEW-WIDTH  [ FRAME-BUFFER last-dim>> first ] |

            OLD-PIXELS OLD-WIDTH NEW-PIXELS NEW-WIDTH copy-pixels ] ]
      ]
    }
    { [ t ] [ ] }
  }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M:: <frame-buffer> draw-gadget* ( FRAME-BUFFER -- )

  FRAME-BUFFER rect-dim { 0 1 } v* first2 glRasterPos2i

  FRAME-BUFFER draw-pixels

  FRAME-BUFFER update-frame-buffer

  glFlush

  FRAME-BUFFER read-pixels ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

