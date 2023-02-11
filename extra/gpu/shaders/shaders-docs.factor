! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: classes classes.struct gpu.buffers gpu.shaders.private
help.markup help.syntax images math sequences strings words ;
IN: gpu.shaders

HELP: <multi-vertex-array>
{ $values
    { "vertex-formats" "a list of " { $link buffer-ptr } "/" { $link vertex-format } " pairs" }
    { "program-instance" program-instance }
    { "vertex-array" vertex-array }
}
{ $description "Creates a new " { $link vertex-array } " to feed data to " { $snippet "program-instance" } " from the set of " { $link buffer } "s specified in " { $snippet "vertex-formats" } ". The first element of each pair in " { $snippet "vertex-formats" } " can be either a " { $link buffer-ptr } " or a " { $link buffer } "; in the latter case, vertex data in the associated format is read from the beginning of the buffer." } ;

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

HELP: <vertex-array-object>
{ $values
  { "vertex-buffer" "a vertex buffer" }
  { "program-instance" program-instance }
  { "format" vertex-format }
  { "vertex-array" vertex-array }
}
{ $description "Creates a new vertex array object." } ;

HELP: feedback-format:
{ $syntax "feedback-format: vertex-format" }
{ $description "When used as part of a " { $link POSTPONE: GLSL-PROGRAM: } " definition, this syntax specifies the " { $link vertex-format } " in which transform feedback output will be generated." } ;

HELP: GLSL-PROGRAM:
{ $syntax "GLSL-PROGRAM: program-name shader shader ... [vertex-format vertex-format ...] [feedback-format: vertex-format] ;" }
{ $description "Defines a new shader " { $link program } " named " { $snippet "program-name" } ". When the program is instantiated with " { $link <program-instance> } ", it will link together instances of all of the specified " { $link shader } "s to create the program instance. If any " { $link vertex-format } "s are specified, their attributes will be pre-assigned attribute indexes at link time, to ensure that their indexes remain constant if the program is refreshed with " { $link refresh-program } ". A transform feedback vertex format may optionally be specified with " { $link POSTPONE: feedback-format: } "; if the program is used to collect transform feedback, the given vertex format will be used for the output." }
{ $notes "Transform feedback requires OpenGL 3.0 or one of the " { $snippet "GL_EXT_transform_feedback" } " or " { $snippet "GL_ARB_transform_feedback" } " extensions." } ;

HELP: GLSL-SHADER-FILE:
{ $syntax "GLSL-SHADER-FILE: shader-name shader-kind \"filename\"" }
{ $description "Defines a new " { $link shader } " of kind " { $link shader-kind } " named " { $snippet "shader-name" } ". The shader will read its source code from " { $snippet "filename" } " in the current Factor source file's directory." } ;

HELP: GLSL-SHADER:
{ $syntax "GLSL-SHADER: shader-name shader-kind

shader source

;" }
{ $description "Defines a new " { $link shader } " of kind " { $link shader-kind } " named " { $snippet "shader-name" } ". The shader will read its source code from the current Factor source file between the " { $snippet "GLSL-SHADER:" } " line and the first subsequent line with a single semicolon on it." } ;

HELP: VERTEX-FORMAT:
{ $syntax "VERTEX-FORMAT: format-name
    { \"attribute\"/f component-type dimension normalize? }
    { \"attribute\"/f component-type dimension normalize? }
    ...
    { \"attribute\"/f component-type dimension normalize? } ;" }
{ $description "Defines a new binary " { $link vertex-format } " for structuring vertex data stored in " { $link buffer } "s. Each " { $snippet "attribute" } " name either corresponds to an input parameter of a vertex shader, or is " { $link f } " to include padding in the vertex format. The " { $link component-type } " determines the format of the components, and the " { $snippet "dimension" } " determines the number of components. If the " { $snippet "component-type" } " is an integer type and " { $snippet "normalize?" } " is true, the component values will be scaled to the range 0.0 to 1.0 when fed to the vertex shader; otherwise, they will be cast to floats retaining their integral values." } ;

HELP: VERTEX-STRUCT:
{ $syntax "VERTEX-STRUCT: struct-name format-name" }
{ $description "Defines a struct class (like " { $link POSTPONE: STRUCT: } ") with the same binary format and component types as the given " { $link vertex-format } "." } ;

{ POSTPONE: GLSL-PROGRAM: POSTPONE: GLSL-SHADER-FILE: POSTPONE: GLSL-SHADER: } related-words

HELP: attribute-index
{ $values
    { "program-instance" program-instance } { "attribute-name" string }
    { "index" integer }
}
{ $description "Returns the numeric index of the vertex attribute named " { $snippet "attribute-name" } " in " { $snippet "program-instance" } "." } ;

HELP: <vertex-array>
{ $values
    { "vertex-buffer" "a " { $link buffer } " or " { $link buffer-ptr } } { "program-instance" program-instance }
    { "vertex-array" vertex-array }
}
{ $description "Creates a new " { $link vertex-array } " from the entire contents of a single " { $link buffer } " for use with a " { $link program-instance } ". The data in " { $snippet "buffer" } " is taken in the first " { $link vertex-format } " specified in the program instance's originating " { $link POSTPONE: GLSL-PROGRAM: } " definition. If the program has no associated vertex formats, an error will be thrown. To specify a different vertex format, use " { $link <vertex-array*> } "." } ;

HELP: <vertex-array*>
{ $values
    { "vertex-buffer" "a " { $link buffer } " or " { $link buffer-ptr } } { "program-instance" program-instance } { "format" vertex-format }
    { "vertex-array" vertex-array }
}
{ $description "Creates a new " { $link vertex-array } " from the entire contents of a single " { $link buffer } " for use with a " { $link program-instance } ". The data in " { $snippet "buffer" } " is taken in the specified " { $link vertex-format } "." } ;

{ vertex-array <multi-vertex-array> <vertex-array> <vertex-array*> } related-words

HELP: compile-shader-error
{ $class-description "An error compiling the source for a " { $link shader } "."
{ $list
{ "The " { $snippet "shader" } " slot indicates the shader that failed to compile." }
{ "The " { $snippet "log" } " slot contains the error string from the GLSL compiler." }
} } ;

HELP: define-vertex-format
{ $values
    { "class" class } { "vertex-attributes" sequence }
}
{ $description "Defines a new " { $link vertex-format } " with the binary format specified by the " { $link vertex-attribute } " tuple values in " { $snippet "vertex-attributes" } ". The runtime equivalent of " { $link POSTPONE: VERTEX-FORMAT: } ". This word must be called inside a compilation unit." } ;

HELP: define-vertex-struct
{ $values
    { "class" word } { "vertex-format" vertex-format }
}
{ $description "Defines a new struct C type from a " { $link vertex-format } ". The runtime equivalent of " { $link POSTPONE: VERTEX-STRUCT: } ". This word must be called inside a compilation unit." } ;

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
{ $class-description "A " { $snippet "program" } " provides a specification for linking a " { $link program-instance } " in a graphics context. Programs are defined with " { $link POSTPONE: GLSL-PROGRAM: } " and instantiated for a context with " { $link <program-instance> } "." } ;

HELP: program-instance
{ $class-description "A " { $snippet "program-instance" } " is a shader " { $link program } " that has been compiled and linked for a graphics context using " { $link <program-instance> } "." } ;

HELP: refresh-program
{ $values
    { "program" program }
}
{ $description "Rereads the source code for every " { $link shader } " in " { $link program } " and attempts to refresh all the existing " { $link shader-instance } "s and " { $link program-instance } "s for those shaders. If any of the new source code fails to compile or link, the existing valid shader and program instances will remain untouched. However, subsequent attempts to compile new shader or program instances will still attempt to use the new source code. If the compilation and linking succeed, the existing shader and program instances will be updated on the fly to reference the newly compiled code." } ;

HELP: shader
{ $class-description "A " { $snippet "shader" } " provides a block of GLSL source code that can be compiled into a " { $link shader-instance } " in a graphics context. Shaders are defined with " { $link POSTPONE: GLSL-SHADER: } " or " { $link POSTPONE: GLSL-SHADER-FILE: } " and instantiated for a context with " { $link <shader-instance> } "." } ;

HELP: shader-instance
{ $class-description "A " { $snippet "shader-instance" } " is a " { $link shader } " that has been compiled for a graphics context using " { $link <shader-instance> } "." } ;

HELP: shader-kind
{ $class-description "A " { $snippet "shader-kind" } " value is passed as part of a " { $link POSTPONE: GLSL-SHADER: } " or " { $link POSTPONE: GLSL-SHADER-FILE: } " definition to indicate the kind of " { $link shader } " being defined."
{ $list
{ { $link vertex-shader } "s run during primitive assembly and map input vertex data to positions in screen space for rasterization." }
{ { $link fragment-shader } "s run as part of rasterization and decide the final rendered output of a primitive as the outputs of the vertex shader are interpolated across its surface." }
} } ;

HELP: too-many-feedback-formats-error
{ $class-description "This error is thrown when a " { $link POSTPONE: GLSL-PROGRAM: } " definition attempts to include more than one " { $link vertex-format } " for transform feedback formatting." } ;

HELP: invalid-link-feedback-format-error
{ $class-description "This error is thrown when the " { $link vertex-format } " specified as the transform feedback output format of a " { $link program } " is not suitable for the purpose. Transform feedback formats do not support padding (fields with a name of " { $link f } ")." } ;

HELP: inaccurate-feedback-attribute-error
{ $class-description "This error is thrown when the " { $link vertex-format } " specified as the transform feedback output format of a " { $link program } " does not match the format of the output attributes linked into a " { $link program-instance } "." } ;

HELP: uniform-index
{ $values
    { "program-instance" program-instance } { "uniform-name" string }
    { "index" integer }
}
{ $description "Returns the numeric index of the uniform parameter named " { $snippet "output-name" } " in " { $snippet "program-instance" } "." } ;

HELP: vertex-shader
{ $class-description "This " { $link shader-kind } " indicates that a " { $link shader } " is a vertex shader." } ;

HELP: vertex-array
{ $class-description "A " { $snippet "vertex-array" } " object associates a shader " { $link program-instance } " with vertex attribute data from one or more " { $link buffer } "s. The format of the binary data inside these buffers is described using " { $link vertex-format } "s. " { $snippet "vertex-array" } "s are constructed using the " { $link <multi-vertex-array> } " or " { $link <vertex-array*> } " words. The actual type of a vertex-array object is opaque, but the " { $link vertex-array-buffers } " word can be used to query a vertex array object for its component buffers." } ;

HELP: vertex-array-buffers
{ $values
    { "vertex-array" vertex-array }
    { "buffers" sequence }
}
{ $description "Returns a sequence containing all of the " { $link buffer } " objects that make up " { $snippet "vertex-array" } "." } ;

HELP: vertex-array-buffer
{ $values
    { "vertex-array" vertex-array }
    { "vertex-buffer" buffer }
}
{ $description "Returns the first " { $link buffer } " object that makes up " { $snippet "vertex-array" } "." } ;

{ vertex-array-buffer vertex-array-buffers } related-words

HELP: vertex-attribute
{ $class-description "This tuple type is passed to " { $link define-vertex-format } " to define a new " { $link vertex-format } " type." } ;

HELP: vertex-format
{ $class-description "This class encompasses all vertex formats defined by " { $link POSTPONE: VERTEX-FORMAT: } ". A vertex format defines the binary layout of vertex attribute data in a " { $link buffer } " for use as part of a " { $link vertex-array } ". See the " { $link POSTPONE: VERTEX-FORMAT: } " documentation for details on how vertex formats are defined." } ;

HELP: vertex-format-size
{ $values
    { "format" vertex-format }
    { "size" integer }
}
{ $description "Returns the size in bytes of a set of vertex attributes in " { $snippet "format" } "." } ;

ARTICLE: "gpu.shaders" "Shader objects"
"The " { $vocab-link "gpu.shaders" } " vocabulary supports defining, compiling, and linking " { $link shader } "s into " { $link program } "s that run on the GPU and control rendering."
{ $subsections
    POSTPONE: GLSL-PROGRAM:
    POSTPONE: GLSL-SHADER:
    POSTPONE: GLSL-SHADER-FILE:
}
"A program must be instantiated for each graphics context it is used in:"
{ $subsections <program-instance> }
"Program instances can be updated on the fly, allowing for interactive development of shaders:"
{ $subsections refresh-program }
"Render data inside GPU " { $link buffer } "s is organized into " { $link vertex-array } "s for consumption by shader code:"
{ $subsections
    vertex-array
    <multi-vertex-array>
    <vertex-array*>
    <vertex-array>
    POSTPONE: VERTEX-FORMAT:
} ;

ABOUT: "gpu.shaders"
