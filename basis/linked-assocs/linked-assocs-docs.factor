IN: linked-assocs
USING: assocs help.markup help.syntax linked-assocs.prettyprint ;

HELP: linked-assoc
{ $class-description "The class of linked assocs. Linked assoc are implemented by combining an assoc with a dlist. The assoc is used for lookup and retrieval of single values, while the dlist is used for getting lists of keys/values, which will be in insertion order." } ;

HELP: <linked-assoc>
{ $values { "exemplar" "an exemplar assoc" } { "assoc" linked-assoc } }
{ $description "Creates an empty linked assoc backed by a new instance of the same type as the exemplar." } ;

HELP: >linked-hash
{ $values { "assoc" assoc } { "assoc'" linked-hash } }
{ $description "Creates a new " { $link linked-hash } " containing the same elements as 'assoc'. The keys are inserted in the same order as the input assoc, if it has an order." } ;

HELP: <linked-hash>
{ $values { "assoc" linked-assoc } }
{ $description "Creates an empty linked assoc backed by a hashtable." } ;

ARTICLE: "linked-assocs" "Linked assocs"
"A " { $emphasis "linked assoc" } " is an assoc which combines an underlying assoc with a dlist to form a structure which has the insertion and retrieval characteristics of the underlying assoc (typically a hashtable), but with the ability to get the entries in insertion order by calling " { $link >alist } "."
$nl
"Linked assocs are implemented in the " { $vocab-link "linked-assocs" } " vocabulary."
{ $subsections
    linked-assoc
    <linked-hash>
    <linked-assoc>
} ;

ABOUT: "linked-assocs"
