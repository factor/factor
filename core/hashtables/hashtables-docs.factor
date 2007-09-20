USING: hashtables.private help.markup help.syntax
kernel prettyprint generic sequences sequences.private
namespaces assocs ;
IN: hashtables

ARTICLE: "hashtables.private" "Hashtable implementation details"
"This hashtable implementation uses only one auxilliary array in addition to the hashtable tuple itself. The array stores keys in even slots and values in odd slots. Values are looked up with a hashing strategy that uses linear probing to resolve collisions."
$nl
"There are two special objects: the " { $link ((tombstone)) } " marker and the " { $link ((empty)) } " marker. Neither of these markers can be used as hashtable keys."
$nl
"The " { $link hash-count } " slot is the number of entries including deleted entries, and " { $link hash-deleted } " is the number of deleted entries."
{ $subsection <hash-array> }
{ $subsection nth-pair }
{ $subsection set-nth-pair }
{ $subsection find-pair }
"If a hashtable's keys are mutated, or if hashing algorithms change, hashtables can be rehashed:"
{ $subsection rehash } ;

ARTICLE: "hashtables" "Hashtables"
"A hashtable provides efficient (expected constant time) lookup and storage of key/value pairs. Keys are compared for equality, and a hashing function is used to reduce the number of comparisons made. The literal syntax is covered in " { $link "syntax-hashtables" } "."
$nl
"Hashtable words are in the " { $vocab-link "hashtables" } " vocabulary. Unsafe implementation words are in the " { $vocab-link "hashtables.private" } " vocabulary."
$nl
"Hashtables implement the " { $link "assocs-protocol" } "."
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
"Utility words to create a new hashtable from a single key/value pair:"
{ $subsection associate }
{ $subsection ?set-at }
"Removing duplicate elements from a sequence in linear time, using a hashtable:"
{ $subsection prune }
{ $subsection "hashtables.private" } ;

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

HELP: nth-pair
{ $values { "n" "an index in the sequence" } { "seq" "a sequence" } { "key" "the first element of the pair" } { "value" "the second element of the pair" } }
{ $description "Fetches the elements with index " { $snippet "n" } " and " { $snippet "n+1" } ", respectively." }
{ $warning "This word is in the " { $vocab-link "hashtables.private" } " vocabulary because it does not perform bounds checks." } ;

{ nth-pair set-nth-pair } related-words

HELP: set-nth-pair
{ $values { "value" "the second element of the pair" } { "key" "the first element of the pair" } { "n" "an index in the sequence" } { "seq" "a sequence" } }
{ $description "Stores a pair of values into the elements with index " { $snippet "n" } " and " { $snippet "n+1" } ", respectively." }
{ $warning "This word is in the " { $vocab-link "hashtables.private" } " vocabulary because it does not perform bounds checks." }
{ $side-effects "seq" } ;

HELP: find-pair
{ $values { "array" "an array of pairs" } { "quot" "a quotation with stack effect " { $snippet "( key value -- ? )" } } { "key" "the successful key" } { "value" "the successful value" } { "?" "a boolean of whether there was success" } }
{ $description "Applies a quotation to successive pairs in the array, yielding the first successful pair." }
{ $warning "This word is in the " { $vocab-link "hashtables.private" } " vocabulary because passing an array of odd length can lead to memory corruption." } ;

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

HELP: (set-hash)
{ $values { "value" "a value" } { "key" "a key to add" } { "hash" hashtable } }
{ $description "Stores the key/value pair into the hashtable. This word does not grow the hashtable if it exceeds capacity, therefore a hang can result. User code should use " { $link set-at } " instead, which grows the hashtable if necessary." }
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

HELP: (hashtable) ( -- hash )
{ $values { "hash" "a new hashtable" } }
{ $description "Allocates a hashtable stub object without an underlying array. User code should call " { $link <hashtable> } " instead." } ;

HELP: associate
{ $values { "value" "a value" } { "key" "a key" } { "hash" "a new " { $link hashtable } } }
{ $description "Create a new hashtable holding one key/value pair." } ;

HELP: >hashtable
{ $values { "assoc" "an assoc" } { "hashtable" "a hashtable" } }
{ $description "Constructs a hashtable from any assoc." } ;

HELP: prune
{ $values { "seq" "a sequence" } { "newseq" "a sequence" } }
{ $description "Outputs a new sequence with each distinct element of " { $snippet "seq" } " appearing only once. Elements are compared for equality using " { $link = } " and elements are ordered according to their position in " { $snippet "seq" } "." }
{ $examples
    { $example "USE: hashtables" "{ 1 1 t 3 t } prune ." "V{ 1 t 3 }" }
} ;

HELP: rehash
{ $values { "hash" hashtable } }
{ $description "Rebuild the hashtable. This word should be called if the hashcodes of the hashtable's keys have changed, or if the hashing algorithms themselves have changed, neither of which should occur during normal operation." } ;
