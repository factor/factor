
USING: kernel alien.c-types namespaces sequences opengl.gl ;

IN: cfdg.gl

: get-modelview-matrix ( -- alien )
  GL_MODELVIEW_MATRIX 16 "GLdouble" <c-array> tuck glGetDoublev ;

SYMBOL: modelview-matrix-stack

: init-modelview-matrix-stack ( -- ) V{ } clone modelview-matrix-stack set ;

: push-modelview-matrix ( -- )
  get-modelview-matrix modelview-matrix-stack get push ;

: pop-modelview-matrix ( -- ) modelview-matrix-stack get pop glLoadMatrixd ;