! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar help.markup help.syntax io.pathnames kernel math
strings urls ;
IN: http.download


HELP: download
{ $values { "url" { $or url string } } { "path" "a pathname string" } }
{ $description "Downloads the contents of the URL to a file in the " { $link current-directory } " having the same file name and returns the pathname." }
{ $notes "Use this to download the file every time." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: download-into
{ $values
    { "url" url } { "directory" "a pathname string" }
    { "path" "a pathname string" }
}
{ $description "Downloads the contents of the URL to a file the given directory and returns the pathname." } ;

HELP: download-as
{ $values { "url" { $or url string } } { "path" "a pathname string" } }
{ $description "Downloads the contents of the URL to a file with the given pathname and returns the pathname." }
{ $notes "Use this to download the file every time." }
{ $errors "Throws an error if the HTTP request fails." } ;


HELP: download-once
{ $values
    { "url" url }
    { "path" "a pathname string" }
}
{ $description "Downloads a file to " { $link current-directory } " and returns the path. If the path already exists, this word does not download it again." } ;

HELP: download-once-into
{ $values
    { "url" url } { "directory" "a pathname string" }
    { "path" "a pathname string" }
}
{ $description "Downloads a file to " { $snippet "directory" } " and returns the path. If the path already exists, this word does not download it again." } ;

HELP: download-once-as
{ $values { "url" { $or url string } } { "path" "a pathname string" } }
{ $description "If the file exists on disk, returns that pathname without downloading anything. Otherwise, downloads the contents of the URL to a file with the given pathname and returns the pathname." }
{ $notes "Use this if the contents of the URL are not expected to change." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: download-outdated
{ $values
    { "url" url } { "duration" duration }
    { "path" "a pathname string" }
}
{ $description "Download a URL into " { $link current-directory } " unless the an existing file has a timestamp newer than " { $snippet "duration" } " ago." } ;

HELP: download-outdated-as
{ $values
    { "url" url } { "path" "a pathname string" } { "duration" duration }
    { "path'" "a pathname string" }
}
{ $description "Download a URL into a directory unless the an existing file has a timestamp newer than " { $snippet "duration" } " ago." } ;

HELP: download-outdated-into
{ $values
    { "url" url } { "directory" "a pathname string" } { "duration" duration }
    { "path" "a pathname string" }
}
{ $description "Download a URL into a directory unless the an existing file has a timestamp newer than " { $snippet "duration" } " ago." } ;


HELP: download-to-temporary-file
{ $values
    { "url" url }
    { "path" "a pathname string" }
}
{ $description "Downloads a url to a unique temporary file in " { $link current-directory } " named " { $snippet "temp.XXXXXXXXXreal-file-name.ext.temp" } "." } ;

HELP: download-name
{ $values
    { "url" url }
    { "name" object }
}
{ $description "Turns a URL into a filename suitable for downloading to locally." } ;

ARTICLE: "http.download" "HTTP Download Utilities"
"The " { $vocab-link "http.download" } " vocabulary provides utilities for downloading files from the web."

"Utilities to retrieve a " { $link url } " and save the contents to a file:"
{ $subsections
    download
    download-into
    download-as
    download-once
    download-once-into
    download-once-as
    download-outdated
    download-outdated-into
    download-outdated-as
}

"Helper words:"
{ $subsections
    download-to-temporary-file
    download-name
} ;

ABOUT: "http.download"
