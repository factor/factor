! Copyright (C) 2007 Daniel Ehrenberg and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences
sequences.private namespaces classes math ;
IN: assocs

ARTICLE: "alists" "Association lists"
"An " { $emphasis "association list" } ", abbreviated " { $emphasis "alist" } ", is an association represented as a sequence where all elements are key/value pairs. The " { $link sequence } " mixin is an instance of the " { $link assoc } " mixin, hence all sequences support the " { $link "assocs-protocol" } " in this way."
$nl
"While not an association list, note that " { $link f } " also implements the associative mapping protocol in a trivial way; it is an immutable assoc with no entries."
$nl
"An alist is slower to search than a hashtable for a large set of associations. The main advantage of an association list is that the elements are ordered; also sometimes it is more convenient to construct an association list with sequence words than to construct a hashtable with association words. Much of the time, hashtables are more appropriate. See " { $link "hashtables" } "."
$nl
"There is no special syntax for literal alists since they are just sequences; in practice, literals look like so:"
{ $code "{" "    { key1 value1 }" "    { key2 value2 }" "}" }
"To make an assoc into an alist:"
{ $subsection >alist } ;

ARTICLE: "assocs-protocol" "Associative mapping protocol"
"All associative mappings must be instances of a mixin class:"
{ $subsection assoc }
{ $subsection assoc? }
"All associative mappings must implement methods on the following generic words:"
{ $subsection at* }
{ $subsection assoc-size }
"At least one of the following two generic words must have a method; the " { $link assoc } " mixin has default definitions which are mutually recursive:"
{ $subsection >alist }
{ $subsection assoc-find }
"Mutable assocs should implement the following additional words:"
{ $subsection set-at }
{ $subsection delete-at }
{ $subsection clear-assoc }
"The following two words are optional:"
{ $subsection new-assoc }
{ $subsection assoc-like }
"Assocs should also implement methods on the " { $link clone } ", " { $link equal? } " and " { $link hashcode } " generic words. Two utility words will help with the implementation of the last two:"
{ $subsection assoc= }
{ $subsection assoc-hashcode }
"Finally, assoc classes should define a word for converting other types of assocs; conventionally, such words are named " { $snippet ">" { $emphasis "class" } } " where " { $snippet { $emphasis "class" } } " is the class name. Such a word can be implemented using a utility:"
{ $subsection assoc-clone-like } ;

ARTICLE: "assocs-lookup" "Lookup and querying of assocs"
"Utility operations built up from the " { $link "assocs-protocol" } ":"
{ $subsection key? }
{ $subsection at }
{ $subsection value-at }
{ $subsection assoc-empty? }
{ $subsection keys }
{ $subsection values }
{ $subsection assoc-stack }
{ $see-also at* assoc-size } ;

ARTICLE: "assocs-sets" "Set-theoretic operations on assocs"
"It is often useful to use the keys of an associative mapping as a set, exploiting the constant or logarithmic lookup time of most implementations (" { $link "alists" } " being a notable exception)."
{ $subsection subassoc? }
{ $subsection intersect }
{ $subsection update }
{ $subsection union }
{ $subsection diff }
{ $subsection remove-all }
{ $subsection substitute }
{ $see-also key? } ;

ARTICLE: "assocs-mutation" "Storing keys and values in assocs"
"Utility operations built up from the " { $link "assocs-protocol" } ":"
{ $subsection delete-at* }
{ $subsection rename-at }
{ $subsection change-at }
{ $subsection at+ }
{ $see-also set-at delete-at clear-assoc } ;

ARTICLE: "assocs-combinators" "Associative mapping combinators"
"The following combinators can be used on any associative mapping."
$nl
"The " { $link assoc-find } " combinator is part of the " { $link "assocs-protocol" } " and must be implemented once for each class of assoc. All other combinators are implemented in terms of this combinator."
$nl
"The standard functional programming idioms:"
{ $subsection assoc-each }
{ $subsection assoc-map }
{ $subsection assoc-push-if }
{ $subsection assoc-subset }
{ $subsection assoc-all? }
"Three additional combinators:"
{ $subsection cache }
{ $subsection map>assoc }
{ $subsection assoc>map } ;

ARTICLE: "assocs" "Associative mapping operations"
"An " { $emphasis "associative mapping" } ", abbreviated " { $emphasis "assoc" } ", is a collection of key/value pairs which provides efficient lookup and storage indexed by key."
$nl
"Words used for working with assocs are in the " { $vocab-link "assocs" } " vocabulary."
$nl
"Associative mappings implement a protocol:"
{ $subsection "assocs-protocol" }
"A large set of utility words work on any object whose class implements the associative mapping protocol."
{ $subsection "assocs-lookup" }
{ $subsection "assocs-mutation" }
{ $subsection "assocs-combinators" }
{ $subsection "assocs-sets" } ;

ABOUT: "assocs"

HELP: assoc
{ $class-description "A mixin class whose instances are associative mappings. Custom implementations of the assoc protocol should be declared as instances of this mixin for all assoc functionality to work correctly:"
    { $code "INSTANCE: avl-tree assoc" }
} ;

HELP: at*
{ $values { "key" "an object to look up in the assoc" } { "assoc" assoc } { "value/f" "the value associated to the key, or " { $link f } " if the key is not present in the assoc" } { "?" "a boolean indicating if the key was present" } }
{ $contract "Looks up the value associated with a key. The boolean flag can decide between the case of a missing value, and a value of " { $link f } "." } ;

HELP: set-at
{ $values { "value" "a value" } { "key" "a key to add" } { "assoc" assoc } }
{ $contract "Stores the key/value pair into the assoc." }
{ $side-effects "assoc" } ;

HELP: new-assoc
{ $values { "capacity" "a non-negative integer" } { "exemplar" assoc } { "newassoc" assoc } }
{ $contract "Creates a new assoc of the same size as " { $snippet "exemplar" } " which can hold " { $snippet "capacity" } " entries before growing." } ;

HELP: assoc-find
{ $values { "assoc" assoc } { "quot" "a quotation with stack effect " { $snippet "( key value -- ? )" } } { "key" "the successful key, or f" } { "value" "the successful value, or f" } { "?" "a boolean" } }
{ $contract "Applies a predicate quotation to each entry in the assoc. Returns the key or value that the quotation succeeds on, or " { $link f } " for both if the quotation fails. It also returns a boolean describing whether there was anything found." }
{ $notes "The " { $link assoc } " mixin has a default implementation for this generic word which first converts the assoc to an association list, then iterates over that with the " { $link find } " combinator for sequences." } ;

HELP: clear-assoc
{ $values { "assoc" assoc } }
{ $contract "Removes all entries from the assoc."  }
{ $side-effects "assoc" } ;

HELP: delete-at
{ $values { "key" "a key" } { "assoc" assoc } }
{ $contract "Removes an entry from the assoc." }
{ $side-effects "assoc" } ;

HELP: assoc-size
{ $values { "assoc" assoc } { "n" "a non-negative integer" } }
{ $contract "Outputs the number of entries stored in the assoc." } ;

HELP: assoc-like
{ $values { "assoc" assoc } { "exemplar" assoc } { "newassoc" "a new assoc" } }
{ $contract "Creates a new assoc having the same entries as  "{ $snippet "assoc" } " and the same type as " { $snippet "exemplar" } "." } ;

HELP: assoc-empty?
{ $values { "assoc" assoc } { "?" "a boolean" } }
{ $description "Tests if the assoc contains no entries." } ;

HELP: key?
{ $values { "key" object } { "assoc" assoc } { "?" "a boolean" } }
{ $description "Tests if an assoc contains a key." } ;

{ at at* key? } related-words

HELP: at
{ $values { "key" "an object" } { "assoc" assoc } { "value/f" "the value associated to the key, or " { $link f } " if the key is not present in the assoc" } }
{ $description "Looks up the value associated with a key. This word makes no distinction between a missing value and a value set to " { $link f } "; if the difference is important, use " { $link at* } "." } ;

HELP: assoc-each
{ $values { "assoc" assoc } { "quot" "a quotation with stack effect " { $snippet "( key value -- )" } } }
{ $description "Applies a quotation to each entry in the assoc." }
{ $examples
    { $example
        "H{ { \"bananas\" 5 } { \"apples\" 42 } { \"pears\" 17 } }"
        "0 swap [ nip + ] assoc-each ."
        "64"
    }
} ;

HELP: assoc-map
{ $values { "assoc" assoc } { "quot" "a quotation with stack effect " { $snippet "( key value -- newkey newvalue )" } } { "newassoc" "a new assoc" } }
{ $description "Applies the quotation to each entry in the input assoc and collects the results in a new assoc of the same type as the input." }
{ $examples
    { $unchecked-example
        ": discount ( prices n -- newprices )"
        "    [ - ] curry assoc-each ;"
        "H{ { \"bananas\" 5 } { \"apples\" 42 } { \"pears\" 17 } }"
        "2 discount ."
        "H{ { \"bananas\" 3 } { \"apples\" 39 } { \"pears\" 15 } }"
    }
} ;

HELP: assoc-push-if
{ $values { "accum" "a resizable mutable sequence" } { "quot" "a quotation with stack effect " { $snippet "( key value -- ? )" } } { "key" object } { "value" object } }
{ $description "If the quotation yields true when applied to the key/value pair, adds the key/value pair at the end of " { $snippet "accum" } "." } ;

HELP: assoc-subset
{ $values { "assoc" assoc } { "quot" "a quotation with stack effect " { $snippet "( key value -- ? )" } } { "subassoc" "a new assoc" } }
{ $description "Outputs an assoc of the same type as " { $snippet "assoc" } " consisting of all entries for which the predicate quotation yields true." } ;

HELP: assoc-all?
{ $values { "assoc" assoc } { "quot" "a quotation with stack effect " { $snippet "( key value -- ? )" } } { "?" "a boolean" } }
{ $description "Applies a predicate quotation to entry in the assoc. Outputs true if the assoc yields true for each entry (which includes the case where the assoc is empty)." } ;

HELP: subassoc?
{ $values { "assoc1" assoc } { "assoc2" assoc } { "?" "a new assoc" } }
{ $description "Tests if " { $snippet "assoc2" } " contains all key/value pairs of " { $snippet "assoc1" } "." } ;

HELP: assoc=
{ $values { "assoc1" assoc } { "assoc2" assoc } { "?" "a boolean" } }
{ $description "Tests if two assocs contain the same entries. Unlike " { $link = } ", the two assocs may be of different types." }
{ $notes "Assoc implementations should define a method for the " { $link equal? } " generic word which calls this word after checking that both inputs have the same type." } ;

HELP: assoc-hashcode
{ $values { "n" "a non-negative integer" } { "assoc" assoc } { "code" integer } }
{ $description "Computes a hashcode for an assoc, such that equal assocs will have the same hashcode." }
{ $notes "Custom assoc implementations should use this word to implement a method for the " { $link hashcode* } " generic word." } ;

HELP: assoc-stack
{ $values { "key" "a key" } { "seq" "a sequence of assocs" } { "value" "a value or " { $link f } } }
{ $description "Searches for the key in successive elements of the sequence, starting from the end. If an assoc containing the key is found, the associated value is output. If no assoc contains the key, outputs " { $link f } "." }
{ $notes "This word is used to implement abstractions such as nested scopes; if the sequence is a stack represented by a vector, then the most recently pushed assoc -- the innermost scope -- will be searched first." } ;

HELP: value-at
{ $values { "value" "an object" } { "assoc" assoc } { "key/f" "the key associated to the value, or " { $link f } } }
{ $description "Looks up the key associated with a value. No distinction is made between a missing key and a key set to " { $link f } "." }
{ $notes "This word runs in linear time, proportional to the number of entries in the assoc." } ;

HELP: delete-at*
{ $values { "key" "a key" } { "assoc" assoc } { "old" "the previous value or " { $link f } } { "?" "a boolean" } }
{ $description "Removes an entry from the assoc and outputs the previous value together with a boolean indicating whether it was present." }
{ $side-effects "assoc" } ;

HELP: rename-at
{ $values { "newkey" object } { "key" object } { "assoc" assoc } }
{ $description "Removes the values associated to " { $snippet "key" } " and re-adds it as " { $snippet "newkey" } ". Does nothing if the assoc does not contain " { $snippet "key" } "." }
;

HELP: keys
{ $values { "assoc" assoc } { "keys" "an array of keys" } }
{ $description "Outputs an array of all keys in the assoc." } ;

HELP: values
{ $values { "assoc" assoc } { "values" "an array of values" } }
{ $description "Outputs an array of all values in the assoc." } ;

{ keys values } related-words

HELP: intersect
{ $values { "assoc1" assoc } { "assoc2" assoc } { "intersection" "a new assoc" } }
{ $description "Outputs an assoc consisting of all entries from " { $snippet "assoc2" } " such that the key is also present in " { $snippet "assoc1" } "." }
{ $notes "The values of the keys in " { $snippet "assoc1" } " are disregarded, so this word is usually used for set-theoretic calculations where the assoc in question either has dummy sentinels as values, or the values equal the keys." } ;

HELP: update
{ $values { "assoc1" assoc } { "assoc2" assoc } }
{ $description "Adds all entries from " { $snippet "assoc2" } " to " { $snippet "assoc1" } "." }
{ $side-effects "assoc1" } ;

HELP: union
{ $values { "assoc1" assoc } { "assoc2" assoc } { "union" "a new assoc" } }
{ $description "Outputs a assoc consisting of all entries from " { $snippet "assoc1" } " and " { $snippet "assoc2" } ", with entries from " { $snippet "assoc2" } " taking precedence in case the corresponding values are not equal." } ;

HELP: diff
{ $values { "assoc1" assoc } { "assoc2" assoc } { "diff" "a new assoc" } }
{ $description "Outputs an assoc consisting of all entries from " { $snippet "assoc2" } " whose key is not contained in " { $snippet "assoc1" } "." } 
;
HELP: remove-all
{ $values { "assoc" assoc } { "seq" "a sequence" } { "subseq" "a new sequence" } }
{ $description "Constructs a sequence consisting of all elements in " { $snippet "seq" } " which do not appear as keys in " { $snippet "assoc" } "." }
{ $notes "The values of the keys in the assoc are disregarded, so this word is usually used for set-theoretic calculations where the assoc in question either has dummy sentinels as values, or the values equal the keys." }
{ $side-effects "assoc" } ;

HELP: substitute
{ $values { "assoc" assoc } { "seq" "a mutable sequence" } }
{ $description "Replaces elements of " { $snippet "seq" } " which appear in as keys in " { $snippet "assoc" } " with the corresponding values, acting as the identity on all other elements." }
{ $errors "Throws an error if " { $snippet "assoc" } " contains values whose types are not permissible in " { $snippet "seq" } "." }
{ $side-effects "seq" } ;

HELP: cache
{ $values { "key" "a key" } { "assoc" assoc } { "quot" "a quotation with stack effect " { $snippet "( key -- value )" } } { "value" "a previously-retained or freshly-computed value" } }
{ $description "If the key is present in the assoc, outputs the associated value, otherwise calls the quotation to produce a value and stores the key/value pair into the assoc." }
{ $side-effects "assoc" } ;

HELP: map>assoc
{ $values { "seq" "a sequence" } { "quot" "a quotation with stack effect " { $snippet "( elt -- key value )" } } { "exemplar" assoc } { "assoc" "a new assoc" } }
{ $description "Applies the quotation to each element of the sequence, and collects the keys and values into a new assoc having the same type as " { $snippet "exemplar" } "." } ;

HELP: assoc>map
{ $values { "assoc" assoc } { "quot" "a quotation with stack effect " { $snippet "( key value -- elt )" } } { "exemplar" "a sequence" } { "seq" "a new sequence" } }
{ $description "Applies the quotation to each entry of the assoc and collects the results into a new sequence of the same type as the exemplar." } ;

HELP: change-at
{ $values { "key" object } { "assoc" assoc } { "quot" "a quotation with stack effect " { $snippet "( value -- newvalue )" } } }
{ $description "Applies the quotation to the value associated with " { $snippet "key" } ", storing the new value back in the assoc." }
{ $side-effects "assoc" } ;

{ change-at change-nth change } related-words

HELP: at+
{ $values { "n" number } { "key" object } { "assoc" assoc } }
{ $description "Adds " { $snippet "n" } " to the value associated with " { $snippet "key" } "; if there is no value, stores " { $snippet "n" } ", thus behaving as if the value was 0." }
{ $side-effects "assoc" } ;

HELP: >alist
{ $values { "assoc" assoc } { "newassoc" "an array of key/value pairs" } }
{ $contract "Converts an associative structure into an association list." }
{ $notes "The " { $link assoc } " mixin has a default implementation for this generic word which constructs the association list by iterating over the assoc with " { $link assoc-find } "." } ;
