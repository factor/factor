! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel semantic-db sequences sequences.lib ;
IN: tangle.page

RELATION: has-abbreviation
RELATION: has-content
RELATION: has-subsection
RELATION: before
RELATION: authored-by
RELATION: authored-on

TUPLE: page name abbreviation author created content ;
C: <page> page

: load-page-content ( node -- content )
    has-content-objects [ node-content ] map concat ;

: load-page ( node -- page )
    dup [ has-abbreviation-objects ?first ] keep
    [ authored-by-objects ?first ] keep
    [ authored-on-objects ?first ] keep
    load-page-content <page> ;
