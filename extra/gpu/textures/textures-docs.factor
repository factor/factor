! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien byte-arrays classes gpu.buffers help.markup help.syntax
images kernel math ;
IN: gpu.textures

HELP: +X
{ $class-description "This " { $link cube-map-axis } " references the positive X face of a " { $link texture-cube-map } "." } ;

HELP: +Y
{ $class-description "This " { $link cube-map-axis } " references the positive Y face of a " { $link texture-cube-map } "." } ;

HELP: +Z
{ $class-description "This " { $link cube-map-axis } " references the positive Z face of a " { $link texture-cube-map } "." } ;

HELP: -X
{ $class-description "This " { $link cube-map-axis } " references the negative X face of a " { $link texture-cube-map } "." } ;

HELP: -Y
{ $class-description "This " { $link cube-map-axis } " references the negative Y face of a " { $link texture-cube-map } "." } ;

HELP: -Z
{ $class-description "This " { $link cube-map-axis } " references the negative Z face of a " { $link texture-cube-map } "." } ;

HELP: <cube-map-face>
{ $values
    { "texture" texture-cube-map } { "axis" cube-map-axis }
    { "cube-map-face" cube-map-face }
}
{ $description "Constructs a new " { $link cube-map-face } " reference." } ;

HELP: <texture-1d-array>
{ $values
    { "component-order" component-order } { "component-type" component-type } { "parameters" texture-parameters }
    { "texture" texture-1d-array }
}
{ $description "Creates a new one-dimensional array texture. The new texture starts out with no image data; " { $link allocate-texture } " or " { $link allocate-texture-image } " must be used to allocate memory for the required levels of detail of the texture." }
{ $notes "Array textures require OpenGL 3.0 or the " { $snippet "GL_EXT_texture_array" } " extension." } ;

HELP: <texture-1d>
{ $values
    { "component-order" component-order } { "component-type" component-type } { "parameters" texture-parameters }
    { "texture" texture-1d }
}
{ $description "Creates a new one-dimensional texture. The new texture starts out with no image data; " { $link allocate-texture } " or " { $link allocate-texture-image } " must be used to allocate memory for the required levels of detail of the texture." } ;

HELP: <texture-2d-array>
{ $values
    { "component-order" component-order } { "component-type" component-type } { "parameters" texture-parameters }
    { "texture" texture-2d-array }
}
{ $description "Creates a new two-dimensional array texture. The new texture starts out with no image data; " { $link allocate-texture } " or " { $link allocate-texture-image } " must be used to allocate memory for the required levels of detail of the texture." }
{ $notes "Array textures require OpenGL 3.0 or the " { $snippet "GL_EXT_texture_array" } " extension." } ;

HELP: <texture-2d>
{ $values
    { "component-order" component-order } { "component-type" component-type } { "parameters" texture-parameters }
    { "texture" texture-2d }
}
{ $description "Creates a new two-dimensional texture. The new texture starts out with no image data; " { $link allocate-texture } " or " { $link allocate-texture-image } " must be used to allocate memory for the required levels of detail of the texture." } ;

HELP: <texture-3d>
{ $values
    { "component-order" component-order } { "component-type" component-type } { "parameters" texture-parameters }
    { "texture" texture-3d }
}
{ $description "Creates a new three-dimensional texture. The new texture starts out with no image data; " { $link allocate-texture } " or " { $link allocate-texture-image } " must be used to allocate memory for the required levels of detail of the texture." } ;

HELP: <texture-cube-map>
{ $values
    { "component-order" component-order } { "component-type" component-type } { "parameters" texture-parameters }
    { "texture" texture-cube-map }
}
{ $description "Creates a new cube map texture. The new texture starts out with no image data; " { $link allocate-texture } " or " { $link allocate-texture-image } " must be used to allocate memory for the required levels of detail of each " { $link cube-map-face } " of the new texture." } ;

HELP: <texture-data>
{ $values
    { "ptr" gpu-data-ptr } { "component-order" component-order } { "component-type" component-type }
    { "texture-data" texture-data }
}
{ $description "Constructs a new " { $link texture-data } " tuple." }
{ $notes "Using a " { $link buffer-ptr } " as the " { $snippet "ptr" } " of a " { $snippet "texture-data" } " object requires OpenGL 2.1 or later or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

HELP: <texture-rectangle>
{ $values
    { "component-order" component-order } { "component-type" component-type } { "parameters" texture-parameters }
    { "texture" texture-rectangle }
}
{ $description "Creates a new rectangle texture. The new texture starts out with no image data; " { $link allocate-texture } " or " { $link allocate-texture-image } " must be used to allocate memory for the texture." }
{ $notes "Rectangle textures require OpenGL 3.1 or the " { $snippet "GL_ARB_texture_rectangle" } " extension." } ;

HELP: allocate-compressed-texture
{ $values
    { "tdt" texture-data-target } { "level" integer } { "dim" "an " { $link integer } " or sequence of " { $link integer } "s" } { "compressed-data" compressed-texture-data }
}
{ $description "Allocates a new block of GPU memory for the " { $snippet "level" } "th level of detail of a " { $link texture-data-target } ". The new data is initialized with compressed texture data from the given " { $link compressed-texture-data } " object." }
{ $notes "Using a " { $link buffer-ptr } " as the " { $snippet "ptr" } " of a " { $snippet "compressed-texture-data" } " object requires OpenGL 2.1 or later or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

HELP: allocate-texture
{ $values
    { "tdt" texture-data-target } { "level" integer } { "dim" "an " { $link integer } " or sequence of " { $link integer } "s" } { "data" { $maybe texture-data } }
}
{ $description "Allocates a new block of GPU memory for the " { $snippet "level" } "th level of detail of a " { $link texture-data-target } ". If " { $snippet "data" } " is not " { $link f } ", the new data is initialized from the given " { $link texture-data } " object; otherwise, the new image is left uninitialized." }
{ $notes "Using a " { $link buffer-ptr } " as the " { $snippet "ptr" } " of a " { $snippet "texture-data" } " object requires OpenGL 2.1 or later or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

HELP: allocate-texture-image
{ $values
    { "tdt" texture-data-target } { "level" integer } { "image" image }
}
{ $description "Allocates a new block of GPU memory for the " { $snippet "level" } "th level of detail of a " { $link texture-data-target } " and initializes it with the contents of an " { $link image } "." } ;

{ allocate-compressed-texture allocate-texture allocate-texture-image } related-words

HELP: clamp-texcoord-to-border
{ $class-description "This " { $link texture-wrap } " value clamps texture coordinates to a texture's border." } ;

HELP: clamp-texcoord-to-edge
{ $class-description "This " { $link texture-wrap } " value clamps texture coordinates to a texture image's edge." } ;

HELP: cube-map-axis
{ $class-description "Objects of this class are stored in the " { $snippet "axis" } " slot of a " { $link cube-map-face } " to choose the referenced face: " { $link +X } ", " { $link +Y } ", " { $link +Z } ", " { $link -X } ", " { $link -Y } ", or " { $link -Z } "."
} ;

HELP: cube-map-face
{ $class-description "A " { $snippet "cube-map-face" } " tuple references a single face of a " { $link texture-cube-map } " object for use with " { $link allocate-texture } ", " { $link update-texture } ", or " { $link read-texture } "."
{ $list
{ "The " { $snippet "texture" } " slot indicates the cube map texture being referenced." }
{ "The " { $snippet "axis" } " slot indicates which face to reference: " { $link +X } ", " { $link +Y } ", " { $link +Z } ", " { $link -X } ", " { $link -Y } ", or " { $link -Z } "." }
} } ;

HELP: filter-linear
{ $class-description "This " { $link texture-filter } " value selects linear filtering between pixel samples." } ;

HELP: filter-nearest
{ $class-description "This " { $link texture-filter } " value selects nearest-neighbor sampling." } ;

HELP: generate-mipmaps
{ $values
    { "texture" texture }
}
{ $description "Replaces the image data for all levels of detail of " { $snippet "texture" } " below the highest level with images automatically generated from the highest level of detail image." }
{ $notes "This word requires OpenGL 3.0 or one of the " { $snippet "GL_EXT_framebuffer_object" } " or " { $snippet "GL_ARB_framebuffer_object" } " extensions." } ;

HELP: image>texture-data
{ $values
    { "image" image }
    { "dim" "a sequence of " { $link integer } "s" } { "texture-data" texture-data }
}
{ $description "Constructs a " { $link texture-data } " tuple referencing the pixel data from an " { $link image } "." } ;

HELP: read-compressed-texture
{ $values
    { "tdt" texture-data-target } { "level" integer }
    { "byte-array" byte-array }
}
{ $description "Reads the entire compressed image for the " { $snippet "level" } "th level of detail of a texture into a new " { $link byte-array } ". The format of the data in the byte array is determined by the " { $link compressed-texture-format } " of the data originally allocated by " { $link allocate-compressed-texture } " for the texture." } ;

HELP: read-compressed-texture-to
{ $values
    { "tdt" texture-data-target } { "level" integer }
    { "gpu-data-ptr" byte-array }
}
{ $description "Reads the entire compressed image for the " { $snippet "level" } "th level of detail of a texture into the CPU or GPU memory referenced by " { $link gpu-data-ptr } ". The format of the written data is determined by the " { $link compressed-texture-format } " of the data originally allocated by " { $link allocate-compressed-texture } " for the texture." }
{ $notes "Reading texture data into a GPU " { $snippet "buffer-ptr" } " requires OpenGL 2.1 or later or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

HELP: read-texture
{ $values
    { "tdt" texture-data-target } { "level" integer }
    { "byte-array" byte-array }
}
{ $description "Reads the entire image for the " { $snippet "level" } "th level of detail of a texture into a new " { $link byte-array } ". The format of the data in the byte array is determined by the " { $link component-order } " and " { $link component-type } " of the texture." } ;

HELP: read-texture-image
{ $values
    { "tdt" texture-data-target } { "level" integer }
    { "image" image }
}
{ $description "Reads the entire image for the " { $snippet "level" } "th level of detail of a texture into a new " { $link image } ". The format of the image is determined by the " { $link component-order } " and " { $link component-type } " of the texture." } ;

HELP: read-texture-to
{ $values
    { "tdt" texture-data-target } { "level" integer } { "gpu-data-ptr" gpu-data-ptr }
}
{ $description "Reads the entire image for the " { $snippet "level" } "th level of detail of a texture into the CPU or GPU memory referenced by " { $link gpu-data-ptr } ". The format of the written data is determined by the " { $link component-order } " and " { $link component-type } " of the texture." }
{ $notes "Reading texture data into a GPU " { $snippet "buffer-ptr" } " requires OpenGL 2.1 or later or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

{ read-compressed-texture read-compressed-texture-to read-texture read-texture-image read-texture-to } related-words

HELP: repeat-texcoord
{ $class-description "This " { $link texture-wrap } " value causes the texture image to be repeated through texture coordinate space." } ;

HELP: repeat-texcoord-mirrored
{ $class-description "This " { $link texture-wrap } " value causes the texture image to be repeated through texture coordinate space, mirroring the image on every repetition." } ;

HELP: set-texture-parameters
{ $values
    { "texture" texture } { "parameters" texture-parameters }
}
{ $description "Changes the " { $link texture-parameters } " of a " { $link texture } "." } ;

HELP: texture
{ $class-description "Textures are typed, multidimensional arrays of GPU memory used for storing image data, lookup tables, and other kinds of multidimensional data for use with shader programs. They come in different types depending on dimensionality and intended usage:"
{ $subsections
    texture-1d
    texture-2d
    texture-3d
    texture-cube-map
    texture-rectangle
    texture-1d-array
    texture-2d-array
}
"Textures are constructed using the corresponding " { $snippet "<constructor word>" } " for their type. The constructor sets the texture's " { $link component-order } ", " { $link component-type } ", and " { $link texture-parameters } ". Once created, memory for a texture can be allocated with " { $link allocate-texture } ", updated with " { $link update-texture } ", or retrieved with " { $link read-texture } "." } ;

HELP: texture-1d
{ $class-description "A one-dimensional " { $link texture } " object. Textures of this type are dimensioned by single integers in calls to " { $link allocate-texture } " and " { $link update-texture } "." } ;

{ texture-1d <texture-1d> } related-words

HELP: texture-1d-array
{ $class-description "A one-dimensional array " { $link texture } " object. Textures of this type are dimensioned by pairs of integers in calls to " { $link allocate-texture } " and " { $link update-texture } ". A 1D array texture is distinct from a 2D texture (" { $link texture-2d } ") in that each row of the texture is independent; texture values are not filtered between rows, and lower levels of detail retain the same height, only losing detail in the width direction." }
{ $notes "Array textures require OpenGL 3.0 or the " { $snippet "GL_EXT_texture_array" } " extension." } ;

{ texture-1d-array <texture-1d-array> } related-words

HELP: texture-2d
{ $class-description "A two-dimensional " { $link texture } " object. Textures of this type are dimensioned by pairs of integers in calls to " { $link allocate-texture } " and " { $link update-texture } "." } ;

{ texture-2d <texture-2d> } related-words

HELP: texture-2d-array
{ $class-description "A two-dimensional array " { $link texture } " object. Textures of this type are dimensioned by sequences of three integers in calls to " { $link allocate-texture } " and " { $link update-texture } ". A 2D array texture is distinct from a 3D texture (" { $link texture-3d } ") in that each plane of the texture is independent; texture values are not filtered between planes, and lower levels of detail retain the same depth, only losing detail in the width and height directions." }
{ $notes "Array textures require OpenGL 3.0 or the " { $snippet "GL_EXT_texture_array" } " extension." } ;

{ texture-2d-array <texture-2d-array> } related-words

HELP: texture-3d
{ $class-description "A three-dimensional " { $link texture } " object. Textures of this type are dimensioned by sequences of three integers in calls to " { $link allocate-texture } " and " { $link update-texture } "." } ;

{ texture-3d <texture-3d> } related-words

HELP: texture-wrap
{ $class-description "Values of this class are used in the " { $snippet "wrap" } " slot of a set of " { $link texture-parameters } " to specify how texture coordinates outside the 0.0 to 1.0 range should be mapped onto the texture image."
{ $list
{ { $link clamp-texcoord-to-edge } " clamps coordinates to the edge of the texture image." }
{ { $link clamp-texcoord-to-border } " clamps coordinates to the border of the texture image." }
{ { $link repeat-texcoord } " repeats the texture image." }
{ { $link repeat-texcoord-mirrored } " repeats the texture image, mirroring it with each repetition." }
} } ;

HELP: texture-cube-map
{ $class-description "A cube map " { $link texture } " object. Textures of this type comprise six two-dimensional image sets, which are independently referenced by " { $link cube-map-face } " objects and dimensioned by pairs of integers in calls to " { $link allocate-texture } " and " { $link update-texture } ". When a cube map is sampled in shader code, the three-dimensional texture coordinates are projected onto the unit cube, and the cube face that is hit by the vector is used to select a face of the cube map texture." } ;

{ texture-cube-map <texture-cube-map> } related-words

HELP: texture-data
{ $class-description { $snippet "texture-data" } " tuples are used to feed image data to " { $link allocate-texture } " and " { $link update-texture } "."
{ $list
{ "The " { $snippet "ptr" } " slot references either CPU memory (as a " { $link byte-array } " or " { $link alien } ") or a GPU " { $link buffer-ptr } " that contains the image data." }
{ "The " { $snippet "component-order" } " and " { $snippet "component-type" } " slots determine the " { $link component-order } " and " { $link component-type } " of the referenced data." }
} }
{ $notes "Using a " { $link buffer-ptr } " as the " { $snippet "ptr" } " of a " { $snippet "texture-data" } " object requires OpenGL 2.1 or later or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

{ texture-data <texture-data> } related-words

HELP: texture-data-size
{ $values
    { "tdt" texture-data-target } { "level" integer }
    { "size" integer }
}
{ $description "Returns the size in bytes of the image data allocated for the " { $snippet "level" } "th level of detail of a " { $link texture-data-target } "." } ;

HELP: texture-data-target
{ $class-description "Most " { $link texture } " types can have image data assigned to themselves directly by " { $link allocate-texture } " and " { $link update-texture } "; however, " { $link texture-cube-map } " objects comprise six independent image sets, each of which must be referenced separately with a " { $link cube-map-face } " tuple when allocating or updating images. The " { $snippet "texture-data-target" } " class is a union of all " { $link texture } " classes (except " { $snippet "texture-cube-map" } ") and the " { $snippet "cube-map-face" } " class." } ;

HELP: texture-dim
{ $values
    { "tdt" texture-data-target } { "level" integer }
    { "dim" "an " { $link integer } " or sequence of integers" }
}
{ $description "Returns the dimensions of the memory allocated for the " { $snippet "level" } "th level of detail of the given " { $link texture-data-target } "." } ;

HELP: compressed-texture-data-size
{ $values
    { "tdt" texture-data-target } { "level" integer }
    { "size" integer }
}
{ $description "Returns the size in bytes of the memory allocated for the compressed texture data making up the " { $snippet "level" } "th level of detail of the given " { $link texture-data-target } "." } ;

HELP: texture-filter
{ $class-description { $snippet "texture-filter" } " values are used in a " { $link texture-parameters } " tuple to determine how a texture should be sampled between pixels or between levels of detail. " { $link filter-linear } " selects linear filtering, while " { $link filter-nearest } " selects nearest-neighbor sampling." } ;

HELP: texture-parameters
{ $class-description "A " { $snippet "texture-parameters" } " tuple is supplied when constructing a " { $link texture } " to control the wrapping, filtering, and level-of-detail handling of the texture. These tuples have the following slots:"
{ $list
{ "The " { $snippet "wrap" } " slot determines how texture coordinates outside the 0.0 to 1.0 range are mapped to the texture image. The slot either contains a single " { $link texture-wrap } " value, which will apply to all three axes, or a sequence of up to three values, which will apply to the S, T, and R axes, respectively." }
{ "The " { $snippet "min-filter" } " and " { $snippet "min-mipmap-filter" } " determine how the texture image is filtered when sampled below its highest level of detail, the former filtering between pixels within a level of detail and the latter filtering between levels of detail. A setting of " { $link filter-linear } " uses linear, bilinear, or trilinear filtering among the sampled pixels, while a setting of " { $link filter-nearest } " uses nearest-neighbor sampling. The " { $snippet "min-mipmap-filter" } " slot may additionally be set to " { $link f } " to disable mipmapping and only sample the highest level of detail." }
{ "The " { $snippet "mag-filter" } " analogously determines how the texture image is filtered when sampled above its highest level of detail." }
{ "The " { $snippet "min-lod" } " and " { $snippet "max-lod" } " slots contain integer values that will clamp the range of levels of detail that will be sampled from the texture." }
{ "The " { $snippet "lod-bias" } " slot contains an integer value that will offset the levels of detail that would normally be sampled from the texture." }
{ "The " { $snippet "base-level" } " slot contains an integer value that identifies the highest level of detail for the image, typically zero." }
{ "The " { $snippet "max-level" } " slot contains an integer value that identifies the lowest level of detail for the image. This value will automatically be clamped to the maximum of the base-2 logarithms of the dimensions of the highest level of detail image." }
} } ;

{ texture-parameters set-texture-parameters } related-words

HELP: texture-rectangle
{ $class-description "A two-dimensional rectangle " { $link texture } " object. Textures of this type are dimensioned by pairs of integers in calls to " { $link allocate-texture } " and " { $link update-texture } ". Rectangle textures differ from normal 2D textures (" { $link texture-2d } ") in that texture coordinates map directly to pixel coordinates when they are sampled from shader code, rather than being normalized into the 0.0 to 1.0 range as with other texture types. Also, rectangle textures do not support mipmapping or texture wrapping." }
{ $notes "Rectangle textures require OpenGL 3.1 or the " { $snippet "GL_ARB_texture_rectangle" } " extension." } ;

HELP: update-compressed-texture
{ $values
    { "tdt" texture-data-target } { "level" integer } { "loc" "an " { $link integer } " or sequence of integers" } { "dim" "an " { $link integer } " or sequence of integers" } { "compressed-data" texture-data }
}
{ $description "Updates the linear, rectangular, or cubic subregion of a compressed " { $link texture-data-target } " bounded by " { $snippet "loc" } " and " { $snippet "dim" } " with the data referenced by the given " { $link compressed-texture-data } " tuple. The given level of detail of the texture must have been previously allocated for compressed data with " { $link allocate-compressed-texture } "." }
{ $notes "Using a " { $link buffer-ptr } " as the " { $snippet "ptr" } " of a " { $snippet "compressed-texture-data" } " object requires OpenGL 2.1 or later or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

HELP: update-texture
{ $values
    { "tdt" texture-data-target } { "level" integer } { "loc" "an " { $link integer } " or sequence of integers" } { "dim" "an " { $link integer } " or sequence of integers" } { "data" texture-data }
}
{ $description "Updates the linear, rectangular, or cubic subregion of a " { $link texture-data-target } " bounded by " { $snippet "loc" } " and " { $snippet "dim" } " with new image data from a " { $link texture-data } " tuple." }
{ $notes "Using a " { $link buffer-ptr } " as the " { $snippet "ptr" } " of a " { $snippet "texture-data" } " object requires OpenGL 2.1 or later or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

HELP: update-texture-image
{ $values
    { "tdt" texture-data-target } { "level" integer } { "loc" "an " { $link integer } " or sequence of integers" } { "image" image }
}
{ $description "Updates the linear, rectangular, or cubic subregion of a " { $link texture-data-target } " bounded by " { $snippet "loc" } " and " { $snippet "dim" } " with new image data from an " { $link image } " object." } ;

{ update-compressed-texture update-texture update-texture-image } related-words

HELP: compressed-texture-format
{ $class-description { $snippet "compressed-texture-format" } " values are used as part of a " { $link compressed-texture-data } " tuple to specify the binary format of texture data being given to " { $link allocate-compressed-texture } " or " { $link update-compressed-texture } ". The following compressed formats are available:"
{ $list
{ { $link DXT1-RGB } }
{ { $link DXT1-RGBA } }
{ { $link DXT3 } }
{ { $link DXT5 } }
{ { $link LATC1 } }
{ { $link LATC1-SIGNED } }
{ { $link LATC2 } }
{ { $link LATC2-SIGNED } }
{ { $link RGTC1 } }
{ { $link RGTC1-SIGNED } }
{ { $link RGTC2 } }
{ { $link RGTC2-SIGNED } }
} }
{ $notes "The " { $snippet "DXT1" } " formats require either the " { $snippet "GL_EXT_texture_compression_s3tc" } " or " { $snippet "GL_EXT_texture_compression_dxt1" } " extension. The other " { $snippet "DXT" } " formats require the " { $snippet "GL_EXT_texture_compression_s3tc" } " extension. The " { $snippet "LATC" } " formats require the " { $snippet "GL_EXT_texture_compression_latc" } " extension. The " { $snippet "RGTC" } " formats require OpenGL 3.0 or later or the " { $snippet "GL_EXT_texture_compression_rgtc" } " extension." } ;

HELP: compressed-texture-data
{ $class-description { $snippet "compressed-texture-data" } " tuples are used to feed compressed texture data to " { $link allocate-compressed-texture } " and " { $link update-compressed-texture } "."
{ $list
{ "The " { $snippet "ptr" } " slot references either CPU memory (as a " { $link byte-array } " or " { $link alien } ") or a GPU " { $link buffer-ptr } " that contains the image data." }
{ "The " { $snippet "format" } " slot determines the " { $link compressed-texture-format } " of the referenced data." }
{ "The " { $snippet "length" } " slot determines the size in bytes of the referenced data." }
} }
{ $notes "Using a " { $link buffer-ptr } " as the " { $snippet "ptr" } " of a " { $snippet "texture-data" } " object requires OpenGL 2.1 or later or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

{ compressed-texture-data <compressed-texture-data> } related-words

ARTICLE: "gpu.textures" "Texture objects"
"The " { $vocab-link "gpu.textures" } " vocabulary provides words for creating, allocating, updating, and reading GPU texture objects."
{ $subsections
    texture
    texture-data
    allocate-texture
    update-texture
    texture-dim
    read-texture
    read-texture-to
}
"Words are also provided to use " { $link image } " objects from the " { $vocab-link "images" } " library as data sources and destinations for texture data:"
{ $subsections
    allocate-texture-image
    update-texture-image
    read-texture-image
}
"Compressed texture data can also be supplied and read:"
{ $subsections
    compressed-texture-format
    compressed-texture-data
    allocate-compressed-texture
    update-compressed-texture
    compressed-texture-data-size
    read-compressed-texture
    read-compressed-texture-to
} ;

ABOUT: "gpu.textures"
