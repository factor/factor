USING: help help.markup help.syntax io.streams.256color
io.streams.ansi kernel sequences strings terminfo ;
IN: io.streams.escape-codes

DEFER: with-ansi
DEFER: with-256color

HELP: ansi-font-style
{ $values
    { "font-style" "a style or sequence of styles" }
    { "string" string }
}
{ $description
    Returns a string containing one or more ANSI escape sequences implementing the given style(s).
} ;

HELP: strip-ansi-escapes
{ $values
    str: string
    str': string
}
{ $description
    Returns a copy of { $snippet "str" } with all ANSI escape sequences stripped out.
} ;

ARTICLE: "io.streams.escape-codes" "Formatted TTY Output"
In addition to HTML and GUI output, Factor has facilities for displaying formatted text -- such as that produced by \ help -- on terminals that support text attributes and colours.

The { $vocab-link "io.streams.escape-codes" } vocabulary provides words for generating ANSI escape codes from text attributes, and is not typically useful to end users. The { $vocab-link "io.streams.ansi" } and { $vocab-link "io.streams.256color" } vocabularies, however, provide output streams suitable for displaying formatted text on 16- and 256-color terminals, respectively. In deciding which one to use, you may also want to use { $vocab-link "terminfo" } to query the capabilities of your controlling terminal.

{ $heading "Limitations" }
These vocabularies do not attempt to query the terminal to figure out what features they support; it's assumed that the caller has done so, if necessary.

Similarly, it assumes the terminal it's talking to supports ECMA/ISO escape sequences rather than querying terminfo to find out if it uses nonstandard sequences. This may change in the future, but this is sufficient for compatibility with the most commonly used terminal emulators.

Palettes are not standardized across terminals, and even across different installs of the same terminal, individual users may have set up custom palettes. These vocabularies do not attempt to read palette information from the terminal; instead, they use builtin palettes that should closely approximate the default configurations for a wide range of terminals.

Formatted output:
{ $subsections
    with-ansi
    with-256color
}

Querying terminal capabilities:
{ $subsections
    tty-supports-ansicolor?
    tty-supports-256color?
    tty-supports-rgbcolor?
    tty-supports-attributes?
}

{ $see-also "terminfo" }
;

ABOUT: "io.streams.escape-codes"
