! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: matrices
USING: kernel math ;

: norm ( vec -- n ) norm-sq sqrt ;
: normalize ( vec -- vec ) dup norm v/n ;
