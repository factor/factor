! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io.directories io.encodings.utf8 io.files
io.pathnames kernel math.parser prettyprint sequences splitting
unicode.categories ;
IN: tools.ps

: ps-comm ( path -- string )
    "/comm" append utf8 file-contents "\0" split " " join
    [ blank? ] trim "[" "]" surround ;

: ps-cmdline ( path -- path string )
    dup "/cmdline" append utf8 file-contents
    [ dup ps-comm ] [ "\0" split " " join ] if-empty ;

: ps ( -- assoc )
    "/proc" [
        "." directory-files [ file-name string>number ] filter
        [ ps-cmdline ] { } map>assoc
    ] with-directory ;

: ps. ( -- )
    ps simple-table. ;
