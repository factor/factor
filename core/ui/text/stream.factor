! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: io strings kernel gadgets ;
IN: gadgets-text

! Editors support the stream output protocol
M: editor stream-write1 >r 1string r> stream-write ;

M: editor stream-write
    control-self dup end-of-document user-input ;

M: editor stream-close drop ;

M: editor stream-flush drop ;
