! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: kernel words ;

! Null metaclass with no instances.
SYMBOL: null
null [ drop [ ] ] "builtin-supertypes" set-word-prop
null [ 2drop 2drop ] "add-method" set-word-prop
null [ drop f ] "predicate" set-word-prop
null 100 "priority" set-word-prop
null [ 2drop t ] "class<" set-word-prop
null null define-class
