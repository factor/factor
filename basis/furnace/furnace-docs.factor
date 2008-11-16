USING: assocs help.markup help.syntax kernel
quotations sequences strings urls xml.data http ;
IN: furnace

HELP: adjust-redirect-url
{ $values { "url" url } { "url'" url } }
{ $description "Adjusts a redirection URL by filtering the URL's query parameters through the " { $link modify-redirect-query } " generic word on every responder involved in handling the current request." } ;

HELP: adjust-url
{ $values { "url" url } { "url'" url } }
{ $description "Adjusts a link URL by filtering the URL's query parameters through the " { $link modify-query } " generic word on every responder involved in handling the current request." } ;

HELP: client-state
{ $values { "key" string } { "value/f" { $maybe string } } }
{ $description "Looks up a cookie (if the current request is a GET or HEAD request) or a POST parameter (if the current request is a POST request)." }
{ $notes "This word is used by session management, conversation scope and asides." } ;

HELP: each-responder
{ $values { "quot" { $quotation "( responder -- )" } } }
{ $description "Applies the quotation to each responder involved in processing the current request." } ;

HELP: hidden-form-field
{ $values { "value" string } { "name" string } }
{ $description "Renders an HTML hidden form field tag." }
{ $notes "This word is used by session management, conversation scope and asides." }
{ $examples
    { $example
        "USING: furnace io ;"
        "\"bar\" \"foo\" hidden-form-field nl"
        "<input type='hidden' name='foo' value='bar'/>"
    }
} ;

HELP: link-attr
{ $values { "tag" tag } { "responder" "a responder" } }
{ $contract "Modifies an XHTML " { $snippet "a" } " tag." }
{ $notes "This word is called by " { $link "html.templates.chloe.tags.form" } "." }
{ $examples "Conversation scope adds attributes to link tags." } ;

HELP: modify-form
{ $values { "responder" "a responder" } }
{ $contract "Emits hidden form fields using " { $link hidden-form-field } "." }
{ $notes "This word is called by " { $link "html.templates.chloe.tags.form" } "." }
{ $examples "Session management, conversation scope and asides use hidden form fields to pass state." } ;

HELP: modify-query
{ $values { "query" assoc } { "responder" "a responder" } { "query'" assoc } }
{ $contract "Modifies the query parameters of a URL destined to be displayed as a link." }
{ $notes "This word is called by " { $link "html.templates.chloe.tags.form" } "." }
{ $examples "Asides add query parameters to URLs." } ;

HELP: modify-redirect-query
{ $values { "query" assoc } { "responder" "a responder" } { "query'" assoc } }
{ $contract "Modifies the query parameters of a URL destined to be used with a redirect." }
{ $notes "This word is called by " { $link "furnace.redirection" } "." }
{ $examples "Conversation scope and asides add query parameters to redirect URLs." } ;

HELP: nested-responders
{ $values { "seq" "a sequence of responders" } }
{ $description "" } ;

HELP: referrer
{ $values { "referrer/f" { $maybe string } } }
{ $description "Outputs the current request's referrer URL." } ;

HELP: request-params
{ $values { "request" request } { "assoc" assoc } }
{ $description "Outputs the query parameters (if the current request is a GET or HEAD request) or the POST parameters (if the current request is a POST request)." } ;

HELP: resolve-base-path
{ $values { "string" string } { "string'" string } }
{ $description "" } ;

HELP: resolve-template-path
{ $values { "pair" "a pair with shape " { $snippet "{ class string }" } } { "path" "a pathname string" } }
{ $description "" } ;

HELP: same-host?
{ $values { "url" url } { "?" "a boolean" } }
{ $description "Tests if the given URL is located on the same host as the URL of the current request." } ;

HELP: user-agent
{ $values { "user-agent" { $maybe string } } }
{ $description "Outputs the user agent reported by the client for the current request." } ;

HELP: vocab-path
{ $values { "vocab" "a vocabulary specifier" } { "path" "a pathname string" } }
{ $description "" } ;

HELP: exit-with
{ $values { "value" object } }
{ $description "Exits from an outer " { $link with-exit-continuation } "." } ;

HELP: with-exit-continuation
{ $values { "quot" { $quotation { "( -- value )" } } } { "value" "a value returned by the quotation or an " { $link exit-with } " invocation" } }
{ $description "Runs a quotation with the " { $link exit-continuation } " variable bound. Calling " { $link exit-with } " in the quotation will immediately return." }
{ $notes "Furnace actions and authentication realms wrap their execution in this combinator, allowing form validation failures and login requests, respectively, to immediately return an HTTP response to the client without running any more responder code." } ;

ARTICLE: "furnace.extension-points" "Furnace extension points"
"Furnace features such as session management, conversation scope and asides need to modify URLs in links and redirects, and insert hidden form fields, to implement state on top of the setateless HTTP protocol. In order to decouple the server-side state management code from the HTML templating code, a series of hooks are used."
$nl
"Responders can implement methods on the following generic words:"
{ $subsection modify-query }
{ $subsection modify-redirect-query }
{ $subsection link-attr }
{ $subsection modify-form }
"Presentation-level code can call the following words:"
{ $subsection adjust-url }
{ $subsection adjust-redirect-url } ;

ARTICLE: "furnace.misc" "Miscellaneous Furnace features"
"Inspecting the chain of responders handling the current request:"
{ $subsection nested-responders }
{ $subsection each-responder }
{ $subsection resolve-base-path }
"Vocabulary root-relative resources:"
{ $subsection vocab-path }
{ $subsection resolve-template-path }
"Early return from a responder:"
{ $subsection with-exit-continuation }
{ $subsection exit-with }
"Other useful words:"
{ $subsection hidden-form-field }
{ $subsection request-params }
{ $subsection client-state }
{ $subsection user-agent } ;

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
