! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.crossref help.stylesheet help.topics help.syntax
definitions io prettyprint summary arrays math sequences vocabs strings
see xml.data hashtables assocs game.models.collada.private game.models
game.models.util ;
IN: game.models.collada

ABOUT: "game.models.collada"

ARTICLE: "game.models.collada" "Conversion of COLLADA assets"
"The " { $vocab-link "game.models.collada" } " vocabulary implements words for converting COLLADA assets to data suitable for use with OpenGL. See the COLLADA documentation at " { $url "https://collada.org" } "." ;

HELP: source
{ $class-description "Tuple of a vertex attribute semantic, offset in triangle index buffer and float data for a single vertex attribute." } ;

HELP: up-axis
{ $description "Dynamically-scoped variable with the up axis of the tags being read." } ;

HELP: unit-ratio
{ $description "Scaling ratio for the coordinates of the tags being read." } ;

HELP: string>numbers
{ $values { "string" string } { "number-seq" sequence } }
{ $description "Splits a string on whitespace and converts the elements to a number sequence." } ;

HELP: x-up { $class-description "Right-handed 3D coordinate system where X is up." } ;
HELP: y-up { $class-description "Right-handed 3D coordinate system where Y is up." } ;
HELP: z-up { $class-description "Right-handed 3D coordinate system where Z is up." } ;

HELP: >y-up-axis!
{ $values { "seq" sequence } { "from-axis" rh-up } }
{ $description "Destructively swizzles the first three elements of the input sequence to a right-handed 3D coordinate system where Y is up and returns the modified sequence." } ;

HELP: source>sequence
{ $values { "source-tag" tag } { "up-axis" rh-up } { "scale" number } { "sequence" sequence } }
{ $description "Convert the " { $emphasis "float_array" } " in a " { $emphasis "source tag" } " to a sequence of number sequences according to the element stride. The values are scaled according to " { $emphasis "scale" } " and swizzled from " { $emphasis "up-axis" } " so that the Y coordinate points up." } ;

HELP: source>pair
{ $values { "source-tag" tag } { "pair" pair } }
{ $description "Convert the source tag to an id and number sequence pair." } ;

HELP: mesh>sources
{ $values { "mesh-tag" tag } { "hashtable" pair } }
{ $description "Convert the mesh tag's source elements to a hashtable from id to number sequence." } ;

HELP: mesh>vertices
{ $values { "mesh-tag" tag } { "pair" pair } }
{ $description "Convert the mesh tag's vertices element to a pair for further lookup in " { $link collect-sources } "." } ;

HELP: collect-sources
{ $values { "sources" hashtable } { "vertices" pair } { "inputs" tag sequence } { "seq" sequence } }
{ $description "Look up the sources for these " { $emphasis "input" } " elements and return a sequence of " { $link source } " tuples." } ;

HELP: group-indices
{ $values { "index-stride" number } { "triangle-count" number } { "indices" sequence } { "grouped-indices" sequence } }
{ $description "Groups the index sequence by triangle and then groups each triangle's indices by vertex." } ;

HELP: triangles>numbers
{ $values { "triangles-tag" tag } { "number-seq" sequence } }
{ $description "Converts the triangle data in a triangles tag from string form to a sequence of numbers." } ;

HELP: largest-offset+1
{ $values { "source-seq" sequence } { "largest-offset+1" number } }
{ $description "Finds the largest offset in the sequence of " { $link source } " tuples and adds 1, which is the index stride for " { $link group-indices } "." } ;

HELP: pack-attributes
{ $values { "source-indices" sequence } { "sources" sequence } { "attributes" sequence } }
{ $description "Packs the attributes for a single vertex into a sequence from a set of source data streams." } ;

HELP: soa>aos
{ $values { "triangles-indices" sequence } { "sources" sequence } { "attribute-buffer" sequence } { "index-buffer" sequence } }
{ $description "Swizzles the input sources from a structure of arrays form to an array of structures form and generates a new index buffer." } ;

HELP: triangles>model
{ $values { "sources" sequence } { "vertices" pair } { "triangles-tag" tag } { "model" model } }
{ $description "Creates a " { $link model } " tuple from the given triangles tag, source set and vertices pair." } ;

HELP: mesh>triangles
{ $values { "sources" sequence } { "vertices" pair } { "mesh-tag" tag } { "models" sequence } }
{ $description "Creates a sequence of models from the triangles in the mesh tag." } ;

HELP: mesh>models
{ $values { "mesh-tag" tag } { "models" sequence } }
{ $description "Converts a triangle mesh to a set of models suitable for rendering with OpenGL." } ;
