USING: help.markup help.syntax ui.theme ;
IN: ui.theme.switching

HELP: switch-theme
{ $values { "theme" "theme" } }
{ $description "Switch to a new theme." }
{ $examples
    "To switch to a " { $link light-theme } ":"
    { $code "USING: ui.theme ui.theme.switching ;" "light-theme switch-theme" }
    "To switch to a " { $link dark-theme } ":"
    { $code "USING: ui.theme ui.theme.switching ;" "dark-theme switch-theme" }
} ;
