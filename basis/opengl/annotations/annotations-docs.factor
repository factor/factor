USING: help.markup help.syntax opengl words ;
IN: opengl.annotations

HELP: log-gl-error
{ $values { "function" word } }
{ $description "If the most recent OpenGL call resulted in an error, append it to the " { $link gl-error-log } "." }
{ $notes "Don't call this function directly. Call " { $link log-gl-errors } " to annotate every OpenGL function to automatically log errors." } ;

HELP: gl-error-log
{ $var-description "A vector of OpenGL errors logged by " { $link log-gl-errors } ". Each log entry has the following tuple slots:" }
{ $list
    { { $snippet "function" } " is the OpenGL function that raised the error." }
    { { $snippet "error" } " is the OpenGL error code." }
    { { $snippet "timestamp" } " is the time the error was logged." }
}
{ "The error log is emptied using the " { $link clear-gl-error-log } " word." } ;

HELP: clear-gl-error-log
{ $description "Empties the OpenGL error log populated by " { $link log-gl-errors } "." } ;

HELP: throw-gl-errors
{ $description "Annotate every OpenGL function to throw a " { $link gl-error } " if the function results in an error. Use " { $link reset-gl-functions } " to reverse this operation." } ;

HELP: log-gl-errors
{ $description "Annotate every OpenGL function to log using " { $link log-gl-error } " if the function results in an error. Use " { $link reset-gl-functions } " to reverse this operation." } ;

HELP: reset-gl-functions
{ $description "Removes any annotations from all OpenGL functions, such as those applied by " { $link throw-gl-errors } " or " { $link log-gl-errors } "." } ;

{ throw-gl-errors gl-error log-gl-errors log-gl-error clear-gl-error-log reset-gl-functions } related-words

ARTICLE: "opengl.annotations" "OpenGL error reporting"
"The " { $vocab-link "opengl.annotations" } " vocabulary provides some tools for tracking down GL errors:"
{ $subsections
    throw-gl-errors
    log-gl-errors
    clear-gl-error-log
    reset-gl-functions
} ;

ABOUT: "opengl.annotations"
