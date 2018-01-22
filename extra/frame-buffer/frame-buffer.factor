USING: accessors alien.c-types alien.data combinators grouping
kernel locals math math.vectors opengl.gl sequences
specialized-arrays ui.gadgets ui.render ;
SPECIALIZED-ARRAY: uint
IN: frame-buffer

TUPLE: frame-buffer < gadget pixels last-dim ;

: <frame-buffer> ( -- frame-buffer ) frame-buffer new ;

GENERIC: update-frame-buffer ( frame-buffer -- )

: init-frame-buffer-pixels ( frame-buffer -- )
  dup dim>> product 4 * uint <c-array> >>pixels
  drop ;

:: draw-pixels ( FRAME-BUFFER -- )
    FRAME-BUFFER dim>> first2
    GL_RGBA
    GL_UNSIGNED_INT
    FRAME-BUFFER pixels>>
    glDrawPixels ;

:: read-pixels ( FRAME-BUFFER -- )
    0
    0
    FRAME-BUFFER dim>> first2
    GL_RGBA
    GL_UNSIGNED_INT
    FRAME-BUFFER pixels>>
    glReadPixels ;

:: copy-row ( OLD NEW -- )
    OLD NEW min-length :> LEN
    OLD LEN head-slice 0 NEW copy ;

: copy-pixels ( old-pixels old-width new-pixels new-width -- )
    [ [ drop { } ] [ 16 * <groups> ] if-zero ] 2bi@
    [ copy-row ] 2each ;

: update-last-dim ( frame-buffer -- ) dup dim>> >>last-dim drop ;

M:: frame-buffer layout* ( FRAME-BUFFER -- )
    FRAME-BUFFER last-dim>> [
        FRAME-BUFFER dim>> = [
            FRAME-BUFFER pixels>> :> OLD-PIXELS
            FRAME-BUFFER last-dim>> first :> OLD-WIDTH
            FRAME-BUFFER init-frame-buffer-pixels
            FRAME-BUFFER update-last-dim
            FRAME-BUFFER pixels>> :> NEW-PIXELS
            FRAME-BUFFER last-dim>> first :> NEW-WIDTH
            OLD-PIXELS OLD-WIDTH NEW-PIXELS NEW-WIDTH copy-pixels
        ] unless
    ] [
        FRAME-BUFFER init-frame-buffer-pixels
        FRAME-BUFFER update-last-dim
    ] if* ;

M:: frame-buffer draw-gadget* ( FRAME-BUFFER -- )
    FRAME-BUFFER dim>> { 0 1 } v* first2 glRasterPos2i
    FRAME-BUFFER draw-pixels
    FRAME-BUFFER update-frame-buffer
    glFlush
    FRAME-BUFFER read-pixels ;

