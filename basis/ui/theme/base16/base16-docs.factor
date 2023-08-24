USING: help.markup help.syntax ui.theme ;
IN: ui.theme.base16

HELP: base16-theme
{ $description "Apply a base16 theme." }
{ $examples
    "First set which base16 theme to " { $link base16-theme-name } ":"
    { $code "USING: ui.theme.base16 namespaces ;" "\"monokai\" base16-theme-name set" }
    "Then switch to the base16 theme:"
    { $code "USING: ui.theme.switching ui.theme.base16 ;" "base16-theme switch-theme" }
    "This can also be changed while running the listener :"
    { $code "USING: ui.theme.base16 namespaces ui.theme.switching.private ;"
            "\"embers\" base16-theme-name set update-stylesheet listener-window" }
    "To persist for that session you can set-global."
    "The following variations are implemented:"
    { $list        "3024"
                   "apathy"
                   "ashes"
                   "atelierdune"
                   "atelierforest"
                   "atelierheath"
                   "atelierlakeside"
                   "atelierseaside"
                   "bespin"
                   "brewer"
                   "bright"
                   "chalk"
                   "codeschool"
                   "colors"
                   "default"
                   "eighties"
                   "embers"
                   "flat"
                   "google"
                   "grayscale"
                   "greenscreen"
                   "harmonic16"
                   "isotope"
                   "londontube"
                   "marrakesh"
                   "mocha"
                   "monokai"
                   "ocean"
                   "paraiso"
                   "pop"
                   "railscasts"
                   "shapeshifter"
                   "solarized"
                   "summerfruit"
                   "tomorrow"
                   "twilight" }
} ;
