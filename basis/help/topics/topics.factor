! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.x
USING: accessors assocs definitions kernel make namespaces
prettyprint summary vocabs words ;
IN: help.topics

TUPLE: link name ;

INSTANCE: link definition-mixin

MIXIN: topic

INSTANCE: link topic

INSTANCE: word topic

GENERIC: >link ( obj -- obj )
M: link >link ;
M: wrapper >link wrapped>> >link ;
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

GENERIC: valid-article? ( topic -- ? )
GENERIC: article-title ( topic -- string )
GENERIC: article-name ( topic -- string )
GENERIC: article-content ( topic -- content )
GENERIC: article-parent ( topic -- parent/f )
GENERIC: set-article-parent ( parent topic -- )

M: object article-name article-title ;

TUPLE: article title content loc ;

: <article> ( title content -- article )
    f \ article boa ;

M: article valid-article? drop t ;
M: article article-title title>> ;
M: article article-content content>> ;

ERROR: no-article name ;

M: no-article summary
    drop "Help article does not exist" ;

: lookup-article ( name -- article )
    articles get ?at [ no-article ] unless ;

M: object valid-article? articles get key? ;
M: object article-title lookup-article article-title ;
M: object article-content lookup-article article-content ;
M: object article-parent article-xref get at ;
M: object set-article-parent article-xref get set-at ;

M: link valid-article? name>> valid-article? ;
M: link article-title name>> article-title ;
M: link article-content name>> article-content ;
M: link article-parent name>> article-parent ;
M: link set-article-parent name>> set-article-parent ;

! Special case: f help
M: f valid-article? drop t ;
M: f article-title drop \ f article-title ;
M: f article-content drop \ f article-content ;
M: f article-parent drop \ f article-parent ;
M: f set-article-parent drop \ f set-article-parent ;
