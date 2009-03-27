! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.x
USING: accessors arrays definitions generic assocs
io kernel namespaces make prettyprint prettyprint.sections
sequences words summary classes strings vocabs ;
IN: help.topics

TUPLE: link name ;

INSTANCE: link definition

MIXIN: topic

INSTANCE: link topic

INSTANCE: word topic

GENERIC: >link ( obj -- obj )
M: link >link ;
M: vocab-spec >link ;
M: object >link link boa ;
M: f >link drop \ f >link ;

PREDICATE: word-link < link name>> word? ;

M: link summary
    [
        "Link: " %
        name>> dup word? [ summary ] [ unparse-short ] if %
    ] "" make ;

! Help articles
SYMBOL: articles

articles [ H{ } clone ] initialize
    
SYMBOL: article-xref

article-xref [ H{ } clone ] initialize

GENERIC: article-name ( topic -- string )
GENERIC: article-title ( topic -- string )
GENERIC: article-content ( topic -- content )
GENERIC: article-parent ( topic -- parent )
GENERIC: set-article-parent ( parent topic -- )

TUPLE: article title content loc ;

: <article> ( title content -- article )
    f \ article boa ;

M: article article-name title>> ;
M: article article-title title>> ;
M: article article-content content>> ;

ERROR: no-article name ;

M: no-article summary
    drop "Help article does not exist" ;

: article ( name -- article )
    articles get ?at [ no-article ] unless ;

M: object article-name article article-name ;
M: object article-title article article-title ;
M: object article-content article article-content ;
M: object article-parent article-xref get at ;
M: object set-article-parent article-xref get set-at ;

M: link article-name name>> article-name ;
M: link article-title name>> article-title ;
M: link article-content name>> article-content ;
M: link article-parent name>> article-parent ;
M: link set-article-parent name>> set-article-parent ;

! Special case: f help
M: f article-name drop \ f article-name ;
M: f article-title drop \ f article-title ;
M: f article-content drop \ f article-content ;
M: f article-parent drop \ f article-parent ;
M: f set-article-parent drop \ f set-article-parent ;