! Copyright (C) 2011 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax strings ;
IN: graphviz.attributes

{
    node-attributes
    edge-attributes
    graph-attributes
    <node-attributes>
    <edge-attributes>
    <graph-attributes>
} related-words

HELP: <edge-attributes>
{ $values
        { "attrs" edge-attributes }
}
{ $description "Constructs " { $instance edge-attributes } " tuple with no attributes set." } ;

HELP: <graph-attributes>
{ $values
        { "attrs" graph-attributes }
}
{ $description "Constructs " { $instance graph-attributes } " tuple with no attributes set." } ;

HELP: <node-attributes>
{ $values
        { "attrs" node-attributes }
}
{ $description "Constructs " { $instance node-attributes } " tuple with no attributes set." } ;

HELP: edge-attributes
{ $class-description "Represents Graphviz attributes that are valid for edges. See attributes marked " { $emphasis "E" } " in " { $url "https://graphviz.org/content/attrs" } ". Each slot must be " { $maybe string } "." } ;

HELP: graph-attributes
{ $class-description "Represents Graphviz attributes that are valid for graphs and subgraphs (including clusters). See attributes marked " { $emphasis "G" } ", " { $emphasis "S" } ", and " { $emphasis "C" } " in " { $url "https://graphviz.org/content/attrs" } ". Each slot must be " { $maybe string } "." } ;

HELP: node-attributes
{ $class-description "Represents Graphviz attributes that are valid for nodes. See attributes marked " { $emphasis "N" } " in " { $url "https://graphviz.org/content/attrs" } ". Each slot must be " { $maybe string } "." } ;

ARTICLE: "graphviz.attributes" "Graphviz attributes"
"In Graphviz, " { $emphasis "attributes" } " control different layout characteristics of graphs, subgraphs, nodes, and edges. For example, you can specify the color of an edge or the shape of a node. Graphviz provides documentation for all valid attributes at " { $url "https://graphviz.org/content/attrs" } "."
$nl
"The " { $vocab-link "graphviz.attributes" } " vocabulary simply provides three different tuples to encapsulate Graphviz attributes:"
{ $subsections node-attributes edge-attributes graph-attributes }
"Empty instances are created with the following constructors:"
{ $subsections <node-attributes> <edge-attributes> <graph-attributes> }
;

ABOUT: "graphviz.attributes"
