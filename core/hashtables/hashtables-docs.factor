USING: hashtables.private help.markup help.syntax
kernel prettyprint generic sequences sequences.private
namespaces assocs ;
IN: hashtables

ARTICLE: "hashtables.private" "Hashtable implementation details"
"This hashtable implementation uses only one auxilliary array in addition to the hashtable tuple itself. The array stores keys in even slots and values in odd slots. Values are looked up with a hashing strategy that uses linear probing to resolve collisions."
$nl
"There are two special objects: the " { $link ((tombstone)) } " marker and the " { $link ((empty)) } " marker. Neither of these markers can be used as hashtable keys."
$nl
"The " { $snippet "count" } " slot is the number of entries including deleted entries, and " { $snippet "deleted" } " is the number of deleted entries."
{ $subsection <hash-array> }
{ $subsection set-nth-pair }
"If a hashtable's keys are mutated, or if hashing algorithms change, hashtables can be rehashed:"
{ $subsection rehash } ;

ARTICLE: "hashtables" "Hashtables"
"A hashtable provides efficient (expected constant time) lookup and storage of key/value pairs. Keys are compared for equality, and a hashing function is used to reduce the number of comparisons made. The literal syntax is covered in " { $link "syntax-hashtables" } "."
$nl
"Words for constructing hashtables are in the " { $vocab-link "hashtables" } " vocabulary. Hashtables implement the " { $link "assocs-protocol" } ", and all " { $link "assocs" } " can be used on them; there are no hashtable-specific words to access and modify keys, because associative mapping operations are generic and work with all associative mappings."
$nl
"Hashtables are a class of objects."
{ $subsection hashtable }
{ $subsection hashtable? }
"You can create a new hashtable with an initial capacity."
{ $subsection <hashtable> }
"If you don't care about initial capacity, a more elegant way to create a new hashtable is to write:"
{ $code "H{ } clone" }
"To convert an assoc to a hashtable:"
{ $subsection >hashtable }
"Further topics:"
{ $subsection "hashtables.keys" }
{ $subsection "hashtables.utilities" }
{ $subsection "hashtables.private" } ;

ARTICLE: "hashtables.keys" "Hashtable keys"
"Hashtables rely on the " { $link hashcode } " word to rapidly locate values associated with keys. The objects used as keys in a hashtable must obey certain restrictions."
$nl
"The " { $link hashcode } " of a key is a function of the its slot values, and if the hashcode changes then the hashtable will be left in an inconsistent state. The easiest way to avoid this problem is to never mutate objects used as hashtable keys."
$nl
"In certain advanced applications, this cannot be avoided and the best design involves mutating hashtable keys. In this case, a custom " { $link hashcode* } " method must be defined which only depends on immutable slots."
$nl
"In addition, the " { $link equal? } " and " { $link hashcode* } " methods must be congruent, and if one is defined the other should be defined also. This is documented in detail in the documentation for these respective words." ;

ARTICLE: "hashtables.utilities" "Hashtable utilities"
"Utility words to create a new hashtable from a single key/value pair:"
{ $subsection associate }
{ $subsection ?set-at } ;

ABOUT: "hashtables"

HELP: hashtable
{ $description "The class of hashtables. See " { $link "syntax-hashtables" } " for syntax and " { $link "hashtables" } " for general information." } ;

HELP: hash@
{ $values { "key" "a key" } { "array" "the underlying array of a hashtable" } { "i" "the index to begin hashtable search" } }
{ $description "Computes the index to begin searching from the hashcode of the key. Always outputs an even value since keys are stored at even indices of the underlying array." } ;

HELP: probe
{ $values { "array" "the underlying array of a hashtable" } { "i" "a search index" } }
{ $description "Outputs the next hashtable search index." } ;

HELP: key@
{ $values { "key" "a key" } { "hash" hashtable } { "array" "the underlying array of the hashtable" } { "n" "the index of the key" } { "?" "a boolean indicating whether the key was present" } }
{ $description "Searches the hashtable for the key using a linear probing strategy. Searches stop if either the key or an " { $link ((empty)) } " sentinel is found. Searches skip the " { $link ((tombstone)) } " sentinel." } ;

{ key@ new-key@ } related-words

HELP: new-key@
{ $values { "key" "a key" } { "hash" hashtable } { "array" "the underlying array of the hashtable" } { "n" "the index where the key would be stored" } { "empty?" "a boolean indicating whether the location is currently empty" } }
{ $description "Searches the hashtable for the key using a linear probing strategy. If the key is not present in the hashtable, outputs the index where it should be stored." } ;

HELP: set-nth-pair
{ $values { "value" "the second element of the pair" } { "key" "the first element of the pair" } { "seq" "a sequence" } { "n" "an index in the sequence" } }
{ $description "Stores a pair of values into the elements with index " { $snippet "n" } " and " { $snippet "n+1" } ", respectively." }
{ $warning "This word is in the " { $vocab-link "hashtables.private" } " vocabulary because it does not perform bounds checks." }
{ $side-effects "seq" } ;

HELP: reset-hash
{ $values { "n" "a positive integer specifying hashtable capacity" } { "hash" hashtable } }
{ $description "Resets the underlying array of the hashtable to a new array with the given capacity. Removes all entries from the hashtable." }
{ $side-effects "hash" } ;

HELP: hash-count+
{ $values { "hash" hashtable } }
{ $description "Called to increment the hashtable size when a new entry is added with " { $link set-at } }
{ $side-effects "hash" } ;

HELP: hash-deleted+
{ $values { "hash" hashtable } }
{ $description "Called to increment the deleted entry counter when an entry is removed with " { $link delete-at } }
{ $side-effects "hash" } ;

HELP: grow-hash
{ $values { "hash" hashtable } }
{ $description "Enlarges the capacity of a hashtable. User code does not need to call this word directly." }
{ $side-effects "hash" } ;

HELP: ?grow-hash
{ $values { "hash" hashtable } }
{ $description "Enlarges the capacity of a hashtable if it is almost full. User code does not need to call this word directly." }
{ $side-effects "hash" } ;

HELP: <hashtable>
{ $values { "n" "a positive integer specifying hashtable capacity" } { "hash" "a new hashtable" } }
{ $description "Create a new hashtable capable of storing " { $snippet "n" } " key/value pairs before growing." } ;

HELP: associate
{ $values { "value" "a value" } { "key" "a key" } { "hash" "a new " { $link hashtable } } }
{ $description "Create a new hashtable holding one key/value pair." } ;

HELP: ?set-at
{ $values
     { "value" object } { "key" object } { "assoc/f" "an assoc or " { $link f } }
     { "assoc" assoc } }
{ $description "If the third input is an assoc, stores the key/value pair into that assoc, or else creates a new hashtable with the key/value pair as its only entry." } ;

HELP: >hashtable
{ $values { "assoc" assoc } { "hashtable" hashtable } }
{ $description "Constructs a hashtable from any assoc." } ;

HELP: rehash
{ $values { "hash" hashtable } }
{ $description "Rebuild the hashtable. This word should be called if the hashcodes of the hashtable's keys have changed, or if the hashing algorithms themselves have changed, neither of which should occur during normal operation." } ;
