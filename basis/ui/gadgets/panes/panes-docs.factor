USING: help.markup help.syntax io kernel models quotations ui.gadgets
ui.gadgets.panes.private ;
IN: ui.gadgets.panes

HELP: pane
{ $class-description "A pane " { $link gadget } " displays formatted text which is written to a " { $link pane-stream } " targeting the pane. Panes are created by calling " { $link <pane> } " or " { $link <pane-control> } ". Panes have the following slots"
  { $table
    {
        { $slot "input" }
        { "A gadget that receives input events and writes to the pane's input stream." }
    }
  }
} ;

HELP: <pane>
{ $values { "pane" "a new " { $link pane } } }
{ $description "Creates a new " { $link pane } " gadget." } ;

HELP: write-gadget
{ $values { "gadget" gadget } { "stream" "an output stream" } }
{ $contract "Writes a gadget to the stream." }
{ $notes "Not all streams support this operation." } ;

{ write-gadget print-gadget gadget. } related-words

HELP: pane-nl
{ $values { "pane" pane } }
{ $description "Outputs a virtual newline character to the pane stream." }
{ $see-also nl } ;

HELP: print-gadget
{ $values { "gadget" gadget } { "stream" "an output stream" } }
{ $description "Writes a gadget to the stream, followed by a newline." }
{ $notes "Not all streams support this operation." } ;

HELP: gadget.
{ $values { "gadget" gadget } }
{ $description "Writes a gadget followed by a newline to " { $link output-stream } "." }
{ $notes "Not all streams support this operation." } ;

HELP: with-pane
{ $values { "pane" pane } { "quot" quotation } }
{ $description "Clears the pane and calls the quotation in a new scope where " { $link output-stream } " is rebound to a " { $link pane-stream } " writing to the pane." } ;

HELP: make-pane
{ $values { "quot" quotation } { "gadget" "a new " { $link gadget } } }
{ $description "Calls the quotation in a new scope where " { $link output-stream } " is rebound to a " { $link pane-stream } " writing to a new pane. The output area of the new pane is output on the stack after the quotation returns. The pane itself is not output." } ;

HELP: <pane-control>
{ $values { "model" model } { "quot" { $quotation ( value -- ) } } { "pane" "a new " { $link pane } } }
{ $description "Creates a new control delegating to a " { $link pane } ". When the value of the model changes, the value is pushed on the stack and the quotation is called using " { $link with-pane } "." } ;

HELP: pane-stream
{ $class-description "Pane streams implement the portion of the " { $link "stream-protocol" } " responsible for output of text, including full support for " { $link "styles" } ". Pane streams also support direct output of gadgets via " { $link write-gadget } " and " { $link print-gadget } ". Pane streams are created by calling " { $link <pane-stream> } "." } ;

HELP: <pane-stream>
{ $values { "pane" pane } { "pane-stream" "a new " { $link pane-stream } } }
{ $description "Creates a new " { $link pane-stream } " for writing to " { $snippet "pane" } "." } ;

{ with-pane make-pane } related-words

HELP: content-gadget
{ $values { "object" object } { "gadget/f" { $maybe gadget } } }
{ $description "This generic function may be implemented for objects in order to display a rich representation of the object in the " { $link "ui-inspector" } ". If " { $snippet "content-gadget" } " returns a gadget for an inspected object, the returned gadget is displayed under the \"Content\" heading in the inspector window. If " { $snippet "content-gadget" } " returns " { $link POSTPONE: f } ", no content section is included in the given object's inspector." } ;

ARTICLE: "ui.gadgets.panes" "Pane gadgets"
"The " { $vocab-link "ui.gadgets.panes" } " vocabulary implements panes, which display formatted text."
{ $subsections
    pane
    <pane>
    <pane-control>
}
"Panes are written to by creating a special output stream:"
{ $subsections
    pane-stream
    <pane-stream>
}
"In addition to the stream output words (" { $link "stream-protocol" } "), pane streams can have gadgets written to them:"
{ $subsections
    write-gadget
    print-gadget
    gadget.
}
"The " { $link gadget. } " word is useful for interactive debugging of gadgets in the listener."
$nl
"There are a few combinators for working with panes:"
{ $subsections
    with-pane
    make-pane
} ;

ABOUT: "ui.gadgets.panes"
