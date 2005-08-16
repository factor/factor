! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: kernel words ;

! Null metaclass with no instances.
null { } "types" set-word-prop
null [ drop f ] "predicate" set-word-prop
null null define-class
