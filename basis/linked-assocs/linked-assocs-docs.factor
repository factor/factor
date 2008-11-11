IN: linked-assocs
USING: help.markup help.syntax assocs ;

HELP: linked-assoc
{ $class-description "The class of linked assocs. Linked assoc are implemented by combining an assocs and a dlist.  The assoc is used for lookup and retrieval of single values, while the dlist is used for getting lists of keys/values, which will be in insertion order." } ;

HELP: <linked-hash>
{ $values { "assoc" "A new linked-assoc" } }
{ $description "Creates a new, empty linked assoc." } ;

ARTICLE: "linked-assocs" "Linked assocs"
"A " { $emphasis "linked assoc" } " is an assoc which combines a hash table and a dlist to form a structure which has the insertion and retrieval characteristics of a hash table, but with the ability to get the items in insertion order."
$nl
"Linked assocs implement the following methods from the assoc protocol:"
{ $subsection at* }
{ $subsection assoc-size }
{ $subsection >alist }
{ $subsection set-at }
{ $subsection delete-at }
{ $subsection clear-assoc }
{ $subsection >alist } ;

ABOUT: "linked-assocs"