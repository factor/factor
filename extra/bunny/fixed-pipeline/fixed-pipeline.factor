USING: accessors alien.c-types bunny.model destructors kernel
opengl.gl specialized-arrays ;
SPECIALIZED-ARRAY: float
IN: bunny.fixed-pipeline

TUPLE: bunny-fixed-pipeline ;

: <bunny-fixed-pipeline> ( gadget -- draw )
    drop
    bunny-fixed-pipeline new ;

M: bunny-fixed-pipeline draw-bunny
    drop
    GL_LIGHTING glEnable
    GL_LIGHT0 glEnable
    GL_COLOR_MATERIAL glEnable
    GL_LIGHT0 GL_POSITION float-array{ 1.0 -1.0 1.0 1.0 } underlying>> glLightfv
    GL_FRONT_AND_BACK GL_SHININESS 100.0 glMaterialf
    GL_FRONT_AND_BACK GL_SPECULAR glColorMaterial
    GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE glColorMaterial
    0.6 0.5 0.5 1.0 glColor4f
    bunny-geom ;

M: bunny-fixed-pipeline dispose
    drop ;
