! (c)2009 Joe Groff bsd license
USING: help.markup help.syntax kernel words ;
IN: tools.deprecation

HELP: :deprecations
{ $description "Prints all deprecation notes." } ;

ARTICLE: "tools.deprecation" "Deprecation tracking"
"Factor's core syntax defines a " { $link POSTPONE: deprecated } " word that can be applied to words to mark them as deprecated. Notes are collected and reported by the " { $link "tools.errors" } " mechanism when deprecated words are used to define other words."
{ $subsections
    POSTPONE: deprecated
    :deprecations
} ;

ABOUT: "tools.deprecation"
