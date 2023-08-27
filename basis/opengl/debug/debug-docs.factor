! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax tools.continuations ;
IN: opengl.debug

HELP: G
{ $description "Makes the OpenGL context associated with " { $link G-world } " active for subsequent OpenGL calls. This is intended to be used from the listener, where interactively entered OpenGL calls can be directed to any window. Note that the Factor UI resets the OpenGL context every time a window is updated, so every code snippet entered in the listener must be prefixed with " { $snippet "G" } " in this use case." }
{ $examples { $code "USING: opengl.debug ui ;

[ drop t ] find-window G-world set
G 0.0 0.0 1.0 1.0 glClearColor
G GL_COLOR_BUFFER_BIT glClear" } } ;

HELP: F
{ $description "Flushes the OpenGL context associated with " { $link G-world } ", thereby committing any outstanding drawing operations." } ;

HELP: G-world
{ $var-description "The world whose OpenGL context is made active by " { $link G } "." } ;

HELP: GB
{ $description "A shorthand for " { $link gl-break } "." } ;

HELP: gl-break
{ $description "Suspends the current thread and activates the walker like " { $link break } ", but also preserves the current OpenGL context, saves it to " { $link G-world } " for interactive use through " { $link G } ", and restores the current context when the suspended thread is continued. The shorthand word " { $link POSTPONE: GB } " can also be used." } ;

{ G F G-world POSTPONE: GB gl-break } related-words

ARTICLE: "opengl.debug" "Interactive debugging of OpenGL applications"
"The " { $vocab-link "opengl.debug" } " vocabulary provides words to assist with interactive debugging of OpenGL applications in the Factor UI."
{ $subsections
    G-world
    G
    F
    GB
    gl-break
} ;

ABOUT: "opengl.debug"
