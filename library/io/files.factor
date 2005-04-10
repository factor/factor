! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: files
USING: kernel lists strings ;

! Words for accessing filesystem meta-data.

: exists? ( file -- ? ) stat >boolean ;
: directory? ( file -- ? ) stat car ;
: directory ( dir -- list ) (directory) [ string> ] sort ;
: file-length ( file -- length ) stat dup [ cdr cdr car ] when ;
: file-extension ( filename -- extension )
    "." split cdr dup [ last ] when ;
