! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io.directories io.encodings.utf8 io.files
io.pathnames kernel math.parser prettyprint sequences splitting
unicode.categories ;
IN: tools.ps

! Only in Linux 3
: ps-comm ( path -- string )
    "/comm" append utf8 file-contents "\0" split " " join
    [ blank? ] trim "[" "]" surround ;

: parse-stat ( string -- program-name )
    " " split
    second
    [ CHAR: ( = ] trim-head
    [ CHAR: ) = ] trim-tail 
    "[" "]" surround ;

: ps-stat ( path -- string )
    "/stat" append utf8 file-contents parse-stat ;

: ps-cmdline ( path -- path string )
    dup "/cmdline" append utf8 file-contents
    [ dup ps-stat ] [ "\0" split " " join ] if-empty ;

: ps ( -- assoc )
    "/proc" [
        "." directory-files [ file-name string>number ] filter
        [ ps-cmdline ] { } map>assoc
    ] with-directory ;

: ps. ( -- )
    ps simple-table. ;
