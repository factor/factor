USING: help.markup help.syntax io.pathnames sequences strings ;

IN: globs

HELP: glob
{ $values
    glob: string
    files: sequence
}
{ $description
    Search the \ current-directory using a { $snippet "glob" } pattern. This
    supports some wildcard characters:

    { $table
        { { $snippet "*" } "Matches multiple characters" }
        { { $snippet "?" } "Matches a single character" }
        { { $snippet "[]" } "Matches a specified group of characters" }
    }
} ;

HELP: rglob
{ $values
    glob: string
    files: sequence
}
{ $description
    A " recursive " version of \ glob . This is equivalent to { $snippet "**/glob" } .
} ;

ARTICLE: "globs" "Globs"

The { $vocab-link "globs" } vocabulary is useful for finding pathnames of
files matching a specified pattern according to the typical rules used by the
Unix shell, although results are returned in arbitrary order. No tilde
expansion is done, but { $snippet "*" } , { $snippet "?" } , and
character ranges expressed with { $snippet "[]" } will be correctly
matched.

The \ current-directory is searched, and these are the typical entry-points:

{ $subsections
    glob
    rglob
} ;

ABOUT: "globs"
