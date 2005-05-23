! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: matrices
USING: kernel math ;

: norm ( vec -- n ) dup v. sqrt ;
: normalize ( vec -- vec ) [ norm recip ] keep n*v ;
