! (c)2009 Joe Groff bsd license
USING: help.markup help.syntax kernel words ;
IN: deprecation

HELP: :deprecations
{ $description "Prints all deprecation notes." } ;

ARTICLE: "deprecation" "Deprecation tracking"
"Factor's core syntax defines a " { $link POSTPONE: deprecated } " word that can be applied to words to mark them as deprecated. When the " { $vocab-link "deprecation" } " vocabulary is loaded, notes will be collected and reported by the " { $link "tools.errors" } " mechanism when deprecated words are used to define other words."
{ $subsection POSTPONE: deprecated }
{ $subsection :deprecations } ;

ABOUT: "deprecation"
