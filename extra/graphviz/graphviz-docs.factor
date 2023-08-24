! Copyright (C) 2011 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays graphviz.attributes help.markup
help.syntax kernel present sequences strings ;
IN: graphviz

{ subgraph <subgraph> <anon> <cluster> } related-words
{ graph <graph> <digraph> <strict-graph> <strict-digraph> } related-words
{ node <node> add-node add-nodes } related-words
{ edge <edge> add-edge add-path } related-words
{ add add-node add-edge add-nodes add-path } related-words

HELP: <anon>
{ $values
        { "subgraph" subgraph }
}
{ $description
"Constructs an empty, anonymous " { $link subgraph } " by automatically generating a (somewhat) unique " { $slot "id" } "."
}
{ $notes
"Each " { $slot "id" } " has the form " { $snippet "\"_anonymous_n\"" } ", where " { $snippet "n" } " is a counter incremented by 1 each time an anonymous " { $slot "id" } " is generated (e.g., each time you call " { $link <anon> } " or " { $link <graph> } "). This is also how the Graphviz DOT parser internally handles anonymous graphs and subgraphs."
$nl
"Thus, while it's possible to manually create a " { $link subgraph } " whose " { $slot "id" } " conflicts with an " { $link <anon> } "'s , in practice it's unlikely to happen by accident."
}
{ $examples
    "Each " { $link <anon> } " will generate a " { $link subgraph } " with a new " { $slot "id" } ", such as:"
    { $unchecked-example
      "USING: graphviz prettyprint ;"
      "<anon> . <anon> ."
      "T{ subgraph { id \"_anonymous_5\" } { statements V{ } } }\nT{ subgraph { id \"_anonymous_6\" } { statements V{ } } }"
    }
    $nl
    "More generally, the following should always be the case:"
    { $example
      "USING: accessors graphviz kernel prettyprint ;"
      "<anon> <anon> [ id>> ] same? ."
      "f"
    }
}
;

HELP: <cluster>
{ $values
    { "id" object }
    { "subgraph" subgraph }
}
{ $description
"Constructs a cluster, which is a " { $link subgraph } " whose " { $slot "id" } " begins with the word " { $emphasis "\"cluster\"" } "."
$nl
{ $snippet "id" } " must be an object supported by the " { $link present } " word. The string " { $snippet "\"cluster_\"" } " is automatically prefixed to the " { $slot "id" } " of the resulting " { $link subgraph } "."
}
{ $notes
"Clusters are just a syntactic convention. Not all Graphviz layout engines treat clusters any differently from regular subgraphs. See the Graphviz documentation (" { $url "https://graphviz.org/Documentation.php" } ") for more information."
}
{ $examples
  { $example
    "USING: graphviz prettyprint ;"
    "\"foo\" <cluster> ."
    "T{ subgraph { id \"cluster_foo\" } { statements V{ } } }"
  }
  $nl
  { $example
    "USING: accessors graphviz prettyprint ;"
    "0 <cluster> id>> ."
    "\"cluster_0\""
  }
}
;

HELP: <digraph>
{ $values
        { "graph" graph }
}
{ $description
"Constructs an empty, non-strict, directed " { $link graph } "."
}
{ $notes
"Because it's rare for " { $link graph } " " { $slot "id" } "s to be meaningful or useful, " { $link <digraph> } " automatically generates one, just as in " { $link <anon> } "."

$nl

"If you want, you can still give the resulting " { $link graph } " a specific " { $slot "id" } " using standard words like " { $link >>id } ". For example,"
{ $code "<digraph> \"G\" >>id" }
}
{ $examples
    { $example "USING: graphviz prettyprint ;" "<digraph> graph? ." "t" }
    $nl
    { $example "USING: accessors graphviz prettyprint sequences ;" "<digraph> statements>> empty? ." "t" }
    $nl
    { $example "USING: accessors graphviz prettyprint ;" "<digraph> strict?>> ." "f" }
    $nl
    { $example "USING: accessors graphviz prettyprint ;" "<digraph> directed?>> ." "t" }
}
;

HELP: <edge>
{ $values
    { "tail" object }
    { "head" object }
    { "edge" edge }
}
{ $description
"Constructs an " { $link edge } " with the given " { $slot "tail" } " and " { $slot "head" } ", each of which must be either:"
{ $list
  { "an " { $link array } " of objects supported by the " { $link present } " word, which is treated as an anonymous " { $link subgraph } " of " { $link node } "s with corresponding " { $slot "id" } "s;" }
  { "a " { $link subgraph } "; or" }
  { "any object supported by the " { $link present } " word, which is taken to be the " { $slot "id" } " of a " { $link node } "." }
}
}
{ $notes
"There is more detailed information about how different " { $slot "tail" } " and " { $slot "head" } " types interact in the documentation for " { $link edge } "."
}
{ $examples
  { $example
    "USING: accessors graphviz kernel prettyprint ;"
    "1 \"one\" <edge>"
    "[ tail>> . ] [ head>> . ] bi"
    "\"1\"\n\"one\""
  }
  $nl
  { $example
    "USING: accessors classes graphviz kernel prettyprint strings ;"
    "1 { 2 3 4 } <edge>"
    "[ tail>> class-of . ] [ head>> class-of . ] bi"
    "string\nsubgraph"
  }
  $nl
  { $example
    "USING: accessors graphviz kernel prettyprint ;"
    "<anon> <anon> <edge>"
    "[ tail>> id>> ] [ head>> id>> ] bi = ."
    "f"
  }
}
;

HELP: <graph>
{ $values
        { "graph" graph }
}
{ $description
"Constructs an empty, non-strict, undirected " { $link graph } "."
}
{ $notes
"Because it's rare for " { $link graph } " " { $slot "id" } "s to be meaningful or useful, " { $link <graph> } " automatically generates one, just as in " { $link <anon> } "."

$nl

"If you want, you can still give the resulting " { $link graph } " a specific " { $slot "id" } " using standard words like " { $link >>id } ". For example,"
{ $code "<graph> \"G\" >>id" }
}
{ $examples
    { $example "USING: graphviz prettyprint ;" "<graph> graph? ." "t" }
    $nl
    { $example "USING: accessors graphviz prettyprint sequences ;" "<graph> statements>> empty? ." "t" }
    $nl
    { $example "USING: accessors graphviz prettyprint ;" "<graph> strict?>> ." "f" }
    $nl
    { $example "USING: accessors graphviz prettyprint ;" "<graph> directed?>> ." "f" }
}
;

HELP: <node>
{ $values
    { "id" object }
    { "node" node }
}
{ $description
"Constructs a " { $link node } " with the given " { $slot "id" } ", which must be an object supported by the " { $link present } " word."
}
{ $examples
  { $example
    "USING: graphviz prettyprint ;"
    "\"foo\" <node> ."
    "T{ node { id \"foo\" } }"
  }
  $nl
  { $example
    "USING: accessors graphviz prettyprint ;"
    "0 <node> id>> ."
    "\"0\""
  }
}
;

HELP: <strict-digraph>
{ $values
        { "graph" graph }
}
{ $description
"Constructs an empty, strict, directed " { $link graph } "."
}
{ $notes
"Because it's rare for " { $link graph } " " { $slot "id" } "s to be meaningful or useful, " { $link <strict-digraph> } " automatically generates one, just as in " { $link <anon> } "."

$nl

"If you want, you can still give the resulting " { $link graph } " a specific " { $slot "id" } " using standard words like " { $link >>id } ". For example,"
{ $code "<strict-digraph> \"G\" >>id" }

$nl

"In " { $emphasis "strict" } " " { $link graph } "s, there is at most one " { $link edge } " between any two " { $link node } "s, so duplicates are ignored by Graphviz."
}
{ $examples
    { $example "USING: graphviz prettyprint ;" "<strict-digraph> graph? ." "t" }
    $nl
    { $example "USING: accessors graphviz prettyprint sequences ;" "<strict-digraph> statements>> empty? ." "t" }
    $nl
    { $example "USING: accessors graphviz prettyprint ;" "<strict-digraph> strict?>> ." "t" }
    $nl
    { $example "USING: accessors graphviz prettyprint ;" "<strict-digraph> directed?>> ." "t" }
}
;

HELP: <strict-graph>
{ $values
        { "graph" graph }
}
{ $description
"Constructs an empty, strict, undirected " { $link graph } "."
}
{ $notes
"Because it's rare for " { $link graph } " " { $slot "id" } "s to be meaningful or useful, " { $link <strict-graph> } " automatically generates one, just as in " { $link <anon> } "."

$nl

"If you want, you can still give the resulting " { $link graph } " a specific " { $slot "id" } " using standard words like " { $link >>id } ". For example,"
{ $code "<strict-digraph> \"G\" >>id" }

$nl

"In " { $emphasis "strict" } " " { $link graph } "s, there is at most one " { $link edge } " between any two " { $link node } "s, so duplicates are ignored by Graphviz."
}
{ $examples
    { $example "USING: graphviz prettyprint ;" "<strict-graph> graph? ." "t" }
    $nl
    { $example "USING: accessors graphviz prettyprint sequences ;" "<strict-graph> statements>> empty? ." "t" }
    $nl
    { $example "USING: accessors graphviz prettyprint ;" "<strict-graph> strict?>> ." "t" }
    $nl
    { $example "USING: accessors graphviz prettyprint ;" "<strict-graph> directed?>> ." "f" }
}
;

HELP: <subgraph>
{ $values
    { "id" object }
    { "subgraph" subgraph }
}
{ $description
"Constructs an empty " { $link subgraph } " with the given " { $slot "id" } ", which must be an object supported by the " { $link present } " word."
}
{ $notes
"The empty string, " { $snippet "\"\"" } ", counts as a distinct " { $slot "id" } ". To create an anonymous " { $link subgraph } ", use " { $link <anon> } "."
}
{ $examples
  { $example
    "USING: graphviz prettyprint ;"
    "\"subg\" <subgraph> subgraph? ."
    "t"
  }
  $nl
  { $example
    "USING: accessors graphviz prettyprint ;"
    "3.14 <subgraph> id>> ."
    "\"3.14\""
  }
  $nl
  { $example
    "USING: accessors graphviz prettyprint sequences ;"
    "\"foo\" <subgraph> statements>> empty? ."
    "t"
  }
}
;

HELP: add
{ $values
    { "graph" { $or graph subgraph } }
    { "statement" object }
    { "graph'" { $or graph subgraph } }
}
{ $description
"Adds an arbitrary object to the " { $slot "statements" } " slot of a " { $link graph } " or " { $link subgraph } ", leaving the updated tuple on the stack. This is the most basic way to construct a " { $link graph } "."
}
{ $notes ! $warning
  { $link add } " does not check the type of " { $snippet "statement" } ". You should ensure that " { $link graph } "s and " { $link subgraph } "s only contain instances of:"
  { $list
    { $link subgraph }
    { $link node }
    { $link edge }
    { $link graph-attributes }
    { $link node-attributes }
    { $link edge-attributes }
  }
}
{ $examples
  { $example
    "USING: accessors graphviz prettyprint sequences ;"
    "<graph>"
    "    1 <node> add"
    "statements>> [ id>> . ] each"
    "\"1\""
  }
  $nl
  { $example
    "USING: accessors graphviz prettyprint sequences ;"
    "<graph>"
    "    1 <node> add"
    "    2 <node> add"
    "statements>> [ id>> . ] each"
    "\"1\"\n\"2\""
  }
  $nl
  { $example
    "USING: accessors classes graphviz prettyprint sequences ;"
    "<graph>"
    "    1 <node> add"
    "    2 <node> add"
    "    1 2 <edge> add"
    "statements>> [ class-of . ] each"
    "node\nnode\nedge"
  }
}
;

HELP: add-edge
{ $values
    { "graph" { $or graph subgraph } }
    { "tail" object }
    { "head" object }
    { "graph'" { $or graph subgraph } }
}
{ $description
"Adds an " { $link edge } " in " { $snippet "graph" } " from " { $slot "tail" } " to " { $slot "head" } ". That is,"
{ $code "X Y add-edge" }
"is shorthand for"
{ $code "X Y <edge> add" }
}
{ $examples
  { $example
    "USING: accessors graphviz io kernel sequences ;"
    "<graph>"
    "    1 2 add-edge"
    "    3 4 add-edge"
    "    1 2 add-edge ! duplicate"
    "    5 6 add-edge"
    "statements>> [ dup tail>> write \"--\" write head>> print ] each"
    "1--2\n3--4\n1--2\n5--6"
  }
  $nl
  { $example
    "USING: accessors graphviz io kernel math.combinatorics"
    "sequences ;"
    "<graph>"
    "    { \"a\" 2 \"c\" }"
    "    2 [ first2 add-edge ] each-combination"
    "statements>> [ dup tail>> write \"--\" write head>> print ] each"
    "a--2\na--c\n2--c"
  }
}
;

HELP: add-node
{ $values
    { "graph" { $or graph subgraph } }
    { "id" object }
    { "graph'" { $or graph subgraph } }
}
{ $description
"Adds a " { $link node } " with the given " { $slot "id" } " to " { $snippet "graph" } ". That is,"
{ $code "X add-node" }
"is shorthand for"
{ $code "X <node> add" }
}
{ $examples
  { $example
    "USING: accessors graphviz prettyprint sequences ;"
    "<graph>"
    "    \"foo\" add-node"
    "    \"bar\" add-node"
    "    \"baz\" add-node"
    "statements>> [ id>> . ] each"
    "\"foo\"\n\"bar\"\n\"baz\""
  }
  $nl
  { $example
    "USING: accessors graphviz prettyprint sequences ;"
    "<graph>"
    "    5 <iota> [ add-node ] each"
    "statements>> [ id>> . ] each"
    "\"0\"\n\"1\"\n\"2\"\n\"3\"\n\"4\""
  }
}
;

HELP: add-nodes
{ $values
    { "graph" { $or graph subgraph } }
    { "nodes" sequence }
    { "graph'" { $or graph subgraph } }
}
{ $description
"Adds a " { $link node } " to " { $snippet "graph" } " for each element in " { $snippet "nodes" } ", which must be a " { $link sequence } " of objects that are supported by the " { $link present } " word. Thus, the following two lines are equivalent:"
{ $code
    "{ X Y Z } add-nodes"
    "X add-node Y add-node Z add-node"
}
}
{ $examples
  { $example
    "USING: accessors graphviz prettyprint sequences ;"
    "<graph>"
    "    { 8 6 7 5 3 0 9 \"Jenny\" \"Jenny\" } add-nodes"
    "statements>> length ."
    "9"
  }
  $nl
  { $example
    "USING: accessors graphviz kernel math prettyprint sequences ;"
    "<graph>"
    "    100 [ \"spam\" ] replicate add-nodes"
    "statements>> [ id>> \"spam\" = ] all? ."
    "t"
  }
}
;

HELP: add-path
{ $values
    { "graph" { $or graph subgraph } }
    { "nodes" sequence }
    { "graph'" { $or graph subgraph } }
}
{ $description
"Adds " { $link edge } "s to " { $snippet "graph" } " corresponding to a path through " { $snippet "nodes" } "."

$nl

"That is, an " { $link edge } " is added between each object and the one immediately following it in " { $snippet "nodes" } ". Thus, the following two lines are equivalent:"
{ $code
    "{ A B C D E } add-path"
    "A B add-edge B C add-edge C D add-edge D E add-edge"
}
}
{ $examples
  { $example
    "USING: accessors graphviz prettyprint sequences ;"
    "<graph>"
    "    f add-path"
    "statements>> empty? ."
    "t"
  }
  $nl
  { $example
    "USING: accessors graphviz prettyprint sequences ;"
    "<graph>"
    "    { \"the cheese stands alone\" } add-path"
    "statements>> empty? ."
    "t"
  }
  $nl
  { $example
    "USING: accessors graphviz io kernel sequences ;"
    "<digraph>"
    "  { 1 2 3 4 5 } add-path"
    "statements>> [ dup tail>> write \" -> \" write head>> print ] each"
    "1 -> 2\n2 -> 3\n3 -> 4\n4 -> 5"
  }
  $nl
  { $example
    "USING: accessors graphviz io kernel sequences ;"
    "<strict-digraph>"
    "  { \"cycle\" \"cycle\" } add-path"
    "statements>> [ dup tail>> write \" -> \" write head>> print ] each"
    "cycle -> cycle"
  }
}
;

HELP: edge
{ $class-description
"Represents a Graphviz edge. Each " { $link edge } " is defined by its " { $slot "tail" } " slot and its " { $slot "head" } " slot. Each slot must be either"
{ $list
    { { $instance string } " representing the " { $snippet "id" } " of a " { $link node } " or" }
    { { $instance subgraph } ", which is a convenient way to represent multiple Graphviz edges." }
}

"In particular, using " { $link subgraph } "s gives us shorthand forms for the following cases:"

{
    $table
    {
        ""
        { { $slot "head" } " is a " { $link string } "..." }
        { { $slot "head" } " is a " { $link subgraph } "..." }
    }
    {
        { { $slot "tail" } " is a " { $link string } "..." }
        { "edge from " { $slot "tail" } " node\nto " { $slot "head" } " node" }
        { "edge from " { $slot "tail" } " node\nto each node in " { $slot "head" } }
    }
    {
        { { $slot "tail" } " is a " { $link subgraph } "..." }
        { "edge from each node in " { $slot "tail" } "\nto " { $slot "head" } " node" }
        { "edge from each node in " { $slot "tail" } "\nto each node in " { $slot "head" } }
    }
}
$nl
"In addition, an " { $link edge } " may store local attributes in its " { $slot "attributes" } " slot (" { $instance edge-attributes } " tuple)."
}
{ $notes
"By convention, an " { $link edge } " orders its endpoints \"from\" " { $slot "tail" } " \"to\" " { $slot "head" } ", even if it belongs to an undirected " { $link graph } ", where such a distinction is generally meaningless. See the Graphviz documentation (" { $url "https://graphviz.org/Documentation.php" } "), and specifically the notes about ambiguous attributes (in " { $url "https://graphviz.org/content/attrs" } ") for more information."
} ;

HELP: graph
{ $class-description
"Represents the top-level (or " { $emphasis "root" } ") graph used in Graphviz. Its structure is modeled after the DOT language (see " { $url "https://graphviz.org/Documentation.php" } "):"
$nl
{ $table
  {
      { $strong "Slot name" }
      { $strong "Value" }
      { $strong "Meaning in DOT" }
  }
  {
      { $slot "id" }
      { $instance string }
      { "the reference name of a graph, as in " { $strong "graph" } " " { $slot "id" } " " { $strong "{" } " ... " { $strong "}" } }
  }
  {
      { $slot "strict?" }
      { $instance boolean }
      { "indicates strictness, as in " { $strong "strict graph {" } " ... " { $strong "}" } }
  }
  {
      { $slot "directed?" }
      { $instance boolean }
      { "corresponds to " { $strong "digraph {" } " ... " { $strong "}" } " vs. " { $strong "graph {" } " ... " { $strong "}" } }
  }
  {
      { $slot "statements" }
      { $instance sequence }
      { "the defining \"body\", as in " { $strong "graph {" } " ... " { $slot "statements" } " ... " { $strong "}" } }
  }
}
$nl
"In particular, " { $slot "statements" } " should be a " { $link sequence } " containing only instances of:"
{ $list
  { $link subgraph }
  { $link node }
  { $link edge }
  { $link graph-attributes }
  { $link node-attributes }
  { $link edge-attributes }
}
} ;

HELP: node
{ $class-description
"Represents a single Graphviz node. Each " { $link node } " is uniquely determined by an " { $slot "id" } " (" { $instance string } ") and may have per-node attributes stored in its " { $slot "attributes" } " slot (" { $instance node-attributes } " tuple)."
} ;

HELP: subgraph
{ $class-description
"Represents a logical grouping of nodes and edges within a Graphviz graph. See " { $url "https://graphviz.org/Documentation.php" } " for more information."
$nl
"Its structure is largely similar to " { $link graph } ", except " { $link subgraph } " only has two slots: " { $slot "id" } " (" { $instance string } ") and " { $slot "statements" } " (" { $instance sequence } "). The " { $snippet "strict?" } " and " { $snippet "directed?" } " slots of the parent " { $link graph } " are implicitly inherited by a " { $link subgraph } "."
$nl
{ $slot "id" } " and " { $slot "statements" } " correspond to the name and defining \"body\" of a subgraph in the DOT language, as in " { $strong "subgraph" } " " { $slot "id" } " " { $strong "{" } " ... " { $slot "statements" } " ... " { $strong "}" } "."
$nl
"In particular, " { $slot "statements" } " should be a " { $link sequence } " containing only instances of:"
{ $list
  { $link subgraph }
  { $link node }
  { $link edge }
  { $link graph-attributes }
  { $link node-attributes }
  { $link edge-attributes }
}
} ;

ARTICLE: { "graphviz" "data" } "Graphviz data structures"
"To use the " { $vocab-link "graphviz" } " vocabulary, we construct Factor objects that can be converted to data understood by Graphviz (see " { $vocab-link "graphviz.dot" } ")."
$nl
"The following classes are used to represent their equivalent Graphviz structures:"
{ $subsections node edge subgraph graph }
"Several constructor variations exist to make building graphs convenient."
$nl
"To construct different sorts of graphs:"
{ $subsections <graph> <digraph> <strict-graph> <strict-digraph> }
"To construct different sorts of subgraphs:"
{ $subsections <subgraph> <anon> <cluster> }
"To construct nodes and edges:"
{ $subsections <node> <edge> }
"Finally, use the following words to combine these objects into a single " { $link graph } ":"
{ $subsections add add-node add-edge add-nodes add-path }
;

ARTICLE: { "graphviz" "gallery" "complete" } "Complete graphs"
"In graph theory, a " { $emphasis "complete graph" } " is one in which there is an edge between each pair of distinct nodes."
$nl
{ $code
"USING: kernel math.combinatorics math.parser sequences"
"graphviz graphviz.notation graphviz.render ;"
""
": K_n ( n -- )"
"    <graph>"
"        [node \"point\" =shape ]; "
"        [graph \"t\" =labelloc \"circo\" =layout ];"
""
"        over number>string \"K \" prepend =label"
""
"        swap <iota> 2 [ first2 add-edge ] each-combination"
"    preview ;"
}
$nl
{ $code "5 K_n" }
{ $image "resource:extra/graphviz/gallery/k5.png" }
$nl
{ $code "6 K_n" }
{ $image "resource:extra/graphviz/gallery/k6.png" }
$nl
{ $code "7 K_n" }
{ $image "resource:extra/graphviz/gallery/k7.png" }
;

ARTICLE: { "graphviz" "gallery" "bipartite" } "Complete bipartite graphs"
"In graph theory, a " { $emphasis "bipartite graph" } " is one in which the nodes can be divided into exactly two independent sets (i.e., there are no edges between nodes in the same set)."
$nl
{ $code
"USING: formatting locals math.parser sequences"
"graphviz graphviz.notation graphviz.render ;"
""
":: partite-set ( n color -- cluster )"
"    color <cluster>"
"        color =color"
"        [node color =color ];"
"        n <iota> ["
"            number>string color prepend add-node"
"        ] each ;"
""
":: K_n,m ( n m -- )"
"    <graph>"
"        [node \"point\" =shape ];"
"        [graph \"t\" =labelloc \"dot\" =layout \"LR\" =rankdir ];"
""
"        n \"#FF0000\" partite-set"
"        m \"#0000FF\" partite-set"
""
"        add-edge ! between clusters"
""
"        ! set label last so that clusters don't inherit it"
"        n m \"K %d,%d\" sprintf =label"
"    preview ;"
}
$nl
{ $code "3 3 K_n,m" }
{ $image "resource:extra/graphviz/gallery/k33.png" }
$nl
{ $code "3 4 K_n,m" }
{ $image "resource:extra/graphviz/gallery/k34.png" }
$nl
{ $code "5 4 K_n,m" }
{ $image "resource:extra/graphviz/gallery/k54.png" }
;

ARTICLE: { "graphviz" "gallery" "cycle" } "Cycle graphs"
"In graph theory, a " { $emphasis "cycle graph" } " is one in which all the nodes are connected in a single circle."
$nl
{ $code
"USING: kernel math math.parser sequences"
"graphviz graphviz.notation graphviz.render ;"
""
": add-cycle ( graph n -- graph' )"
"    [ <iota> add-path ] [ 1 - 0 add-edge ] bi ;"
""
": C_n ( n -- )"
"    <graph>"
"        [graph \"t\" =labelloc \"circo\" =layout ];"
"        [node \"point\" =shape ];"
"        over number>string \"C \" prepend =label"
"        swap add-cycle"
"    preview ;"
}
$nl
{ $code "5 C_n" }
{ $image "resource:extra/graphviz/gallery/c5.png" }
$nl
{ $code "6 C_n" }
{ $image "resource:extra/graphviz/gallery/c6.png" }
$nl
{ $code "7 C_n" }
{ $image "resource:extra/graphviz/gallery/c7.png" }
;

ARTICLE: { "graphviz" "gallery" "wheel" } "Wheel graphs"
"In graph theory, a " { $emphasis "wheel graph" } " on " { $emphasis "n" } " nodes is composed of a single node connected to each node of a cycle of " { $emphasis "n-1" } " nodes."
$nl
{ $code
"USING: arrays kernel math math.parser sequences"
"graphviz graphviz.notation graphviz.render ;"
""
": add-cycle ( graph n -- graph' )"
"    [ <iota> add-path ] [ 1 - 0 add-edge ] bi ;"
""
": W_n ( n -- )"
"    <graph>"
"        [graph \"t\" =labelloc \"twopi\" =layout ];"
"        [node \"point\" =shape ];"
"        over number>string \"W \" prepend =label"
"        over add-node"
"        over 1 - add-cycle"
"        swap [ ] [ 1 - <iota> >array ] bi add-edge"
"    preview ;"
}
$nl
{ $code "6 W_n" }
{ $image "resource:extra/graphviz/gallery/w6.png" }
{ $code "7 W_n" }
{ $image "resource:extra/graphviz/gallery/w7.png" }
{ $code "8 W_n" }
{ $image "resource:extra/graphviz/gallery/w8.png" }
;

ARTICLE: { "graphviz" "gallery" "cluster" } "Cluster example"
"This example is adapted from " { $url "https://graphviz.org/content/cluster" } "."
$nl
{ $code
"USING: graphviz graphviz.notation graphviz.render ;"
""
"<digraph>"
"    \"dot\" =layout"
""
"    0 <cluster>"
"        \"filled\" =style"
"        \"lightgrey\" =color"
"        [node \"filled\" =style \"white\" =color ];"
"        { \"a0\" \"a1\" \"a2\" \"a3\" } ~->"
"        \"process #1\" =label"
"    add"
""
"    1 <cluster>"
"        [node \"filled\" =style ];"
"        { \"b0\" \"b1\" \"b2\" \"b3\" } ~->"
"        \"process #2\" =label"
"        \"blue\" =color"
"    add"
""
"    \"start\" \"a0\" ->"
"    \"start\" \"b0\" ->"
"    \"a1\" \"b3\" ->"
"    \"b2\" \"a3\" ->"
"    \"a3\" \"a0\" ->"
"    \"a3\" \"end\" ->"
"    \"b3\" \"end\" ->"
""
"    \"start\" [add-node \"Mdiamond\" =shape ];"
"    \"end\" [add-node \"Msquare\" =shape ];"
"preview"
}
{ $image "resource:extra/graphviz/gallery/cluster.png" }
;

ARTICLE: { "graphviz" "gallery" "circles" } "Colored circles example"
"This example was adapted from the \"star\" example in PyGraphviz (" { $url "https://networkx.lanl.gov/pygraphviz/" } ") and modified slightly."
$nl
{ $code
"USING: formatting kernel math sequences"
"graphviz graphviz.notation graphviz.render ;"
""
": colored-circle ( i -- node )"
"    [ <node> ] keep"
"    [ 16.0 / 0.5 + =width ]"
"    [ 16.0 / 0.5 + =height ]"
"    [ 16 * \"#%2x0000\" sprintf =fillcolor ] tri ;"
""
"<graph>"
"    [graph \"3,3\" =size \"circo\" =layout ];"
""
"    [node \"filled\" =style"
"          \"circle\" =shape"
"          \"true\"   =fixedsize"
"          \"\"       =label ];"
""
"    [edge \"invis\" =style ];"
""
"    0 [add-node \"invis\" =style \"none\" =shape ];"
""
"    16 <iota> ["
"        [ 0 -- ] [ colored-circle add ] bi"
"    ] each"
"preview"
}
{ $image "resource:extra/graphviz/gallery/circles.png" }
;

ARTICLE: { "graphviz" "gallery" "fsm" } "Finite state machine example"
"This example is adapted from " { $url "https://graphviz.org/content/fsm" } "."
$nl
{ $code
"USING: graphviz graphviz.notation graphviz.render ;"
""
"<digraph>"
"    \"LR\" =rankdir"
"    \"8,5\" =size"
"    [node \"doublecircle\" =shape ];"
"    { \"LR_0\" \"LR_3\" \"LR_4\" \"LR_8\" } add-nodes"
"    [node \"circle\" =shape ];"
"    \"LR_0\" \"LR_2\" [-> \"SS(B)\" =label ];"
"    \"LR_0\" \"LR_1\" [-> \"SS(S)\" =label ];"
"    \"LR_1\" \"LR_3\" [-> \"S($end)\" =label ];"
"    \"LR_2\" \"LR_6\" [-> \"SS(b)\" =label ];"
"    \"LR_2\" \"LR_5\" [-> \"SS(a)\" =label ];"
"    \"LR_2\" \"LR_4\" [-> \"S(A)\" =label ];"
"    \"LR_5\" \"LR_7\" [-> \"S(b)\" =label ];"
"    \"LR_5\" \"LR_5\" [-> \"S(a)\" =label ];"
"    \"LR_6\" \"LR_6\" [-> \"S(b)\" =label ];"
"    \"LR_6\" \"LR_5\" [-> \"S(a)\" =label ];"
"    \"LR_7\" \"LR_8\" [-> \"S(b)\" =label ];"
"    \"LR_7\" \"LR_5\" [-> \"S(a)\" =label ];"
"    \"LR_8\" \"LR_6\" [-> \"S(b)\" =label ];"
"    \"LR_8\" \"LR_5\" [-> \"S(a)\" =label ];"
"preview"
}
{ $image "resource:extra/graphviz/gallery/fsm.png" }
;

ARTICLE: { "graphviz" "gallery" "record" } "Record example"
"This example is adapted (and slightly altered) from " { $url "https://graphviz.org/content/datastruct" } "."
$nl
"As it shows, special label syntax is still parsed, like escape sequences (see " { $url "https://graphviz.org/content/attrs#kescString" } ") or, in this case, record syntax (see " { $url "https://graphviz.org/content/node-shapes#record" } "). However, there is no equivalent to Graphviz's headport/tailport syntax, so we set the " { $link edge } " attributes explicitly."
$nl
{ $code
"USING: graphviz graphviz.notation graphviz.render ;"
""
"<digraph>"
"    [graph \"LR\" =rankdir \"8,8\" =size ];"
"    [node 8 =fontsize \"record\" =shape ];"
""
"    \"node0\" [add-node"
"        \"<f0> 0x10ba8| <f1>\" =label"
"    ];"
"    \"node1\" [add-node"
"        \"<f0> 0xf7fc4380| <f1> | <f2> |-1\" =label"
"    ];"
"    \"node2\" [add-node"
"        \"<f0> 0xf7fc44b8| | |2\" =label"
"    ];"
"    \"node3\" [add-node"
"        \"<f0> 3.43322790286038071e-06|44.79998779296875|0\" =label"
"    ];"
"    \"node4\" [add-node"
"        \"<f0> 0xf7fc4380| <f1> | <f2> |2\" =label"
"    ];"
"    \"node5\" [add-node"
"        \"<f0> (nil)| | |-1\" =label"
"    ];"
"    \"node6\" [add-node"
"        \"<f0> 0xf7fc4380| <f1> | <f2> |1\" =label"
"    ];"
"    \"node7\" [add-node"
"        \"<f0> 0xf7fc4380| <f1> | <f2> |2\" =label"
"    ];"
"    \"node8\" [add-node"
"        \"<f0> (nil)| | |-1\" =label"
"    ];"
"    \"node9\" [add-node"
"        \"<f0> (nil)| | |-1\" =label"
"    ];"
"    \"node10\" [add-node"
"        \"<f0> (nil)| <f1> | <f2> |-1\" =label"
"    ];"
"    \"node11\" [add-node"
"        \"<f0> (nil)| <f1> | <f2> |-1\" =label"
"    ];"
"    \"node12\" [add-node"
"        \"<f0> 0xf7fc43e0| | |1\" =label"
"    ];"
""
"    \"node0\" \"node1\"   [-> \"f0\" =tailport \"f0\" =headport ];"
"    \"node0\" \"node2\"   [-> \"f1\" =tailport \"f0\" =headport ];"
"    \"node1\" \"node3\"   [-> \"f0\" =tailport \"f0\" =headport ];"
"    \"node1\" \"node4\"   [-> \"f1\" =tailport \"f0\" =headport ];"
"    \"node1\" \"node5\"   [-> \"f2\" =tailport \"f0\" =headport ];"
"    \"node4\" \"node3\"   [-> \"f0\" =tailport \"f0\" =headport ];"
"    \"node4\" \"node6\"   [-> \"f1\" =tailport \"f0\" =headport ];"
"    \"node4\" \"node10\"  [-> \"f2\" =tailport \"f0\" =headport ];"
"    \"node6\" \"node3\"   [-> \"f0\" =tailport \"f0\" =headport ];"
"    \"node6\" \"node7\"   [-> \"f1\" =tailport \"f0\" =headport ];"
"    \"node6\" \"node9\"   [-> \"f2\" =tailport \"f0\" =headport ];"
"    \"node7\" \"node3\"   [-> \"f0\" =tailport \"f0\" =headport ];"
"    \"node7\" \"node1\"   [-> \"f1\" =tailport \"f0\" =headport ];"
"    \"node7\" \"node8\"   [-> \"f2\" =tailport \"f0\" =headport ];"
"    \"node10\" \"node11\" [-> \"f1\" =tailport \"f0\" =headport ];"
"    \"node10\" \"node12\" [-> \"f2\" =tailport \"f0\" =headport ];"
"    \"node11\" \"node1\"  [-> \"f2\" =tailport \"f0\" =headport ];"
"preview"
}
{ $image "resource:extra/graphviz/gallery/record.png" }
;

ARTICLE: { "graphviz" "gallery" } "Graphviz gallery"
"Below are some examples of the typical usage of the " { $vocab-link "graphviz" } " vocabulary."
$nl
"The images in the gallery were pre-compiled using Graphviz version 2.26.3. Depending on your particular Graphviz installation, these examples may not actually work for you, especially if you have a non-standard installation."
$nl
"Also, while most of the images have a reasonable size, some of these examples may be slow to load in the UI listener."
$nl
{ $subsections
    { "graphviz" "gallery" "complete" }
    { "graphviz" "gallery" "bipartite" }
    { "graphviz" "gallery" "cycle" }
    { "graphviz" "gallery" "wheel" }
    { "graphviz" "gallery" "cluster" }
    { "graphviz" "gallery" "circles" }
    { "graphviz" "gallery" "fsm" }
    { "graphviz" "gallery" "record" }
}
;

ARTICLE: "graphviz" "Graphviz"
"The " { $vocab-link "graphviz" } " vocabulary provides an interface to your existing Graphviz installation, thus allowing you to create, edit, and render Graphviz graphs using Factor. For more information about Graphviz, see " { $url "https://graphviz.org" } "."
$nl
"This vocabulary provides the basic tools to construct Factor representations of graphs. For more details, see:"
{ $subsections { "graphviz" "data" } }
"Other vocabularies let you change a graph's look & feel, write cleaner code to represent it, and (of course) generate its Graphviz output:"
{ $vocab-subsections
    { "Graphviz attributes" "graphviz.attributes" }
    { "Graphviz notation" "graphviz.notation" }
    { "Rendering Graphviz output" "graphviz.render" }
}
"After reading the above, you can see several examples in action:"
{ $subsections { "graphviz" "gallery" } }
;

ABOUT: "graphviz"
