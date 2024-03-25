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

HELP: download-to
{ $values { "url" { $or url string } } { "file" "a pathname string" } { "path" "a pathname string" } }
{ $description "Downloads the contents of the URL to a file with the given pathname and returns the pathname." }
{ $notes "Use this to download the file every time." }
{ $errors "Throws an error if the HTTP request fails." } ;

HELP: download-once-to
{ $values { "url" { $or url string } } { "file" "a pathname string" } { "path" "a pathname string" } }
{ $description "If the file exists on disk, returns that pathname without downloading anything. Otherwise, downloads the contents of the URL to a file with the given pathname and returns the pathname." }
{ $notes "Use this if the contents of the URL are not expected to change." }
{ $errors "Throws an error if the HTTP request fails." } ;


ARTICLE: "http.download" "HTTP Download Utilities"
"The " { $vocab-link "http.download" } " vocabulary provides utilities for downloading files from the web."

"Utilities to retrieve a " { $link url } " and save the contents to a file:"
{ $subsections
    download
    download-to
    download-once-to
}
;

ABOUT: "http.download"
