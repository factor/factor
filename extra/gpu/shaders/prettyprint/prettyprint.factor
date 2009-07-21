USING: accessors debugger gpu.shaders io kernel prettyprint ;
IN: gpu.shaders.prettyprint

M: compile-shader-error error.
    "The GLSL shader " write
    [ shader>> name>> pprint-short " failed to compile." write nl ]
    [ log>> write nl ] bi ;

M: link-program-error error.
    "The GLSL program " write
    [ shader>> name>> pprint-short " failed to link." write nl ]
    [ log>> write nl ] bi ;
