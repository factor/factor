! (c)2009 Joe Groff bsd license
USING: help.markup help.syntax ui.gadgets.worlds ;
IN: gpu

HELP: finish-gpu
{ $description "Waits for all outstanding GPU commands in the current graphics context to complete." } ;

HELP: flush-gpu
{ $description "Forces the execution of all outstanding GPU commands in the current graphics context." }
{ $notes { $snippet "flush-gpu" } " does not wait for execution to finish. For that, use " { $link finish-gpu } "." } ;

{ finish-gpu flush-gpu } related-words

HELP: gpu-object
{ $class-description "Parent class of all GPU resources." } ;

HELP: init-gpu
{ $description "Initializes the current graphics context for use with the " { $snippet "gpu" } " library. This should be the first thing called in a world's " { $link begin-world } " method." } ;

HELP: reset-gpu
{ $description "Clears all framebuffer, GPU buffer, shader, and vertex array bindings. Call this before directly calling OpenGL functions after using " { $snippet "gpu" } " functions." } ;

ARTICLE: "gpu" "Graphics context management"
"Preparing the GPU library:"
{ $subsection init-gpu }
"Forcing execution of queued commands:"
{ $subsection flush-gpu }
{ $subsection finish-gpu }
"Resetting OpenGL state:"
{ $subsection reset-gpu } ;

ARTICLE: "gpu-summary" "GPU-accelerated rendering"
"The " { $vocab-link "gpu" } " library is a set of vocabularies that work together to provide a convenient interface to creating, managing, and using GPU resources."
{ $subsection "gpu" }
{ $subsection "gpu.state" }
{ $subsection "gpu.buffers" }
{ $subsection "gpu.textures" }
{ $subsection "gpu.framebuffers" }
{ $subsection "gpu.shaders" }
{ $subsection "gpu.render" }
"The library is built on top of the OpenGL API, but it aims to be complete enough that raw OpenGL calls are never needed. OpenGL 2.0 with the vertex array object extension (" { $snippet "GL_APPLE_vertex_array_object" } " or " { $snippet "GL_ARB_vertex_array_object" } ") is required. Some features require later OpenGL versions or additional extensions; these requirements are documented alongside individual words. To make full use of the library, an OpenGL 3.1 or later implementation is recommended." ;

ABOUT: "gpu-summary"
