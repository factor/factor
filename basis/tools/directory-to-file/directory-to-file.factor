! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: base64 command-line escape-strings fry io.backend
io.directories io.directories.search io.encodings.binary
io.encodings.utf8 io.files io.files.info io.pathnames kernel
locals math namespaces sequences sequences.extras splitting ;
IN: tools.directory-to-file

: file-is-binary? ( path -- ? )
    binary file-contents [ 127 <= ] all? ;

:: directory-to-string ( path -- string )
    path normalize-path
    [ path-separator = ] trim-tail "/" append
    [ recursive-directory-files [ file-info directory? ] reject ] keep
    dup '[
        [ _  ?head drop ] map
    [
        dup file-is-binary? [
            utf8 file-contents escape-string
        ] [
            binary file-contents >base64 "" like escape-string
            "base64" prepend
        ] if
        ] map-zip
    ] with-directory
    [
        first2
        [ escape-simplest "FILE:: " prepend ] dip " " glue
    ] map "\n\n" join
    "<DIRECTORY: " path escape-simplest "\n\n" 3append
    "\n\nDIRECTORY>" surround ;

: directory-to-file ( path -- )
    [ directory-to-string ] keep ".modern" append
    utf8 set-file-contents ;

: directory-to-file-main ( -- )
    command-line get dup length 1 = [ "oops" throw ] unless first
    directory-to-file ;

MAIN: directory-to-file-main
