! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: definitions help help.topics help.syntax
prettyprint.backend prettyprint words kernel effects ;
IN: help.definitions

! Definition protocol implementation

M: link definer drop \ ARTICLE: \ ; ;

M: link where link-name article article-loc ;

M: link set-where link-name article set-article-loc ;

M: link forget link-name remove-article ;

M: link definition article-content ;

M: link see (see) ;

M: link synopsis*
    \ ARTICLE: pprint-word
    dup link-name pprint*
    article-title pprint* ;

M: word-link definer drop \ HELP: \ ; ;

M: word-link where link-name "help-loc" word-prop ;

M: word-link set-where link-name swap "help-loc" set-word-prop ;

M: word-link definition link-name "help" word-prop ;

M: word-link synopsis*
    \ HELP: pprint-word
    link-name dup pprint-word
    stack-effect. ;

M: word-link forget link-name remove-word-help ;
