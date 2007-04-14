! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.x
USING: arrays definitions generic assocs
io kernel namespaces prettyprint prettyprint.sections
sequences words inspector classes strings vocabs ;
IN: help.topics

TUPLE: link name ;

MIXIN: topic
INSTANCE: link topic
INSTANCE: word topic

GENERIC: >link ( obj -- obj )
M: link >link ;
M: vocab-spec >link ;
M: object >link link construct-boa ;

PREDICATE: word-link < link link-name word? ;

M: link summary
    [
        "Link: " %
        link-name dup word? [ summary ] [ unparse ] if %
    ] "" make ;

! Help articles
SYMBOL: articles

articles global [ H{ } assoc-like ] change-at
    
SYMBOL: article-xref

article-xref global [ H{ } assoc-like ] change-at

GENERIC: article-name ( topic -- string )
GENERIC: article-parent ( topic -- parent )
GENERIC: set-article-parent ( parent topic -- )

TUPLE: article title content loc ;

: <article> ( title content -- article )
    f \ article construct-boa ;

M: article article-name article-title ;

TUPLE: no-article name ;

: no-article ( name -- * ) \ no-article construct-boa throw ;

M: no-article summary
    drop "Help article does not exist" ;

: article ( name -- article )
    dup articles get at* [ nip ] [ drop no-article ] if ;

M: object article-name article article-name ;
M: object article-title article article-title ;
M: object article-content article article-content ;
M: object article-parent article-xref get at ;
M: object set-article-parent article-xref get set-at ;

M: link article-name link-name article-name ;
M: link article-title link-name article-title ;
M: link article-content link-name article-content ;
M: link article-parent link-name article-parent ;
M: link set-article-parent link-name set-article-parent ;

! Special case: f help
M: f article-name drop \ f article-name ;
M: f article-title drop \ f article-title ;
M: f article-content drop \ f article-content ;
M: f article-parent drop \ f article-parent ;
M: f set-article-parent drop \ f set-article-parent ;
