USING: bencode help.markup help.syntax kernel strings ;
IN: bencode+docs

HELP: >bencode
{ $values { "obj" object } { "bencode" string } }
{ $description "Encodes an object using the bencode algorithm." } ;

HELP: bencode>
{ $values { "bencode" string } { "obj" object } }
{ $description "Decodes an object using the bencode algorithm." } ;
