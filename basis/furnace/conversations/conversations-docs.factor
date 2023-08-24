USING: furnace.db furnace.sessions help.markup help.syntax http
kernel urls words.symbol ;
IN: furnace.conversations

HELP: <conversations>
{ $values
    { "responder" "a responder" }
    { "responder'" "a new responder" }
}
{ $description "Creates a new " { $link conversations } " responder wrapping an existing responder." } ;

HELP: begin-conversation
{ $description "Starts a new conversation scope. Values can be stored in the conversation scope with " { $link cset } ", and the conversation can be continued with " { $link <continue-conversation> } "." } ;

HELP: end-conversation
{ $description "Ends the current conversation scope." } ;

HELP: <continue-conversation>
{ $values { "url" url } { "response" response } }
{ $description "Creates an HTTP response which redirects the client to the specified URL while continuing the conversation. Any values set in the current conversation scope will be visible to the resonder handling the URL." } ;

HELP: cget
{ $values { "key" symbol } { "value" object } }
{ $description "Outputs the value of a conversation variable." } ;

HELP: cset
{ $values { "value" object } { "key" symbol } }
{ $description "Sets the value of a conversation variable." } ;

HELP: cchange
{ $values { "key" symbol } { "quot" { $quotation ( old -- new ) } } }
{ $description "Applies the quotation to the old value of the conversation variable, and assigns the resulting value back to the variable." } ;

ARTICLE: "furnace.conversations" "Furnace conversation scope"
"The " { $vocab-link "furnace.conversations" } " vocabulary implements conversation scope, which allows data to be passed between requests on a finer level of granularity than session scope."
$nl
"Conversation scope is used by form validation to pass validation errors between requests."
$nl
"To use conversation scope, wrap your responder in an conversation responder:"
{ $subsections <conversations> }
"The conversations responder must be wrapped inside a session responder (" { $link <sessions> } "), which in turn must be wrapped inside a database persistence responder (" { $link <db-persistence> } "). The " { $vocab-link "furnace.alloy" } " vocabulary combines all of these responders into one."
$nl
"Managing conversation scopes:"
{ $subsections
    begin-conversation
    end-conversation
    <continue-conversation>
}
"Reading and writing conversation variables:"
{ $subsections
    cget
    cset
    cchange
}
"Note that conversation scope is serialized as part of the session, which means that only serializable objects can be stored there. See " { $link "furnace.sessions.serialize" } " for details." ;

ABOUT: "furnace.conversations"
