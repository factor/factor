! (c)2009 Joe Groff bsd license
USING: help.markup help.syntax kernel math multiline quotations strings ;
IN: gpu.shaders

HELP: <program-instance>
{ $values
    { "program" program }
    { "instance" program-instance }
}
{ $description "Compiles and links an instance of " { $snippet "program" } " for the current graphics context. If an instance already exists for " { $snippet "program" } " in the current context, it is reused." } ;

HELP: <shader-instance>
{ $values
    { "shader" shader }
    { "instance" shader-instance }
}
{ $description "Compiles an instance of " { $snippet "shader" } " for the current graphics context. If an instance already exists for " { $snippet "shader" } " in the current context, it is reused." } ;

HELP: GLSL-PROGRAM:
{ $syntax "GLSL-PROGRAM: program-name shader shader ... shader ;" }
{ $description "Defines a new " { $link program } " named " { $snippet "program-name" } ". When the program is instantiated with " { $link <program-instance> } ", it will link together instances of all of the specified " { $link shader } "s to create the program instance." } ;

HELP: GLSL-SHADER-FILE:
{ $syntax "GLSL-SHADER-FILE: shader-name shader-kind \"filename\"" }
{ $description "Defines a new " { $link shader } " of kind " { $link shader-kind } " named " { $snippet "shader-name" } ". The shader will read its source code from " { $snippet "filename" } " in the current Factor source file's directory." } ;

HELP: GLSL-SHADER:
{ $syntax <" GLSL-SHADER-FILE: shader-name shader-kind

shader source

; "> }
{ $description "Defines a new " { $link shader } " of kind " { $link shader-kind } " named " { $snippet "shader-name" } ". The shader will read its source code from the current Factor source file between the " { $snippet "GLSL-SHADER:" } " line and the first subsequent line with a single semicolon on it." } ;

{ POSTPONE: GLSL-PROGRAM: POSTPONE: GLSL-SHADER-FILE: POSTPONE: GLSL-SHADER: } related-words

HELP: attribute-index
{ $values
    { "program-instance" program-instance } { "attribute-name" string }
    { "index" integer }
}
{ $description "Returns the numeric index of the vertex attribute named " { $snippet "attribute-name" } " in " { $snippet "program-instance" } "." } ;

HELP: compile-shader-error
{ $class-description "An error compiling the source for a " { $link shader } "."
{ $list
{ "The " { $snippet "shader" } " slot indicates the shader that failed to compile." }
{ "The " { $snippet "log" } " slot contains the error string from the GLSL compiler." }
} } ;

HELP: fragment-shader
{ $class-description "This " { $link shader-kind } " indicates that a " { $link shader } " is a fragment shader." } ;

HELP: link-program-error
{ $class-description "An error linking the constituent shaders of a " { $link program } "."
{ $list
{ "The " { $snippet "program" } " slot indicates the program that failed to link." }
{ "The " { $snippet "log" } " slot contains the error string from the GLSL linker." }
} } ;

{ compile-shader-error link-program-error } related-words

HELP: output-index
{ $values
    { "program-instance" program-instance } { "output-name" string }
    { "index" integer }
}
{ $description "Returns the numeric index of the fragment shader output named " { $snippet "output-name" } " in " { $snippet "program-instance" } "." }
{ $notes "Named fragment shader outputs require OpenGL 3.0 or later and GLSL 1.30 or later, or OpenGL 2.0 or later and GLSL 1.20 or earlier with the " { $snippet "GL_EXT_gpu_shader4" } " extension." } ;

HELP: program
{ $class-description "A " { $snippet "program" } " provides a specification for linking a " { $link program-instance } " in a graphics context. Programs are defined with " { $link POSTPONE: GLSL-PROGRAM: } " and instantiated in a context with " { $link <program-instance> } "." } ;

HELP: program-instance
{ $class-description "A " { $snippet "program-instance" } " is a shader " { $link program } " that has been compiled and linked for a graphics context using " { $link <program-instance> } "." } ;

HELP: refresh-program
{ $values
    { "program" program }
}
{ $description "Rereads the source code for every " { $link shader } " in " { $link program } " and attempts to refresh all the existing " { $link shader-instance } "s and " { $link program-instance } "s for those programs. If the new source code fails to compile or link, the existing instances are untouched; otherwise, they are updated on the fly to reference the newly compiled code." } ;

HELP: shader
{ $class-description "A " { $snippet "shader" } " provides a block of GLSL source code that can be compiled into a " { $link shader-instance } " in a graphics context. Shaders are defined with " { $link POSTPONE: GLSL-SHADER: } " or " { $link POSTPONE: GLSL-SHADER-FILE: } " and instantiated in a context with " { $link <shader-instance> } "." } ;

HELP: shader-instance
{ $class-description "A " { $snippet "shader-instance" } " is a " { $link shader } " that has been compiled for a graphics context using " { $link <shader-instance> } "." } ;

HELP: shader-kind
{ $class-description "A " { $snippet "shader-kind" } " value is passed as part of a " { $link POSTPONE: GLSL-SHADER: } " or " { $link POSTPONE: GLSL-SHADER-FILE: } " definition to indicate the kind of " { $link shader } " being defined."
{ $list
{ { $link vertex-shader } "s run during primitive assembly and map input vertex data to positions in screen space for rasterization." }
{ { $link fragment-shader } "s run as part of rasterization and decide the final rendered output of a primitive as the outputs of the vertex shader are interpolated across its surface." }
} } ;

HELP: uniform-index
{ $values
    { "program-instance" program-instance } { "uniform-name" string }
    { "index" integer }
}
{ $description "Returns the numeric index of the uniform parameter named " { $snippet "output-name" } " in " { $snippet "program-instance" } "." } ;

HELP: vertex-shader
{ $class-description "This " { $link shader-kind } " indicates that a " { $link shader } " is a vertex shader." } ;

ARTICLE: "gpu.shaders" "Shader objects"
"The " { $vocab-link "gpu.shaders" } " vocabulary supports defining, compiling, and linking " { $link shader } "s into " { $link program } "s that run on the GPU and control rendering."
{ $subsection POSTPONE: GLSL-PROGRAM: }
{ $subsection POSTPONE: GLSL-SHADER: }
{ $subsection POSTPONE: GLSL-SHADER-FILE: }
"A program must be instantiated for each graphics context it is used in:"
{ $subsection <program-instance> }
"Program instances can be updated on the fly, allowing for interactive development of shaders:"
{ $subsection refresh-program } ;

ABOUT: "gpu.shaders"
