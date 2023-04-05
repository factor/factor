USING: accessors colors kernel math opengl opengl.gl sequences
skov.basis.ui.tools.environment.theme ui.pens ;
IN: skov.basis.ui.pens.title-gradient

TUPLE: title-gradient  colors foreground selected? ;

: <title-gradient> ( colors foreground selected? -- gradient )
    title-gradient new swap >>selected? swap >>foreground swap >>colors ;

:: draw-gradient ( dim gradient -- )
    GL_QUADS glBegin
        gradient first >rgba-components glColor4f
        0.0 0.0 glVertex2f
        dim first 0.0 glVertex2f
        gradient second >rgba-components glColor4f
        dim first2 glVertex2f
        0.0 dim second glVertex2f
    glEnd ;

:: draw-underline ( dim gradient -- )
    1 gl-scale glLineWidth
    GL_LINES glBegin
        gradient first >rgba-components glColor4f
        0.0 dim second glVertex2f
        dim first2 glVertex2f
    glEnd ;
    
CONSTANT: shadow-width 20.0

:: draw-shadows ( dim -- )
    GL_QUADS glBegin
        content-background-colour >rgba-components glColor4f
        0.0 0.0 glVertex2f
        0.0 dim second 1 + glVertex2f
        content-background-colour >rgba-components drop 0.0 glColor4f
        shadow-width dim second 1 + glVertex2f
        shadow-width 0.0 glVertex2f
        content-background-colour >rgba-components glColor4f
        dim first 0.0 glVertex2f
        dim first dim second 1 + glVertex2f
        content-background-colour >rgba-components drop 0.0 glColor4f
        dim first shadow-width - dim second 1 + glVertex2f
        dim first shadow-width - 0.0 glVertex2f
    glEnd ;

: draw-title ( dim gradient -- )
    [ draw-gradient ] [ draw-underline ] [ drop draw-shadows ] 2tri ;

M: title-gradient draw-interior
    [ dim>> ] dip colors>> draw-title ;

M: title-gradient pen-background
     2drop transparent ;

M: title-gradient pen-foreground
    nip foreground>> ;
