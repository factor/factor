! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic assocs
io kernel namespaces prettyprint prettyprint.sections
sequences words inspector classes help.topics help.markup ;
IN: help.crossref

: article-children ( topic -- seq )
    article-content { $subsection } collect-elements ;

M: link uses
    article-content
    { $subsection $link $see-also }
    collect-elements [ \ f or ] map ;

: help-path ( topic -- seq )
    [ dup ] [ [ article-parent ] keep ] [ ] unfold nip 1 tail ;

: set-article-parents ( parent article -- )
    article-children [ set-article-parent ] curry* each ;

: xref-article ( topic -- )
    dup >link xref dup set-article-parents ;

: unxref-article ( topic -- )
    >link unxref ;
