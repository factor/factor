IN: html.templates.chloe
USING: help.markup help.syntax html.components html.forms
html.templates html.templates.chloe.syntax
html.templates.chloe.compiler html.templates.chloe.components
math strings quotations namespaces ;
FROM: xml.data => tag ;

HELP: <chloe>
{ $values { "path" "a pathname string without the trailing " { $snippet ".xml" } " extension" } { "chloe" chloe } }
{ $description "Creates a new Chloe template object which can be passed to " { $link call-template } "." } ;

HELP: required-attr
{ $values { "tag" tag } { "name" string } { "value" string } }
{ $description "Extracts an attribute from a tag." }
{ $errors "Throws an error if the attribute is not specified." } ;

HELP: optional-attr
{ $values { "tag" tag } { "name" string } { "value" { $maybe string } } }
{ $description "Extracts an attribute from a tag." }
{ $notes "Outputs " { $link f } " if the attribute is not specified." } ;

HELP: compile-attr
{ $values { "value" "an attribute value" } }
{ $description "Compiles code which pushes an attribute value previously extracted by " { $link required-attr } " or " { $link optional-attr } " on the stack. If the attribute value begins with " { $snippet "@" } ", compiles into code which pushes the a form value." } ;

HELP: CHLOE:
{ $syntax "CHLOE: name definition... ;" }
{ $values { "name" "the tag name" } { "definition" { $quotation ( tag -- ) } } }
{ $description "Defines compilation semantics for the Chloe tag named " { $snippet "tag" } ". The definition body receives a " { $link tag } " on the stack." } ;

HELP: COMPONENT:
{ $syntax "COMPONENT: name" }
{ $description "Defines a Chloe tag named " { $snippet "name" } " rendering the HTML component with class word " { $snippet "name" } ". See " { $link "html.components" } "." } ;

HELP: reset-cache
{ $description "Resets the compiled template cache. Chloe automatically recompiles templates when their file changes on disk, however other when redefining Chloe tags or words which they call, the cache may have to be reset manually for the changes to take effect." } ;

HELP: tag-stack
{ $var-description "During template compilation, holds the current nesting of XML element names. Can be used from " { $link POSTPONE: CHLOE: } " definitions to make a custom tag behave differently depending on how it is nested." } ;

HELP: [write]
{ $values { "string" string } }
{ $description "Compiles code which writes the string when the template is called." } ;

HELP: [code]
{ $values { "quot" quotation } }
{ $description "Compiles the quotation. It will be called when the template is called." } ;

HELP: process-children
{ $values { "tag" tag } { "quot" { $quotation ( compiled-tag -- ) } } }
{ $description "Compiles the tag. The quotation will be applied to the resulting quotation when the template is called." }
{ $examples "See " { $link "html.templates.chloe.extend.tags.example" } " for an example which uses this word to implement a custom control flow tag." } ;

HELP: compile-children>string
{ $values { "tag" tag } }
{ $description "Compiles the tag so that the output it generates is written to a string, which is pushed on the stack when the template runs. A subsequent " { $link [code] } " call must be made with a quotation which consumes the string." } ;

HELP: compile-with-scope
{ $values { "quot" quotation } }
{ $description "Calls the quotation and wraps any output it compiles in a " { $link with-scope } " form." } ;

ARTICLE: "html.templates.chloe.tags.component" "Component Chloe tags"
"The following Chloe tags correspond exactly to " { $link "html.components" } ". The " { $snippet "name" } " attribute should be the name of a form value (see " { $link "html.forms.values" } "). Singleton component tags do not allow any other attributes. Tuple component tags map all other attributes to tuple slot values of the component instance."
{ $table
    { { $strong "Tag" } { $strong "Component class" } }
    { { $snippet "t:checkbox" }   { $link checkbox } }
    { { $snippet "t:choice" }     { $link choice } }
    { { $snippet "t:code" }       { $link code } }
    { { $snippet "t:comparison" } { $link comparison } }
    { { $snippet "t:farkup" }     { $link farkup } }
    { { $snippet "t:field" }      { $link field } }
    { { $snippet "t:hidden" }     { $link hidden } }
    { { $snippet "t:html" }       { $link html } }
    { { $snippet "t:xml" }        { $link xml } }
    { { $snippet "t:inspector" }  { $link inspector } }
    { { $snippet "t:label" }      { $link label } }
    { { $snippet "t:link" }       { $link link } }
    { { $snippet "t:password" }   { $link password } }
    { { $snippet "t:textarea" }   { $link textarea } }
} ;

ARTICLE: "html.templates.chloe.tags.boilerplate" "Boilerplate Chloe tags"
"The following Chloe tags interface with the HTML templating " { $link "html.templates.boilerplate" } "."
$nl
"The tags marked with (*) are only available if the " { $vocab-link "furnace.chloe-tags" } " vocabulary is loaded."
{ $table
    { { $snippet "t:title" } "Sets the title. Intended for use in a master template." }
    { { $snippet "t:write-title" } "Renders the child's title. Intended for use in a child template." }
    { { $snippet "t:style" } { "Adds CSS markup from the file named by the " { $snippet "t:include" } " attribute. Intended for use in a child template." } }
    { { $snippet "t:write-style" } "Renders the children's CSS markup. Intended for use in a master template." }
    { { $snippet "t:script" } { "Adds JS from the file named by the " { $snippet "t:include" } " attribute. Intended for use in a child template." } }
    { { $snippet "t:write-script" } "Renders the children's JS. Intended for use in a master template." }
    { { $snippet "t:meta" } { "Adds meta tags to the header. Intended for use in a child template." } }
    { { $snippet "t:write-meta" } "Renders the children's meta tags. Intended for use in a master template." }
    { { $snippet "t:atom" } { "Adds an Atom feed link. The attributes are the same as the " { $snippet "t:link" } " tag. Intended for use in a child template. (*)" } }
    { { $snippet "t:write-atom" } "Renders the children's list of Atom feed links. Intended for use in a master template. (*)" }
    { { $snippet "t:call-next-template" } "Calls the next child template from a master template." }
} ;

ARTICLE: "html.templates.chloe.tags.control" "Control-flow Chloe tags"
"While most control flow and logic should be embedded in the web actions themselves and not in the template, Chloe templates do support a minimal amount of control flow."
{ $table
    { { $snippet "t:comment" } "All markup within a comment tag is ignored by the compiler." }
    { { $snippet "t:bind" } { "Renders child content bound to a nested form named by the " { $snippet "t:name" } " attribute. See " { $link with-form } "." } }
    { { $snippet "t:each" } { "Renders child content once for each element of the sequence in the value named by the " { $snippet "t:name" } " attribute. The sequence element and index are bound to the " { $snippet "value" } " and " { $snippet "index" } " values, respectively. See " { $link with-each-value } "." } }
    { { $snippet "t:bind-each" } { "Renders child content once for each element of the sequence in the value named by the " { $snippet "t:name" } " attribute. The sequence element's slots are bound to values. See " { $link with-each-object } "." } }
    { { $snippet "t:even" } { "Only valid inside a " { $snippet "t:each" } " or " { $snippet "t:bind-each" } ". Only renders child content if the " { $snippet "index" } " value is even." } }
    { { $snippet "t:odd" } "As above, but only if the index value is odd." }
    { { $snippet "t:if" } { "Renders child content if a boolean condition evaluates to true. The condition value is determined by the " { $snippet "t:code" } " or " { $snippet "t:value" } " attribute, exactly one of which must be specified. The former is a string of the form " { $snippet "vocabulary:word" } " denoting a word to execute with stack effect " { $snippet "( -- ? )" } ". The latter is a value name." } }
} ;

ARTICLE: "html.templates.chloe.tags.form" "Chloe link and form tags"
"The following tags are only available if the " { $vocab-link "furnace.chloe-tags" } " vocabulary is loaded."
{ $table
    { { $snippet "t:a" } { "Renders a link; extends the standard HTML " { $snippet "a" } " tag by providing some integration with other web framework features. The following attributes are supported:"
        { $list
            { { $snippet "href" } " - a URL. If it begins with " { $snippet "$" } ", then it is interpreted as a responder-relative path." }
            { { $snippet "rest" } " - a value to add at the end of the URL." }
            { { $snippet "query" } " - a comma-separated list of value names defined in the current form which are to be passed to the link as query parameters." }
            { { $snippet "value" } " - a value name holding a URL. If this attribute is specified, it overrides all others." }
        }
        "Any attributes not in the Chloe XML namespace are passed on to the generated " { $snippet "a" } " tag."
        $nl
        "An example:"
        { $code
            "<t:a t:href=\"$wiki/view/\""
            "     t:rest=\"title\""
            "     class=\"small-link\">"
            "    View"
            "</t:a>"
        }
        "The above might render as"
        { $code
            "<a href=\"http://mysite.org/wiki/view/Factor\""
            "   class=\"small-link\">"
            "    View"
            "</a>"
        }
    } }
    { { $snippet "t:base" } { "Outputs an HTML " { $snippet "<base>" } " tag. The attributes are interpreted in the same manner as the attributes of " { $snippet "t:a" } "." } }
    { { $snippet "t:form" } {
        "Renders a form; extends the standard HTML " { $snippet "form" } " tag by providing some integration with other web framework features, for example by adding hidden fields for authentication credentials and session management allowing those features to work with form submission transparently. The following attributes are supported:"
        { $list
            { { $snippet "t:method" } " - just like the " { $snippet "method" } " attribute of an HTML " { $snippet "form" } " tag, this can equal " { $snippet "get" } " or " { $snippet "post" } ". Unlike the HTML tag, the default is " { $snippet "post" } "." }
            { { $snippet "t:action" } " - a URL. If it begins with " { $snippet "$" } ", then it is interpreted as a responder-relative path." }
            { { $snippet "t:for" } " - a comma-separated list of form values which are to be inserted in the form as hidden fields. Other than being more concise, this is equivalent to nesting a series of " { $snippet "t:hidden" } " tags inside the form." }
        }
        "Any attributes not in the Chloe XML namespace are passed on to the generated " { $snippet "form" } " tag."
    } }
    { { $snippet "t:button" } {
        "Shorthand for a form with a single button, whose label is the text child of the " { $snippet "t:button" } " tag. Attributes are processed as with the " { $snippet "t:form" } " tag, with the exception that any attributes not in the Chloe XML namespace are passed on to the generated " { $snippet "button" } " tag, rather than the " { $snippet "form" } " tag surrounding it."
        $nl
        "An example:"
        { $code
            "<t:button t:method=\"POST\""
            "          t:action=\"$wiki/delete\""
            "          t:for=\"id\""
            "          class=\"link-button\">"
            "    Delete"
            "</t:button>"
        }
    } }
    { { $snippet "t:validation-errors" } {
        "Renders validation errors in the current form which are not associated with any field. Such errors are reported by invoking " { $link validation-error } "."
    } }
} ;

ARTICLE: "html.templates.chloe.tags" "Standard Chloe tags"
"A Chloe template is an XML file with a mix of standard HTML and Chloe tags."
$nl
"HTML tags are rendered verbatim, except attribute values which begin with " { $snippet "@" } " are replaced with the corresponding " { $link "html.forms.values" } "."
$nl
"Chloe tags are defined in the " { $snippet "http://factorcode.org/chloe/1.0" } " namespace; by convention, it is bound with a prefix of " { $snippet "t" } ". The top-level tag must always be the " { $snippet "t:chloe" } " tag. A typical Chloe template looks like so:"
{ $code
    "<?xml version=\"1.0\"?>"
    ""
    "<t:chloe xmlns:t=\"http://factorcode.org/chloe/1.0\">"
    "    ..."
    "</t:chloe>"
}
{ $subsections
    "html.templates.chloe.tags.component"
    "html.templates.chloe.tags.boilerplate"
    "html.templates.chloe.tags.control"
    "html.templates.chloe.tags.form"
} ;

ARTICLE: "html.templates.chloe.extend" "Extending Chloe"
"The " { $vocab-link "html.templates.chloe.syntax" } " and " { $vocab-link "html.templates.chloe.compiler" } " vocabularies contain the heart of the Chloe implementation."
$nl
"Chloe is implemented as a compiler which converts XML templates into Factor quotations. The template only has to be parsed and compiled once, and not on every HTTP request. This helps improve performance and memory usage."
$nl
"These vocabularies provide various hooks by which Chloe can be extended. First of all, new " { $link "html.components" } " can be wired in. If further flexibility is needed, entirely new tags can be defined by hooking into the Chloe compiler."
{ $subsections
    "html.templates.chloe.extend.components"
    "html.templates.chloe.extend.tags"
} ;

ARTICLE: "html.templates.chloe.extend.tags" "Extending Chloe with custom tags"
"Syntax for defining custom tags:"
{ $subsections POSTPONE: CHLOE: }
"A number of compiler words can be used from the " { $link POSTPONE: CHLOE: } " body to emit compiled template code."
$nl
"Extracting attributes from the XML tag:"
{ $subsections
    required-attr
    optional-attr
    compile-attr
}
"Examining tag nesting:"
{ $subsections tag-stack }
"Generating code for printing strings and calling quotations:"
{ $subsections
    [write]
    [code]
}
"Generating code from child elements:"
{ $subsections
    process-children
    compile-children>string
    compile-with-scope
}
"Examples which illustrate some of the above:"
{ $subsections "html.templates.chloe.extend.tags.example" } ;

ARTICLE: "html.templates.chloe.extend.tags.example" "Examples of custom Chloe tags"
"As a first example, let's develop a custom Chloe tag which simply renders a random number. The tag will be used as follows:"
{ $code
    "<t:random t:min='10' t:max='20' t:generator='system' />"
}
"The " { $snippet "t:min" } " and " { $snippet "t:max" } " parameters are required, and " { $snippet "t:generator" } ", which can equal one of " { $snippet "default" } ", " { $snippet "system" } " or " { $snippet "secure" } ", is optional, with the default being " { $snippet "default" } "."
$nl
"Here is the " { $link POSTPONE: USING: } " form that we need for the below code to work:"
{ $code
    "USING: combinators kernel math.parser ranges random"
    "html.templates.chloe.compiler html.templates.chloe.syntax ;"
}
"We write a word which extracts the relevant attributes from an XML tag:"
{ $code
    ": random-attrs ( tag -- min max generator )"
    "    [ \"min\" required-attr string>number ]"
    "    [ \"max\" required-attr string>number ]"
    "    [ \"generator\" optional-attr ]"
    "    tri ;"
}
"Next, we convert a random generator name into a random generator object:"
{ $code
    ": string>random-generator ( string -- generator )"
    "    {"
    "        { \"default\" [ random-generator ] }"
    "        { \"system\" [ system-random-generator ] }"
    "        { \"secure\" [ secure-random-generator ] }"
    "    } case ;"
}
"Finally, we can write our Chloe tag:"
{ $code
    "CHLOE: random"
    "    random-attrs string>random-generator"
    "    '["
    "        _ _ _"
    "        [ [a..b] random present write ]"
    "        with-random-generator"
    "    ] [code] ;"
}
"For the second example, let's develop a Chloe tag which repeatedly renders its child several times, where the number comes from a form value. The tag will be used as follows:"
{ $code
    "<t:repeat t:times='n'>Hello world.<br /></t:repeat>"
}
"This time, we cannot simply extract the " { $snippet "t:times" } " attribute at compile time since its value cannot be determined then. Instead, we execute " { $link compile-attr } " to generate code which pushes the value of that attribute on the stack. We then use " { $link process-children } " to compile child elements as a nested quotation which we apply " { $link times } " to."
{ $code
    "CHLOE: repeat"
    "    [ \"times\" required-attr compile-attr ]"
    "    [ [ times ] process-children ]"
    "    bi ;"
} ;

ARTICLE: "html.templates.chloe.extend.components.example" "An example of a custom Chloe component"
"As an example, let's develop a custom Chloe component which renders an image stored in a form value. Since the component does not require any configuration, we can define a singleton class:"
{ $code "SINGLETON: image" }
"Now we define a method on the " { $link render* } " generic word which renders the image using " { $link { "xml.syntax" "literals" } } ":"
{ $code "M: image render* 2drop [XML <img src=<-> /> XML] ;" }
"Finally, we can define a Chloe component:"
{ $code "COMPONENT: image" }
"We can use it as follows, assuming the current form has a value named " { $snippet "image" } ":"
{ $code "<t:image t:name='image' />" } ;

ARTICLE: "html.templates.chloe.extend.components" "Extending Chloe with custom components"
"Custom HTML components implementing the " { $link render* } " word can be wired up with Chloe using the following syntax from " { $vocab-link "html.templates.chloe.components" } ":"
{ $subsections
    POSTPONE: COMPONENT:
    "html.templates.chloe.extend.components.example"
} ;

ARTICLE: "html.templates.chloe" "Chloe templates"
"The " { $vocab-link "html.templates.chloe" } " vocabulary implements an HTML templating engine. Unlike " { $vocab-link "html.templates.fhtml" } ", Chloe templates are always well-formed XML, and no Factor code can be embedded in them, enforcing proper separation of concerns. Chloe templates can be edited using standard XML editing tools; they are less flexible than FHTML, but often simpler as a result."
{ $subsections
    <chloe>
    reset-cache
    "html.templates.chloe.tags"
    "html.templates.chloe.extend"
} ;

ABOUT: "html.templates.chloe"
