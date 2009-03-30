USING: help.markup help.syntax ui.commands ;
IN: ui.tools.browser

ARTICLE: "ui-browser" "UI browser"
"The browser is used to display Factor code, documentation, and vocabularies. The browser is opened when a word or article link presentation is clicked. It can also be opened using words:"
{ $subsection com-browse }
{ $subsection browser-window }
{ $command-map browser-gadget "toolbar" }
{ $command-map browser-gadget "scrolling" }
{ $command-map browser-gadget "navigation" }
{ $command-map browser-gadget "multi-touch" }
"Browsers are instances of " { $link browser-gadget } "." ;

ABOUT: "ui-browser"