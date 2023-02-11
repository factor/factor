! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: assocs game.models.obj.private help.markup help.syntax
io.pathnames kernel sequences strings ;
IN: game.models.obj

ABOUT: "game.models.obj"

ARTICLE: "game.models.obj" "Conversion of Wavefront OBJ assets"
"The " { $vocab-link "game.models.obj" } " vocabulary implements words for converting Wavefront OBJ assets to data suitable for use with OpenGL." ;

HELP: material
{ $class-description "Tuple describing the GPU state that needs to be applied prior to rendering geometry tagged with this material." } ;

HELP: cm
{ $values { "current-material" material } }
{ $description "Convenience word for accessing the current material while parsing primitives." } ;

HELP: md
{ $values { "material-dictionary" assoc } }
{ $description "Convenience word for accessing the material dictionary while parsing primitives." } ;

HELP: strings>numbers
{ $values { "strings" sequence } { "numbers" sequence } }
{ $description "Convert a sequence of strings to a sequence of numbers." } ;

HELP: strings>faces
{ $values { "strings" sequence } { "faces" sequence } }
{ $description "Convert a sequence of '/'-delimited strings into a sequence of sequences of numbers. Each number is an index into the vertex, texture or normal tables, respectively." } ;

HELP: split-string
{ $values { "string" string } { "strings" sequence } }
{ $description "Split the given string on whitespace." } ;

HELP: line>mtl
{ $values { "line" string } }
{ $description "Process a line from a material file within the current parsing context." } ;

HELP: read-mtl
{ $values { "file" pathname } { "material-dictionary" assoc } }
{ $description "Read the specified material file and generate a material dictionary keyed by material name." } ;

HELP: obj-vertex-format
{ $class-description "Vertex format used for rendering OBJ geometry." } ;

HELP: triangle>aos
{ $values { "x" sequence } { "y" sequence } }
{ $description "Convert a sequence of vertex, texture and normal indices into a sequence of vertex, texture and normal values." } ;

HELP: quad>aos
{ $values { "x" sequence } { "y" sequence } { "z" sequence } }
{ $description "Convert a sequence of vertex, texture and normal indices into two sequences of vertex, texture and normal values. This splits a quad into two triangles." } ;

HELP: face>aos
{ $values { "x" sequence } { "y" sequence } }
{ $description "Convert a face line to a sequence of vertex attributes." } ;

HELP: push*
{ $values { "elt" object } { "seq" sequence } }
{ $description "Push the value onto the sequence, keeping the sequence on the stack." } ;

HELP: push-current-model
{ $description "Push the current model being built onto the models list and initialize a fresh empty model." } ;

HELP: line>obj
{ $values { "line" string } }
{ $description "Process a line from the object file within the current parsing context." } ;
