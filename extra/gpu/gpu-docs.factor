! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: gpu.private help.markup help.syntax ui.gadgets.worlds ;
IN: gpu

HELP: finish-gpu
{ $description "Waits for all outstanding GPU commands in the current graphics context to complete." } ;

HELP: flush-gpu
{ $description "Forces the execution of all outstanding GPU commands in the current graphics context." }
{ $notes { $snippet "flush-gpu" } " does not wait for execution to finish. For that, use " { $link finish-gpu } "." } ;

{ finish-gpu flush-gpu } related-words

HELP: gpu-object
{ $class-description "Parent class of all GPU resources." } ;

HELP: has-vertex-array-objects?
{ $var-description "Whether the opengl version supports Vertex Array Objects or not." } ;

HELP: init-gpu
{ $description "Initializes the current graphics context for use with the " { $snippet "gpu" } " library. This should be the first thing called in a world's " { $link begin-world } " method." } ;

HELP: reset-gpu
{ $description "Clears all framebuffer, GPU buffer, shader, and vertex array bindings. Call this before directly calling OpenGL functions after using " { $snippet "gpu" } " functions." } ;

ARTICLE: "gpu" "Graphics context management"
"Preparing the GPU library:"
{ $subsections init-gpu }
"Forcing execution of queued commands:"
{ $subsections
    flush-gpu
    finish-gpu
}
"Resetting OpenGL state:"
{ $subsections reset-gpu } ;

ARTICLE: "gpu-summary" "GPU-accelerated rendering"
"The " { $vocab-link "gpu" } " library is a set of vocabularies that work together to provide a convenient interface to creating, managing, and using GPU resources."
{ $subsections
    "gpu"
    "gpu.state"
    "gpu.buffers"
    "gpu.textures"
    "gpu.framebuffers"
    "gpu.shaders"
    "gpu.render"
}
"The library is built on top of the OpenGL API, but it aims to be complete enough that raw OpenGL calls are never needed. OpenGL 2.0 is required. Some features require later OpenGL versions or additional extensions; these requirements are documented alongside individual words. To make full use of the library, an OpenGL 3.1 or later implementation is recommended." ;

ABOUT: "gpu-summary"
