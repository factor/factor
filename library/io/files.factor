! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: kernel lists sequences strings ;

! Words for accessing filesystem meta-data.

: path+ ( path path -- path ) "/" swap append3 ;
: exists? ( file -- ? ) stat >boolean ;
: directory? ( file -- ? ) stat car ;
: directory ( dir -- list ) (directory) [ string> ] sort ;
: file-length ( file -- length ) stat third ;
: file-extension ( filename -- extension )
    "." split cdr dup [ peek ] when ;
