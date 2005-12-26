! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings
USING: kernel math strings sequences-internals sequences ;

M: string resize resize-string ;

M: sbuf set-length ( n sbuf -- ) grow-length ;

M: sbuf nth-unsafe ( n sbuf -- ch ) underlying nth-unsafe ;

M: sbuf nth ( n sbuf -- ch ) bounds-check nth-unsafe ;

M: sbuf set-nth-unsafe ( ch n sbuf -- )
    underlying set-nth-unsafe ;

M: sbuf set-nth ( ch n sbuf -- )
    growable-check 2dup ensure set-nth-unsafe ;

M: sbuf clone clone-growable ;
