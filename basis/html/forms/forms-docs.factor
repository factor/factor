IN: html.forms
USING: help.markup help.syntax strings quotations kernel assocs ;

HELP: <form>
{ $values { "form" form } }
{ $description "Creates a new form. Usually " { $link with-form } " is used instead." } ;

HELP: form
{ $var-description "Variable holding current form. Bound by " { $link with-form } ", " { $link nest-form } " and " { $link begin-form } "." }
{ $class-description "The class of HTML forms. New instances are created by " { $link <form> } "." } ;

HELP: with-form
{ $values { "name" string } { "quot" quotation } }
{ $description "Runs the quotation in a new dynamic scope with the " { $link form } " variable rebound to the form stored in the value named " { $snippet "name" } "." } ;

HELP: nest-form
{ $values { "name" string } { "quot" quotation } }
{ $description "Runs the quotation in a new dynamic scope with the " { $link form } " variable rebound to a new form, which is subsequently stored in the value named " { $snippet "name" } "." }
{ $examples
    "The " { $vocab-link "webapps.pastebin" } " uses a form to display pastes; inside this form it nests another form for creating annotations, and fills in some default values for new annotations:"
    { $code
        "<page-action>"
        "    ["
        "        validate-integer-id"
        "        \"id\" value paste from-object"
        ""
        "        \"id\" value"
        "        \"new-annotation\" ["
        "            \"parent\" set-value"
        "            mode-names \"modes\" set-value"
        "            \"factor\" \"mode\" set-value"
        "        ] nest-form"
        "    ] >>init"
    }
} ;

HELP: begin-form
{ $description "Begins a new form." } ;

HELP: value
{ $values { "name" string } { "value" object } }
{ $description "Gets a form value. This word is used to get form field values after validation." } ;

HELP: set-value
{ $values { "value" object } { "name" string } }
{ $description "Sets a form value. This word is used to preset form field values before rendering." } ;

HELP: from-object
{ $values { "object" object } }
{ $description "Sets the current form's values to the object's slot values." }
{ $examples
    "Here is a typical action implementation, which selects a golf course object from the database with the ID specified in the HTTP request, and renders a form with values from this object:"
    { $code
        "<page-action>"
        ""
        "    ["
        "        validate-integer-id"
        "        \"id\" value <golf-course>"
        "        select-tuple from-object"
        "    ] >>init"
        ""
        "    { golf \"view-course\" } >>template"
    }
} ;

HELP: to-object
{ $values { "destination" object } { "names" "a sequence of value names" } }
{ $description "Stores the given sequence of form values into the slots of the object having the same names. This word is used to extract form field values after validation." } ;

HELP: with-each-value
{ $values { "name" string } { "quot" quotation } }
{ $description "Calls the quotation with each element of the value named " { $snippet "name" } "; the value must be a sequence. The quotation is called in a new dynamic scope with the " { $snippet "index" } " and " { $snippet "value" } " values set to the one-based index, and the sequence element in question, respectively." }
{ $notes "This word is used to implement the " { $snippet "t:each" } " tag of the " { $vocab-link "html.templates.chloe" } " templating system. It can also be called directly from " { $vocab-link "html.templates.fhtml" } " templates." } ;

HELP: with-each-object
{ $description "Calls the quotation with each element of the value named " { $snippet "name" } "; the value must be a sequence. The quotation is called in a new dynamic scope where the object's slots become named values, as if " { $link from-object } " was called." }
{ $notes "This word is used to implement the " { $snippet "t:bind-each" } " tag of the " { $vocab-link "html.templates.chloe" } " templating system. It can also be called directly from " { $vocab-link "html.templates.fhtml" } " templates." } ;

HELP: validation-failed?
{ $values { "?" "a boolean" } }
{ $description "Tests if validation of the current form failed." } ;

HELP: validate-values
{ $values { "assoc" assoc } { "validators" "an assoc mapping value names to quotations" } }
{ $description "Validates values in the assoc by looking up the corresponding validation quotation, and storing the results in named values of the current form." } ;

ARTICLE: "html.forms.forms" "HTML form infrastructure"
"The below words are used to implement the " { $vocab-link "furnace.actions" } " vocabulary. Calling them directly is rarely necessary."
$nl
"Creating a new form:"
{ $subsection <form> }
"Variable holding current form:"
{ $subsection form }
"Working with forms:"
{ $subsection with-form }
{ $subsection begin-form }
"Validation:"
{ $subsection validation-error }
{ $subsection validation-failed? }
{ $subsection validate-values } ;

ARTICLE: "html.forms.values" "HTML form values"
"Form values are a central concept in the Furnace framework. Web actions primarily concern themselves with validating values, marshalling values to a database, and setting values for display in a form."
$nl
"Getting and setting values:"
{ $subsection value }
{ $subsection set-value }
{ $subsection from-object }
{ $subsection to-object }
"Iterating over values; these words are used by " { $vocab-link "html.templates.chloe" } " to implement the " { $snippet "t:each" } " and " { $snippet "t:bind-each" } " tags:"
{ $subsection with-each-value }
{ $subsection with-each-object }
"Nesting a form inside another form as a value:"
{ $subsection nest-form } ;

ARTICLE: "html.forms" "HTML forms"
"The " { $vocab-link "html.forms" } " vocabulary implements support for rendering and validating HTML forms. The definition of a " { $emphasis "form" } " is a bit more general than the content of an " { $snippet "<form>" } " tag. Namely, a page which displays a database record without offering any editing capability is considered a form too; it consists entirely of read-only components."
$nl
"This vocabulary is an integral part of the " { $vocab-link "furnace" } " web framework. The " { $vocab-link "html.templates.chloe" } " vocabulary uses the HTML form words to implement various template tags. The words are also often used directly from web action implementations."
$nl
"This vocabulary can be used without either the Furnace framework or the HTTP server; for example, as part of a static HTML generation tool."
{ $subsection "html.forms.forms" }
{ $subsection "html.forms.values" } ;

ABOUT: "html.forms"
