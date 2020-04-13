! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: base91 combinators command-line escape-strings fry
io.backend io.directories io.directories.search
io.encodings.binary io.encodings.utf8 io.files io.files.info
io.pathnames kernel locals math namespaces sequences
sequences.extras splitting ;
IN: tools.directory-to-file

: file-is-text? ( path -- ? )
    binary file-contents [ 127 < ] all? ;

: directory-repr ( path -- obj )
    escape-simplest
    "DIRECTORY: " prepend ;

: file-repr ( path string -- obj )
    [ escape-simplest "FILE:: " prepend ] dip " " glue ;

:: directory-to-string ( path -- string )
    path normalize-path
    [ path-separator = ] trim-tail "/" append
    [ recursive-directory-files ] keep
    dup '[
        [ _  ?head drop ] map
        [
            {
                { [ dup file-info directory? ] [ directory-repr ] }
                { [ dup file-is-text? ] [ dup utf8 file-contents escape-string file-repr ] }
                [
                    dup binary file-contents >base91
                    "" like escape-string
                    "base91" prepend file-repr
                ]
            } cond
        ] map
    ] with-directory
    "\n\n" join
    "<DIRECTORY: " path escape-simplest "\n\n" 3append
    "\n\n;DIRECTORY>" surround ;

: directory-to-file ( path -- )
    [ directory-to-string ] keep ".modern" append
    utf8 set-file-contents ;

: directory-to-file-main ( -- )
    command-line get dup length 1 = [ "oops" throw ] unless first
    directory-to-file ;

MAIN: directory-to-file-main
