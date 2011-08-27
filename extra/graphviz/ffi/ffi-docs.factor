! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel math quotations strings ;
IN: graphviz.ffi

HELP: ffi-errors
{ $values
    { "n" number }
}
{ $error-description "Thrown by " { $link gvFreeContext } " if the low-level Graphviz libraries (" { $emphasis "libgraph" } " and " { $emphasis "libgvc" } ") encountered one or more errors (specifically " { $slot "n" } " of them) while rendering. The C libraries themselves may print specific error messages to the standard error stream (see " { $url "http://graphviz.org/pdf/libguide.pdf" } "), but these messages will not be captured by " { $vocab-link "graphviz.ffi" } "." } ;

{ supported-engines supported-formats } related-words

HELP: supported-engines
{ $values
    { "value" array }
}
{ $description "An " { $link array } " of " { $link string } "s representing all valid " { $emphasis "layout engines" } ". For example, the " { $emphasis "dot" } " engine is typically included in a Graphviz installation, so " { $snippet "\"dot\"" } " will be an element of " { $link supported-engines } ". See " { $url "http://graphviz.org/Documentation.php" } " for more details." }
{ $notes "This constant's definition is determined at parse-time by asking the system's Graphviz installation what engines are supported." }
;

HELP: supported-formats
{ $values
    { "value" array }
}
{ $description "An " { $link array } " of " { $link string } "s representing all valid " { $emphasis "layout formats" } ". For example, Graphviz can typically render using the Postscript format, in which case " { $snippet "\"ps\"" } " will be an element of " { $link supported-formats } ". See " { $url "http://graphviz.org/Documentation.php" } " for more details." }
{ $notes "This constant's definition is determined at parse-time by asking the system's Graphviz installation what formats are supported."
$nl
"The Graphviz " { $emphasis "plugin" } " mechanism is not supported, so formats with colons like " { $snippet "\"png:cairo:gd\"" } " are not recognized."
}
;

ARTICLE: "graphviz.ffi" "Graphviz C library interface"
"The " { $vocab-link "graphviz.ffi" } " vocabulary defines words that interface with the low-level Graphviz libraries " { $emphasis "libgraph" } " and " { $emphasis "libgvc" } ", which should come installed with Graphviz."
$nl
"User code shouldn't call these words directly. Instead, use the " { $vocab-link "graphviz.render" } " vocabulary."
$nl
"User code may, however, encounter the following words exported from the " { $vocab-link "graphviz.ffi" } " vocabulary:"
{ $subsections ffi-errors supported-engines supported-formats }

{ $curious "Graphviz has documentation for " { $emphasis "libgraph" } " and " { $emphasis "libgvc" } " at " { $url "http://graphviz.org/pdf/libguide.pdf" } "." }
;

ABOUT: "graphviz.ffi"
