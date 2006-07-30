! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: hashtables kernel math memory namespaces sequences
strings styles ;

! Words for accessing filesystem meta-data.

: path+ ( path path -- path )
    over "/" tail? [ append ] [ "/" swap append3 ] if ;

: exists? ( file -- ? ) stat >boolean ;

: directory? ( file -- ? ) stat first ;

: directory ( dir -- list )
    (directory)
    [ { "." ".." } member? not ] subset natural-sort ;

: file-length ( file -- length ) stat third ;

: parent-dir ( path -- path )
    CHAR: / over last-index CHAR: \\ pick last-index max
    dup -1 = [ 2drop "." ] [ head ] if ;

: resource-path ( path -- path )
    image parent-dir swap path+ ;

: <resource-reader> ( path -- stream )
    resource-path <file-reader> ;

TUPLE: pathname string ;

: (file.) ( name path -- )
    <pathname> write-object ;

DEFER: directory.

: (directory.) ( name path -- )
    >r "/" append r> dup <pathname> swap [ directory. ] curry
    write-outliner terpri ;

: file. ( dir name -- )
    tuck path+
    dup directory? [ (directory.) ] [ (file.) terpri ] if ;

: directory. ( dir -- )
    dup directory [ file. ] each-with ;
