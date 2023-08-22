! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.crossref help.stylesheet help.topics help.syntax
definitions io prettyprint summary arrays math sequences vocabs strings
see ;
IN: game.models

HELP: model
{ $class-description "Tuple of a packed attribute buffer, index buffer, vertex format and material suitable for a single OpenGL draw call." } ;
