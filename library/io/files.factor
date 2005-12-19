! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: hashtables kernel lists math namespaces sequences strings
styles ;

! Words for accessing filesystem meta-data.

: path+ ( path path -- path ) "/" swap append3 ;

: exists? ( file -- ? ) stat >boolean ;

: directory? ( file -- ? ) stat car ;

: directory ( dir -- list )
    (directory) [ { "." ".." } member? not ] subset string-sort ;

: file-length ( file -- length ) stat third ;

: resource-path ( path -- path )
    "resource-path" get [ "." ] unless* swap path+ ;

: <resource-stream> ( path -- stream )
    #! Open a file path relative to the Factor source code root.
    resource-path <file-reader> ;

: (file.) ( name path -- )
    file associate [ format* ] with-style ;

DEFER: directory.

: (directory.) ( name path -- )
    dup [ directory. ] curry
    [ "/" append (file.) ] write-outliner ;

: file. ( dir name -- )
    tuck path+
    dup directory? [ (directory.) ] [ (file.) terpri ] if ;

: directory. ( dir -- )
    dup directory [ file. ] each-with ;
