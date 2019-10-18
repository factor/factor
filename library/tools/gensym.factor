! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words USING: kernel math namespaces sequences strings
unparser ;

SYMBOL: gensym-count

: (gensym) ( -- name )
    "G:" global [
        gensym-count [ 1 + dup ] change
    ] bind unparse append ;

: gensym ( -- word )
    #! Return a word that is distinct from every other word, and
    #! is not contained in any vocabulary.
    (gensym) f (create) ;

global [ 0 gensym-count set ] bind
