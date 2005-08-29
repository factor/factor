! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: hashtables kernel math namespaces parser sequences
strings ;

: gensym ( -- word )
    #! Return a word that is distinct from every other word, and
    #! is not contained in any vocabulary.
    "G:"
    global [ \ gensym dup inc get ] bind
    number>string append f <word> ;

0 \ gensym global set-hash
