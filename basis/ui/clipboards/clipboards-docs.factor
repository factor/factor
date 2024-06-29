USING: help.markup help.syntax kernel strings ui.gadgets
ui.gestures ;
IN: ui.clipboards

HELP: clipboard
{ $var-description "Global variable holding the system clipboard. By convention, text should only be copied to the clipboard via an explicit user action, for example by pressing " { $snippet "C+c" } "." }
{ $class-description "A mutable container for a single string implementing the " { $link "clipboard-protocol" } "." } ;

HELP: paste-clipboard
{ $values { "gadget" gadget } { "clipboard" object } }
{ $contract "Arranges for the contents of the clipboard to be inserted into the gadget at some point in the near future via a call to " { $link user-input } ". The gadget must be grafted." } ;

HELP: copy-clipboard
{ $values { "string" string } { "gadget" gadget } { "clipboard" object } }
{ $contract "Arranges for the string to be copied to the clipboard on behalf of the gadget. The gadget must be grafted." } ;

HELP: selection
{ $var-description "Global variable holding the system selection. By convention, text should be copied to the selection as soon as it is selected by the user." } ;

ARTICLE: "clipboard-protocol" "Clipboard protocol"
"Custom gadgets that wish to interact with the clipboard must use the following two generic words to read and write clipboard contents:"
{ $subsections
    paste-clipboard
    copy-clipboard
}
"UI backends can either implement the above two words in the case of an asynchronous clipboard model (for example, X11). If direct access to the clipboard is provided (Windows, macOS), the following two generic words may be implemented instead:"
{ $subsections
    clipboard-contents
    set-clipboard-contents
}
"However, gadgets should not call these words, since they will fail if only the asynchronous method of clipboard access is supported by the backend in use."
$nl
"Access to two clipboards is provided:"
{ $subsections
    clipboard
    selection
}
"These variables may contain clipboard protocol implementations which transfer data to and from the native system clipboard. However an UI backend may leave one or both of these variables in their default state, which is a trivial clipboard implementation internal to the Factor UI." ;

ABOUT: "clipboard-protocol"
