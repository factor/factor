! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: strings
USING: kernel math strings sequences-internals sequences ;

M: sbuf set-length grow-length ;
M: sbuf nth-unsafe underlying nth-unsafe ;
M: sbuf nth bounds-check nth-unsafe ;
M: sbuf set-nth-unsafe underlying set-nth-unsafe ;
M: sbuf set-nth growable-check 2dup ensure set-nth-unsafe ;
M: sbuf clone clone-growable ;
M: sbuf thaw drop SBUF" " clone ;
: >sbuf [ sbuf? ] [ <sbuf> ] >sequence ; inline
M: sbuf like drop dup sbuf? [ >sbuf ] unless ;
