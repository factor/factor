
USING: classes command-line command-line.parser help.markup
help.syntax math ;

IN: command-line.parser

ARTICLE: "command-line.parser" "Parsing command-line arguments"
The { $vocab-link "command-line.parser" } vocabulary can be used to parse
{ $link command-line } arguments.

A sequence of { $link option } instances is used to control how the arguments
are parsed and is typically passed to the following words from a command-line
program:
{ $subsections
    with-options
    parse-options
    (parse-options)
}

Some variables control certain aspects of the parsing:
{ $table
    { { $link default-help? } { "A boolean value controlling if a " { $snippet "--help" } " option is added." } }
    { { $link allow-abbrev? } { "A boolean value controlling if abbreviations are allowed for options." } }
    { { $link program-name } { "An optional program name, or it will be inferred from the script or launched binary name." } }
    { { $link program-prolog } { "Some text to include in the help display before the options." } }
    { { $link program-epilog } { "Some text to include in the help display after the options." } }
}

In the case that you want to pass an option lookalike as a positional argument,
for example { $snippet "--foo" } then you can pass it after { $snippet "--" }
to indicate that the remaining arguments should be interpreted as positional
arguments.

;

HELP: option
{ $class-description "An option that can be specified on the command-line. It has the following slots:"
    { $slots
        { "name" { "The name of the argument (prefixed by dashes " { $snippet "\"-\"" } " if optional)." } }
        { "type" { "The " { $link class } " type of the argument." } }
        { "help" "Some help text to display." }
        { "variable" "An optional variable used to set a parsed value." }
        { "default" "A default value if not present on the command-line." }
        { "convert" "A converter from a string argument." }
        { "validate" "A validater to constrain the specified argument." }
        { "const" "A constant value to be used if the argument is specified." }
        { "required?" "A flag to indicate this option is required." }
        { "meta" "A meta variable name used to display." }
        { "#args" { "The number of arguments to parse specified as an " { $link integer } ", " { $snippet "\"*\"" } " (zero or more), " { $snippet  "\"+\"" } " (one or more), or " { $snippet "\"?\"" } " (optionally one) argument." } }
    }
} ;

ABOUT: "command-line.parser"
