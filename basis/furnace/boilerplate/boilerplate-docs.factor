USING: help.markup help.syntax http.server.dispatchers ;
IN: furnace.boilerplate

HELP: <boilerplate>
{ $values
    { "responder" "a responder" }
    { "boilerplate" "a new boilerplate responder" }
}
{ $description "Wraps a responder in a boilerplate responder. The boilerplate responder needs to be configured before use; see " { $link "furnace.boilerplate.config" } "." } ;

HELP: boilerplate
{ $class-description "The class of boilerplate responders. Slots are documented in " { $link "furnace.boilerplate.config" } "." } ;

ARTICLE: "furnace.boilerplate.config" "Boilerplate configuration"
"The " { $link boilerplate } " tuple has two slots which can be set:"
{ $table
    { { $slot "template" } { "A pair with shape " { $snippet "{ responder name }" } ", where " { $snippet "responder" } " is a responder class, usually a subclass of " { $link dispatcher } ", and " { $snippet "name" } " is the name of a template file, without the " { $snippet ".xml" } " extension, relative to the directory containing the responder's vocabulary source file." } }
    { { $slot "init" } { "A quotation run before the boilerplate template is rendered. This quotation can set values which the template can then display." } }
} ;

ARTICLE: "furnace.boilerplate.example" "Boilerplate example"
"The " { $vocab-link "webapps.wiki" } " vocabulary uses boilerplate to add a footer and sidebar to every page. Since the footer and sidebar are themselves dynamic content, it sets the " { $slot "init" } " quotation as well as the " { $slot "template" } " slot:"
{ $code "<boilerplate>"
"    [ init-sidebars init-relative-link-prefix ] >>init"
"    { wiki \"wiki-common\" } >>template" } ;

ARTICLE: "furnace.boilerplate" "Furnace boilerplate support"
"The " { $vocab-link "furnace.boilerplate" } " vocabulary implements a facility for sharing a common header and footer between different pages on a web site. It builds on top of " { $link "html.templates.boilerplate" } "."
{ $subsections
    <boilerplate>
    "furnace.boilerplate.config"
    "furnace.boilerplate.example"
}
{ $see-also "html.templates.chloe.tags.boilerplate" } ;

ABOUT: "furnace.boilerplate"
