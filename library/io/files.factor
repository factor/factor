! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: hashtables kernel math memory namespaces sequences
strings styles ;

! Words for accessing filesystem meta-data.

: path+ ( str1 str2 -- str )
    over "/" tail? [ append ] [ "/" swap append3 ] if ;

: exists? ( path -- ? ) stat >boolean ;

: directory? ( path -- ? ) stat first ;

: directory ( path -- seq )
    (directory)
    [ { "." ".." } member? not ] subset natural-sort ;

: file-length ( path -- n ) stat third ;

: file-modified ( path -- n ) stat fourth ;

: parent-dir ( path -- parent )
    CHAR: / over last-index CHAR: \\ pick last-index max
    dup -1 = [ 2drop "." ] [ head ] if ;

: resource-path ( resource -- path )
    \ resource-path get [ image parent-dir ] unless*
    swap path+ ;

: <resource-reader> ( resource -- stream )
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

: directory. ( path -- )
    dup directory [ file. ] each-with ;
