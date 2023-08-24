! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: fry help.markup help.topics kernel math sequences ;
IN: help.crossref

: article-links ( topic elements -- seq )
    [ article-content ] dip collect-elements ;

: article-children ( topic -- seq )
    { $subsection $subsections } article-links [ >link ] map ;

: help-path ( topic -- seq )
    [ article-parent ] follow rest ;

: set-article-parents ( parent article -- )
    article-children [ set-article-parent ] with each ;

: xref-article ( topic -- )
    dup set-article-parents ;

: prev/next ( obj seq n -- obj' )
    [ [ index dup ] keep ] dip swap
    '[ _ + _ ?nth ] when ;

: prev/next-article ( article n -- article' )
    [ dup article-parent dup ] dip
    '[ article-children _ prev/next ] [ 2drop f ] if ;

: prev-article ( article -- prev ) -1 prev/next-article ;

: next-article ( article -- next ) 1 prev/next-article ;
