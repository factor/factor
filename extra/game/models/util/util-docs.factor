! Copyright (C) 2010 Erik Charlebois
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.crossref help.stylesheet help.topics help.syntax
definitions io prettyprint summary arrays math sequences vocabs strings
see xml.data hashtables assocs ;
IN: game.models.util

HELP: indexed-seq
{ $class-description "A sequence described by a sequence of unique elements and a sequence of indices. The sequence can only be appended to. An associative map is used as a reverse lookup table when appending." } ;

HELP: <indexed-seq>
{ $values { "dseq-exemplar" sequence } { "iseq-examplar" sequence } { "rassoc-examplar" assoc } }
{ $class-description "Construct an " { $link indexed-seq } " using the given examplars for the underlying data structures." } ;
