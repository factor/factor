USING: help.markup help.syntax ;
IN: cocoa.dialogs

HELP: <NSOpenPanel>
{ $values { "panel" "an " { $snippet "NSOpenPanel" } } }
{ $description "Creates a new " { $snippet "NSOpenPanel" } "." } ;

HELP: <NSSavePanel>
{ $values { "panel" "an " { $snippet "NSSavePanel" } } }
{ $description "Creates a new " { $snippet "NSSavePanel" } "." } ;

HELP: open-panel
{ $values { "paths" "a sequence of pathname strings" } }
{ $description "Displays a file open panel, and outputs a sequence of selected pathnames." } ;

HELP: save-panel
{ $values { "path" "a pathname string" } { "path/f" { $maybe "a pathname string" } } }
{ $description "Displays a file save panel, and outputs the selected path, or " { $link f } " if the user cancelled the operation." } ;

ARTICLE: "cocoa-dialogs" "Cocoa file dialogs"
"Open dialogs:"
{ $subsections
    <NSOpenPanel>
    open-panel
}
"Save dialogs:"
{ $subsections
    <NSSavePanel>
    save-panel
} ;

ABOUT: "cocoa-dialogs"
