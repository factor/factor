! Copyright (C) 2011 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license.
USING: graphviz graphviz.attributes help.markup help.syntax
kernel present sequences ;
IN: graphviz.notation

{ add-edge [add-edge -- ~-- [-- } related-words
{ add-edge [add-edge -> ~-> [-> } related-words
{
    [add-node [add-edge [-- [-> [node [edge [graph ];
} related-words

HELP: --
{ $values
    { "graph" { $or graph subgraph } }
    { "tail" object }
    { "head" object }
    { "graph'" { $or graph subgraph } }
}
{ $description "Shorthand for " { $link add-edge } ". Makes undirected " { $link graph } "s read more like graphs in the DOT language." }
{ $examples
    "Instead of writing"
    { $code
        "<graph>"
        "    1 2 add-edge"
        "    3 4 add-edge"
        "    5 6 add-edge"
    }
    "it looks better to write"
    { $code
        "<graph>"
        "    1 2 --"
        "    3 4 --"
        "    5 6 --"
    }
    "Compare this with the DOT language, where you'd write"
    { $code
        "graph {"
        "    1 -- 2"
        "    3 -- 4"
        "    5 -- 6"
        "}"
    }
}
;

HELP: ->
{ $values
    { "graph" { $or graph subgraph } }
    { "tail" object }
    { "head" object }
    { "graph'" { $or graph subgraph } }
}
{ $description "Shorthand for " { $link add-edge } ". Makes directed " { $link graph } "s read more like digraphs in the DOT language." }
{ $examples
    "Instead of writing"
    { $code
        "<digraph>"
        "    1 2 add-edge"
        "    3 4 add-edge"
        "    5 6 add-edge"
    }
    "it looks better to write"
    { $code
        "<digraph>"
        "    1 2 ->"
        "    3 4 ->"
        "    5 6 ->"
    }
    "Compare this with the DOT language, where you'd write"
    { $code
        "digraph {"
        "    1 -> 2"
        "    3 -> 4"
        "    5 -> 6"
        "}"
    }
}
;

HELP: [--
{ $values
    { "tail" object }
    { "head" object }
    { "edge" edge }
}
{ $description "Shorthand for " { $link <edge> } " to be used with " { $link ]; } " and attribute-setting generic words (see " { $link { "graphviz.notation" "=attrs" } } ") so that undirected " { $link graph } "s read more like graphs in the DOT language." }
{ $examples
  "Instead of writing"
  { $code
    "<graph>"
    "    1 2 <edge> \"red\" =color add"
  }
  "it looks better to write"
  { $code
    "<graph>"
    "    1 2 [-- \"red\" =color ];"
  }
  "Compare this with the DOT language, where you'd write"
  { $code
    "graph {"
    "    1 -- 2 [ color=\"red\" ];"
    "}"
  }
}
;

HELP: [->
{ $values
    { "tail" object }
    { "head" object }
    { "edge" edge }
}
{ $description "Shorthand for " { $link <edge> } " to be used with " { $link ]; } " and attribute-setting generic words (see " { $link { "graphviz.notation" "=attrs" } } ") so that directed " { $link graph } "s read more like digraphs in the DOT language." }
{ $examples
  "Instead of writing"
  { $code
    "<digraph>"
    "    1 2 <edge> \"red\" =color add"
  }
  "it looks better to write"
  { $code
    "<digraph>"
    "    1 2 [-> \"red\" =color ];"
  }
  "Compare this with the DOT language, where you'd write"
  { $code
    "digraph {"
    "    1 -> 2 [ color=\"red\" ];"
    "}"
  }
}
;

HELP: ];
{ $values
    { "graph" { $or graph subgraph } }
    { "statement" object }
    { "graph'" { $or graph subgraph } }
}
{ $description "Synonym for " { $link add } " meant to be the \"other half\" of various " { $vocab-link "graphviz.notation" } " words like " { $links [add-edge [add-node [graph } ", etc." }
{ $examples "Refer to the documentation for the complementary words listed below." }
;

HELP: [add-edge
{ $values
    { "tail" object }
    { "head" object }
    { "edge" edge }
}
{ $description "Shorthand for " { $link <edge> } " to be used with " { $link ]; } " and attribute-setting generic words (see " { $link { "graphviz.notation" "=attrs" } } ") so that setting an " { $link edge } "'s " { $slot "attributes" } " reads more like the equivalent in the DOT language." }
{ $examples
  "Instead of writing"
  { $code
    "<graph>"
    "    1 2 <edge> \"red\" =color add"
  }
  "it looks better to write"
  { $code
    "<graph>"
    "    1 2 [add-edge \"red\" =color ];"
  }
  "Compare this with the DOT language, where you'd write"
  { $code
    "graph {"
    "    1 -- 2 [ color=\"red\" ];"
    "}"
  }
  $nl
  "This has the advantage over " { $link [-- } " and " { $link [-> } " of reading nicely for both directed " { $emphasis "and" } " undirected " { $link graph } "s."
}
;

HELP: [add-node
{ $values
    { "id" object }
    { "node" node }
}
{ $description "Shorthand for " { $link <node> } " to be used with " { $link ]; } " and attribute-setting generic words (see " { $link { "graphviz.notation" "=attrs" } } ") so that setting a " { $link node } "'s " { $slot "attributes" } " reads more like the equivalent in the DOT language." }
{ $examples
  "Instead of writing"
  { $code
    "<graph>"
    "    \"foo\" <node> \"red\" =color add"
  }
  "it looks better to write"
  { $code
    "<graph>"
    "    \"foo\" [add-node \"red\" =color ];"
  }
  "Compare this with the DOT language, where you'd write"
  { $code
    "graph {"
    "    foo [ color=\"red\" ];"
    "}"
  }
}
;

HELP: [edge
{ $values
        { "attrs" edge-attributes }
}
{ $description "Shorthand for " { $link <edge-attributes> } " to be used with " { $link ]; } " and attribute-setting generic words (see " { $link { "graphviz.notation" "=attrs" } } ") so that adding " { $link edge-attributes } " to a " { $link graph } " or " { $link subgraph } " reads more like the equivalent in the DOT language." }
{ $examples
  "Instead of writing"
  { $code
    "<graph>"
    "    <edge-attributes> \"red\" =color add"
  }
  "it looks better to write"
  { $code
    "<graph>"
    "    [edge \"red\" =color ];"
  }
  "Compare this with the DOT language, where you'd write"
  { $code
    "graph {"
    "    [edge color=\"red\" ];"
    "}"
  }
}
;

HELP: [graph
{ $values
        { "attrs" graph-attributes }
}
{ $description "Shorthand for " { $link <graph-attributes> } " to be used with " { $link ]; } " and attribute-setting generic words (see " { $link { "graphviz.notation" "=attrs" } } ") so that adding " { $link graph-attributes } " to a " { $link graph } " or " { $link subgraph } " reads more like the equivalent in the DOT language." }
{ $notes "This word is rendered redundant by the " { $link graph } " and " { $link subgraph } " methods defined by " { $vocab-link "graphviz.notation" } " for setting attributes. Sometimes it still might look better to delineate certain attribute-setting code." }
{ $examples
  "Instead of writing"
  { $code
    "<graph>"
    "    <graph-attributes> \"LR\" =rankdir \"blah\" =label add"
  }
  "it looks better to write"
  { $code
    "<graph>"
    "    [graph \"LR\" =rankdir \"blah\" =label ];"
  }
  "Compare this with the DOT language, where you'd write"
  { $code
    "graph {"
    "    [graph rankdir=\"LR\" label=\"blah\" ];"
    "}"
  }
  $nl
  "Of course, you could just write"
  { $code
    "<graph>"
    "    \"LR\" =rankdir"
    "    \"blah\" =label"
  }
  "Similarly, in the DOT language you could just write"
  { $code
    "graph {"
    "    rankdir=\"LR\""
    "    label=\"blah\""
    "}"
  }
}
;

HELP: [node
{ $values
        { "attrs" node-attributes }
}
{ $description "Shorthand for " { $link <node-attributes> } " to be used with " { $link ]; } " and attribute-setting generic words (see " { $link { "graphviz.notation" "=attrs" } } ") so that adding " { $link node-attributes } " to a " { $link graph } " or " { $link subgraph } " reads more like the equivalent in the DOT language." }
{ $examples
  "Instead of writing"
  { $code
    "<graph>"
    "    <node-attributes> \"red\" =color add"
  }
  "it looks better to write"
  { $code
    "<graph>"
    "    [node \"red\" =color ];"
  }
  "Compare this with the DOT language, where you'd write"
  { $code
    "graph {"
    "    [node color=\"red\" ];"
    "}"
  }
}
;

HELP: ~--
{ $values
    { "graph" { $or graph subgraph } }
    { "nodes" sequence }
    { "graph'" { $or graph subgraph } }
}
{ $description "Shorthand for " { $link add-path } ". Meant to be a Factor replacement for the DOT language's more verbose path notation." }
{ $examples
    "Instead of writing"
    { $code
      "<graph>"
      "    1 2 --"
      "    2 3 --"
      "    3 4 --"
    }
    "you can write"
    { $code
      "<graph>"
      "    { 1 2 3 4 } ~--"
    }
    "whereas in the DOT language you'd write"
    { $code
      "graph {"
      "    1 -- 2 -- 3 -- 4"
      "}"
    }
}
;

HELP: ~->
{ $values
    { "graph" { $or graph subgraph } }
    { "nodes" sequence }
    { "graph'" { $or graph subgraph } }
}
{ $description "Shorthand for " { $link add-path } ". Meant to be a Factor replacement for the DOT language's more verbose path notation." }
{ $examples
    "Instead of writing"
    { $code
      "<digraph>"
      "    1 2 ->"
      "    2 3 ->"
      "    3 4 ->"
    }
    "you can write"
    { $code
      "<digraph>"
      "    { 1 2 3 4 } ~->"
    }
    "whereas in the DOT language you'd write"
    { $code
      "digraph {"
      "    1 -> 2 -> 3 -> 4"
      "}"
    }
}
;

ARTICLE: { "graphviz.notation" "=attrs" } "Notation for setting Graphviz attributes"
"The " { $vocab-link "graphviz.notation" } " vocabulary provides words for setting Graphviz attributes in a way that looks similar to the DOT language (see " { $url "https://graphviz.org/content/dot-language" } ")."
$nl
"For every slot named, say, " { $snippet "attr" } " in the " { $link node-attributes } ", " { $link edge-attributes } ", and " { $link graph-attributes } " tuples, a generic word named " { $snippet "=attr" } " is defined with the stack effect " { $snippet "( graphviz-obj val -- graphviz-obj' )" } "."
$nl
"In each such " { $snippet "=attr" } " word, " { $snippet "val" } " must be an object supported by the " { $link present } " word, which is always called on " { $snippet "val" } " before it's stored in a slot."
$nl
"These generics will \"do the right thing\" in setting the corresponding attribute of " { $snippet "graphviz-obj" } "."
$nl
"For example, since " { $link graph-attributes } " has a " { $slot "label" } " slot, the generic " { $link =label } " is defined, along with methods so that if " { $snippet "graphviz-obj" } " is a..."
{ $list
    { "..." { $link graph } " or " { $link subgraph } ", a new " { $link graph-attributes } " instance is created, has its " { $slot "label" } " slot set to " { $snippet "val" } ", and is " { $link add } "ed to " { $snippet "graphviz-obj" } "." }
    { "..." { $link graph-attributes } " instance, its " { $slot "label" } " slot is set to " { $snippet "val" } "." }
}
$nl
"Since " { $link edge-attributes } " has a " { $slot "label" } " slot, further methods are defined so that if " { $snippet "graphviz-obj" } " is an..."
{ $list
    { "..." { $link edge } ", its " { $slot "attributes" } " slot has its " { $slot "label" } " slot set to " { $snippet "val" } "." }
    { "..." { $link edge-attributes } " instance, its " { $slot "label" } " slot is set to " { $snippet "val" } "." }
}
$nl
"Finally, since " { $link node-attributes } " has a " { $slot "label" } " slot, still more methods are defined so that if " { $snippet "graphviz-obj" } " is a..."
{ $list
    { "..." { $link node } ", its " { $slot "attributes" } " slot has its " { $slot "label" } " slot set to " { $snippet "val" } "." }
    { "..." { $link node-attributes } " instance, its " { $slot "label" } " slot is set to " { $snippet "val" } "." }
}
$nl
"Thus, instead of"
{ $code
  "<graph>"
  "    <graph-attributes>"
  "        \"Bad-ass graph\" >>label"
  "    add"
  "    1 2 <edge> dup attributes>>"
  "        \"This edge is dumb\" swap label<<"
  "    add"
  "    3 <node> dup attributes>>"
  "        \"This node is cool\" swap label<<"
  "    add"
}
"you can simply write"
{ $code
  "<graph>"
  "    \"Bad-ass graph\" =label"
  "    1 2 <edge>"
  "        \"This edge is dumb\" =label"
  "    add"
  "    3 <node>"
  "        \"This node is cool\" =label"
  "    add"
}
$nl
"However, since the slot " { $slot "labelloc" } " only exists in " { $link graph-attributes } " and " { $link node-attributes } ", there won't be a method for " { $link edge } " or " { $link edge-attributes } " objects:"
{ $example
    "USING: continuations graphviz graphviz.notation io kernel ;"
    "<graph>"
    "    ! This is OK:"
    "    \"t\" =labelloc"
    ""
    "    ! This is not OK:"
    "    [ 1 2 <edge> \"b\" =labelloc add ]"
    "    [ drop \"not for edges!\" write ] recover drop"
    "not for edges!"
}
$nl
"For the full list of attribute-setting words, consult the list of generic words for the " { $vocab-link "graphviz.notation" } " vocabulary."
;

ARTICLE: { "graphviz.notation" "synonyms" } "Aliases that resemble DOT code"
"The " { $vocab-link "graphviz.notation" } " vocabulary provides aliases for words defined in the " { $vocab-link "graphviz" } " and " { $vocab-link "graphviz.attributes" } " vocabularies. These will make Factor code read more like DOT code (see " { $url "https://graphviz.org/content/dot-language" } ")."
$nl
"Notation for edges without attributes:"
{ $subsections
    --
    ->
    ~--
    ~->
}
"Notation for nodes/edges with local attributes:"
{ $subsections
    [add-node
    [add-edge
    [--
    [->
}
"Notation for global attributes:"
{ $subsections
    [node
    [edge
    [graph
}
"Word to \"close off\" notation for attributes:"
{ $subsections
    ];
}
;

ARTICLE: "graphviz.notation" "Graphviz notation"
"The " { $vocab-link "graphviz.notation" } " vocabulary provides words for building " { $link graph } "s in a way that looks similar to the DOT language (see " { $url "https://graphviz.org/content/dot-language" } ")."
$nl
"The " { $vocab-link "graphviz" } " vocabulary alone already follows the general structure of the DOT language: " { $link graph } "s and " { $link subgraph } "s consist of an ordered sequence of " { $slot "statements" } "; each statement will " { $link add } " either a " { $link node } ", an " { $link edge } ", or some attribute declaration (" { $links graph-attributes node-attributes edge-attributes } "); and " { $slot "attributes" } " may be set on individual " { $link node } "s and " { $link edge } "s. Even some DOT niceties are already supported, like being able to have an " { $link edge } " between anonymous " { $link subgraph } "s. For instance, compare"
{ $code
  "<digraph>"
  "    { 1 2 3 } { 4 5 6 } add-edge"
}
"with the DOT code"
{ $code
  "digraph {"
  "    { 1 2 3 } -> { 4 5 6 }"
  "}"
}
$nl
"However, there are some rough points that this vocabulary addresses:"
{ $subsections
    { "graphviz.notation" "=attrs" }
    { "graphviz.notation" "synonyms" }
}
;

ABOUT: "graphviz.notation"
