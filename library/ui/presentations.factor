! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: hashtables io kernel lists namespaces prettyprint ;

: actions-menu ( -- )
    "actions" get <menu> show-menu ;

: init-actions ( gadget -- )
    [ "actions" get actions-menu ] button-gestures ;

: <styled-label> ( style text -- label )
    <label> "actions" pick assoc [ dup init-actions ] when
    swap alist>hash over set-gadget-paint ;
