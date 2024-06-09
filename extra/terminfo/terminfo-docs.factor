USING: help.markup help.syntax assocs terminfo.private kernel ;
IN: terminfo

HELP: my-terminfo
{ $values
    terminfo/f: { $maybe assoc }
}
{ $description
    As \ name>terminfo , but gets the name from { $snippet "$TERM" } , thus retrieving the capabilities for the current terminal.
}
{ $errors
    Throws \ bad-magic if a database entry is found but the header isn't recognized.
} ;

HELP: name>terminfo
{ $values
    name: { "a terminal name string" }
    terminfo/f: { $maybe assoc }
}
{ $description
    Returns the terminfo for the named terminal, or \ f if no entry for it is found in the database.
}
{ $errors
    Throws \ bad-magic if a database entry is found but the header isn't recognized.
} ;

HELP: tty-supports-attributes?
{ $values ?: boolean }
{ $description
    Outputs \ t if the current terminal (based on { $snippet "$TERM" } ) supports text attributes such as bold or underline. If you need to know specifically what attributes are supported, you will need to inspect the terminfo; that said, most modern terminals support at least bold, dim, inverse, and underline, and support for italics and strikethrough is increasingly common.

    { $see-also tty-supports-ansicolor? tty-supports-256color? tty-supports-rgbcolor? "terminfo" }
} ;

HELP: tty-supports-dim?
{ $values ?: boolean }
{ $description
    Outputs \ t if the terminal identified by { $snippet "$TERM" } supports dim { " (aka \"faint\" or \"half-bright\") " } text. The exact behaviour varies by terminal, unfortunately; common approaches are to have a separate, user-configured palette for dim colours (e.g. Konsole), or to generate dim colours on the fly by multiplying the current colour by some scaling factor, typically in the 0.4-0.6 range.

    { $see-also tty-supports-attributes? tty-supports-ansicolor? tty-supports-256color? tty-supports-rgbcolor? "terminfo" }
} ;

HELP: tty-supports-rgbcolor?
{ $values ?: boolean }
{ $description
    Outputs \ t if the current terminal (based on { $snippet "$TERM" } and { $snippet "$COLORTERM" } ) supports RGB color output, aka " \"direct colour\"" . On modern terminals this is typically an 8-bit-per-channel RGB mode which either displays the colour as given, or automatically maps it to the perceptually closest colour available in an internal palette.

    If { $snippet "$NO_COLOR" } is set, unconditionally returns \ f regardless of the terminal's underlying capabilities.

    In principle, foreground colour is selected using the sequence { $snippet "SGR 38:2:0:r:g:b" } , and background colour with { $snippet "SGR 48:2:0:r:g:b" } , where { $snippet "r:g:b" } are the channel values in the range 0-255. In practice, there is some disagreement about this; see below.

    { $heading "Caveats" }
    Autodetection of RGB support is a hot mess and false negatives are common. In particular, { $snippet "$COLORTERM" } is not usually propagated across ssh connections unless the user takes extra steps to do so, and while { $snippet "$TERM" } is, many terminfo files do not properly report RGB support.

    Like 256 colour mode (see \ tty-supports-256color? ), there is disagreement across terminals on whether to use { $snippet ":" } or { $snippet ";" } as the argument separator. Additionally, the always-zero second argument is mandatory in some terminals, optional in others, and some may reject it entirely. The standard uses { $snippet ":" } and requires the zero (which is nominally a colourspace ID, and in practice, ignored), and following that format will give you the best out-of-the-box compatibility. For maximum portability, however, you must consult the { $snippet "\"set_a_foreground\"" } and { $snippet "\"set_a_background\"" } terminfo capabilities.

    { $see-also tty-supports-attributes? tty-supports-ansicolor? tty-supports-256color? "terminfo" }
} ;

HELP: tty-supports-256color?
{ $values ?: boolean }
{ $description
    Outputs \ t if the current terminal (based on { $snippet "$TERM" } ) supports 256-color output. This is an indexed mode, consisting of the ANSI and AIXterm palettes in indexes 0-15 (see \ tty-supports-ansicolor? ), an RGB colour cube in indexes 16-231, and a 24-step greyscale ramp in indexes 232-255.

    If { $snippet "$NO_COLOR" } is set, unconditionally returns \ f regardless of the terminal's underlying capabilities.

    Foreground colour is selected using the sequence { $snippet "SGR 38:5:c" } , and background colour with { $snippet "SGR 48:5:c" } , where { $snippet "c" } is the colour index.

    { $heading "Caveats" }
    The standard documents { $snippet ":" } as the separator between arguments to these SGRs. Some terminals support { $snippet ";" } as well, for backwards compatibility with older, non-standards-compliant software; a few insist on { $snippet ";" } and will not understand { $snippet ":" } . Consult the { $snippet "\"set_a_foreground\"" } and { $snippet "\"set_a_background\"" } terminfo capabilities to be sure. If you're winging it, prefer { $snippet ":" } .

    { $see-also tty-supports-attributes? tty-supports-ansicolor? tty-supports-rgbcolor? "terminfo" }
} ;

HELP: tty-supports-ansicolor?
{ $values ?: boolean }
{ $description
    Outputs \ t if the current terminal (based on { $snippet "$TERM" } ) supports ANSI 8-color output. This uses a predefined palette, containing black, red, green, yellow/brown, blue, magenta, cyan, and white, typically at about 70% of full brightness, which can be used for both foreground and background.

    If { $snippet "$NO_COLOR" } is set, unconditionally returns \ f regardless of the terminal's underlying capabilities.

    While this is nominally an 8-colour mode, support for ANSI colour often comes with support for an additional 8-16 colors:
    { $list
        { "The \"AIXterm colours\" are an additional eight-colour palette, traditionally containing lighter versions of the ANSI colours. These can be used for both foreground and background." }
        { "Using dim text in conjunction with ANSI colours (see " { $link tty-supports-dim? } ") will produce darker colours. This can only be used to affect the foreground colour." }
    }

    It is almost universally the case in modern terminals that ANSI colours are selected with { $snippet "SGR" } values 30-37 (foreground) and 40-47 (background), and AIXterm colours, if available, with 90-97 and 100-107. The corresponding terminfo capabilities are { $snippet "\"set_a_foreground\"" } and { $snippet "\"set_a_background\"" } .

    { $heading "Caveats" }
    The palette contents are not standardized across terminal emulators; furthermore, most terminal emulators allow these colours to be configured by the user and/or remapped at runtime by software. Thus, while you can be mostly confident that (e.g.) colour 2 is green, figuring out { $emphasis "which" } green is difficult.

    Dim text is sometimes created on the fly by reducing the foreground lightness, and is sometimes a separate palette. In the latter case, combining dim text with AIXterm colours or other colour modes may not work at all, or may not do what you expect.

    Some terminals render bold text with increased lightness in addition to, or instead of, increased font weight. In some cases (e.g. Konsole) this is user-configurable.

    { $see-also tty-supports-attributes? tty-supports-256color? tty-supports-rgbcolor? "terminfo" }
} ;


ARTICLE: "terminfo" "Terminfo Databases"
The { $vocab-link "terminfo" } vocabulary contains words for querying the terminfo database, which contains low-level information about the capabilities and protocols of different terminals. It supports both SysV { "(\"Legacy\")" } and Curses 6.1 { "(\"Extended Number\")" } formats, and automatically selects the appropriate format depending on the file header. It also supports Curses 5 user-defined { "(\"Extended\")" } capabilities.

Terminfo capability descriptions are returned as assocs, where the keys are capability names; see { $snippet "terminfo(5)" } for a list of standardized capability names and their meanings. Capabilities that are disabled or absent are not present in the assoc and can be assumed to be \ f . In addition, all of the terminal's names are returned in the { $snippet "\".names\"" } pseudocapability, in the same order they appear in the terminfo file.

Words for getting terminal information:
{ $subsections
    my-terminfo
    name>terminfo
    file>terminfo
    bytes>terminfo
}

Words for querying specific capabilities of the current terminal:
{ $subsections
    tty-supports-attributes?
    tty-supports-dim?
    tty-supports-ansicolor?
    tty-supports-256color?
    tty-supports-rgbcolor?
}

{ $heading "Limitations" }
    The database search behaviour is not a perfect match for the behaviour implemented in Curses. In particular, setting the { $snippet "$TERMINFO" } environment variable does not disable searching the system-wide database as well, and the compiled-in search paths are not guaranteed to match the ones compiled into libcurses (although they should be correct on the vast majority of systems).

BerkeleyDB { "\"hashed database\"" } format is not supported and BDB terminfo databases will be ignored.

{ $heading "External References" }
{ $snippet "terminfo(5)" } for information about terminfo capabilities and how to use them; { $snippet "term(5)" } for information about the on-disk database format; and { $snippet "term(7)" } for information about terminal naming conventions. I also found { $url "https://github.com/mauke/unibilium/blob/master/secret/terminfo.pod" } useful for clarifying some aspects of the Curses 5 format which are not clear in the man page. ;

ABOUT: "terminfo"
