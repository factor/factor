! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: kernel lists namespaces sequences strings ;

! Words for accessing filesystem meta-data.

: path+ ( path path -- path ) "/" swap append3 ;
: exists? ( file -- ? ) stat >boolean ;
: directory? ( file -- ? ) stat car ;
: directory ( dir -- list ) (directory) [ lexi ] sort ;
: file-length ( file -- length ) stat third ;
: file-extension ( filename -- extension )
    "." split cdr dup [ peek ] when ;

DEFER: <file-reader>

: resource-path ( -- path )
    "resource-path" get [ "." ] unless* ;

: <resource-stream> ( path -- stream )
    #! Open a file path relative to the Factor source code root.
    resource-path swap path+ <file-reader> ;
