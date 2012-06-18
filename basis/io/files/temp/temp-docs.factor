USING: help.markup help.syntax ;
IN: io.files.temp

ARTICLE: "io.files.temp" "Temporary files"
"Pathnames relative to the system's temporary file directory:"
{ $subsections
    temp-file
    temp-directory
    with-temp-directory
}
"Pathnames relative to Factor's cache directory, used to store persistent intermediate files and resources:"
{ $subsections
    cache-file
    cache-directory
    with-cache-directory
} ;

ABOUT: "io.files.temp"
