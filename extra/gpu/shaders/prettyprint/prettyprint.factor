USING: accessors debugger gpu.shaders io kernel prettyprint ;
IN: gpu.shaders.prettyprint

M: compile-shader-error error.
    "The GLSL shader " write
    [ shader>> name>> pprint-short " failed to compile." print ]
    [ log>> print ] bi ;

M: link-program-error error.
    "The GLSL program " write
    [ shader>> name>> pprint-short " failed to link." print ]
    [ log>> print ] bi ;

M: too-many-feedback-formats-error error.
    drop
    "Only one transform feedback format can be specified for a program." print ;

M: invalid-link-feedback-format-error error.
    drop
    "Vertex formats used for transform feedback can't contain padding fields." print ;

M: inaccurate-feedback-attribute-error error.
    drop
    "The types of the transform feedback attributes don't match those specified by the program's vertex format." print ;
