USING: help.markup help.syntax assocs terminfo.private ;
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

ARTICLE: "terminfo" "Terminfo Databases"
    The { $vocab-link "terminfo" } vocabulary contains words for querying the terminfo database, which contains low-level information about the capabilities and protocols of different terminals.

Terminfo capability descriptions are returned as assocs, where the keys are capability names; see { $snippet "terminfo(5)" } for a list of standardized capability names and their meanings. Capabilities that are disabled or absent are not present in the assoc and can be assumed to be \ f . In addition, all of the terminal's names are returned in the { $snippet "\".names\"" } pseudocapability, in the same order they appear in the terminfo file.

Words for getting terminal information:
{ $subsections
    my-terminfo
    name>terminfo
    file>terminfo
    bytes>terminfo
}
{ $heading "Limitations" }
    The database search behaviour is not a perfect match for the behaviour implemented in Curses. In particular, setting the { $snippet "$TERMINFO" } environment variable does not disable searching the system-wide database as well, and the compiled-in search paths are not guaranteed to match the ones compiled into libcurses (although they should be correct on the vast majority of systems).

Curses 5 user-defined capabilities are not supported and will be skipped in files that contain them (the rest of the file will load normally).

Curses 6.1 terminfo files are not supported and cannot be loaded.

BerkeleyDB { "\"hashed database\"" } format is not supported and BDB terminfo databases will be ignored.

{ $heading "External References" }
{ $snippet "terminfo(5)" } for information about terminfo capabilities and how to use them; { $snippet "term(5)" } for information about the on-disk database format; and { $snippet "term(7)" } for information about terminal naming conventions. ;

ABOUT: "terminfo"
