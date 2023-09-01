! Copyright (C) 2009 Eduardo Cavazos
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax multiline ;
IN: ui.gadgets.slate

ARTICLE: "ui.gadgets.slate" "Slate gadget"
{ $description "A gadget with an 'action' slot which should be set to a callable."}
{ $heading "Example" }
{ $code <" USING: processing.shapes ui.gadgets.slate ui.gadgets.panes ;
[ { { 10 10 } { 50 30 } { 10 50 } } polygon fill-mode ] <slate>
gadget."> } ;

ABOUT: "ui.gadgets.slate"
