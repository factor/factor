! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: tools.walker
USING: kernel sequences tools.interpreter ;

: walk ( quot -- ) [ break ] swap append call ;
