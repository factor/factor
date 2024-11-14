USING: help.markup help.syntax io quotations ;
IN: io.streams.ansi

ABOUT: "io.streams.escape-codes"

HELP: with-ansi
{ $values
    quot: quotation
}
{ $description
    Calls { $snippet "quotation" } with \ output-stream wrapped in a formatter that translates text attributes and colours into ANSI escape codes suitable for use on a text terminal.

    The formatter supports all the text attributes implemented in { $vocab-link "io.streams.escape-codes" } , and maps RGB colours to the 16 ANSI and AIXterm colours - "plain" and "bright" versions of black, white, RGB, and CMY. On terminals that report support for "dim" or "half-bright" text, that will be used to produce an additional 8 darker colours for foreground text.

    Note that since the ANSI and AIX palettes, and the exact behaviour of { $snippet "dim" } , are not standardized across terminals, the colour mapping used is an approximation and may not select optimal colours on all terminals.
} ;
