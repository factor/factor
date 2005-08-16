! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: kernel lists math sequences vectors words ;

! Catch-all metaclass for providing a default method.
object num-types >vector "types" set-word-prop
object [ drop t ] "predicate" set-word-prop
object object define-class
