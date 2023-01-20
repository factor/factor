! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax byte-arrays classes
gpu.buffers gpu.framebuffers gpu.shaders gpu.textures help.markup
help.syntax images kernel math sequences
specialized-arrays strings ;
QUALIFIED-WITH: alien.c-types c
QUALIFIED-WITH: math m
SPECIALIZED-ARRAY: c:float
SPECIALIZED-ARRAY: int
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: ulong
SPECIALIZED-ARRAY: void*
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

HELP: UNIFORM-TUPLE:
{ $syntax "UNIFORM-TUPLE: class-name
    { \"slot\" uniform-type dimension }
    { \"slot\" uniform-type dimension }
    ...
    { \"slot\" uniform-type dimension } ;" }
{ $description "Defines a new " { $link uniform-tuple } " class. Tuples of the new class can be used as the " { $snippet "uniforms" } " slot of a " { $link render-set } " in order to set the uniform parameters of the active shader program. The " { $link uniform-type } " of each slot defines the component type, and the " { $snippet "dimension" } " specifies an array length if not " { $link f } "."
$nl
"Uniform parameters are passed from Factor to the shader program through the uniform tuple as follows:"
{ $list
{ { $link int-uniform } "s and " { $link uint-uniform } "s take their values from Factor " { $link integer } "s." }
{ { $link float-uniform } "s take their values from Factor " { $link m:float } "s." }
{ { $link bool-uniform } "s take their values from Factor " { $link boolean } "s." }
{ { $link texture-uniform } "s take their values from " { $link texture } " objects." }
{ "Vector uniforms take their values from Factor " { $link sequence } "s of the corresponding component type."
    { $list
    { "Float vector types: " { $link vec2-uniform } ", " { $link vec3-uniform } ", " { $link vec4-uniform } }
    { "Integer vector types: " { $link ivec2-uniform } ", " { $link ivec3-uniform } ", " { $link ivec4-uniform } }
    { "Unsigned integer vector types: " { $link uvec2-uniform } ", " { $link uvec3-uniform } ", " { $link uvec4-uniform } }
    { "Boolean vector types: " { $link bvec2-uniform } ", " { $link bvec3-uniform } ", " { $link bvec4-uniform } }
    }
}
{ "Matrix uniforms take their values either from row-major Factor " { $link sequence } "s of sequences of floats, or from " { $link alien } "s or " { $link float-array } "s referencing packed column-major arrays of floats. Matrix types are:"
    { $list
    { { $link mat2-uniform } ", " { $link mat2x3-uniform } ", " { $link mat2x4-uniform } }
    { { $link mat3x2-uniform } ", " { $link mat3-uniform } ", " { $link mat3x4-uniform } }
    { { $link mat4x2-uniform } ", " { $link mat4x3-uniform } ", " { $link mat4-uniform } }
    }
"Rectangular matrix type names are column x row."
}
{ "Uniform slots can also be defined as other " { $snippet "uniform-tuple" } " types to bind uniform structures. The uniform structure will take its value from the slots of a tuple of the given type." }
{ "Array uniforms are passed either as Factor sequences of the corresponding type specified above, or as " { $link alien } "s or " { $vocab-link "specialized-arrays" } " that reference pre-packed binary arrays of " { $link c:int } "s or " { $link c:float } "s." }
}
$nl
"A value of a uniform tuple type is a standard Factor tuple. Uniform tuples are constructed with " { $link new } " or " { $link boa } ", and values are placed inside them using standard slot accessors."
} ;

HELP: bool-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a boolean uniform parameter." } ;

HELP: bvec2-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a two-component boolean vector uniform parameter." } ;

HELP: bvec3-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a three-component boolean vector uniform parameter." } ;

HELP: bvec4-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a four-component boolean vector uniform parameter." } ;

HELP: define-uniform-tuple
{ $values
    { "class" class } { "superclass" class } { "uniforms" sequence }
}
{ $description "Defines a new " { $link uniform-tuple } " as a subclass of " { $snippet "superclass" } " with the slots specified by the " { $link uniform } " tuple values in " { $snippet "uniforms" } ". The runtime equivalent of " { $link POSTPONE: UNIFORM-TUPLE: } ". This word must be called inside a compilation unit." } ;

HELP: float-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a float uniform parameter." } ;

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
{ $class-description "The " { $snippet "index-type" } " slot of an " { $link index-elements } " or " { $link multi-index-elements } " tuple indicates the type of the index array's elements: one-byte " { $link ubyte-indexes } ", two-byte " { $link ushort-indexes } ", or four-byte " { $link uint-indexes } "." } ;

{ index-type ubyte-indexes ushort-indexes uint-indexes } related-words

HELP: int-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a signed integer uniform parameter." } ;

HELP: invalid-uniform-type
{ $values
    { "uniform" uniform }
}
{ $description "Throws an error indicating that a slot of a " { $link uniform-tuple } " has been declared to have an invalid type." } ;

HELP: ivec2-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a two-component integer vector uniform parameter." } ;

HELP: ivec3-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a three-component integer vector uniform parameter." } ;

HELP: ivec4-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a four-component integer vector uniform parameter." } ;

HELP: lines-mode
{ $class-description "This " { $link primitive-mode } " value instructs " { $link render } " to assemble a line from each pair of indexed vertex array elements." } ;

HELP: line-loop-mode
{ $class-description "This " { $link primitive-mode } " value instructs " { $link render } " to assemble a connected loop of lines from each consecutive pair of indexed vertex array elements, adding another line to close the last and first elements." } ;

HELP: line-strip-mode
{ $class-description "This " { $link primitive-mode } " value instructs " { $link render } " to assemble a connected strip of lines from each consecutive pair of indexed vertex array elements." } ;

HELP: mat2-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a 2x2 square float matrix uniform parameter." } ;

HELP: mat2x3-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a 2-column, 3-row float matrix uniform parameter." } ;

HELP: mat2x4-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a 2-column, 4-row float matrix uniform parameter." } ;

HELP: mat3x2-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a 3-column, 2-row float matrix uniform parameter." } ;

HELP: mat3-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a 3x3 square float matrix uniform parameter." } ;

HELP: mat3x4-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a 3-column, 4-row float matrix uniform parameter." } ;

HELP: mat4x2-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a 4-column, 2-row float matrix uniform parameter." } ;

HELP: mat4x3-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a 4-column, 3-row float matrix uniform parameter." } ;

HELP: mat4-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a 4x4 square float matrix uniform parameter." } ;

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
{ $class-description "The " { $snippet "primitive-mode" } " slot of a " { $link render-set } " tells " { $link render } " what kind of primitives to generate and how to assemble them from the selected elements of the active " { $link vertex-array } "." }
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
{ "The " { $snippet "framebuffer" } " slot determines the target for the rendering output. Either the " { $link system-framebuffer } " or a user-created " { $link framebuffer } " object can be specified. " { $link f } " can also be specified to disable rasterization and only run the vertex transformation rendering stage." }
{ "The " { $snippet "output-attachments" } " slot specifies which of the framebuffer's " { $link color-attachment-ref } "s to write the fragment shader's color output to. If the shader uses " { $snippet "gl_FragColor" } " or " { $snippet "gl_FragData[n]" } " to write its output, then " { $snippet "output-attachments" } " should be an array of " { $link color-attachment-ref } "s, and the output to color attachment binding is determined positionally. If the shader uses named output values, then " { $snippet "output-attachments" } " should be a list of string/" { $link color-attachment-ref } " pairs, mapping output names to color attachments." }
{ "The " { $snippet "transform-feedback-output" } " slot specifies a target for transform feedback output from the vertex shader: either an entire " { $link buffer } ", a " { $link buffer-range } " subset, or a " { $link buffer-ptr } " offset into the buffer. If " { $link f } ", no transform feedback output is collected. The shader program associated with " { $snippet "vertex-array" } " must have a transform feedback output format specified." }
} }
{ $notes "User-created framebuffers require OpenGL 3.0 or one of the " { $snippet "GL_EXT_framebuffer_object" } " or " { $snippet "GL_ARB_framebuffer_object" } " extensions. Disabling rasterization requires OpenGL 3.0 or the " { $snippet "GL_EXT_transform_feedback" } " extension. Named output-attachment values are available in GLSL 1.30 or later, and GLSL 1.20 and earlier using the " { $snippet "GL_EXT_gpu_shader4" } " extension. Transform feedback requires OpenGL 3.0 or one of the " { $snippet "GL_EXT_transform_feedback" } " or " { $snippet "GL_ARB_transform_feedback" } " extensions." } ;

HELP: bind-uniforms
{ $values { "program-instance" program-instance } { "uniforms" uniform-tuple } }
{ $description "Binds the uniform shader parameters for " { $snippet "program-instance" } " using values from the given uniform tuple." }
{ $notes "The " { $link render } " word uses this word. Calling this word directly is only necessary if uniform parameters need to be bound independently of a " { $snippet "render" } " operation." } ;

{ render render-set } related-words

HELP: texture-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a texture uniform parameter." } ;

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
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to an unsigned integer uniform parameter." } ;

HELP: uniform
{ $class-description "Values of this tuple type are passed to " { $link define-uniform-tuple } " to define a new " { $link uniform-tuple } " type." } ;

HELP: uniform-tuple
{ $class-description "The base class for tuple types defined with " { $link POSTPONE: UNIFORM-TUPLE: } ". A uniform tuple is used as part of a " { $link render-set } " to supply values for a shader program's uniform parameters. See the " { $link POSTPONE: UNIFORM-TUPLE: } " documentation for details on how uniform tuples are defined and used." } ;

HELP: uniform-type
{ $class-description { $snippet "uniform-type" } " values are used as part of a " { $link POSTPONE: UNIFORM-TUPLE: } " definition to define the types of uniform slots." } ;

HELP: ushort-indexes
{ $class-description "This " { $link index-type } " indicates that an " { $link index-elements } " or " { $link multi-index-elements } " buffer consists of two-byte unsigned short indexes." } ;

{ index-type ubyte-indexes ushort-indexes uint-indexes } related-words

HELP: uvec2-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a two-component unsigned integer vector uniform parameter." } ;

HELP: uvec3-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a three-component unsigned integer vector uniform parameter." } ;

HELP: uvec4-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a four-component unsigned integer vector uniform parameter." } ;

HELP: vec2-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a two-component float vector uniform parameter." } ;

HELP: vec3-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a three-component float vector uniform parameter." } ;

HELP: vec4-uniform
{ $class-description "This " { $link uniform-type } " indicates that a slot of a " { $link uniform-tuple } " corresponds to a four-component float vector uniform parameter." } ;

HELP: vertex-indexes
{ $class-description "This class is a union of the following tuple types, any of which can be used as the " { $snippet "indexes" } " slot of a " { $link render-set } " to select elements from a " { $link vertex-array } " for rendering."
{ $list
{ "An " { $link index-range } " value submits a sequential slice of a vertex array for rendering." }
{ "An " { $link index-elements } " value submits vertex array elements in an order specified by an array of indexes." }
{ "A " { $link multi-index-range } " value submits multiple sequential slices of a vertex array." }
{ "A " { $link multi-index-elements } " value submits multiple separate lists of indexed vertex array elements." }
{ "Specialized arrays of " { $link c:uchar } ", " { $link c:ushort } ", or " { $link c:uint } " elements may also be used directly as arrays of indexes." }
} } ;

ARTICLE: "gpu.render" "Rendering"
"The " { $vocab-link "gpu.render" } " vocabulary contains words for organizing and submitting data to the GPU for rendering."
{ $subsections
    render
    render-set
}
{ $link uniform-tuple } "s provide Factor types for containing and submitting shader uniform parameters:"
{ $subsections POSTPONE: UNIFORM-TUPLE: }
;

ABOUT: "gpu.render"
