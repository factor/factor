
USING: kernel namespaces math opengl.gl opengl.glu ui ui.gadgets.slate
       random-weighted cfdg ;

IN: cfdg.models.game1-turn6

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: f-triangles ( -- )
  {
    [ 0.1 x 0.1 y -0.33 alpha 20 hue 0.7 sat 0.80 b triangle ]
    [                         10 hue 0.9 sat 0.33 b triangle ]
    [ 0.9 s                   10 hue 0.5 sat 1.00 b triangle ]
    [ 0.8 s 5 r f-triangles ]
  }
  rule ;

: f-squares ( -- )
  {
    [ 0.1 x 0.1 y -0.33 alpha 250 hue 0.70 sat 0.80 b square ]
    [                         220 hue 0.90 sat 0.33 b square ]
    [ 0.9 s                   220 hue 0.25 sat 1.00 b square ]
    [ 0.8 s 5 r f-squares ]
  }
  rule ;

DEFER: start

: spiral ( -- )
  {
    { 1 [ f-squares ]
        [ 0.5 x 0.5 y 45 r f-triangles ]
        [ 1 y 25 r 0.9 s spiral ] }
            
    { 0.022 [ 90 flip 50 hue start ] }
  }
  rules ;

: start ( -- )
  [       spiral ] do
  [ 120 r spiral ] do
  [ 240 r spiral ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )
  [ 66 hue 0.4 sat 0.5 b ] >background
  { -5 10 -5 10 }          >viewport
  0.001                    >threshold
  [ start ]                >start-shape ;

: run ( -- ) [ init ] cfdg-window. ;

MAIN: run