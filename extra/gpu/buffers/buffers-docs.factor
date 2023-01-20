! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien byte-arrays destructors help.markup help.syntax
math ;
IN: gpu.buffers

HELP: <buffer-ptr>
{ $values
    { "buffer" buffer } { "offset" integer }
    { "buffer-ptr" buffer-ptr }
}
{ $description "Constructs a " { $link buffer-ptr } " tuple." } ;

HELP: <buffer-range>
{ $values
    { "buffer" buffer } { "offset" integer } { "size" integer }
    { "buffer-range" buffer-range }
}
{ $description "Constructs a " { $link buffer-range } " tuple." } ;

HELP: <buffer>
{ $values
    { "upload" buffer-upload-pattern }
    { "usage" buffer-usage-pattern }
    { "kind" buffer-kind }
    { "size" integer }
    { "initial-data" { $maybe c-ptr } }
    { "buffer" buffer }
}
{ $description "Allocates a new " { $link buffer } " object of " { $snippet "size" } " bytes. If " { $snippet "initial-data" } " is not " { $link f } ", " { $snippet "size" } " bytes are copied from " { $snippet "initial-data" } " into the buffer to initialize it; otherwise, the buffer content is left uninitialized. " { $snippet "upload" } ", " { $snippet "usage" } ", and " { $snippet "kind" } " provide hints to the implementation about the expected usage pattern of the buffer as documented in the " { $link buffer } " class documentation." } ;

HELP: allocate-buffer
{ $values
    { "buffer" buffer } { "size" integer } { "initial-data" { $maybe c-ptr } }
}
{ $description "Discards any memory currently held by " { $snippet "buffer" } " and reallocates a new memory block of " { $snippet "size" } " bytes for it. If " { $snippet "initial-data" } " is not " { $link f } ", " { $snippet "size" } " bytes are copied from " { $snippet "initial-data" } " into the buffer to initialize it; otherwise, the buffer content is left uninitialized." } ;

HELP: allocate-byte-array
{ $values
    { "buffer" buffer } { "byte-array" byte-array }
}
{ $description "Discards any memory currently held by " { $snippet "buffer" } " and reallocates a new memory block large enough to store " { $snippet "byte-array" } ". The contents of " { $snippet "byte-array" } " are then copied into the buffer." } ;

HELP: buffer
{ $class-description "Objects of this class represent GPU-accessible memory buffers. Buffer objects can be used to store vertex data and to update or read pixel data from textures and framebuffers without CPU involvement. The data inside buffer objects may be resident in main memory or different parts of GPU memory; the graphics driver will choose a location for a buffer based on usage hints specified when the buffer object is constructed with " { $link <buffer> } " or " { $link byte-array>buffer } ":"
{ $list
{ { $snippet "upload-pattern" } " is one of the " { $link buffer-upload-pattern } " values and indicates how frequently the data in the buffer will be updated with new data from CPU memory." }
{ { $snippet "usage-pattern" } " is one of the " { $link buffer-usage-pattern } " values and indicates how frequently the data in the buffer will be updated with new data from CPU memory." }
{ { $snippet "kind" } " is one of the " { $link buffer-kind } " values and indicates the primary purpose of the buffer." }
}
"These settings are only performance hints and do not restrict the usage of the buffer in any way. For example, a buffer constructed as a " { $link vertex-buffer } " with " { $link static-upload } " can still receive pixel data as though it were a " { $link pixel-pack-buffer } ", and can still be updated with " { $link copy-buffer } " or " { $link update-buffer } ". However, performance may be worse when actual usage conflicts with declared usage."
} ;

HELP: buffer-access-mode
{ $class-description "A " { $snippet "buffer-access-mode" } " value is passed to " { $link with-mapped-buffer } " to control access to the mapped address space." }
{ $list
{ { $link read-access } " permits the mapped address space only to be read from." }
{ { $link write-access } " permits the mapped address space only to be written to." }
{ { $link read-write-access } " permits full access to the mapped address space." }
} ;

HELP: buffer-kind
{ $class-description { $snippet "buffer-kind" } " values tell the graphics driver what the primary application of a " { $link buffer } " object will be. Note that any buffer can be used for any purpose; however, performance may be improved if a buffer object is constructed as the same kind as its primary use case."
{ $list
{ "A " { $link vertex-buffer } " is used to store vertex attribute data to be rendered as part of a vertex array." }
{ "An " { $link index-buffer } " is used to store indexes into a vertex array." }
{ "A " { $link pixel-unpack-buffer } " is used as a source for updating texture image data." }
{ "A " { $link pixel-pack-buffer } " is used as a destination for reading texture or framebuffer image data." }
{ "A " { $link transform-feedback-buffer } " is used as a destination for transform feedback output from a vertex shader." }
} }
{ $notes "The " { $snippet "pixel-unpack-buffer" } " and " { $snippet "pixel-pack-buffer" } " kinds require OpenGL 2.1 or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

HELP: buffer-ptr
{ $class-description "A " { $snippet "buffer-ptr" } " references a memory location inside a " { $link buffer } " object. " { $snippet "buffer-ptr" } "s are tuples with the following slots:"
{ $list
{ { $snippet "buffer" } " is the " { $link buffer } " object being referenced." }
{ { $snippet "offset" } " is an integer offset from the beginning of the buffer." }
} } ;

HELP: buffer-ptr>range
{ $values
    { "buffer-ptr" buffer-ptr }
    { "buffer-range" buffer-range }
}
{ $description "Converts a " { $link buffer-ptr } " into a " { $link buffer-range } " spanning from the " { $snippet "offset" } " referenced by the " { $snippet "buffer-ptr" } " to the end of the underlying " { $link buffer } "." } ;

HELP: buffer-range
{ $class-description "A " { $snippet "buffer-range" } " references a subset of a " { $link buffer } " object's memory. " { $snippet "buffer-range" } "s are tuples with the following slots:"
{ $list
{ { $snippet "buffer" } " is the " { $link buffer } " object being referenced." }
{ { $snippet "offset" } " is an integer offset from the beginning of the buffer to the beginning of the referenced range." }
{ { $snippet "size" } " is the integer length from the beginning offset to the end of the referenced range." }
} } ;

{ buffer-ptr buffer-range } related-words

HELP: buffer-size
{ $values
    { "buffer" buffer }
    { "size" integer }
}
{ $description "Returns the size in bytes of the memory currently allocated for a " { $link buffer } " object." } ;

HELP: buffer-upload-pattern
{ $class-description { $snippet "buffer-upload-pattern" } " values aid the graphics driver in optimizing access to " { $link buffer } " objects by declaring the frequency with which the buffer will be supplied new data."
{ $list
{ { $link stream-upload } " declares that the buffer data will only be used a few times before being deallocated by " { $link dispose } " or replaced by " { $link allocate-buffer } "." }
{ { $link static-upload } " declares that the buffer data will be provided once and accessed frequently without modification." }
{ { $link dynamic-upload } " declares that the buffer data will be frequently modified." }
}
"A " { $snippet "buffer-upload-pattern" } " is only a declaration and does not actually control access to the underlying buffer data." } ;

HELP: buffer-usage-pattern
{ $class-description { $snippet "buffer-usage-pattern" } " values aid the graphics driver in optimizing access to " { $link buffer } " objects by declaring the primary provider and consumer of data for the buffer."
{ $list
{ { $link draw-usage } " declares that the buffer will be supplied with data from CPU memory and read from by the GPU for vertex or texture image data." }
{ { $link read-usage } " declares that the buffer will be supplied with data from other GPU resources and read from primarily by the CPU." }
{ { $link copy-usage } " declares that the buffer will both receive and supply data primarily for other GPU resources." }
}
"A " { $snippet "buffer-usage-pattern" } " is only a declaration and does not actually control access to the underlying buffer data." } ;

{ buffer-kind buffer-upload-pattern buffer-usage-pattern } related-words

HELP: byte-array>buffer
{ $values
    { "byte-array" byte-array }
    { "upload" buffer-upload-pattern }
    { "usage" buffer-usage-pattern }
    { "kind" buffer-kind }
    { "buffer" buffer }
}
{ $description "Allocates a new " { $link buffer } " object with the size and contents of " { $snippet "byte-array" } ". " { $snippet "upload" } ", " { $snippet "usage" } ", and " { $snippet "kind" } " provide hints to the implementation about the expected usage pattern of the buffer as documented in the " { $link buffer } " class documentation." } ;

HELP: copy-buffer
{ $values
    { "to-buffer-ptr" buffer-ptr } { "from-buffer-ptr" buffer-ptr } { "size" integer }
}
{ $description "Instructs the GPU to asynchronously copy " { $snippet "size" } " bytes from " { $snippet "from-buffer-ptr" } " into " { $snippet "to-buffer-ptr" } "." }
{ $notes "This word requires that the graphics context support OpenGL 3.1 or the " { $snippet "GL_ARB_copy_buffer" } " extension." } ;

HELP: copy-usage
{ $class-description "This " { $link buffer-usage-pattern } " declares that a " { $link buffer } " object will be primarily read from and written to by other GPU resources." } ;

HELP: draw-usage
{ $class-description "This " { $link buffer-usage-pattern } " declares that a " { $link buffer } " object will be primarily read from by the GPU and written to by the CPU." } ;

HELP: dynamic-upload
{ $class-description "This " { $link buffer-upload-pattern } " declares that a " { $link buffer } " object's data store will be updated frequently during its lifetime." } ;

HELP: gpu-data-ptr
{ $class-description "This class is a union of the " { $link c-ptr } " and " { $link buffer-ptr } " classes. It represents a value that can be supplied either from CPU or GPU memory." } ;

HELP: grow-buffer
{ $values { "buffer" buffer } { "target-size" integer } }
{ $description "If the " { $link buffer-size } " of the given " { $link buffer } " is less than " { $snippet "target-size" } ", reallocates the buffer to a size large enough to accommodate " { $snippet "target-size" } " bytes. If the buffer is reallocated, the original contents are lost." } ;

HELP: index-buffer
{ $class-description "This " { $link buffer-kind } " declares that a " { $link buffer } "'s primary use will be to index vertex arrays." } ;

HELP: pixel-pack-buffer
{ $class-description "This " { $link buffer-kind } " declares that a " { $link buffer } "'s primary use will be as a destination for receiving image data from textures or framebuffers." }
{ $notes "This word requires OpenGL 2.1 or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

HELP: pixel-unpack-buffer
{ $class-description "This " { $link buffer-kind } " declares that a " { $link buffer } "'s primary use will be as a source for supplying image data to textures." }
{ $notes "This word requires OpenGL 2.1 or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

HELP: read-access
{ $class-description "This " { $link buffer-access-mode } " value requests read-only access when mapping a " { $link buffer } " object through " { $link with-mapped-buffer } "." } ;

HELP: read-buffer
{ $values
    { "buffer-ptr" buffer-ptr } { "size" integer }
    { "data" byte-array }
}
{ $description "Reads " { $snippet "size" } " bytes from " { $snippet "buffer" } " into a new " { $link byte-array } "." } ;

HELP: read-usage
{ $class-description "This " { $link buffer-usage-pattern } " declares that a " { $link buffer } " object will be primarily read from by the CPU and written to by the GPU." } ;

{ copy-usage draw-usage read-usage } related-words

HELP: read-write-access
{ $class-description "This " { $link buffer-access-mode } " value requests full access when mapping a buffer object through " { $link with-mapped-buffer } "." } ;

HELP: static-upload
{ $class-description "This " { $link buffer-upload-pattern } " declares that a " { $link buffer } " object's data store will be read from frequently and modified infrequently." } ;

HELP: stream-upload
{ $var-description "This " { $link buffer-upload-pattern } " declares that a " { $link buffer } " object's data store will be used only a handful of times before being deallocated or replaced." } ;

{ dynamic-upload static-upload stream-upload } related-words

HELP: transform-feedback-buffer
{ $class-description "This " { $link buffer-kind } " declares that a " { $link buffer } "'s primary use will be to receive transform feedback output from a render job." }
{ $notes "Transform feedback requires OpenGL 3.0 or one of the " { $snippet "GL_EXT_transform_feedback" } " or " { $snippet "GL_ARB_transform_feedback" } " extensions." } ;

HELP: update-buffer
{ $values
    { "buffer-ptr" buffer-ptr } { "size" integer } { "data" { $maybe c-ptr } }
}
{ $description "Replaces " { $snippet "size" } " bytes of data in the " { $link buffer } " referenced by " { $snippet "buffer-ptr" } " with data from " { $snippet "data" } "." } ;

HELP: vertex-buffer
{ $class-description "This " { $link buffer-kind } " declares that a " { $link buffer } "'s primary use will be to provide vertex attribute information to a vertex array." } ;

{ index-buffer pixel-pack-buffer pixel-unpack-buffer vertex-buffer transform-feedback-buffer } related-words

HELP: with-mapped-buffer
{ $values
    { "buffer" buffer } { "access" buffer-access-mode } { "quot" { $quotation ( ..a alien -- ..b ) } }
}
{ $description "Maps " { $snippet "buffer" } " into CPU address space with " { $snippet "access" } " for the dynamic extent of " { $snippet "quot" } ". " { $snippet "quot" } " is called with a pointer to the mapped memory on top of the stack." } ;

HELP: with-mapped-buffer-array
{ $values
    { "buffer" buffer } { "access" buffer-access-mode } { "c-type" "a C type" } { "quot" { $quotation ( ..a array -- ..b ) } }
}
{ $description "Maps " { $snippet "buffer" } " into CPU address space with " { $snippet "access" } " for the dynamic extent of " { $snippet "quot" } ". " { $snippet "quot" } " is called with the pointer to the mapped memory wrapped in a specialized array of " { $snippet "c-type" } "." }
{ $notes "The appropriate specialized array vocabulary must be loaded; otherwise, an error will be thrown. See the " { $vocab-link "specialized-arrays" } " vocabulary for details on the underlying sequence type constructed." } ;

{ allocate-buffer allocate-byte-array buffer-size update-buffer read-buffer copy-buffer with-mapped-buffer } related-words

HELP: write-access
{ $class-description "This " { $link buffer-access-mode } " value requests write-only access when mapping a buffer object through " { $link with-mapped-buffer } "." } ;

{ read-access read-write-access write-access } related-words

ARTICLE: "gpu.buffers" "Buffer objects"
"The " { $vocab-link "gpu.buffers" } " vocabulary provides words for creating, allocating, updating, and reading GPU data buffers."
{ $subsections
    buffer
    <buffer>
    byte-array>buffer
}
"Declaring buffer usage:"
{ $subsections
    buffer-kind
    buffer-upload-pattern
    buffer-usage-pattern
}
"Referencing buffer data:"
{ $subsections
    buffer-ptr
    buffer-range
}
"Manipulating buffer data:"
{ $subsections
    allocate-buffer
    allocate-byte-array
    grow-buffer
    update-buffer
    read-buffer
    copy-buffer
    with-mapped-buffer
    with-mapped-buffer-array
} ;

ABOUT: "gpu.buffers"
