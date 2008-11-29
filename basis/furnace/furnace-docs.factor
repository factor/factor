USING: assocs help.markup help.syntax kernel
quotations sequences strings urls xml.data http ;
IN: furnace

ARTICLE: "furnace.persistence" "Furnace persistence layer"
{ $subsection "furnace.db" }
"Server-side state:"
{ $subsection "furnace.sessions" }
{ $subsection "furnace.conversations" }
{ $subsection "furnace.asides" }
{ $subsection "furnace.presentation" } ;

ARTICLE: "furnace.presentation" "Furnace presentation layer"
"HTML components:"
{ $subsection "html.components" }
{ $subsection "html.forms" }
"Content templates:"
{ $subsection "html.templates" }
{ $subsection "html.templates.chloe" }
{ $subsection "html.templates.fhtml" }
{ $subsection "furnace.boilerplate" }
"Other types of content:"
{ $subsection "furnace.syndication" }
{ $subsection "furnace.json" } ;

ARTICLE: "furnace.load-balancing" "Load balancing and fail-over with Furnace"
"The Furnace session manager persists sessions to a database. This means that HTTP requests can be transparently distributed between multiple Factor HTTP server instances, running the same web app on top of the same database, as long as the web applications do not use mutable global state, such as global variables. The Furnace framework itself does not use any mutable global state." ;

ARTICLE: "furnace" "Furnace framework"
"The " { $vocab-link "furnace" } " vocabulary implements a full-featured web framework on top of the " { $link "http.server" } ". Some of its features include:"
{ $list
    "Session management capable of load-balancing and fail-over"
    "Form components and validation"
    "Authentication system with basic authentication or login pages, and pluggable authentication backends"
    "Easy Atom feed syndication"
    "Conversation scope and asides for complex page flow"
}
"Major functionality:"
{ $subsection "furnace.actions" }
{ $subsection "furnace.alloy" }
{ $subsection "furnace.persistence" }
{ $subsection "furnace.presentation" }
{ $subsection "furnace.auth" }
{ $subsection "furnace.load-balancing" }
"Utilities:"
{ $subsection "furnace.referrer" }
{ $subsection "furnace.redirection" }
{ $subsection "furnace.extension-points" }
{ $subsection "furnace.misc" }
"Related frameworks:"
{ $subsection "db" }
{ $subsection "xml" }
{ $subsection "http.server" }
{ $subsection "logging" }
{ $subsection "urls" } ;

ABOUT: "furnace"
