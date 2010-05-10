! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors definitions help help.topics help.syntax
prettyprint.backend prettyprint.custom prettyprint words kernel
effects see ;
IN: help.definitions

! Definition protocol implementation

M: link definer drop \ ARTICLE: \ ; ;

M: link where name>> article loc>> ;

M: link set-where name>> article loc<< ;

M: link forget* name>> remove-article ;

M: link definition article-content ;

M: link synopsis*
    dup definer.
    dup name>> pprint*
    article-title pprint* ;

M: word-link definer drop \ HELP: \ ; ;

M: word-link where name>> "help-loc" word-prop ;

M: word-link set-where name>> swap "help-loc" set-word-prop ;

M: word-link definition name>> "help" word-prop ;

M: word-link synopsis*
    dup definer.
    name>> dup pprint-word
    stack-effect. ;

M: word-link forget* name>> remove-word-help ;
