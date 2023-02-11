! Copyright (C) 2011 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license.
USING: alien graphviz graphviz.attributes graphviz.ffi
help.markup help.syntax kernel ;
IN: graphviz.builder

HELP: build-alien
{ $values
    { "Agraph_t*" c-ptr }
    { "graph" graph }
}
{ $description "Constructs a C representation of the given " { $link graph } " in memory by using the " { $vocab-link "graphviz.ffi" } " vocabulary to destructively modify " { $snippet "Agraph_t*" } " (a " { $link c-ptr } " created by " { $link agopen } ")." }
{ $notes "User code should not call this word directly. Use the " { $vocab-link "graphviz.render" } " vocabulary instead." }
{ $errors "Throws " { $link non-graph-error } " if applied to anything other than an instance of " { $link graph } "."
$nl
"Throws " { $link improper-statement-error } " if any of the " { $link graph } "'s " { $slot "statements" } " is not an instance of:"
{ $list { $link subgraph } { $link node } { $link edge } { $link graph-attributes } { $link node-attributes } { $link edge-attributes } }
}
;

HELP: improper-statement-error
{ $values
    { "obj" object }
}
{ $error-description "Thrown if, in a call to " { $link build-alien } ", any of a " { $link graph } "'s " { $snippet "statements" } " is not an instance of:" { $list { $link subgraph } { $link node } { $link edge } { $link graph-attributes } { $link node-attributes } { $link edge-attributes } } }
;

HELP: non-graph-error
{ $values
    { "obj" object }
}
{ $error-description "Thrown if " { $link build-alien } " is applied to an object that is not an instance of " { $link graph } "." } ;

ARTICLE: "graphviz.builder" "Constructing C versions of Graphviz graphs"
"The " { $vocab-link "graphviz.builder" } " vocabulary implements words to convert a " { $link graph } " object into its equivalent C representation in " { $emphasis "libgvc" } " and " { $emphasis "libgraph" } " (see the " { $vocab-link "graphviz.ffi" } " vocabulary)."
$nl
"These are low-level words used to implement the " { $vocab-link "graphviz.render" } " vocabulary. As such, user code should not use " { $vocab-link "graphviz.builder" } " directly."
$nl
"The main word:"
{ $subsections build-alien }
"Errors that might be thrown:"
{ $subsections non-graph-error improper-statement-error }
;

ABOUT: "graphviz.builder"
