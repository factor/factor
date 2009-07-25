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
