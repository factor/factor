USING: help.markup help.syntax ;
IN: furnace

ARTICLE: "furnace.persistence" "Furnace persistence layer"
{ $subsections "furnace.db" }
"Server-side state:"
{ $subsections
    "furnace.sessions"
    "furnace.conversations"
    "furnace.asides"
    "furnace.presentation"
} ;

ARTICLE: "furnace.presentation" "Furnace presentation layer"
"HTML components:"
{ $subsections
    "html.components"
    "html.forms"
}
"Content templates:"
{ $subsections
    "html.templates"
    "html.templates.chloe"
    "html.templates.fhtml"
    "furnace.boilerplate"
}
"Other types of content:"
{ $subsections
    "furnace.syndication"
    "furnace.json"
} ;

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
{ $subsections
    "furnace.actions"
    "furnace.alloy"
    "furnace.persistence"
    "furnace.presentation"
    "furnace.auth"
    "furnace.load-balancing"
}
"Utilities:"
{ $subsections
    "furnace.referrer"
    "furnace.redirection"
    "furnace.extension-points"
    "furnace.misc"
}
"Related frameworks:"
{ $subsections
    "db"
    "xml"
    "http.server"
    "logging"
    "urls"
} ;

ABOUT: "furnace"
