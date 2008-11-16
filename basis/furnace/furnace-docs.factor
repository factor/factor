USING: assocs help.markup help.syntax kernel
quotations sequences strings urls ;
IN: furnace

HELP: adjust-redirect-url
{ $values
     { "url" url }
     { "url'" url }
}
{ $description "" } ;

HELP: adjust-url
{ $values
     { "url" url }
     { "url'" url }
}
{ $description "" } ;

HELP: base-path
{ $values
     { "string" string }
     { "pair" null }
}
{ $description "" } ;

HELP: client-state
{ $values
     { "key" null }
     { "value/f" null }
}
{ $description "" } ;

HELP: cookie-client-state
{ $values
     { "key" null } { "request" null }
     { "value/f" null }
}
{ $description "" } ;

HELP: each-responder
{ $values
     { "quot" quotation }
}
{ $description "" } ;

HELP: exit-continuation
{ $description "" } ;

HELP: exit-with
{ $values
     { "value" null }
}
{ $description "" } ;

HELP: hidden-form-field
{ $values
     { "value" null } { "name" null }
}
{ $description "" } ;

HELP: link-attr
{ $values
     { "tag" null } { "responder" null }
}
{ $description "" } ;

HELP: modify-form
{ $values
     { "responder" null }
}
{ $description "" } ;

HELP: modify-query
{ $values
     { "query" null } { "responder" null }
     { "query'" null }
}
{ $description "" } ;

HELP: modify-redirect-query
{ $values
     { "query" null } { "responder" null }
     { "query'" null }
}
{ $description "" } ;

HELP: nested-forms-key
{ $description "" } ;

HELP: nested-responders
{ $values
    
     { "seq" sequence }
}
{ $description "" } ;

HELP: post-client-state
{ $values
     { "key" null } { "request" null }
     { "value/f" null }
}
{ $description "" } ;

HELP: referrer
{ $values
    
     { "referrer/f" null }
}
{ $description "" } ;

HELP: request-params
{ $values
     { "request" null }
     { "assoc" assoc }
}
{ $description "" } ;

HELP: resolve-base-path
{ $values
     { "string" string }
     { "string'" string }
}
{ $description "" } ;

HELP: resolve-template-path
{ $values
     { "pair" null }
     { "path" "a pathname string" }
}
{ $description "" } ;

HELP: same-host?
{ $values
     { "url" url }
     { "?" "a boolean" }
}
{ $description "" } ;

HELP: user-agent
{ $values
    
     { "user-agent" null }
}
{ $description "" } ;

HELP: vocab-path
{ $values
     { "vocab" "a vocabulary specifier" }
     { "path" "a pathname string" }
}
{ $description "" } ;

HELP: with-exit-continuation
{ $values
     { "quot" quotation }
}
{ $description "" } ;

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
"Related frameworks:"
{ $subsection "db" }
{ $subsection "xml" }
{ $subsection "http.server" }
{ $subsection "logging" }
{ $subsection "urls" } ;

ABOUT: "furnace"
