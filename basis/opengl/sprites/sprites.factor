! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences opengl opengl.gl assocs ;
IN: opengl.sprites

TUPLE: sprite loc dim dim2 dlist texture ;

: <sprite> ( loc dim dim2 -- sprite )
    f f sprite boa ;

: sprite-size2 ( sprite -- w h ) dim2>> first2 ;

: sprite-width ( sprite -- w ) dim>> first ;

: draw-sprite ( sprite -- )
    GL_TEXTURE_COORD_ARRAY [
        dup loc>> gl-translate
        GL_TEXTURE_2D over texture>> glBindTexture
        init-texture rect-texture-coords
        dim2>> fill-rect-vertices
        (gl-fill-rect)
        GL_TEXTURE_2D 0 glBindTexture
    ] do-enabled-client-state ;

: make-sprite-dlist ( sprite -- id )
    GL_MODELVIEW [
        GL_COMPILE [ draw-sprite ] make-dlist
    ] do-matrix ;

: init-sprite ( texture sprite -- )
    swap >>texture
    dup make-sprite-dlist >>dlist drop ;

: free-sprite ( sprite -- )
    [ dlist>> delete-dlist ]
    [ texture>> delete-texture ] bi ;

: free-sprites ( sprites -- )
    [ nip [ free-sprite ] when* ] assoc-each ;