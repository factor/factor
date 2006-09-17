REQUIRES: contrib/slate ;
USING: kernel io math alien namespaces sequences opengl slate ;
IN: redbook-quadric

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (error-callback) ( GLenum -- )
gluErrorString "Quadratic Error: " swap append print ;

: error-callback ( -- alien )
"void" { "GLenum" } [ (error-callback) ] alien-callback ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: start-list
SYMBOL: qobj

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )

4 glGenLists start-list set
start-list get [ start-list set ] curry add-dlist

[
    gluNewQuadric qobj set

    qobj get GLU_ERROR error-callback gluQuadricCallback

    qobj get GLU_FILL gluQuadricDrawStyle
    qobj get GLU_SMOOTH gluQuadricNormals
    start-list get GL_COMPILE glNewList
    qobj get 0.75 15 10 gluSphere
    glEndList

    qobj get GLU_FILL gluQuadricDrawStyle
    qobj get GLU_FLAT gluQuadricNormals
    start-list get 1 + GL_COMPILE glNewList
    qobj get 0.5 0.3 1.0 15 5 gluCylinder
    glEndList

    qobj get GLU_LINE gluQuadricDrawStyle
    qobj get GLU_NONE gluQuadricNormals
    start-list get 2 + GL_COMPILE glNewList
    qobj get 0.25 1.0 20 4 gluDisk
    glEndList

    qobj get GLU_SILHOUETTE gluQuadricDrawStyle
    qobj get GLU_NONE gluQuadricNormals
    start-list get 3 + GL_COMPILE glNewList
    qobj get 0.0 1.0 20 4 0.0 225.0 gluPartialDisk
    glEndList
] add-dlist ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: build-dlist ( -- )

GL_FRONT GL_AMBIENT { 0.5 0.5 0.5 1.0 } gl-material-fv
GL_FRONT GL_SPECULAR { 1.0 1.0 1.0 1.0 } gl-material-fv
GL_FRONT GL_SHININESS { 50.0 } gl-material-fv

GL_LIGHT0 GL_POSITION { 1.0 1.0 1.0 0.0 } gl-light-fv

GL_LIGHT_MODEL_AMBIENT { 0.5 0.5 0.5 1.0 } gl-light-model-fv

{ 0 0 0 0 } gl-clear-color

GL_LIGHTING gl-enable
GL_LIGHT0 gl-enable
GL_DEPTH_TEST gl-enable

GL_PROJECTION gl-matrix-mode gl-load-identity
-2.5 2.5 -2.5 2.5 -10.0 10.0 gl-ortho
GL_MODELVIEW gl-matrix-mode gl-load-identity

GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor gl-clear

gl-push-matrix
GL_LIGHTING gl-enable
GL_SMOOTH gl-shade-model
{ -1.0 -1.0 0.0 } gl-translate
start-list get gl-call-list

GL_FLAT gl-shade-model
{ 0 2 0 } gl-translate
gl-push-matrix
300 { 1 0 0 } gl-rotate
start-list get 1 + gl-call-list
gl-pop-matrix

GL_LIGHTING gl-disable
{ 0.0 1.0 1.0 1.0 } gl-color
{ 2.0 -2.0 0.0 } gl-translate
start-list get 2 + gl-call-list

{ 1 1 0 1 } gl-color
{ 0 2 0 } gl-translate
start-list get 3 + gl-call-list

gl-pop-matrix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: threads

: go ( -- )
slate-window
init flush-dlist flush-slate 1000 sleep reset-slate
build-dlist flush-dlist flush-slate ;

! USE: redbook-examples-quadric
! go