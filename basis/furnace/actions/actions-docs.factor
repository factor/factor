USING: classes furnace.redirection help.markup help.syntax
html.forms http http.server.dispatchers http.server.responses ;
IN: furnace.actions

HELP: <action>
{ $values { "action" action } }
{ $description "Creates a new action." } ;

HELP: <chloe-content>
{ $values
    { "path" "a path" }
    { "response" response }
}
{ $description "Creates an HTTP response which serves a Chloe template. See " { $link "html.templates.chloe" } "." } ;

HELP: <page-action>
{ $values { "page" action } }
{ $description "Creates a new action which serves a Chloe template when servicing a GET request." } ;

HELP: action
{ $class-description "The class of Furnace actions. New instances are created with " { $link <action> } ". New instances of subclasses can be created with " { $link new-action } ". The " { $link page-action } " class is a useful subclass."
$nl
"Action slots are documented in " { $link "furnace.actions.config" } "." } ;

HELP: new-action
{ $values
    { "class" class }
    { "action" action }
}
{ $description "Constructs a subclass of " { $link action } "." } ;

HELP: page-action
{ $class-description "The class of Chloe page actions. These are actions whose " { $slot "display" } " slot is pre-set to serve the Chloe template stored in the " { $slot "template" } " slot. The " { $slot "template" } " slot contains a pair with shape " { $snippet "{ responder name }" } "." } ;

HELP: validate-integer-id
{ $description "A utility word which validates an integer parameter named " { $snippet "id" } "." }
{ $examples
    { $code
        "<action>"
        "    ["
        "        validate-integer-id"
        "        \"id\" value <person> select-tuple from-object"
        "    ] >>init"
    }
} ;

HELP: validate-params
{ $values
    { "validators" "an association list mapping parameter names to validator quotations" }
}
{ $description "Validates query or POST parameters, depending on the request type, and stores them in " { $link "html.forms.values" } ". The validator quotations can execute " { $link "validators" } "." }
{ $examples
    "A simple validator from " { $vocab-link "webapps.todo" } "; this word is invoked from the " { $slot "validate" } " quotation of action for editing a todo list item:"
    { $code
        ": validate-todo ( -- )
    {
        { \"summary\" [ v-one-line ] }
        { \"priority\" [ v-integer 0 v-min-value 10 v-max-value ] }
        { \"description\" [ v-required ] }
    } validate-params ;"
    }
} ;

{ validate-params validate-values } related-words

HELP: validation-failed
{ $description "Stops processing the current request and takes action depending on the type of the current request:"
    { $list
        { "For GET or HEAD requests, the client receives a " { $link <400> } " response." }
        { "For POST requests, the client is sent back to the page containing the form submission, with current form values and validation errors passed in a " { $link "furnace.conversations" } "." }
    }
"This word is called by " { $link validate-params } " and can also be called directly. For more details, see " { $link "furnace.actions.lifecycle" } "." } ;

ARTICLE: "furnace.actions.page.example" "Furnace page action example"
"The " { $vocab-link "webapps.counter" } " vocabulary defines a subclass of " { $link dispatcher } ":"
{ $code "TUPLE: counter-app < dispatcher ;" }
"The " { $snippet "<counter-app>" } " constructor word creates a new instance of the " { $snippet "counter-app" } " class, and adds a " { $link page-action } " instance to the dispatcher. This " { $link page-action } " has its " { $slot "template" } " slot set as follows,"
{ $code "{ counter-app \"counter\" } >>template" }
"This means the action will serve the Chloe template located at " { $snippet "resource:extra/webapps/counter/counter.xml" } " upon receiving a GET request." ;

ARTICLE: "furnace.actions.page" "Furnace page actions"
"Page actions implement the common case of an action that simply serves a Chloe template in response to a GET request."
{ $subsections
    page-action
    <page-action>
}
"When using a page action, instead of setting the " { $slot "display" } " slot, the " { $slot "template" } " slot is set instead. The " { $slot "init" } ", " { $slot "authorize" } ", " { $slot "validate" } " and " { $slot "submit" } " slots can still be set as usual."
$nl
"The " { $slot "template" } " slot of a " { $link page-action } " contains a pair with shape " { $snippet "{ responder name }" } ", where " { $snippet "responder" } " is a responder class, usually a subclass of " { $link dispatcher } ", and " { $snippet "name" } " is the name of a template file, without the " { $snippet ".xml" } " extension, relative to the directory containing the responder's vocabulary source file."
{ $subsections "furnace.actions.page.example" } ;

ARTICLE: "furnace.actions.config" "Furnace action configuration"
"Actions have the following slots:"
{ $slots
    { "rest" { "A parameter name to map the rest of the URL, after the action name, to. If this is not set, then navigating to a URL where the action is not the last path component will return to the client with an error. A more general facility can be found in the " { $vocab-link "http.server.rewrite" } " vocabulary." } }
    { "init" { "A quotation called at the beginning of a GET, HEAD or DELETE request. Typically this quotation configures " { $link "html.forms" } " and parses query parameters." } }
    { "authorize" { "A quotation called at the beginning of all implemented requests. In GET, HEAD and DELETE requests, it is called after the " { $slot "init" } " quotation; in PATCH, POST and PUT requests, it is called after the " { $slot "validate" } " quotation. By convention, this quotation performs custom authorization checks which depend on query parameters or POST parameters." } }
    { "display" { "A quotation called after the " { $slot "init" } " quotation in a GET request. This quotation must return an HTTP " { $link response } "." } }
    { "validate" { "A quotation called at the beginning of a POST request to validate POST parameters." } }
    { "submit" { "A quotation called after the " { $slot "validate" } " quotation in a POST request. This quotation must return an HTTP " { $link response } "." } }
    { "replace" { "A quotation called after the " { $slot "validate" } " quotation in a PUT request. This quotation must return an HTTP " { $link response } "." } }
    { "update" { "A quotation called after the " { $slot "validate" } " quotation in a PATCH request. This quotation must return an HTTP " { $link response } "." } }
    { "delete" { "A quotation called after the " { $slot "init" } " quotation in a DELETE request. This quotation must return an HTTP " { $link response } "." } }
}
"At least one of the " { $slot "display" } " and " { $slot "submit" } " slots must be set, otherwise the action will be useless." ;

ARTICLE: "furnace.actions.validation" "Form validation with actions"
"The action code is set up so that the " { $slot "init" } " quotation can validate query parameters, and the " { $slot "validate" } " quotation can validate POST parameters."
$nl
"A word to validate parameters and make them available as HTML form values (see " { $link "html.forms.values" } "); typically this word is invoked from the " { $slot "init" } " and " { $slot "validate" } " quotations:"
{ $subsections validate-params }
"The above word expects an association list mapping parameter names to validator quotations; validator quotations can use the words in the "
"Custom validation logic can invoke a word when validation fails; " { $link validate-params } " invokes this word for you:"
{ $subsections validation-failed }
"If validation fails, no more action code is executed, and the client is redirected back to the originating page, where validation errors can be displayed. Note that validation errors are rendered automatically by the " { $link "html.components" } " words, and in particular, " { $link "html.templates.chloe" } " use these words." ;

ARTICLE: "furnace.actions.lifecycle" "Furnace action lifecycle"
{ $heading "GET request lifecycle" }
"A GET request results in the following sequence of events:"
{ $list
    { "The " { $snippet "init" } " quotation is called." }
    { "The " { $snippet "authorize" } " quotation is called." }
    { "If the GET request was generated as a result of form validation failing during a POST, then the form values entered by the user, along with validation errors, are stored in " { $link "html.forms.values" } "." }
    { "The " { $snippet "display" } " quotation is called; it is expected to output an HTTP " { $link response } " on the stack." }
}
"Any one of the above steps can perform validation; if " { $link validation-failed } " is called during a GET request, the client receives a " { $link <400> } " error."
{ $heading "HEAD request lifecycle" }
"A HEAD request proceeds exactly like a GET request. The only difference is that the " { $slot "body" } " slot of the " { $link response } " object is never rendered."

{ $heading "DELETE request lifecycle" }
"A DELETE request is supposed to act on a whole resources, i.e. a URL sans query parameters. "
"Nevertheless, " { $vocab-link "http.server" } " accepts query parameters that may be used for authorization. "
"A DELETE request results in the following sequence of events:"
{ $list
    { "The " { $snippet "init" } " quotation is called." }
    { "The " { $snippet "authorize" } " quotation is called." }
    { "The " { $snippet "delete" } " quotation is called; it is expected to output an HTTP " { $link response } " on the stack. "
      "By convention, this response should be either a " { $link <redirect> } " (which generates a " { $link <303> } " response) or, "
      "when successful, one of " { $link <200> } ", " { $link <202> } " or " { $link <204> } " responses."
    }
}
"Any one of the above steps can perform validation; if " { $link validation-failed } " is called during a DELETE request, "
"the client is sent back to the originating page with validation errors passed in a " { $link "furnace.conversations" } "."

{ $heading "POST request lifecycle" }
"A POST request results in the following sequence of events:"
{ $list
    { "The " { $snippet "validate" } " quotation is called." }
    { "The " { $snippet "authorize" } " quotation is called." }
    { "The " { $snippet "submit" } " quotation is called; it is expected to output an HTTP " { $link response } " on the stack. By convention, this response should be a " { $link <redirect> } "." }
}
"Any one of the above steps can perform validation; if " { $link validation-failed } " is called during a POST request, the client is sent back to the page containing the form submission, with current form values and validation errors passed in a " { $link "furnace.conversations" } "." ;

ARTICLE: "furnace.actions.impl" "Furnace actions implementation"
"The following parameterized constructor should be called from constructors for subclasses of " { $link action } ":"
{ $subsections new-action } ;

ARTICLE: "furnace.actions" "Furnace actions"
"The " { $vocab-link "furnace.actions" } " vocabulary implements a type of responder, called an " { $emphasis "action" } ", which handles the form validation lifecycle."
$nl
"Other than form validation capability, actions are also often simpler to use than implementing new responders directly, since creating a new class is not required, and the action dispatches on the request type (GET, HEAD, or POST)."
$nl
"The class of actions:"
{ $subsections action }
"Creating a new action:"
{ $subsections <action> }
"Once created, an action needs to be configured; typically the creation and configuration of an action is encapsulated into a single word:"
{ $subsections "furnace.actions.config" }
"Validating forms with actions:"
{ $subsections "furnace.actions.validation" }
"More about the form validation lifecycle:"
{ $subsections "furnace.actions.lifecycle" }
"A convenience class:"
{ $subsections "furnace.actions.page" }
"Low-level features:"
{ $subsections "furnace.actions.impl" } ;

ABOUT: "furnace.actions"
