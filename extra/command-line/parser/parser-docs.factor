
USING: command-line.parser help.markup help.syntax ;

IN: command-line.parser

ARTICLE: "command-line.parser" "Parsing command-line arguments"
The { $vocab-link "command-line.parser" } vocabulary can be used to parse
{ $link command-line } arguments.

A sequence of { $link option } instances is used to control how the arguments
are parsed. This sequence is typically passed to the following words from a
command-line program:

{ $subsections
    with-options
    (with-options)
}
;

HELP: option
{ $class-description "An option that can be specified on the command-line. It has the following slots:"
    { $slots
        { "name" "The name of the argument." }
        { "type" { "The " { $link class } " type of the argument." } }
        { "help" "Some help text to display." }
        { "variable" "An optional variable used to set a parsed value." }
        { "default" "A default value if not present on the command-line." }
        { "convert" "A converter from a string argument." }
        { "validate" "A validater to constrain the specified argument." }
        { "const" "A constant value to be used if the argument is specified." }
        { "required?" "A flag to indicate this option is required." }
        { "meta" "A meta variable name used to display." }
    }
} ;

ABOUT: "command-line.parser"
