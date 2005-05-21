! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: matrices
USING: kernel math ;

: norm ( v -- a )
    dup v. sqrt ;

: normalize ( v -- v )
    [ norm recip ] keep n*v ;
