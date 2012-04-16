USING: help.markup help.syntax ;
IN: io.files.temp

ARTICLE: "io.files.temp" "Temporary files"
"Pathnames relative to the system's temporary file directory:"
{ $subsections
    temp-directory
    temp-file
}
"Pathnames relative to Factor's cache directory, used to store persistent intermediate files and resources:"
{ $subsections
    cache-directory
    cache-file
} ;


ABOUT: "io.files.temp"
