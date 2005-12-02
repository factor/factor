! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
USING: gadgets gadgets-panes gadgets-presentations hashtables io
kernel lists namespaces prettyprint sequences styles ;

! Simple markup language.

! <element> ::== <string> | <simple-element> | <fancy-element>
! <simple-element> ::== { <element>* }
! <fancy-element> ::== { <type> <element> }

! Element types are words whose name begins with $.

: ($span) ( content style -- )
    [ print-element ] with-style ; inline

: ($block) ( content style quot -- )
    >r [ [ print-element ] make-pane ] with-style
    dup r> call gadget. ; inline

: $see ( content -- ) first see ;

! Some spans
: $heading H{ { font "Serif" } { font-size 24 } } ($span) ;

: $subheading H{ { font "Serif" } { font-size 18 } } ($span) ;

: $parameter H{ { font "Monospaced" } { font-size 12 } } ($span) ;

! Some blocks
: $code
    H{ { font "Monospaced" } { font-size 12 } }
    [ T{ solid f { 0.9 0.9 0.9 1 } } swap set-gadget-interior ]
    ($block) ;

! Some links
TUPLE: link name ;

M: link article-title link-name article-title ;

M: link article-content link-name article-content ;

DEFER: help

: $subsection ( object -- )
    first [
        dup <link> presented set
        dup [ link-name help ] curry outline set
    ] make-hash [ article-title $subheading ] with-style terpri ;

: $link ( name -- )
    first dup <link> presented associate
    [ article-title print-element ] with-style ;

: $glossary ( element -- )
    first dup <term> presented associate
    [ print-element ] with-style ;
