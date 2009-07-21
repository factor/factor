! (c)2009 Joe Groff bsd license
USING: alien alien.syntax byte-arrays classes gpu.buffers
gpu.framebuffers gpu.shaders gpu.textures help.markup
help.syntax images kernel math multiline sequences
specialized-arrays.alien specialized-arrays.uint
specialized-arrays.ulong strings ;
IN: gpu.render

HELP: <index-elements>
{ $values
    { "ptr" gpu-data-ptr } { "count" integer } { "index-type" index-type }
    { "index-elements" index-elements }
}
{ $description "Constructs an " { $link index-elements } " tuple." } ;

HELP: <index-range>
{ $values
    { "start" integer } { "count" integer }
    { "index-range" index-range }
}
{ $description "Constructs an " { $link index-range } " tuple." } ;

HELP: <multi-index-elements>
{ $values
    { "buffer" { $maybe buffer } } { "ptrs" "an " { $link uint-array } " or " { $link void*-array } } { "counts" uint-array } { "index-type" index-type }
    { "multi-index-elements" multi-index-elements }
}
{ $description "Constructs a " { $link multi-index-elements } " tuple." } ;

HELP: <multi-index-range>
{ $values
    { "starts" uint-array } { "counts" uint-array }
    { "multi-index-range" multi-index-range }
}
{ $description "Constructs a " { $link multi-index-range } " tuple." } ;

HELP: <vertex-array>
{ $values
    { "program-instance" program-instance } { "vertex-formats" "a list of " { $link buffer-ptr } "/" { $link vertex-format } " pairs" }
    { "vertex-array" vertex-array }
}
{ $description "Creates a new " { $link vertex-array } " to feed data to " { $snippet "program-instance" } " from the set of " { $link buffer } "s specified in " { $snippet "vertex-formats" } "." } ;

HELP: UNIFORM-TUPLE:
{ $syntax <" UNIFORM-TUPLE: class-name
    { "slot" uniform-type dimension }
    { "slot" uniform-type dimension }
    ...
    { "slot" uniform-type dimension } ; "> }
{ $description "Defines a new " { $link uniform-tuple } " class. Tuples of the new class can be used as the " { $snippet "uniforms" } " slot of a " { $link render-set } " in order to set the uniform parameters of the active shader program. The " { $link uniform-type } " of each slot defines the component type, and the " { $snippet "dimension" } " defines the vector or matrix dimensions; for example, a slot " { $snippet "{ \"foo\" float-uniform { 2 2 } }" } " will define a slot " { $snippet "foo" } " as a 2x2 matrix of floats."
$nl
"Uniform parameters are passed from Factor to the shader program through the uniform tuple as follows:"
{ $list
{ { $link int-uniform } "s and " { $link uint-uniform } "s take their values from Factor " { $link integer } "s." }
{ { $link float-uniform } "s take their values from Factor " { $link float } "s." }
{ { $link bool-uniform } "s take their values from Factor " { $link boolean } "s." }
{ { $link texture-uniform } "s take their values from " { $link texture } " objects." }
{ "Vector uniforms are passed as Factor " { $link sequence } "s of the corresponding component type." }
{ "Matrix uniforms are passed as row-major Factor " { $link sequence } "s of sequences of the corresponding component type." } }
"A value of a uniform tuple type is a standard Factor tuple. Uniform tuples are constructed with " { $link new } " or " { $link boa } ", and values are placed inside them using standard slot accessors."
} ;

HELP: VERTEX-FORMAT:
{ $syntax <" VERTEX-FORMAT: format-name
    { "attribute"/f component-type dimension normalize? }
    { "attribute"/f component-type dimension normalize? }
    ...
    { "attribute"/f component-type dimension normalize? } ; "> }
{ $description "Defines a new binary " { $link vertex-format } " for structuring vertex data stored in " { $link buffer } "s. Each " { $snippet "attribute" } " name either corresponds to an input parameter of a vertex shader, or is " { $link f } " to include padding in the vertex format. The " { $link component-type } " determines the format of the components, and the " { $snippet "dimension" } " determines the number of components. If the " { $snippet "component-type" } " is an integer type and " { $snippet "normalize?" } " is true, the component values will be scaled to the range 0.0 to 1.0 when fed to the vertex shader; otherwise, they will be cast to floats retaining their integral values." } ;

HELP: VERTEX-STRUCT:
{ $syntax <" VERTEX-STRUCT: struct-name format-name "> }
{ $description "Defines a struct C type (like " { $link POSTPONE: C-STRUCT: } ") with the same binary format and component types as the given " { $link vertex-format } "." } ;

HELP: bool-uniform
{ $class-description "This " { $link uniform-type } " value indicates a uniform parameter whose components are " { $snippet "bool" } "s." } ;

HELP: buffer>vertex-array
{ $values
    { "vertex-buffer" buffer } { "program-instance" program-instance } { "format" vertex-format }
    { "vertex-array" vertex-array }
}
{ $description "Creates a new " { $link vertex-array } " from the entire contents of a single " { $link buffer } " in a single " { $link vertex-format } " for use with " { $snippet "program-instance" } "." } ;

{ vertex-array <vertex-array> buffer>vertex-array } related-words

HELP: define-uniform-tuple
{ $values
    { "class" class } { "superclass" class } { "uniforms" sequence }
}
{ $description "Defines a new " { $link uniform-tuple } " as a subclass of " { $snippet "superclass" } " with the slots specified by the " { $link uniform } " tuple values in " { $snippet "uniforms" } ". The runtime equivalent of " { $link POSTPONE: UNIFORM-TUPLE: } ". This word must be called inside a compilation unit." } ;

HELP: define-vertex-format
{ $values
    { "class" class } { "vertex-attributes" sequence }
}
{ $description "Defines a new " { $link vertex-format } " with the binary format specified by the " { $link vertex-attribute } " tuple values in " { $snippet "vertex-attributes" } ". The runtime equivalent of " { $link POSTPONE: VERTEX-FORMAT: } ". This word must be called inside a compilation unit." } ;

HELP: define-vertex-struct
{ $values
    { "struct-name" string } { "vertex-format" vertex-format }
}
{ $description "Defines a new struct C type from a " { $link vertex-format } ". The runtime equivalent of " { $link POSTPONE: VERTEX-STRUCT: } ". This word must be called inside a compilation unit." } ;

HELP: float-uniform
{ $class-description "This " { $link uniform-type } " value indicates a uniform parameter whose components are " { $snippet "float" } "s." } ;

{ bool-uniform int-uniform float-uniform texture-uniform } related-words

{ index-elements index-range multi-index-elements multi-index-range } related-words

HELP: index-elements
{ $class-description "Objects of this tuple class can be passed as the " { $snippet "indexes" } " slot of a " { $link render-set } " to instruct " { $link render } " to assemble primitives from the active " { $link vertex-array } " by using an array of indexes in CPU or GPU memory."
{ $list
{ "The " { $snippet "ptr" } " slot contains a " { $link byte-array } ", " { $link alien } ", or " { $link buffer-ptr } " value referencing the beginning of the index array." }
{ "The " { $snippet "count" } " slot contains an " { $link integer } " value specifying the number of indexes to supply from the array." }
{ "The " { $snippet "index-type" } " slot contains an " { $link index-type } " value specifying whether the array consists of " { $link ubyte-indexes } ", " { $link ushort-indexes } ", or " { $link uint-indexes } "." } 
} } ;

HELP: index-range
{ $class-description "Objects of this tuple class can be passed as the " { $snippet "indexes" } " slot of a " { $link render-set } " to instruct " { $link render } " to assemble primitives sequentially from a slice of the active " { $link vertex-array } "."
{ $list
{ "The " { $snippet "start" } " slot contains an " { $link integer } " value indicating the first element of the array to draw." }
{ "The " { $snippet "count" } " slot contains an " { $link integer } " value indicating the number of elements to draw." }
} } ;

HELP: index-type
{ $class-description "The " { $snippet "index-type" } " slot of an " { $link index-elements } " or " { $link multi-index-elements } " tuple indicates the type of the index array's elements: one-byte " { $link ubyte-indexes } ", two-byte " { $link ushort-indexes } ", or four-byte " { $link uint-indexes } "."  } ;

{ index-type ubyte-indexes ushort-indexes uint-indexes } related-words

HELP: int-uniform
{ $class-description "This " { $link uniform-type } " value indicates a uniform parameter whose components are " { $snippet "int" } "s." } ;

HELP: invalid-uniform-type
{ $values
    { "uniform" uniform }
}
{ $description "Throws an error indicating that a slot of a " { $link uniform-tuple } " has been declared to have an invalid type." } ;

HELP: lines-mode
{ $class-description "This " { $link primitive-mode } " value instructs " { $link render } " to assemble a line from each pair of indexed vertex array elements." } ;

HELP: line-loop-mode
{ $class-description "This " { $link primitive-mode } " value instructs " { $link render } " to assemble a connected loop of lines from each consecutive pair of indexed vertex array elements, adding another line to close the last and first elements." } ;

HELP: line-strip-mode
{ $class-description "This " { $link primitive-mode } " value instructs " { $link render } " to assemble a connected strip of lines from each consecutive pair of indexed vertex array elements." } ;

HELP: multi-index-elements
{ $class-description "Objects of this tuple class can be passed as the " { $snippet "indexes" } " slot of a non-instanced " { $link render-set } " to instruct " { $link render } " to assemble primitives from the active " { $link vertex-array } " by using multiple arrays of indexes in CPU or GPU memory."
{ $list
{ "The " { $snippet "buffer" } " slot contains either a " { $link buffer } " object to read indexes from, or " { $link f } " to read from CPU memory." }
{ "The " { $snippet "ptrs" } " slot contains either a " { $link void*-array } " of pointers to the starts of index data, or a pointer-sized " { $link ulong-array } " of offsets into " { $snippet "buffer" } "." }
{ "The " { $snippet "counts" } " slot contains a " { $link uint-array } " containing the number of indexes to read from each pointer or offset in " { $snippet "ptrs" } "." }
{ "The " { $snippet "index-type" } " slot contains an " { $link index-type } " value specifying whether the arrays consist of " { $link ubyte-indexes } ", " { $link ushort-indexes } ", or " { $link uint-indexes } "." }
} } ;

HELP: multi-index-range
{ $class-description "Objects of this tuple class can be passed as the " { $snippet "indexes" } " slot of a non-instanced " { $link render-set } " to instruct " { $link render } " to assemble primitives from the active " { $link vertex-array } " by using multiple consecutive slices of its elements."
{ $list
{ "The " { $snippet "starts" } " slot contains a " { $link uint-array } " of indexes into the array from which to start generating primitives." }
{ "The " { $snippet "counts" } " slot contains a " { $link uint-array } " of corresponding counts of indexes to read from each specified " { $snippet "start" } " index." }
} } ;

HELP: points-mode
{ $class-description "This " { $link primitive-mode } " value instructs " { $link render } " to generate a point for each indexed vertex array element." } ;

HELP: primitive-mode
{ $class-description "The " { $snippet "primitive-mode" } " slot of a " { $link render-set } " tells " { $link render } " what kind of primitives to generate and how to assemble them from the selected elements of the active " { $link vertex-array } "."  }
{ $list
{ { $link points-mode } " causes each element to generate a point." }
{ { $link lines-mode } " causes each pair of elements to generate a disconnected line." }
{ { $link line-strip-mode } " causes each consecutive pair of elements to generate a connected strip of lines." }
{ { $link line-loop-mode } " causes each consecutive pair of elements to generate a connected loop of lines, with an extra line connecting the last and first elements." } 
{ { $link triangles-mode } " causes every 3 elements to generate an independent triangle." }
{ { $link triangle-strip-mode } " causes every consecutive group of 3 elements to generate a connected strip of triangles." } 
{ { $link triangle-fan-mode } " causes a triangle to be generated from the first element and every subsequent consecutive pair of elements in a fan pattern." } } ;

{ primitive-mode points-mode lines-mode line-strip-mode line-loop-mode triangles-mode triangle-strip-mode triangle-fan-mode } related-words

HELP: render
{ $values
    { "render-set" render-set }
}
{ $description "Submits a rendering job to the GPU. The values in the " { $link render-set } " tuple describe the job." } ;

HELP: render-set
{ $class-description "A " { $snippet "render-set" } " tuple describes a GPU rendering job."
{ $list
{ "The " { $link primitive-mode } " slot determines what kind of primitives should be rendered, and how they should be assembled." }
{ "The " { $link vertex-array } " slot supplies the shader program and vertex data to be rendered." }
{ "The " { $snippet "uniforms" } " slot contains a " { $link uniform-tuple } " with values for the shader program's uniform parameters." }
{ "The " { $snippet "indexes" } " slot contains one of the " { $link vertex-indexes } " types and selects elements from the vertex array to be rendered." }
{ "The " { $snippet "instances" } " slot, if not " { $link f } ", instructs the GPU to render several instances of the same set of vertexes. Instancing requires OpenGL 3.1 or one of the " { $snippet "GL_EXT_draw_instanced" } " or " { $snippet "GL_ARB_draw_instanced" } " extensions." }
{ "The " { $snippet "framebuffer" } " slot determines the target for the rendering output. Either the " { $link system-framebuffer } " or a user-created " { $link framebuffer } " object can be specified. User-created framebuffers require OpenGL 3.0 or one of the " { $snippet "GL_EXT_framebuffer_object" } " or " { $snippet "GL_ARB_framebuffer_object" } " extensions." }
{ "The " { $snippet "output-attachments" } " slot specifies which of the framebuffer's " { $link color-attachment-ref } "s to write the fragment shader's color output to. If the shader uses " { $snippet "gl_FragColor" } " or " { $snippet "gl_FragData[n]" } " to write its output, then " { $snippet "output-attachments" } " should be an array of " { $link color-attachment-ref } "s, and the output to color attachment binding is determined positionally. If the shader uses named output values, then " { $snippet "output-attachments" } " should be a list of string/" { $link color-attachment-ref } " pairs, mapping output names to color attachments. Named output values are available in GLSL 1.30 or later, and GLSL 1.20 and earlier using the " { $snippet "GL_EXT_gpu_shader4" } " extension." }
} } ;

{ render render-set } related-words

HELP: texture-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " is a texture. The dimension of the corresponding " { $link uniform } " slot must be " { $snippet "1" } "." } ;

HELP: triangle-fan-mode
{ $class-description "This " { $link primitive-mode } " value instructs " { $link render } " to generate a fan of triangles using the first indexed vertex array element and every subsequent consecutive pair of elements." } ;

HELP: triangle-strip-mode
{ $class-description "This " { $link primitive-mode } " value instructs " { $link render } " to generate a strip of triangles using every consecutive group of 3 indexed vertex array elements." } ;

HELP: triangles-mode
{ $class-description "This " { $link primitive-mode } " value instructs " { $link render } " to generate a triangle for each group of 3 indexed vertex array elements." } ;

HELP: ubyte-indexes
{ $class-description "This " { $link index-type } " indicates that an " { $link index-elements } " or " { $link multi-index-elements } " buffer consists of unsigned byte indexes." } ;

HELP: uint-indexes
{ $class-description "This " { $link index-type } " indicates that an " { $link index-elements } " or " { $link multi-index-elements } " buffer consists of four-byte unsigned int indexes." } ;

HELP: uint-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " is a scalar or vector of unsigned integers." } ;

HELP: uniform
{ $class-description "Values of this tuple type are passed to " { $link define-uniform-tuple } " to define a new " { $link uniform-tuple } " type." } ;

HELP: uniform-tuple
{ $class-description "The base class for tuple types defined with " { $link POSTPONE: UNIFORM-TUPLE: } ". A uniform tuple is used as part of a " { $link render-set } " to supply values for a shader program's uniform parameters. See the " { $link POSTPONE: UNIFORM-TUPLE: } " documentation for details on how uniform tuples are defined and used." } ;

HELP: uniform-type
{ $class-description { $snippet "uniform-type" } " values are used as part of a " { $link POSTPONE: UNIFORM-TUPLE: } " definition to define the types of uniform slots." } ;

{ uniform-type bool-uniform int-uniform float-uniform texture-uniform uint-uniform } related-words

HELP: ushort-indexes
{ $class-description "This " { $link index-type } " indicates that an " { $link index-elements } " or " { $link multi-index-elements } " buffer consists of two-byte unsigned short indexes." } ;

{ index-type ubyte-indexes ushort-indexes uint-indexes } related-words

HELP: vertex-array
{ $class-description "A " { $snippet "vertex-array" } " object associates a shader " { $link program-instance } " with vertex attribute data from one or more " { $link buffer } "s. The format of the binary data inside these buffers is described using " { $link vertex-format } "s. " { $snippet "vertex-array" } "s are constructed using the " { $link <vertex-array> } " or " { $link buffer>vertex-array } " words." } ;

HELP: vertex-array-buffer
{ $values
    { "vertex-array" vertex-array }
    { "vertex-buffer" buffer }
}
{ $description "Returns the first " { $link buffer } " object comprised in " { $snippet "vertex-array" } "." } ;

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

HELP: vertex-indexes
{ $class-description "This class is a union of the following tuple types, any of which can be used as the " { $snippet "indexes" } " slot of a " { $link render-set } " to select elements from a " { $link vertex-array } " for rendering."
{ $list
{ "An " { $link index-range } " value submits a sequential slice of a vertex array for rendering." }
{ "An " { $link index-elements } " value submits vertex array elements in an order specified by an array of indexes." }
{ "A " { $link multi-index-range } " value submits multiple sequential slices of a vertex array." }
{ "A " { $link multi-index-elements } " value submits multiple separate lists of indexed vertex array elements." }
} } ;

ARTICLE: "gpu.render" "Rendering"
"The " { $vocab-link "gpu.render" } " vocabulary contains words for organizing and submitting data to the GPU for rendering."
{ $subsection render }
{ $subsection render-set }
"Render data inside GPU " { $link buffer } "s is organized into " { $link vertex-array } "s for consumption by shader code:"
{ $subsection vertex-array }
{ $subsection <vertex-array> }
{ $subsection buffer>vertex-array }
{ $subsection POSTPONE: VERTEX-FORMAT: }
{ $link uniform-tuple } "s provide Factor types for containing and submitting shader uniform parameters:"
{ $subsection POSTPONE: UNIFORM-TUPLE: }
;

ABOUT: "gpu.render"
