USING: accessors alien.c-types alien.data grouping kernel
math math.vectors opengl opengl.gl sequences
specialized-arrays ui.gadgets ui.render ;
SPECIALIZED-ARRAY: uint
IN: ui.gadgets.frame-buffer

TUPLE: frame-buffer < gadget pixels last-dim ;

: <frame-buffer> ( -- frame-buffer ) frame-buffer new ;

GENERIC: update-frame-buffer ( frame-buffer -- )

: init-frame-buffer-pixels ( frame-buffer -- )
  dup dim>> [ gl-scale ] map product >integer 4 * uint <c-array> >>pixels
  drop ;

:: draw-pixels ( FRAME-BUFFER -- )
    FRAME-BUFFER dim>> first2 [ gl-scale >fixnum ] bi@
    GL_RGBA
    GL_UNSIGNED_INT
    FRAME-BUFFER pixels>>
    glDrawPixels ;

:: read-pixels ( FRAME-BUFFER -- )
    0
    0
    FRAME-BUFFER dim>> first2 [ gl-scale >fixnum ] bi@
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

M:: frame-buffer layout* ( FRAME-BUFFER -- )
    FRAME-BUFFER last-dim>> [
        FRAME-BUFFER dim>> = [
            FRAME-BUFFER pixels>> :> OLD-PIXELS
            FRAME-BUFFER last-dim>> first gl-scale >fixnum :> OLD-WIDTH
            FRAME-BUFFER init-frame-buffer-pixels
            FRAME-BUFFER [ dim>> ] [ last-dim<< ] bi
            FRAME-BUFFER pixels>> :> NEW-PIXELS
            FRAME-BUFFER last-dim>> first gl-scale >fixnum :> NEW-WIDTH
            OLD-PIXELS OLD-WIDTH NEW-PIXELS NEW-WIDTH copy-pixels
        ] unless
    ] [
        FRAME-BUFFER init-frame-buffer-pixels
        FRAME-BUFFER [ dim>> ] [ last-dim<< ] bi
    ] if* ;

M:: frame-buffer draw-gadget* ( FRAME-BUFFER -- )
    FRAME-BUFFER dim>> { 0 1 } v* first2 glRasterPos2i
    FRAME-BUFFER draw-pixels
    FRAME-BUFFER update-frame-buffer
    glFlush
    FRAME-BUFFER read-pixels ;

