! Copyright (C) 2009 Eduardo Cavazos
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax multiline quotations ui.gadgets ;
IN: ui.gadgets.slate

ARTICLE: "ui.gadgets.slate" "Slate gadget"
{ $description "A " { $link gadget } " with an " { $slot "action" } " slot that should be set to a " { $link callable } "." }
{ $examples
    { $unchecked-example
        "USING: processing.shapes ui.gadgets.slate ui.gadgets.panes ;"
        "[ { { 10 10 } { 50 30 } { 10 50 } } draw-polygon fill-mode ] <slate> gadget."
        "" }
} ;

ABOUT: "ui.gadgets.slate"
