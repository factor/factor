USING: kernel alien sequences opengl  ;

IN: opengl.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-color-4f ( 4seq -- ) first4 glColor4f ;

: gl-clear-color ( 4seq -- ) first4 glClearColor ;

: gl-vertex-3f ( array -- ) first3 glVertex3f ;

: gl-normal-3f ( array -- ) first3 glNormal3f ;

: gl-material-fv ( face pname params -- ) >float-array glMaterialfv ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: glu-look-at ( eye focus up -- ) >r >r first3 r> first3 r> first3 gluLookAt ;