! Copyright (C) 2008 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax inspector io kernel lcs present
strings urls ;
IN: html.components

HELP: checkbox
{ $class-description "Checkbox components render a boolean value. The " { $slot "label" } " slot must be set to a string." } ;

HELP: choice
{ $class-description "Choice components render a popup menu or list box with either single or multiple selection."
$nl
"The " { $slot "multiple" } " slot determines whether multiple elements may be selected at once; if this is set to a true value, then the component value must be a sequence of strings, otherwise it must be a single string."
$nl
"The " { $slot "size" } " slot determines the number of items visible at one time; if neither this nor " { $slot "multiple" } " is set, the component is rendered as a popup menu rather than a list."
$nl
"The " { $slot "choices" } " slot determines all possible choices which may be selected. It names a value, rather than storing the choices directly." } ;

HELP: code
{ $class-description "Code components render string value with the " { $vocab-link "xmode.code2html" } " syntax highlighting vocabulary. The " { $slot "mode" } " slot names a value holding an XMode mode name." } ;

HELP: field
{ $class-description "Field components display a one-line editor for a string value. The " { $slot "size" } " slot determines the maximum displayed width of the field." } ;

HELP: password
{ $class-description "Password field components display a one-line editor which obscures the user's input. The " { $slot "size" } " slot determines the maximum displayed width of the field. Unlike other components, on failed validation, the contents of a password field are not sent back to the client. This is a security feature, intended to avoid revealing the password to potential snoopers who use the " { $strong "View Source" } " feature." } ;

HELP: textarea
{ $class-description "Text area components display a multi-line editor for a string value. The " { $slot "rows" } " and " { $slot "cols" } " properties determine the size of the text area." } ;

HELP: link
{ $description "Link components render a value responding to the " { $link link-title } " and " { $link link-href } " generic words. The optional " { $slot "target" } " slot is a target frame to open the link in." } ;

HELP: link-title
{ $values { "obj" object } { "string" string } }
{ $description "Outputs the title to render for a link to the object." } ;

HELP: link-href
{ $values { "obj" object } { "url" "a " { $link string } " or " { $link url } } }
{ $description "Outputs the URL to render for a link to the object." } ;

ARTICLE: "html.components.links" "Link components"
"Link components render a link to an object."
{ $subsections link }
"The link title and URL are determined by passing the object to a pair of generic words:"
{ $subsections
    link-title
    link-href
}
"The generic words provide methods on the " { $link string } " and " { $link url } " classes which treat the object as a URL. New methods can be defined for rendering links to custom data types." ;

HELP: comparison
{ $description "Comparison components render diffs output by the " { $link lcs-diff } " word." } ;

HELP: farkup
{ $description "Farkup components render " { $link "farkup" } "." } ;

HELP: hidden
{ $description "Hidden components render as a hidden form field. For example, a page for editing a weblog post might contain a hidden field with the post ID." } ;

HELP: html
{ $description "HTML components render HTML verbatim from a string, without any escaping. Care must be taken to only render trusted input, to avoid cross-site scripting attacks." } ;

HELP: xml
{ $description "XML components render XML verbatim, from an XML chunk. Care must be taken to only render trusted input, to avoid cross-site scripting attacks." } ;

HELP: inspector
{ $description "Inspector components render an arbitrary object by passing it to the " { $link describe } " word." } ;

HELP: label
{ $description "Label components render an object as a piece of text by passing it to the " { $link present } " word." } ;

HELP: render
{ $values { "name" "a value name" } { "renderer" "a component renderer" } }
{ $description "Renders an HTML component to the " { $link output-stream } "." } ;

HELP: render*
{ $values { "value" "a value" } { "name" "a value name" } { "renderer" "a component renderer" } { "xml" "an XML chunk" } }
{ $contract "Renders an HTML component, outputting an XHTML snippet." } ;

ARTICLE: "html.components" "HTML components"
"The " { $vocab-link "html.components" } " vocabulary provides various HTML form components."
$nl
"Most web applications can use the " { $vocab-link "html.templates.chloe" } " templating framework instead of using this vocabulary directly. Where maximum flexibility is required, this vocabulary can be used together with the " { $vocab-link "html.templates.fhtml" } " templating framework."
$nl
"Rendering components:"
{ $subsections render }
"Components render a named value, and the name of the value is passed in every time the component is rendered, rather than being associated with the component itself. Named values are taken from the current HTML form (see " { $link "html.forms" } ")."
$nl
"Component come in two varieties: singletons and tuples. Components with no configuration are singletons; they do not have to instantiated, rather the class word represents the component. Tuple components have to be instantiated and offer configuration options."
$nl
"Singleton components:"
{ $subsections
    hidden
    link
    inspector
    comparison
    html
    xml
}
"Tuple components:"
{ $subsections
    field
    password
    textarea
    choice
    checkbox
    code
    farkup
}
"Creating custom components:"
{ $subsections render* }
"Custom components can emit HTML using the " { $vocab-link "xml.syntax" } " vocabulary." ;

ABOUT: "html.components"
