! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: graphviz graphviz.attributes graphviz.builder
graphviz.ffi help.markup help.syntax images.viewer kernel
strings ;
IN: graphviz.render

HELP: default-format
{ $var-description "Holds a " { $link string } " representing the implicit output format for certain words in the " { $vocab-link "graphviz.render" } " vocabulary." }
{ $see-also graphviz graphviz* preview preview-window default-layout }
;

HELP: default-layout
{ $var-description "Holds a " { $link string } " representing the implicit layout engine for certain words in the " { $vocab-link "graphviz.render" } " vocabulary." }
{ $see-also graphviz graphviz* preview preview-window default-format }
;

{ graphviz graphviz* } related-words

HELP: graphviz
{ $values
    { "graph" graph }
    { "-O" string }
    { "-T" string }
    { "-K" { $maybe string } }
}
{ $description "Renders " { $snippet "graph" } " to a specified output file."
$nl
{ $snippet "-O" } " is similar to the command-line argument of the standard Graphviz commands (see " { $url "http://graphviz.org/content/command-line-invocation" } "). It specifies the base name of the " { $strong "o" } "utput file. Like Graphviz tools, the proper extension (if one is known) is automatically added to the file name based on " { $snippet "-T" } "."
$nl
{ $snippet "-T" } " specifies the output format " { $strong "t" } "ype (which must be a member of " { $link supported-formats } "). This is, again, akin to the command-line flag in standard Graphviz commands."
$nl
{ $snippet "-K" } " specifies the layout engine. If " { $snippet "-K" } " is " { $link f } ", then " { $snippet "graph" } " is checked for a " { $slot "layout" } " attribute (see " { $link graph-attributes } ") and that engine is used; if no such attribute is set, then " { $link default-layout } " is used. Regardless, the resulting engine must be a member of " { $link supported-engines } "."
}
{ $errors
"If " { $snippet "graph" } " is not an instance of " { $link graph } ", a " { $link non-graph-error } " is thrown."
$nl
"An " { $link improper-statement-error } " is thrown if any element of " { $snippet "graph" } "'s " { $snippet "statements" } " slot is not an instance of:"
{ $list
    { $link subgraph }
    { $link node }
    { $link edge }
    { $link graph-attributes }
    { $link node-attributes }
    { "or " { $link edge-attributes } }
}
$nl
"If " { $snippet "-K" } " (or the inferred layout engine) is not a member of " { $link supported-engines } ", an " { $link unsupported-engine } " error is thrown."
$nl
"If " { $snippet "-T" } " is not a member of " { $link supported-formats } ", an " { $link unsupported-format } " error is thrown."
}
{ $examples "To render a " { $link graph } " " { $snippet "G" } " using " { $emphasis "circo" } " and save the output to a PNG file, we could write" { $code "G \"foo\" \"png\" \"circo\" graphviz" } "(assuming " { $emphasis "circo" } " and PNG are supported by your Graphviz installation).  This will save the output to the file " { $snippet "foo.png" } "." }
;

HELP: graphviz*
{ $values
    { "graph" graph }
    { "-O" string }
    { "-T" string }
}
{ $description "Renders " { $snippet "graph" } " to a specified output file (" { $snippet "-O" } ") with the specified format type (" { $snippet "-T" } ") using the " { $link default-layout } " (or " { $snippet "graph" } "'s " { $snippet "layout" } " attribute, if set). That is, the following two lines are equivalent:"
{ $code "-O -T f graphviz" "-O -T graphviz*" }
}
{ $errors
"If " { $snippet "graph" } " is not an instance of " { $link graph } ", a " { $link non-graph-error } " is thrown."
$nl
"An " { $link improper-statement-error } " is thrown if any element of " { $snippet "graph" } "'s " { $snippet "statements" } " slot is not an instance of:"
{ $list
    { $link subgraph }
    { $link node }
    { $link edge }
    { $link graph-attributes }
    { $link node-attributes }
    { "or " { $link edge-attributes } }
}
$nl
"If the inferred layout engine is not a member of " { $link supported-engines } ", an " { $link unsupported-engine } " error is thrown."
$nl
"If " { $snippet "-T" } " is not a member of " { $link supported-formats } ", an " { $link unsupported-format } " error is thrown."
}
{ $examples "To render a " { $link graph } " " { $snippet "G" } " when we don't particularly care about the engine but want to save the output to a PNG file, we could write" { $code "G \"foo\" \"png\" graphviz*" } "(assuming the inferred layout and PNG are supported by your Graphviz installation).  This will save the output to the file " { $snippet "foo.png" } "." }
;

HELP: preview
{ $values
    { "graph" graph }
}
{ $description "Renders " { $snippet "graph" } " to a temporary file of the " { $link default-format } " (assumed to be an image format) using the " { $link default-layout } " (or, if specified, the engine set as the graph's " { $slot "layout" } " attribute). Then, using the " { $vocab-link "images.viewer" } " vocabulary, displays the image in the UI listener." }
{ $errors
"If " { $snippet "graph" } " is not an instance of " { $link graph } ", a " { $link non-graph-error } " is thrown."
$nl
"An " { $link improper-statement-error } " is thrown if any element of " { $snippet "graph" } "'s " { $snippet "statements" } " slot is not an instance of:"
{ $list
    { $link subgraph }
    { $link node }
    { $link edge }
    { $link graph-attributes }
    { $link node-attributes }
    { "or " { $link edge-attributes } }
}
$nl
"If the inferred layout engine is not a member of " { $link supported-engines } ", an " { $link unsupported-engine } " error is thrown."
$nl
"If the inferred output format (i.e., " { $link default-format } ") is not a member of " { $link supported-formats } ", an " { $link unsupported-format } " error is thrown."
}
{ $see-also image. preview-window }
;

HELP: preview-window
{ $values
    { "graph" graph }
}
{ $description "Renders " { $snippet "graph" } " to a temporary file of the " { $link default-format } " (assumed to be an image format) using the " { $link default-layout } " (or, if specified, the engine set as the graph's " { $slot "layout" } " attribute). Then, using the " { $vocab-link "images.viewer" } " vocabulary, opens a new window displaying the image." }
{ $errors
"If " { $snippet "graph" } " is not an instance of " { $link graph } ", a " { $link non-graph-error } " is thrown."
$nl
"An " { $link improper-statement-error } " is thrown if any element of " { $snippet "graph" } "'s " { $snippet "statements" } " slot is not an instance of:"
{ $list
    { $link subgraph }
    { $link node }
    { $link edge }
    { $link graph-attributes }
    { $link node-attributes }
    { "or " { $link edge-attributes } }
}
$nl
"If the inferred layout engine is not a member of " { $link supported-engines } ", an " { $link unsupported-engine } " error is thrown."
$nl
"If the inferred output format (i.e., " { $link default-format } ") is not a member of " { $link supported-formats } ", an " { $link unsupported-format } " error is thrown."
}
{ $see-also image-window preview }
;

HELP: unsupported-engine
{ $values
    { "engine" object }
}
{ $error-description "Thrown if a rendering word tries to use a layout engine that is not a member of " { $link supported-engines } "." }
{ $see-also unsupported-format }
;

HELP: unsupported-format
{ $values
    { "format" object }
}
{ $error-description "Thrown if a rendering word tries to use an output format that is not a member of " { $link supported-formats } "." }
{ $see-also unsupported-engine }
;

ARTICLE: { "graphviz.render" "algorithm" "node" } "Rendering nodes"
"To render a " { $link node } ", a Graphviz equivalent is constructed in memory that is identified by the " { $link node } "'s " { $slot "id" } " slot. Then, any local attributes (as specified in the " { $slot "attributes" } " slot) are set."
$nl
"If two " { $link node } " instances have the same " { $slot "id" } ", they will correspond to the same object in the Graphviz representation. Thus, the effect of any local attributes are cumulative. For example,"
{ $code
"<graph>"
"    1 add-node[ \"blue\" =color ];"
"    1 add-node[ \"red\" =color ];"
}
"will render the same way as just"
{ $code
"<graph>"
"    1 add-node[ \"red\" =color ];"
}
"because statements are rendered in the order they appear. Even " { $link node } " instances in a " { $link subgraph } " are treated this way, so"
{ $code
"<graph>"
"    1 add-node"
"    <anon>"
"        1 add-node"
"    add"
}
"will only create a single Graphviz node."
;

ARTICLE: { "graphviz.render" "algorithm" "subgraph" } "Rendering subgraphs"
"To render a " { $link subgraph } ", a Graphviz equivalent is constructed in memory that is identified by the " { $link subgraph } "'s " { $slot "id" } " slot. This equivalent will inherit any attributes set in its parent graph (see " { $link { "graphviz.render" "algorithm" "attributes" } } ")."
$nl
"Each element of the " { $link subgraph } "'s " { $slot "statements" } " slot is recursively rendered in order. Thus, subgraph attributes are set by rendering a " { $link graph-attributes } " object contained in a " { $link subgraph } "'s " { $slot "statements" } "."
$nl
"If two " { $link subgraph } " instances have the same " { $slot "id" } ", they will correspond to the same object in the Graphviz representation. (Indeed, the " { $slot "id" } "s even share the same namespace as the root " { $link graph } "; see " { $url "http://graphviz.org/content/dot-language" } " for details.) Thus, the effect of rendering " { $emphasis "any" } " statement is cumulative. For example,"
{ $code
"<graph>"
"    { 1 2 3 } add-nodes"
""
"    0 <cluster>"
"        4 add-node"
"    add"
""
"    0 <cluster>"
"        5 add-node"
"    add"
}
"will render the same way as just"
{ $code
"<graph>"
"    { 1 2 3 } add-nodes"
""
"    0 <cluster>"
"        4 add-node"
"        5 add-node"
"    add"
}
;

ARTICLE: { "graphviz.render" "algorithm" "attributes" } "Rendering attributes"
"The way " { $link node-attributes } ", " { $link edge-attributes } ", and " { $link graph-attributes } " are rendered varies by context."
$nl
"If an instance of " { $link node-attributes } " or " { $link edge-attributes } " appears in the " { $slot "statements" } " of a " { $link graph } " or " { $link subgraph } ", it corresponds to global Graphviz attributes that will be set automatically for any " { $emphasis "future" } " " { $link node } " or " { $link edge } " instances (respectively), just like global attribute statements in the DOT language. Rendering " { $link graph-attributes } " behaves similarly, except that the Graphviz attributes of the containing graph/subgraph will also be altered, in addition to future " { $link subgraph } "s inheriting said attributes."
$nl
{ $link node-attributes } " and " { $link edge-attributes } " may also be rendered in the context of a single " { $link node } " or " { $link edge } ", as specified by these objects' " { $slot "attributes" } " slots. They correspond to Graphviz attributes set specifically for the corresponding node/edge, after the defaults are inherited from rendering global statements as in the above."
$nl
"For example, setting " { $emphasis "local" } " attributes like"
{ $code
"<graph>"
"    1 add-node[ \"red\" =color ];"
"    2 add-node[ \"red\" =color ];"
"    3 add-node[ \"blue\" =color ];"
"    4 add-node[ \"blue\" =color ];"
}
"will render the same way as setting " { $emphasis "global" } " attributes that get inherited, like"
{ $code
"<graph>"
"    node[ \"red\" =color ];"
"    1 add-node"
"    2 add-node"
"    node[ \"blue\" =color ];"
"    3 add-node"
"    4 add-node"
}
;

ARTICLE: { "graphviz.render" "algorithm" "edge" } "Rendering edges"
"Instances of " { $link edge } " are not quite in one-to-one correspondence with Graphviz edges. The latter exist solely between two nodes, whereas an " { $link edge } " instance may have a " { $link subgraph } " as an endpoint."
$nl
"To render an " { $link edge } ", first the " { $slot "tail" } " is recursively rendered:"
{ $list
  { "If it is a " { $link string } ", then it's taken to identify a node (if one doesn't already exist in the Graphviz representation, it is created)." }
  { "If it is a " { $link subgraph } ", then it's rendered recursively as per " { $link { "graphviz.render" "algorithm" "subgraph" } } " (thus also creating the Graphviz subgraph if one doesn't already exist)." }
}
$nl
"The " { $slot "head" } " is then rendered in the same way."
$nl
"More than one corresponding Graphviz edge may be created at this point. In general, a Graphviz edge is created from each node in the tail (or just the one, if " { $slot "tail" } " was a " { $link string } ") to each node in the head (or just the one, if " { $slot "head" } " was a " { $link string } "). However, a Grapvhiz edge may or may not be solely identified by its endpoints. Either way, whatever Graphviz-equivalent edges wind up being rendered, their attributes will be set according to the " { $link edge } "'s " { $slot "attributes" } " slot."
$nl
"In particular, if the root graph is strict, then edges are uniquely identified, so attributes are cumulative (like in " { $link { "graphviz.render" "algorithm" "node" } } " and " { $link { "graphviz.render" "algorithm" "subgraph" } } "). For example,"
{ $code
    "<strict-graph>"
    "    1 2 add-edge[ \"blue\" =color ];"
    "    1 2 add-edge[ \"red\" =color ];"
}
"will render the same way as just"
{ $code
    "<strict-graph>"
    "    1 2 add-edge[ \"red\" =color ];"
}
$nl
"But in a non-strict graph, a new Graphviz edge is created with its own local attributes which are not affected by past edges between the same endpoints. So,"
{ $code
    "<graph>"
    "    1 2 add-edge[ \"blue\" =color ];"
    "    1 2 add-edge[ \"red\" =color ];"
}
"will render " { $emphasis "two" } " separate edges with different colors (one red, one blue)."
{ $notes
"Because of the above semantics for edges between subgraphs, the " { $vocab-link "graphviz" } " vocabulary does not support edges betwteen clusters as single entities like certain Graphviz layout engines, specifically " { $emphasis "fdp" } "."
}
;

ARTICLE: { "graphviz.render" "algorithm" "error" } "Rendering unexpected objects"
"If an object in the " { $slot "statements" } " of a " { $link graph } " or " { $link subgraph } " is not an instance of either"
{ $list
  { $link subgraph }
  { $link node }
  { $link edge }
  { $link graph-attributes }
  { $link node-attributes }
  { "or " { $link edge-attributes } }
}
"then it will trigger an " { $link improper-statement-error } "."
;

ARTICLE: { "graphviz.render" "algorithm" } "Graphviz rendering algorithm"
"The " { $vocab-link "graphviz.render" } " vocabulary provides words to " { $emphasis "render" } " graphs. That is, it generates Graphviz output from a " { $link graph } " by using the " { $vocab-link "graphviz.ffi" } " and " { $vocab-link "graphviz.builder" } " vocabularies. Intuitively, " { $link graph } "s follow the same rules as in the DOT language (see " { $url "http://graphviz.org/content/dot-language" } " for more information). To render a " { $link graph } ", each element of its " { $slot "statements" } " slot is added to the Graphviz representation in order. The following gives a general overview of how different objects are rendered, with a few points to keep in mind."
{ $subsections
    { "graphviz.render" "algorithm" "node" }
    { "graphviz.render" "algorithm" "edge" }
    { "graphviz.render" "algorithm" "attributes" }
    { "graphviz.render" "algorithm" "subgraph" }
    { "graphviz.render" "algorithm" "error" }
}
{ $notes
"Each call to a rendering word (like " { $links graphviz graphviz* preview preview-window } ", etc.) will go through the process of reconstructing the equivalent Graphviz representation in memory, even if the underlying " { $link graph } " hasn't changed."
}
;

ARTICLE: { "graphviz.render" "engines" } "Rendering graphs by layout engine"
"For each layout engine in " { $link supported-engines } ", the " { $vocab-link "graphviz.render" } " vocabulary defines a corresponding word that calls " { $link graphviz } " with that engine already supplied as an argument. For instance, instead of writing" { $code "graph -O -T \"dot\" graphviz" } "you can simply write" { $code "graph -O -T dot" } "as long as " { $snippet "\"dot\"" } " is a member of " { $link supported-engines } "."
;

ARTICLE: { "graphviz.render" "formats" } "Rendering graphs by output format"
"For each output format in " { $link supported-formats } ", the " { $vocab-link "graphviz.render" } " vocabulary defines a corresponding word that calls " { $link graphviz* } " with that format already supplied as an argument. For instance, instead of writing" { $code "graph -O \"png\" graphviz*" } "you can simply write" { $code "graph -O png" } "as long as " { $snippet "\"png\"" } " is a member of " { $link supported-formats } "."
$nl
"If any of the formats is also a member of " { $link supported-engines } ", the word is named with a " { $snippet "-file" } " suffix. For instance, the " { $vocab-link "graphviz.render" } " vocabulary may define a word for the " { $snippet "\"dot\"" } " layout engine, so that instead of" { $code "graph -O -T \"dot\" graphviz" } "you can write" { $code "graph -O -T dot" } "But to infer the layout engine and " { $emphasis "output" } " in the " { $snippet "\"dot\"" } " format, instead of" { $code "graph -O \"dot\" graphviz*" } "you can write" { $code "graph -O dot-file" } "as long as " { $snippet "\"dot\"" } " is a member of both " { $link supported-engines } " and " { $link supported-formats } "."

{ $warning "Graphviz may support " { $emphasis "canvas" } " formats, such as " { $snippet "\"xlib\"" } " or " { $snippet "\"gtk\"" } ", that will open windows displaying the graph. However, the listener will not be aware of these windows: when they are closed, the listener will exit as well. You should probably use the " { $link preview-window } " word, instead." }
;

ARTICLE: "graphviz.render" "Rendering Graphviz output"
"The " { $vocab-link "graphviz.render" } " vocabulary provides words for converting " { $link graph } " objects into equivalent Graphviz output. The following provides a general overview of how this process works:"
{ $subsections { "graphviz.render" "algorithm" } }

"Graphviz provides a variety of different layout engines (which give algorithms for placing nodes and edges in a graph) and output formats (e.g., different image filetypes to show the graph structure)."
$nl
"The most general words in this vocabulary will have you manually specify the desired engine and/or format, along with a file to which Graphviz should save its output:"
{ $subsections
    graphviz
    graphviz*
}

"If the graph is small enough, it may be convenient to see an image of it using Factor's UI listener:"
{ $subsections
    preview
    preview-window
}

"Specialized words are also defined to save on extraneous typing:"
{ $subsections
    { "graphviz.render" "engines" }
    { "graphviz.render" "formats" }
}
;

ABOUT: "graphviz.render"
