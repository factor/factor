! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: hashtables io kernel lists namespaces parser prettyprint
sequences ;

DEFER: pane-eval

: actions-menu ( pane actions -- menu )
    [ uncons rot [ pane-eval ] cons cons cons ] map-with <menu> ;

: init-actions ( gadget pane -- )
    over "actions" paint-prop dup [
        actions-menu [ show-menu ] cons button-gestures
    ] [
        3drop
    ] ifte ;

: <styled-label> ( style text -- label )
    <label> swap alist>hash over set-gadget-paint ;

: <presentation> ( style text pane -- presentation )
    >r <styled-label> dup r> init-actions ;
