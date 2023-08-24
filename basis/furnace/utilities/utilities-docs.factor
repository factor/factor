USING: assocs help.markup help.syntax kernel strings urls words
xml.data ;
IN: furnace.utilities

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
{ $values { "quot" { $quotation ( ... responder -- ... ) } } }
{ $description "Applies the quotation to each responder involved in processing the current request." } ;

HELP: hidden-form-field
{ $values { "value" string } { "name" string } { "xml" "an XML chunk" } }
{ $description "Renders an HTML hidden form field tag as XML." }
{ $notes "This word is used by session management, conversation scope and asides." }
{ $examples
    { $example
        "USING: furnace.utilities io xml.writer ;"
        "\"bar\" \"foo\" hidden-form-field write-xml nl"
        "<input type=\"hidden\" value=\"bar\" name=\"foo\"/>"
    }
} ;

HELP: link-attr
{ $values { "tag" tag } { "responder" "a responder" } }
{ $contract "Modifies an XHTML " { $snippet "a" } " tag." }
{ $notes "This word is called by " { $vocab-link "html.templates.chloe" } "." }
{ $examples "Conversation scope adds attributes to link tags." } ;

HELP: modify-form
{ $values { "responder" "a responder" } { "xml/f" "an XML chunk or f" } }
{ $contract "Emits hidden form fields using " { $link hidden-form-field } "." }
{ $notes "This word is called by " { $vocab-link "html.templates.chloe" } "." }
{ $examples "Session management, conversation scope and asides use hidden form fields to pass state." } ;

HELP: modify-query
{ $values { "query" assoc } { "responder" "a responder" } { "query'" assoc } }
{ $contract "Modifies the query parameters of a URL destined to be displayed as a link." }
{ $notes "This word is called by " { $vocab-link "html.templates.chloe" } "." }
{ $examples "Asides add query parameters to URLs." } ;

HELP: modify-redirect-query
{ $values { "query" assoc } { "responder" "a responder" } { "query'" assoc } }
{ $contract "Modifies the query parameters of a URL destined to be used with a redirect." }
{ $notes "This word is called by " { $link "furnace.redirection" } "." }
{ $examples "Conversation scope and asides add query parameters to redirect URLs." } ;

HELP: nested-responders
{ $values { "seq" "a sequence of responders" } }
{ $description "Outputs a sequence of responders which participated in the processing of the current request, with the main responder first and the innermost responder last." } ;

HELP: referrer
{ $values { "referrer/f" { $maybe string } } }
{ $description "Outputs the current request's referrer URL." } ;

HELP: resolve-base-path
{ $values { "string" string } { "string'" string } }
{ $description "Resolves a responder-relative URL." } ;

HELP: resolve-template-path
{ $values { "pair" "a pair with shape " { $snippet "{ class string }" } } { "path" "a pathname string" } }
{ $description "Resolves a responder-relative template path." } ;

HELP: same-host?
{ $values { "url" url } { "?" boolean } }
{ $description "Tests if the given URL is located on the same host as the URL of the current request." } ;

HELP: user-agent
{ $values { "user-agent" { $maybe string } } }
{ $description "Outputs the user agent reported by the client for the current request." } ;

HELP: resolve-word-path
{ $values { "word" word } { "path/f" { $maybe "a pathname string" } } }
{ $description "Outputs the full pathname of the word's vocabulary's directory." } ;

HELP: exit-with
{ $values { "value" object } }
{ $description "Exits from an outer " { $link with-exit-continuation } "." } ;

HELP: with-exit-continuation
{ $values { "quot" { $quotation ( -- value ) } } { "value" "a value returned by the quotation or an " { $link exit-with } " invocation" } }
{ $description "Runs a quotation with the " { $link exit-continuation } " variable bound. Calling " { $link exit-with } " in the quotation will immediately return." }
{ $notes "Furnace actions and authentication realms wrap their execution in this combinator, allowing form validation failures and login requests, respectively, to immediately return an HTTP response to the client without running any more responder code." } ;

ARTICLE: "furnace.extension-points" "Furnace extension points"
"Furnace features such as session management, conversation scope and asides need to modify URLs in links and redirects, and insert hidden form fields, to implement state on top of the stateless HTTP protocol. In order to decouple the server-side state management code from the HTML templating code, a series of hooks are used."
$nl
"Responders can implement methods on the following generic words:"
{ $subsections
    modify-query
    modify-redirect-query
    link-attr
    modify-form
}
"Presentation-level code can call the following words:"
{ $subsections
    adjust-url
    adjust-redirect-url
} ;

ARTICLE: "furnace.misc" "Miscellaneous Furnace features"
"Inspecting the chain of responders handling the current request:"
{ $subsections
    nested-responders
    each-responder
    resolve-base-path
}
"Vocabulary root-relative resources:"
{ $subsections
    resolve-word-path
    resolve-template-path
}
"Early return from a responder:"
{ $subsections
    with-exit-continuation
    exit-with
}
"Other useful words:"
{ $subsections
    hidden-form-field
    client-state
    user-agent
} ;
