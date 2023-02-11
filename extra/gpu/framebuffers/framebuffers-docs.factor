! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien byte-arrays gpu.buffers gpu.textures help.markup
help.syntax images kernel math math.rectangles sequences ;
IN: gpu.framebuffers

HELP: <color-attachment>
{ $values
    { "index" integer }
    { "color-attachment" color-attachment }
}
{ $description "Constructs an " { $link attachment-ref } " referencing the " { $snippet "index" } "th " { $snippet "color-attachment" } " of a framebuffer." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: <framebuffer-rect>
{ $values
    { "framebuffer" any-framebuffer } { "attachment" attachment-ref } { "rect" rect }
    { "framebuffer-rect" framebuffer-rect }
}
{ $description "Constructs a " { $link framebuffer-rect } " tuple that references a rectangular region of " { $snippet "attachment" } " in " { $snippet "framebuffer" } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

{ framebuffer-rect <framebuffer-rect> <full-framebuffer-rect> } related-words

HELP: <framebuffer>
{ $values
    { "color-attachments" sequence } { "depth-attachment" framebuffer-attachment } { "stencil-attachment" framebuffer-attachment } { "dim" { $maybe sequence } }
    { "framebuffer" framebuffer }
}
{ $description "Creates a new " { $link framebuffer } " object comprising the given set of " { $snippet "color-attachments" } ", " { $snippet "depth-attachment" } ", and " { $snippet "stencil-attachment" } ". If " { $snippet "dim" } " is not null, all of the attachments will be resized using " { $link resize-framebuffer } "; otherwise, each texture or renderbuffer being attached must have image memory allocated for the framebuffer creation to succeed." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions. If only the " { $snippet "GL_EXT_framebuffer_object" } " is available, all framebuffer attachments must have the same size, and all color attachments must have the same " { $link component-order } " and " { $link component-type } "." } ;

HELP: <full-framebuffer-rect>
{ $values
    { "framebuffer" any-framebuffer } { "attachment" attachment-ref }
    { "framebuffer-rect" framebuffer-rect }
}
{ $description "Constructs a " { $link framebuffer-rect } " tuple that spans the entire size of " { $snippet "attachment" } " in " { $snippet "framebuffer" } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: <renderbuffer>
{ $values
    { "component-order" component-order } { "component-type" component-type } { "samples" { $maybe integer } } { "dim" { $maybe sequence } }
    { "renderbuffer" renderbuffer }
}
{ $description "Creates a new " { $link renderbuffer } " object. If " { $snippet "samples" } " is not " { $link f } ", it specifies the multisampling level to use. If " { $snippet "dim" } " is not " { $link f } ", image memory of the given dimensions will be allocated for the renderbuffer; otherwise, memory will have to be allocated separately with " { $link allocate-renderbuffer } "." }
{ $notes "Renderbuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions. Multisampled renderbuffers require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_multisample" } " extensions." } ;

HELP: <system-attachment>
{ $values
    { "side" { $maybe framebuffer-attachment-side } } { "face" { $maybe framebuffer-attachment-face } }
    { "system-attachment" system-attachment }
}
{ $description "Constructs an " { $link attachment-ref } " referencing a " { $link system-framebuffer } " color attachment." } ;

HELP: <texture-1d-attachment>
{ $values
    { "texture" texture-data-target } { "level" integer }
    { "texture-1d-attachment" texture-1d-attachment }
}
{ $description "Constructs a " { $link framebuffer-attachment } " to the " { $snippet "level" } "th level of detail of one-dimensional texture " { $snippet "texture" } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: <texture-2d-attachment>
{ $values
    { "texture" texture-data-target } { "level" integer }
    { "texture-2d-attachment" texture-2d-attachment }
}
{ $description "Constructs a " { $link framebuffer-attachment } " to the " { $snippet "level" } "th level of detail of two-dimensional texture " { $snippet "texture" } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: <texture-3d-attachment>
{ $values
    { "texture" texture-data-target } { "z-offset" integer } { "level" integer }
    { "texture-3d-attachment" texture-3d-attachment }
}
{ $description "Constructs a " { $link framebuffer-attachment } " to the " { $snippet "z-offset" } "th plane of the " { $snippet "level" } "th level of detail of three-dimensional texture " { $snippet "texture" } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: <texture-layer-attachment>
{ $values
    { "texture" texture-data-target } { "layer" integer } { "level" integer }
    { "texture-layer-attachment" texture-layer-attachment }
}
{ $description "Constructs a " { $link framebuffer-attachment } " to the " { $snippet "layer" } "th layer of the " { $snippet "level" } "th level of detail of three-dimensional texture or array texture " { $snippet "texture" } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions. Array textures require OpenGL 3.0 or the " { $snippet "GL_EXT_texture_array" } " extension." } ;

HELP: allocate-renderbuffer
{ $values
    { "renderbuffer" renderbuffer } { "dim" sequence }
}
{ $description "Allocates image memory for " { $snippet "renderbuffer" } " with dimension " { $snippet "dim" } "." }
{ $notes "Renderbuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: any-framebuffer
{ $class-description "This class is a union of the " { $link framebuffer } " class, which represents user-created framebuffer objects, and the " { $link system-framebuffer } ". Words which accept " { $snippet "any-framebuffer" } " can operate on either the system framebuffer or user framebuffers." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: attachment-ref
{ $class-description "An " { $snippet "attachment-ref" } " value references a particular color, depth, or stencil attachment to a " { $link framebuffer } " object."
{ $list
{ { $link system-attachment } " references one or more of the color attachments to the " { $link system-framebuffer } "." }
{ { $link color-attachment } " references one of the indexed color attachments to a user-created " { $link framebuffer } "." }
{ { $link default-attachment } " references the back buffer of the " { $snippet "system-framebuffer" } " or the first color attachment of a user " { $snippet "framebuffer" } "." }
{ { $link depth-attachment } " references the depth buffer attachment to any framebuffer." }
{ { $link stencil-attachment } " references the stencil buffer attachment to any framebuffer." }
} }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: back-face
{ $class-description "Use this value in the " { $snippet "face" } " slot of a " { $link system-attachment } " reference to select the back face of a double-buffered " { $link system-framebuffer } "." } ;

HELP: clear-framebuffer
{ $values
    { "framebuffer" any-framebuffer } { "alist" "a list of " { $link attachment-ref } "/value pairs" }
}
{ $description "Clears the active viewport area of the specified attachments to " { $snippet "framebuffer" } " to the associated values." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: clear-framebuffer-attachment
{ $values
    { "framebuffer" any-framebuffer } { "attachment-ref" attachment-ref } { "value" object }
}
{ $description "Clears the active viewport area of the given attachment to " { $snippet "framebuffer" } " to " { $snippet "value" } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

{ clear-framebuffer clear-framebuffer-attachment } related-words

HELP: color-attachment
{ $class-description "This " { $link attachment-ref } " type references a color attachment to a user-created " { $link framebuffer } " object. The " { $snippet "index" } " slot of the tuple indicates the color attachment referenced. Color attachments to the " { $link system-framebuffer } " are referenced by the " { $link system-attachment } " type." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

{
    color-attachment system-attachment default-attachment depth-attachment stencil-attachment
    attachment-ref color-attachment-ref
} related-words

HELP: color-attachment-ref
{ $class-description "A " { $snippet "color-attachment-ref" } " value references a particular color attachment to a " { $link framebuffer } " object."
{ $list
{ { $link system-attachment } " references one or more of the color attachments to the " { $link system-framebuffer } "." }
{ { $link color-attachment } " references one of the indexed color attachments to a user-created " { $link framebuffer } "." }
{ { $link default-attachment } " references the back buffer of the " { $snippet "system-framebuffer" } " or the first color attachment of a user " { $snippet "framebuffer" } "." }
} }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: copy-framebuffer
{ $values
    { "to-fb-rect" framebuffer-rect } { "from-fb-rect" framebuffer-rect } { "depth?" boolean } { "stencil?" boolean } { "filter" texture-filter }
}
{ $description "Copies the rectangular region " { $snippet "from-fb-rect" } " to " { $snippet "to-fb-rect" } ". If " { $snippet "depth?" } " is true, depth values are also copied, and if " { $snippet "stencil?" } " is true, so are stencil values. If the rectangle sizes do not match, the region is scaled using nearest-neighbor or linear filtering based on " { $snippet "filter" } "." }
{ $notes "This word requires OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_blit" } " extensions." } ;

HELP: default-attachment
{ $class-description "This " { $link attachment-ref } " references the back buffer of the " { $link system-framebuffer } " or the first color attachment of a user-created " { $link framebuffer } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: depth-attachment
{ $class-description "This " { $link attachment-ref } " references the depth buffer attachment of a user-created " { $link framebuffer } " or the " { $link system-framebuffer } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: framebuffer
{ $class-description "Objects of this class represent user-created framebuffer objects. These framebuffer objects provide an offscreen target for rendering operations and can send rendering output either to textures or to dedicated " { $link renderbuffer } "s. A framebuffer consists of a set of one or more color " { $link framebuffer-attachment } "s, an optional depth buffer " { $snippet "framebuffer-attachment" } ", and an optional stencil buffer " { $snippet "framebuffer-attachment" } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: framebuffer-attachment
{ $class-description "This class is a union of the " { $link renderbuffer } " and " { $link texture-attachment } " classes, either of which can function as an attachment to a user-created " { $link framebuffer } " object." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: framebuffer-attachment-at
{ $values
    { "framebuffer" framebuffer } { "attachment-ref" attachment-ref }
    { "attachment" framebuffer-attachment }
}
{ $description "Returns the " { $link texture-attachment } " or " { $link renderbuffer } " referenced by " { $snippet "attachment-ref" } " in " { $snippet "framebuffer" } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: framebuffer-attachment-face
{ $class-description "The values " { $link front-face } " and " { $link back-face } " select a face of a double-buffered " { $link system-framebuffer } " when stored in the " { $snippet "face" } " slot of a " { $link system-attachment } " reference." } ;

HELP: framebuffer-attachment-side
{ $class-description "The values " { $link left-side } " and " { $link right-side } " select a face of a stereoscopic " { $link system-framebuffer } " when stored in the " { $snippet "side" } " slot of a " { $link system-attachment } " reference." } ;

HELP: framebuffer-rect
{ $class-description "This tuple class references a rectangular subregion of a color attachment of a " { $link framebuffer } " object."
{ $list
{ { $snippet "framebuffer" } " references either a user-created " { $link framebuffer } " or the " { $link system-framebuffer } "." }
{ { $snippet "attachment" } " is a " { $link color-attachment-ref } " referencing the color attachment of interest in the framebuffer." }
{ { $snippet "rect" } " is a " { $link rect } " referencing the rectangular region of interest of the attachment." }
} }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: front-face
{ $class-description "Use this value in the " { $snippet "face" } " slot of a " { $link system-attachment } " reference to select the front face of a double-buffered " { $link system-framebuffer } "." } ;

{ front-face back-face } related-words

HELP: left-side
{ $class-description "Use this value in the " { $snippet "side" } " slot of a " { $link system-attachment } " reference to select the left side of a stereoscopic " { $link system-framebuffer } "." } ;

{ left-side right-side } related-words

HELP: read-framebuffer
{ $values
    { "framebuffer-rect" framebuffer-rect }
    { "byte-array" byte-array }
}
{ $description "Reads the rectangular region " { $snippet "framebuffer-rect" } " into a new " { $snippet "byte-array" } ". The format of the byte array is determined by the " { $link component-order } " and " { $link component-type } " of the associated " { $link framebuffer-attachment } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: read-framebuffer-image
{ $values
    { "framebuffer-rect" framebuffer-rect }
    { "image" image }
}
{ $description "Reads the rectangular region " { $snippet "framebuffer-rect" } " into a new " { $snippet "image" } ". The format of the image is determined by the " { $link component-order } " and " { $link component-type } " of the associated " { $link framebuffer-attachment } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: read-framebuffer-to
{ $values
    { "framebuffer-rect" framebuffer-rect } { "gpu-data-ptr" gpu-data-ptr }
}
{ $description "Reads the rectangular region " { $snippet "framebuffer-rect" } " into " { $snippet "gpu-data-ptr" } ", which can reference either CPU memory (a " { $link byte-array } " or " { $link alien } ") or a GPU " { $link buffer-ptr } ". The format of the written data is determined by the " { $link component-order } " and " { $link component-type } " of the associated " { $link framebuffer-attachment } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions. Reading into a " { $snippet "buffer-ptr" } " requires OpenGL 2.1 or the " { $snippet "GL_ARB_pixel_buffer_object" } " extension." } ;

{ read-framebuffer read-framebuffer-image read-framebuffer-to } related-words

HELP: renderbuffer
{ $class-description "Objects of this type represent renderbuffer objects, two-dimensional image buffers that can serve as " { $link framebuffer-attachment } "s to user-created " { $link framebuffer } " objects." }
{ $notes "Renderbuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

{ renderbuffer renderbuffer-dim allocate-renderbuffer <renderbuffer> } related-words
{ framebuffer <framebuffer> resize-framebuffer } related-words

HELP: renderbuffer-dim
{ $values
    { "renderbuffer" renderbuffer }
    { "dim" sequence }
}
{ $description "Returns the dimensions of the allocated image memory for " { $snippet "renderbuffer" } "." }
{ $notes "Renderbuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: resize-framebuffer
{ $values
    { "framebuffer" framebuffer } { "dim" sequence }
}
{ $description "Reallocates the image memory for all of the textures and renderbuffers bound to " { $snippet "framebuffer" } " to be of the given dimensions." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: right-side
{ $class-description "Use this value in the " { $snippet "side" } " slot of a " { $link system-attachment } " reference to select the right side of a stereoscopic " { $link system-framebuffer } "." } ;

HELP: stencil-attachment
{ $class-description "This " { $link attachment-ref } " references the stencil buffer attachment of a user-created " { $link framebuffer } " or the " { $link system-framebuffer } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: system-attachment
{ $class-description "This " { $link attachment-ref } " references one or more of the color attachments to the " { $link system-framebuffer } ". Depending on the window system pixel format for the window, up to four attachments may be available:"
{ $list
{ "If double buffering is available, there is a " { $link back-face } ", which holds the screen image as it is drawn, and a " { $link front-face } ", which holds the current contents of the screen. The two buffers get swapped when a scene is completely drawn." }
{ "If stereoscopic rendering is available, there is a " { $link left-side } " and " { $link right-side } ", representing the left and right eye viewpoints of a 3D viewing apparatus." }
}
"To select a subset of these attachments, the " { $snippet "system-attachment" } " tuple type has two slots:"
{ $list
{ { $snippet "side" } " selects either the " { $snippet "left-side" } " or " { $snippet "right-side" } ", or both if set to " { $link f } "." }
{ { $snippet "face" } " selects either the " { $snippet "back-face" } " or " { $snippet "front-face" } ", or both if set to " { $link f } "." }
}
"If stereo or double buffering are not available, then both sides or faces respectively will be equivalent. All attachments can be selected by setting both slots to " { $link f } ", both attachments of a side or face can be selected by setting a single slot, and a single attachment can be targeted by setting both slots." } ;

HELP: system-framebuffer
{ $class-description "This symbol represents the framebuffer supplied by the window system to store the contents of the window on screen. Since this framebuffer is managed by the window system, it cannot have its attachments modified or resized; however, it is still a valid target for rendering, copying via " { $link copy-framebuffer } ", clearing via " { $link clear-framebuffer } ", and reading via " { $link read-framebuffer } "." } ;

HELP: texture-1d-attachment
{ $class-description "This class references a single level of detail of a one-dimensional texture for use as a " { $link framebuffer-attachment } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: texture-2d-attachment
{ $class-description "This class references a single level of detail of a two-dimensional texture for use as a " { $link framebuffer-attachment } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: texture-3d-attachment
{ $class-description "This class references a single plane and level of detail of a three-dimensional texture for use as a " { $link framebuffer-attachment } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: texture-attachment
{ $class-description "This class is a union of the " { $link texture-1d-attachment } ", " { $link texture-2d-attachment } ", " { $link texture-3d-attachment } ", and " { $link texture-layer-attachment } " classes, which select layers and levels of detail of " { $link texture } " objects to serve as " { $link framebuffer } " attachments." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions." } ;

HELP: texture-layer-attachment
{ $class-description "This class references a single layer and level of detail of a three-dimensional texture or array texture for use as a " { $link framebuffer-attachment } "." }
{ $notes "User-created framebuffer objects require OpenGL 3.0 or one of the " { $snippet "GL_ARB_framebuffer_object" } " or " { $snippet "GL_EXT_framebuffer_object" } " extensions. Array textures require OpenGL 3.0 or the " { $snippet "GL_EXT_texture_array" } " extension." } ;

{ texture-1d-attachment <texture-1d-attachment> } related-words
{ texture-2d-attachment <texture-2d-attachment> } related-words
{ texture-3d-attachment <texture-3d-attachment> } related-words
{ texture-layer-attachment <texture-layer-attachment> } related-words

ARTICLE: "gpu.framebuffers" "Framebuffer objects"
"The " { $vocab-link "gpu.framebuffers" } " vocabulary provides words for creating, allocating, and reading from framebuffer objects. Framebuffer objects are used as rendering targets; the " { $link system-framebuffer } " is supplied by the window system and contains the contents of the window on screen. User-created " { $link framebuffer } " objects can also be created to direct rendering output to offscreen " { $link texture } "s or " { $link renderbuffer } "s."
{ $subsections
    system-framebuffer
    framebuffer
    renderbuffer
}
"The contents of a framebuffer can be cleared to known values before rendering a scene:"
{ $subsections
    clear-framebuffer
    clear-framebuffer-attachment
}
"The image memory for a renderbuffer can be resized, or the full set of textures and renderbuffers attached to a framebuffer can be resized to the same dimensions together:"
{ $subsections
    allocate-renderbuffer
    resize-framebuffer
}
"Rectangular regions of framebuffers can be read into memory, read into GPU " { $link buffer } "s, and copied between framebuffers:"
{ $subsections
    framebuffer-rect
    attachment-ref
    read-framebuffer
    read-framebuffer-to
    read-framebuffer-image
    copy-framebuffer
} ;

ABOUT: "gpu.framebuffers"
