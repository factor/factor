! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: hashtables kernel math memory namespaces sequences
strings styles arrays ;

! Words for accessing filesystem meta-data.

: path+ ( str1 str2 -- str )
    over "/" tail? [ append ] [ "/" swap 3append ] if ;

: exists? ( path -- ? ) stat >r 3drop r> >boolean ;

: directory? ( path -- ? ) stat 3drop ;

: directory ( path -- seq )
    (directory)
    [ { "." ".." } member? not ] subset ;

: file-length ( path -- n ) stat 4array third ;

: file-modified ( path -- n ) stat >r 3drop r> ;

: parent-dir ( path -- parent )
    CHAR: / over last-index CHAR: \\ pick last-index max
    dup -1 = [ 2drop "." ] [ head ] if ;

: resource-path ( resource -- path )
    \ resource-path get [ image parent-dir ] unless*
    swap path+ ;

: ?resource-path ( path -- path )
    "resource:" ?head [ resource-path ] when ;

TUPLE: pathname string ;

: write-pathname ( path -- ) dup <pathname> write-object ;

: home ( -- dir )
    windows? "USERPROFILE" "HOME" ? os-env [ "." ] unless* ;
