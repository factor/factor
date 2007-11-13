USING: ui.gadgets models help.markup help.syntax io kernel
quotations ;
IN: ui.gadgets.panes

HELP: pane
{ $class-description "A pane " { $link gadget } " displays formatted text which is written to a " { $link pane-stream } " targetting the pane. Panes are created by calling " { $link <pane> } ", " { $link <scrolling-pane> } " or " { $link <pane-control> } "." } ;

HELP: <pane>
{ $values { "pane" "a new " { $link pane } } }
{ $description "Creates a new " { $link pane } " gadget." } ;

HELP: write-gadget
{ $values { "gadget" gadget } { "stream" "an output stream" } }
{ $contract "Writes a gadget to the stream." }
{ $notes "Not all streams support this operation." } ;

{ write-gadget print-gadget gadget. } related-words

HELP: print-gadget
{ $values { "gadget" gadget } { "stream" "an output stream" } }
{ $description "Writes a gadget to the stream, followed by a newline." }
{ $notes "Not all streams support this operation." } ;

HELP: gadget.
{ $values { "gadget" gadget } }
{ $description "Writes a gadget followed by a newline to the " { $link stdio } " stream." }
{ $notes "Not all streams support this operation." } ;

HELP: ?nl
{ $values { "stream" pane-stream } }
{ $description "Inserts a line break in the pane unless the current line is empty." } ;

HELP: with-pane
{ $values { "pane" pane } { "quot" quotation } }
{ $description "Clears the pane and calls the quotation in a new scope where " { $link stdio } " is rebound to a " { $link pane-stream } " writing to the pane." } ;

HELP: make-pane
{ $values { "quot" quotation } { "gadget" "a new " { $link gadget } } }
{ $description "Calls the quotation in a new scope where " { $link stdio } " is rebound to a " { $link pane-stream } " writing to a new pane. The output area of the new pane is output on the stack after the quotation returns. The pane itself is not output." } ;

HELP: <scrolling-pane>
{ $values { "pane" "a new " { $link pane } } }
{ $description "Creates a new " { $link pane } " gadget which scrolls any scroll pane containing it to the bottom on output. behaving much like a terminal or logger." } ;

HELP: <pane-control>
{ $values { "model" model } { "quot" "a quotation with stack effect " { $snippet "( value -- )" } } { "pane" "a new " { $link pane } } }
{ $description "Creates a new " { $link control } " delegating to a " { $link pane } ". When the value of the model changes, the value is pushed on the stack and the quotation is called using " { $link with-pane } "." } ;

HELP: pane-stream
{ $class-description "Pane streams implement the portion of the " { $link "stream-protocol" } " responsible for output of text, including full support for " { $link "styles" } ". Pane streams also support direct output of gadgets via " { $link write-gadget } " and " { $link print-gadget } ". Pane streams are created by calling " { $link <pane-stream> } "." } ;

HELP: <pane-stream> ( pane -- stream )
{ $values { "pane" pane } { "stream" "a new " { $link pane-stream } } }
{ $description "Creates a new " { $link pane-stream } " for writing to " { $snippet "pane" } "." } ;

{ with-pane make-pane } related-words

ARTICLE: "ui.gadgets.panes" "Pane gadgets"
"A pane displays formatted text."
{ $subsection pane }
{ $subsection <pane> }
{ $subsection <scrolling-pane> }
{ $subsection <pane-control> }
"Panes are written to by creating a special output stream:"
{ $subsection pane-stream }
{ $subsection <pane-stream> }
"In addition to the stream output words (" { $link "stream-protocol" } ", pane streams can have gadgets written to them:"
{ $subsection write-gadget }
{ $subsection print-gadget }
{ $subsection gadget. }
"The " { $link gadget. } " word is useful for interactive debugging of gadgets in the listener."
$nl
"There are a few combinators for working with panes:"
{ $subsection with-pane }
{ $subsection make-pane } ;

ABOUT: "ui.gadgets.panes"
