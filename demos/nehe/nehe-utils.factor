IN: nehe
USING: kernel opengl ;

: with-gl ( type quot -- )
  >r glBegin r> call glEnd ; inline
