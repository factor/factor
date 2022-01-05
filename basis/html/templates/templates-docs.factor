USING: continuations help.markup help.syntax io quotations
strings urls xml.data ;
IN: html.templates

HELP: template
{ $class-description "The class of HTML templates." } ;

HELP: call-template*
{ $values { "template" template } }
{ $contract "Writes a template to " { $link output-stream } ", possibly using " { $vocab-link "html.forms" } " state."
$nl
"In addition to methods added by other vocabularies, this generic word has methods on the following classes:"
{ $list
    { { $link string } " - the simplest type of template; simply written to " { $link output-stream } }
    { { $link callable } " - a custom quotation, called to yield output" }
    { { $link xml } " - written to " { $link output-stream } }
    { "an input stream - copied to " { $link output-stream } }
} } ;

HELP: call-template
{ $values { "template" template } }
{ $description "Writes a template to " { $link output-stream } ", possibly using " { $vocab-link "html.forms" } " state."
$nl
"This word calls " { $link call-template* } ", wrapping it in a " { $link recover } " form which improves error reporting by combining the underlying error with the template object." } ;

HELP: set-title
{ $values { "string" string } }
{ $description "Sets the title of the current page. This is usually called by child templates, and a master template calls " { $link write-title } "." } ;

HELP: write-title
{ $description "Writes the title of the current page, previously set by " { $link set-title } ". This is usually called by a master template after rendering a child template." } ;

HELP: add-style
{ $values { "string" string } }
{ $description "Adds some CSS markup to the CSS stylesheet of a master template. Usually called by child templates which need to insert CSS style information in the " { $snippet "<head>" } " tag of the resulting HTML page." } ;

HELP: write-style
{ $description "Writes a CSS stylesheet assembled from " { $link add-style } " calls by child templates. Usually called by the master template to emit a CSS style in the " { $snippet "<head>" } " tag of the resulting HTML page." } ;

HELP: add-atom-feed
{ $values { "title" string } { "url" "a " { $link string } " or " { $link url } } }
{ $description "Adds an Atom feed link to the list of feeds in a master template. Usually called by child templates which need to insert an Atom feed link information in the " { $snippet "<head>" } " tag of the resulting HTML page." } ;

HELP: write-atom-feeds
{ $description "Writes a list of Atom feed links assembled from " { $link add-atom-feed } " calls by child templates. Usually called by the master template to emit a list of Atom feed links in the " { $snippet "<head>" } " tag of the resulting HTML page." } ;

HELP: nested-template?
{ $var-description "Set to a true value if the current call to " { $link call-template } " is nested inside a " { $link with-boilerplate } " and will therefore appear as part of another template. In this case, XML processing instructions and document type declarations should be omitted." } ;

HELP: call-next-template
{ $description "Calls the next innermost child template from a master template. This is used to implement the " { $snippet "t:call-next-template" } " tag in the " { $vocab-link "html.templates.chloe" } " templating engine." } ;

HELP: with-boilerplate
{ $values { "child" template } { "master" template } }
{ $description "Calls the child template, storing its output in a string, then calls the master template. The master template may call " { $link call-next-template } " to insert the output of the child template at any point; both templates may also use the master/child interface words documented in " { $link "html.templates.boilerplate" } "." } ;

HELP: template-convert
{ $values { "template" template } { "output" "a pathname string" } }
{ $description "Calls the template and writes its output to a file with UTF-8 encoding." } ;

ARTICLE: "html.templates.boilerplate" "Boilerplate support"
"The following words define the interface between a templating engine and the " { $vocab-link "furnace.boilerplate" } " vocabulary."
$nl
"The master/child template interface follows a pattern where for each concept there is a word called by the child to store an entity, and another word to write the entity out; this solves the problem where certain HTML tags, such as " { $snippet "<title>" } " and " { $snippet "<link>" } " must appear inside the " { $snippet "<head>" } " tag, even though those tags are usually precisely those that the child template will want to set."
{ $subsections
    set-title
    write-title
    add-style
    write-style
    add-atom-feed
    write-atom-feeds
}
"Processing a master template with a child:"
{ $subsections
    with-boilerplate
    call-next-template
} ;

ARTICLE: "html.templates" "HTML template interface"
"The " { $vocab-link "html.templates" } " vocabulary implements an abstract interface to HTML templating engines. The " { $vocab-link "html.templates.fhtml" } " and " { $vocab-link "html.templates.chloe" } " vocabularies are two implementations of this."
$nl
"An HTML template is an instance of a mixin:"
{ $subsections template }
"HTML templates must also implement a method on a generic word:"
{ $subsections call-template* }
"Calling an HTML template:"
{ $subsections call-template }
"Usually HTML templates are invoked dynamically by the Furnace web framework and HTTP server. They can also be used in static HTML generation tools:"
{ $subsections
    template-convert
    "html.templates.boilerplate"
} ;

ABOUT: "html.templates"
