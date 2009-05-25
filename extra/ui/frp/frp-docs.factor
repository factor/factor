USING: help.syntax help.markup ;
IN: ui.frp
ARTICLE: { "ui.frp" "index" } "Functional Reactive Programming"
"The " { $vocab-link "ui.frp" } " vocabulary is a take on functional reactive programming for user interfaces. The library is implimented as a set of models collectively called signals, and is made up of multiple submodles, all of which can be imported collectively from ui.frp" $nl
{ $vocab-subsection "Using signals:" "ui.frp.signals" }
{ $vocab-subsection "Creating user interfaces:" "ui.frp.layout" }
{ $vocab-subsection "Using gadgets:" "ui.frp.gadgets" }
{ $vocab-subsection "Combining signals:" "ui.frp.functors" }
{ $vocab-subsection "Typeclass instances:" "ui.frp.instances" }
"To get the hang of using the library, check out " { $vocab-link "darcs-ui-demo" } $nl
"For more information about frp, go to http://haskell.org/haskellwiki/Functional_Reactive_Programming"
;
ABOUT: { "ui.frp" "index" }