USING: arrays bit-arrays help.markup help.syntax
sequences.private vectors strings sbufs kernel math math.vectors
;
IN: sequences

ARTICLE: "sequences-unsafe" "Unsafe sequence operations"
"The " { $link nth-unsafe } " and " { $link set-nth-unsafe } " sequence protocol bypasses bounds checks for increased performance."
$nl
"These words assume the sequence index given is within bounds; if it is not, memory corruption can occur. Great care must be exercised when using these words. First, make sure the code in question is actually a bottleneck; next, try improving the algorithm first. If all else fails, then the unsafe sequence words can be used."
$nl
"There is a very important invariant these word must preserve: if at some point in time, the length of a sequence was " { $snippet "n" } ", then any future lookups of elements with indices below " { $snippet "n" } " must not crash the VM, even if the sequence length is now less than " { $snippet "n" } ". For example, vectors preserve this invariant by never shrinking the underlying storage, only growing it as necessary."
$nl
"The justification for this is that the VM should not crash if a resizable sequence is resized during the execution of an iteration combinator."
$nl
"Indeed, iteration combinators are the primary use-case for these words; if the iteration index is already guarded by a loop test which ensures it is within bounds, then additional bounds checks are redundant. For example, see the implementation of " { $link each } "." ;

ARTICLE: "sequence-protocol" "Sequence protocol"
"All sequences must be instances of a mixin class:"
{ $subsection sequence }
{ $subsection sequence? }
"All sequences must know their length:"
{ $subsection length }
"At least one of the following two generic words must have a method for accessing elements; the " { $link sequence } " mixin has default definitions which are mutually recursive:"
{ $subsection nth }
{ $subsection nth-unsafe }
"At least one of the following two generic words must have a method for storing elements; the " { $link sequence } " mixin has default definitions which are mutually recursive:"
{ $subsection set-nth }
{ $subsection set-nth-unsafe }
"Note that even if the sequence is immutable, at least one of the generic words must be specialized, otherwise calling them will result in an infinite recursion. There is a standard word which throws an error indicating a sequence is immutable:"
{ $subsection immutable }
"The following two generic words are optional, as not all sequences are resizable:"
{ $subsection set-length }
{ $subsection lengthen }
"An optional generic word for creating sequences of the same class as a given sequence:"
{ $subsection like }
"Optional generic words for optimization purposes:"
{ $subsection new }
{ $subsection new-resizable }
{ $see-also "sequences-unsafe" } ;

ARTICLE: "sequences-integers" "Integer sequences and counted loops"
"Integers support the sequence protocol in a trivial fashion; a non-negative integer presents its non-negative predecessors as elements. For example, the integer 3, when viewed as a sequence, contains the elements 0, 1, and 2. This is very useful for performing counted loops."
$nl
"For example, the " { $link each } " combinator, given an integer, simply calls a quotation that number of times, pushing a counter on each iteration that ranges from 0 up to that integer:"
{ $example "3 [ . ] each" "0\n1\n2" }
"A common idiom is to iterate over a sequence, while also maintaining a loop counter. This can be done using " { $link 2each } ":"
{ $example "{ \"a\" \"b\" \"c\" } dup length [\n    \"Index: \" write . \"Element: \" write .\n] 2each" "Index: 0\nElement: \"a\"\nIndex: 1\nElement: \"b\"\nIndex: 2\nElement: \"c\"" }
"Combinators that produce new sequences, such as " { $link map } ", will output an array if the input is an integer." ;

ARTICLE: "sequences-access" "Accessing sequence elements"
{ $subsection ?nth }
"Concise way of extracting one of the first four elements:"
{ $subsection first }
{ $subsection second }
{ $subsection third }
{ $subsection fourth }
"Unpacking sequences:"
{ $subsection first2 }
{ $subsection first3 }
{ $subsection first4 }
{ $see-also nth peek } ;

ARTICLE: "sequences-add-remove" "Adding and removing sequence elements"
"Adding elements:"
{ $subsection add }
{ $subsection add* }
"Removing elements:"
{ $subsection remove }
{ $subsection seq-diff } ;

ARTICLE: "sequences-reshape" "Reshaping sequences"
"A " { $emphasis "repetition" } " is a virtual sequence consisting of a single element repeated multiple times:"
{ $subsection repetition }
{ $subsection <repetition> }
"Reversing a sequence:"
{ $subsection reverse }
"A " { $emphasis "reversal" } " presents a reversed view of an underlying sequence:"
{ $subsection reversed }
{ $subsection <reversed> }
"Transposing a matrix:"
{ $subsection flip }
"A " { $emphasis "column" } " presents a column of a matrix represented as a sequence of rows:"
{ $subsection column }
{ $subsection <column> } ;

ARTICLE: "sequences-appending" "Appending sequences"
{ $subsection append }
{ $subsection 3append }
{ $subsection concat }
{ $subsection join }
"A pair of words useful for aligning strings:"
{ $subsection pad-left }
{ $subsection pad-right } ;

ARTICLE: "sequences-slices" "Subsequences and slices"
"Extracting a subsequence:"
{ $subsection subseq }
{ $subsection head }
{ $subsection tail }
{ $subsection head* }
{ $subsection tail* }
"Taking a sequence apart into a head and a tail:"
{ $subsection unclip }
{ $subsection cut }
{ $subsection cut* }
"A " { $emphasis "slice" } " is a virtual sequence which presents as view of a subsequence of an underlying sequence:"
{ $subsection slice }
{ $subsection slice? }
"Creating slices:"
{ $subsection <slice> }
{ $subsection head-slice }
{ $subsection tail-slice }
{ $subsection head-slice* }
{ $subsection tail-slice* }
"Taking a sequence apart into a head and a tail:"
{ $subsection unclip-slice }
{ $subsection cut-slice }
"A utility for words which use slices as mutable iterators:"
{ $subsection <flat-slice> } ;

ARTICLE: "sequences-combinators" "Sequence combinators"
"Iteration:"
{ $subsection each }
{ $subsection reduce }
{ $subsection interleave }
{ $subsection 2each }
{ $subsection 2reduce }
"Mapping:"
{ $subsection map }
{ $subsection accumulate }
{ $subsection 2map }
"Filtering:"
{ $subsection push-if }
{ $subsection subset } ;

ARTICLE: "sequences-tests" "Testing sequences"
"Testing for an empty sequence:"
{ $subsection empty? }
"Testing indices:"
{ $subsection bounds-check? }
"Testing if a sequence contains an object:"
{ $subsection member? }
{ $subsection memq? }
"Testing if a sequence contains a subsequence:"
{ $subsection head? }
{ $subsection tail? }
{ $subsection subseq? }
"Testing if a sequence contains elements satisfying a predicate:"
{ $subsection contains? }
{ $subsection all? }
{ $subsection 2all? }
"Testing how elements are related:"
{ $subsection monotonic? }
{ $subsection all-eq? }
{ $subsection all-equal? } ;

ARTICLE: "sequences-search" "Searching sequences"
"Finding the index of an element:"
{ $subsection index }
{ $subsection index* }
{ $subsection last-index }
{ $subsection last-index* }
"Finding the start of a subsequence:"
{ $subsection start }
{ $subsection start* }
"Finding the index of an element satisfying a predicate:"
{ $subsection find }
{ $subsection find* }
{ $subsection find-last }
{ $subsection find-last* } ;

ARTICLE: "sequences-destructive" "Destructive operations"
"These words modify their input, instead of creating a new sequence."
$nl
"In-place variant of " { $link reverse } ":"
{ $subsection reverse-here }
"In-place variant of " { $link append } ":"
{ $subsection push-all }
"In-place variant of " { $link remove } ":"
{ $subsection delete }
"In-place variant of " { $link map } ":"
{ $subsection change-each }
"Changing elements:"
{ $subsection change-nth }
{ $subsection cache-nth }
"Deleting elements:"
{ $subsection delete-nth }
{ $subsection delete-slice }
{ $subsection delete-all }
"Other destructive words:"
{ $subsection move }
{ $subsection exchange }
{ $subsection push-new }
{ $subsection copy }
{ $subsection replace-slice }
{ $see-also set-nth push pop "sequences-stacks" } ;

ARTICLE: "sequences-stacks" "Treating sequences as stacks"
"The classical stack operations, modifying a sequence in place:"
{ $subsection peek }
{ $subsection push }
{ $subsection pop }
{ $subsection pop* }
{ $see-also empty? } ;

ARTICLE: "sequences-comparing" "Comparing sequences"
"Element equality testing:"
{ $subsection sequence= }
{ $subsection mismatch }
{ $subsection drop-prefix }
"The " { $link <=> } " generic word performs lexicographic comparison when applied to sequences." ;

ARTICLE: "sequences-f" "The f object as a sequence"
"The " { $link f } " object supports the sequence protocol in a trivial way. It responds with a length of zero and throws an out of bounds error when an attempt is made to access elements." ;

ARTICLE: "sequences" "Sequence operations"
"A " { $emphasis "sequence" } " is a finite, linearly-ordered collection of elements. Words for working with sequences are in the " { $vocab-link "sequences" } " vocabulary."
$nl
"Sequences implement a protocol:"
{ $subsection "sequence-protocol" }
{ $subsection "sequences-f" }
{ $subsection "sequences-integers" }
"Sequence utility words can operate on any object whose class implements the sequence protocol. Most implementations are backed by storage. Some implementations obtain their elements from an underlying sequence, or compute them on the fly. These are known as " { $emphasis "virtual sequences" } "."
{ $subsection "sequences-access" }
{ $subsection "sequences-combinators" }
{ $subsection "sequences-add-remove" }
{ $subsection "sequences-appending" }
{ $subsection "sequences-slices" }
{ $subsection "sequences-reshape" }
{ $subsection "sequences-tests" }
{ $subsection "sequences-search" }
{ $subsection "sequences-comparing" }
{ $subsection "sequences-destructive" }
{ $subsection "sequences-stacks" }
"For inner loops:"
{ $subsection "sequences-unsafe" } ;

ABOUT: "sequences"

HELP: sequence
{ $class-description "A mixin class whose instances are sequences. Custom implementations of the sequence protocol should be declared as instances of this mixin for all sequence functionality to work correctly:"
    { $code "INSTANCE: my-sequence sequence" }
} ;

HELP: length
{ $values { "seq" sequence } { "n" "a non-negative integer" } }
{ $contract "Outputs the length of the sequence. All sequences support this operation." } ;

HELP: set-length
{ $values { "n" "a non-negative integer" } { "seq" "a resizable sequence" } }
{ $contract "Resizes the sequence. Not all sequences are resizable." }
{ $errors "Throws a " { $link bounds-error } " if the new length is negative." }
{ $side-effects "seq" } ;

HELP: lengthen
{ $values { "n" "a non-negative integer" } { "seq" "a resizable sequence" } }
{ $contract "Ensures the sequence has a length of at least " { $snippet "n" } " elements. This word differs from " { $link set-length } " in two respects:"
    { $list
        { "This word does not shrink the sequence if " { $snippet "n" } " is less than its length." }
        { "The word doubles the underlying storage of " { $snippet "seq" } ", whereas " { $link set-length } " is permitted to set it to equal " { $snippet "n" } ". This ensures that repeated calls to this word with constant increments of " { $snippet "n" } " do not result in a quadratic amount of copying, so that for example " { $link push-all } " can run efficiently when used in a loop." }
    }
} ;

HELP: nth
{ $values { "n" "a non-negative integer" } { "seq" sequence } { "elt" "the element at the " { $snippet "n" } "th index" } }
{ $contract "Outputs the " { $snippet "n" } "th element of the sequence. Elements are numbered from zero, so the last element has an index one less than the length of the sequence. All sequences support this operation." }
{ $errors "Throws a " { $link bounds-error } " if the index is negative, or greater than or equal to the length of the sequence." } ;

HELP: set-nth
{ $values { "elt" object } { "n" "a non-negative integer" } { "seq" "a mutable sequence" } }
{ $contract "Sets the " { $snippet "n" } "th element of the sequence. Storing beyond the end of a resizable sequence such as a vector or string buffer grows the sequence." }
{ $errors "Throws an error if the index is negative, or if the sequence is not resizable and the index is greater than or equal to the length of the sequence."
$nl
"Throws an error if the sequence cannot hold elements of the given type." }
{ $side-effects "seq" } ;

HELP: immutable
{ $values { "seq" sequence } }
{ $description "Throws an " { $link immutable } " error." }
{ $error-description "Thrown if an attempt is made to modify an immutable sequence." } ;

HELP: new
{ $values { "len" "a non-negative integer" } { "seq" sequence } { "newseq" "a mutable sequence" } }
{ $contract "Outputs a mutable sequence of length " { $snippet "n" } " which can hold the elements of " { $snippet "seq" } "." } ;

HELP: new-resizable
{ $values { "len" "a non-negative integer" } { "seq" sequence } { "newseq" "a resizable mutable sequence" } }
{ $contract "Outputs a resizable mutable sequence with an initial capacity of " { $snippet "n" } " elements and zero length, which can hold the elements of " { $snippet "seq" } "." }
{ $examples
    { $example "300 V{ } new-resizable ." "V{ }" }
    { $example "300 SBUF\" \" new-resizable ." "SBUF\" \"" }
} ;

HELP: like
{ $values { "seq" sequence } { "exemplar" sequence } { "newseq" "a new sequence" } }
{ $contract "Outputs a sequence with the same elements as " { $snippet "seq" } ", but " { $emphasis "like" } " the template sequence, in the sense that it either has the same class as the template sequence, or if the template sequence is a virtual sequence, the same class as the template sequence's underlying sequence."
$nl
"The default implementation does nothing." }
{ $notes "Unlike " { $link clone-like } ", the output sequence might share storage with the input sequence." } ;

HELP: empty?
{ $values { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if the sequence has zero length." } ;

HELP: delete-all
{ $values { "seq" "a resizable sequence" } }
{ $description "Resizes the sequence to zero length, removing all elements. Not all sequences are resizable." }
{ $errors "Throws a " { $link bounds-error } " if the new length is negative, or if the sequence is not resizable." }
{ $side-effects "seq" } ;

HELP: resize
{ $values { "n" "a non-negative integer" } { "seq" sequence } { "newseq" "a new sequence" } }
{ $description "Creates a new sequence of the same type as " { $snippet "seq" } " with " { $snippet "n" } " elements, and copies the contents of " { $snippet "seq" } " into the new sequence. If " { $snippet "n" } " exceeds the length of " { $snippet "seq" } ", the remaining elements are filled with a default value; " { $link f } " for arrays and 0 for strings." }
{ $notes "This generic word is only implemented for strings and arrays." } ;

HELP: first
{ $values { "seq" sequence } { "first" "the first element of the sequence" } }
{ $description "Outputs the first element of the sequence." }
{ $errors "Throws an error if the sequence is empty." } ;

HELP: second
{ $values { "seq" sequence } { "second" "the second element of the sequence" } }
{ $description "Outputs the second element of the sequence." }
{ $errors "Throws an error if the sequence contains less than two elements." } ;

HELP: third
{ $values { "seq" sequence } { "third" "the third element of the sequence" } }
{ $description "Outputs the third element of the sequence." }
{ $errors "Throws an error if the sequence contains less than three elements." } ;

HELP: fourth
{ $values { "seq" sequence } { "fourth" "the fourth element of the sequence" } }
{ $description "Outputs the fourth element of the sequence." }
{ $errors "Throws an error if the sequence contains less than four elements." } ;

HELP: push
{ $values { "elt" object } { "seq" "a resizable mutable sequence" } }
{ $description "Adds an element at the end of the sequence. The sequence length is adjusted accordingly." }
{ $errors "Throws an error if " { $snippet "seq" } " is not resizable, or if the type of " { $snippet "elt" } " is not permitted in " { $snippet "seq" } "." }
{ $side-effects "seq" } ;

HELP: bounds-check?
{ $values { "n" "an integer" } { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if the index is within the bounds of the sequence." } ;

HELP: bounds-error
{ $values { "n" "a positive integer" } { "seq" sequence } }
{ $description "Throws a " { $link bounds-error } "." }
{ $error-description "Thrown by " { $link nth } ", " { $link set-nth } " and " { $link set-length } " if the given index lies beyond the bounds of the sequence." } ;

HELP: bounds-check
{ $values { "n" "a positive integer" } { "seq" sequence } }
{ $description "Throws an error if " { $snippet "n" } " is negative or if it is greater than or equal to the length of " { $snippet "seq" } ". Otherwise the two inputs remain on the stack." } ;

HELP: ?nth
{ $values { "n" "an integer" } { "seq" sequence } { "elt/f" "an object or " { $link f } } }
{ $description "A forgiving version of " { $link nth } ". If the index is out of bounds, or if the sequence is " { $link f } ", simply outputs " { $link f } "." } ;

HELP: nth-unsafe
{ $values { "n" "an integer" } { "seq" sequence } { "elt" object } }
{ $contract "Unsafe variant of " { $link nth } " that does not perform bounds checks." } ;

HELP: set-nth-unsafe
{ $values { "elt" object } { "n" "an integer" } { "seq" sequence } }
{ $contract "Unsafe variant of " { $link set-nth } " that does not perform bounds checks." } ;

HELP: exchange-unsafe
{ $values { "m" "a non-negative integer" } { "n" "a non-negative integer" } { "seq" "a mutable sequence" } }
{ $description "Unsafe variant of " { $link exchange } " that does not perform bounds checks." } ;

HELP: first2-unsafe
{ $values { "seq" sequence } { "first" "the first element" } { "second" "the second element" } }
{ $contract "Unsafe variant of " { $link first2 } " that does not perform bounds checks." } ;

HELP: first3-unsafe
{ $values { "seq" sequence } { "first" "the first element" } { "second" "the second element" } { "third" "the third element" } }
{ $contract "Unsafe variant of " { $link first3 } " that does not perform bounds checks." } ;

HELP: first4-unsafe
{ $values { "seq" sequence } { "first" "the first element" } { "second" "the second element" } { "third" "the third element" } { "fourth" "the fourth element" } }
{ $contract "Unsafe variant of " { $link first4 } " that does not perform bounds checks." } ;

HELP: 2sequence
{ $values { "obj1" object } { "obj2" object } { "exemplar" sequence } { "seq" sequence } }
{ $description "Creates a two-element sequence of the same type as " { $snippet "exemplar" } "." } ;

HELP: 3sequence
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "exemplar" sequence } { "seq" sequence } }
{ $description "Creates a three-element sequence of the same type as " { $snippet "exemplar" } "." } ;

HELP: 4sequence
{ $values { "obj1" object } { "obj2" object } { "exemplar" sequence } { "obj3" object } { "obj4" object } { "seq" sequence } }
{ $description "Creates a four-element sequence of the same type as " { $snippet "exemplar" } "." } ;

HELP: first2
{ $values { "seq" sequence } { "first" "the first element" } { "second" "the second element" } }
{ $description "Pushes the first two elements of a sequence." }
{ $errors "Throws an error if the sequence has less than two elements." } ;

HELP: first3
{ $values { "seq" sequence } { "first" "the first element" } { "second" "the second element" } { "third" "the third element" } }
{ $description "Pushes the first three elements of a sequence." }
{ $errors "Throws an error if the sequence has less than three elements." } ;

HELP: first4
{ $values { "seq" sequence } { "first" "the first element" } { "second" "the second element" } { "third" "the third element" } { "fourth" "the fourth element" } }
{ $description "Pushes the first four elements of a sequence." }
{ $errors "Throws an error if the sequence has less than four elements." } ;

HELP: array-capacity
{ $values { "array" "an array" } { "n" "a non-negative fixnum" } }
{ $description "Low-level array length accessor." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is unsafe. It does not check types, so improper use can corrupt memory." } ;

HELP: array-nth
{ $values { "n" "a non-negative fixnum" } { "array" "an array" }  { "elt" object } }
{ $description "Low-level array element accessor." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is unsafe. It does not check types or array bounds, and improper use can corrupt memory." } ;

HELP: set-array-nth
{ $values { "elt" object } { "n" "a non-negative fixnum" } { "array" "an array" }  }
{ $description "Low-level array element mutator." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is unsafe. It does not check types or array bounds, and improper use can corrupt memory." } ;

HELP: collect
{ $values { "n" "a non-negative integer" } { "quot" "a quotation with stack effect " { $snippet "( n -- value )" } } { "into" "a sequence of length at least " { $snippet "n" } } }
{ $description "A primitive mapping operation that applies a quotation to all integers from 0 up to but not including " { $snippet "n" } ", and collects the results in a new array. User code should use " { $link map } " instead." } ;

HELP: each
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- )" } } }
{ $description "Applies the quotation to each element of the sequence in turn." } ;

HELP: reduce
{ $values { "seq" sequence } { "identity" object } { "quot" "a quotation with stack effect " { $snippet "( prev elt -- next )" } } { "result" "the final result" } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs the final result. On the first iteration, the two inputs to the quotation are " { $snippet "identity" } ", and the first element of the sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the corresponding element of the sequence." }
{ $examples
    { $example "{ 1 5 3 } 0 [ + ] reduce ." "9" }
} ;

HELP: accumulate
{ $values { "identity" object } { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( prev elt -- next )" } } { "final" "the final result" } { "newseq" "a new sequence" } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs a sequence of intermediate results together with the final result. On the first iteration, the two inputs to the quotation are " { $snippet "identity" } ", and the first element of the sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the corresponding element of the sequence. Given the empty sequence, outputs a one-element sequence consisting of " { $snippet "identity" } "." }
{ $examples
    { $example "{ 2 2 2 2 2 } 0 [ + ] accumulate . ." "{ 0 2 4 6 8 }\n10" }
} ;

HELP: map
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( old -- new )" } } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each element yielding a new element. The new elements are collected into a sequence of the same class as the input sequence." } ;

HELP: change-nth
{ $values { "i" "a non-negative integer" } { "seq" "a mutable sequence" } { "quot" "a quotation with stack effect " { $snippet "( elt -- newelt )" } } }
{ $description "Applies the quotation to the " { $snippet "i" } "th element of the sequence, storing the result back into the sequence." }
{ $errors "Throws an error if the sequence is immutable, if the index is out of bounds, or the sequence cannot hold elements of the type output by " { $snippet "quot" } "." }
{ $side-effects "seq" } ;

HELP: change-each
{ $values { "seq" "a mutable sequence" } { "quot" "a quotation with stack effect " { $snippet "( old -- new )" } } }
{ $description "Applies the quotation to each element yielding a new element, storing the new elements back in the original sequence." }
{ $errors "Throws an error if the sequence is immutable, or the sequence cannot hold elements of the type output by " { $snippet "quot" } "." }
{ $side-effects "seq" } ;

HELP: min-length
{ $values { "seq1" sequence } { "seq2" sequence } { "n" "a non-negative integer" } }
{ $description "Outputs the minimum of the lengths of the two sequences." } ;

HELP: max-length
{ $values { "seq1" sequence } { "seq2" sequence } { "n" "a non-negative integer" } }
{ $description "Outputs the maximum of the lengths of the two sequences." } ;

HELP: 2each
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt1 elt2 -- )" } } }
{ $description "Applies the quotation to pairs of elements from " { $snippet "seq1" } " and " { $snippet "seq2" } "." }
{ $notes "If one sequence is shorter than the other, than only the prefix having the length of the minimum of the two is examined." } ;

HELP: 2reduce
{ $values { "seq1" sequence }
          { "seq2" sequence }
          { "identity" object }
          { "quot" "a quotation with stack effect "
                   { $snippet "( prev elt1 elt2 -- next )" } }
          { "result" "the final result" } }
{ $description "Combines successive pairs of elements from the two sequences using a ternary operation. The first input value at each iteration except the first one is the result of the previous iteration. The first input value at the first iteration is " { $snippet "identity" } "." }
{ $examples "The " { $link v. } " word provides a particularly elegant implementation of the dot product." }
{ $notes "If one sequence is shorter than the other, then only the prefix having the length of the minimum of the two is examined." } ;

HELP: 2map
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt1 elt2 -- new )" } } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each pair of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "seq1" } "." }
{ $notes "If one sequence is shorter than the other, than only the prefix having the length of the minimum of the two is examined." }
{ $see-also v+ v- v* v/ } ;

HELP: 2all?
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt1 elt2 -- ? )" } } { "?" "a boolean" } }
{ $description "Tests the predicate pairwise against elements of " { $snippet "seq1" } " and " { $snippet "seq2" } "." }
{ $notes "If one sequence is shorter than the other, than only the prefix having the length of the minimum of the two is examined." } ;

HELP: find
{ $values { "seq" sequence }
          { "quot" "a quotation with stack effect "
                   { $snippet "( elt -- ? )" } }
          { "i" "the index of the first match, or f" }
          { "elt" "the first matching element, or " { $link f } } }
{ $description "A simpler variant of " { $link find* } " where the starting index is 0." } ;

HELP: find*
{ $values { "n" "a starting index" }
          { "seq" sequence }
          { "quot" "a quotation with stack effect "
                   { $snippet "( elt -- ? )" } }
          { "i" "the index of the first match, or f" }
          { "elt" "the first matching element, or " { $link f } } }
{ $description "Applies the quotation to each element of the sequence in turn, until it outputs a true value or the end of the sequence is reached. If the quotation yields a true value for some sequence element, the word outputs the element index and the element itself. Otherwise, the word outputs an index of f and " { $link f } " as the element." } ;

HELP: find-last
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- ? )" } } { "i" "the index of the first match, or f" } { "elt" "the first matching element, or " { $link f } } }
{ $description "A simpler variant of " { $link find-last* } " where the starting index is one less than the length of the sequence." } ;

HELP: find-last*
{ $values { "n" "a starting index" } { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- ? )" } } { "i" "the index of the first match, or f" } { "elt" "the first matching element, or " { $link f } } }
{ $description "Applies the quotation to each element of the sequence in reverse order, until it outputs a true value or the start of the sequence is reached. If the quotation yields a true value for some sequence element, the word outputs the element index and the element itself. Otherwise, the word outputs an index of f and " { $link f } " as the element." } ;

HELP: contains?
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- ? )" } } { "?" "a boolean" } }
{ $description "Tests if the sequence contains an element satisfying the predicate, by applying the predicate to each element in turn until a true value is found. If the sequence is empty or if the end of the sequence is reached, outputs " { $link f } "." } ;

HELP: all?
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- ? )" } } { "?" "a boolean" } }
{ $description "Tests if all elements in the sequence satisfy the predicate by checking each element in turn. Given an empty sequence, vacuously outputs " { $link t } "." }
{ $notes
    "The implementation makes use of a well-known logical identity:" 
    $nl
    { $snippet "P[x] for all x <==> not ((not P[x]) for some x)" }
} ;

HELP: push-if
{ $values { "elt" object } { "quot" "a quotation with stack effect " { $snippet "( elt -- ? )" } } { "accum" "a resizable mutable sequence" } }
{ $description "Adds the element at the end of the sequence if the quotation yields a true value." } 
{ $notes "This word is a factor of " { $link subset } "." } ;

HELP: subset
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt -- ? )" } } { "subseq" "a new sequence" } }
{ $description "Applies the quotation to each element in turn, and outputs a new sequence containing the elements of the original sequence for which the quotation output a true value." } ;

HELP: monotonic?
{ $values { "seq" sequence } { "quot" "a quotation with stack effect " { $snippet "( elt elt -- ? )" } } { "?" "a boolean" } }
{ $description "Applies the relation to successive pairs of elements in the sequence, testing for a truth value. The relation should be a transitive relation, such as a total order or an equality relation." }
{ $examples
    "Testing if a sequence is non-decreasing:"
    { $example "{ 1 1 2 } [ <= ] monotonic? ." "t" }
    "Testing if a sequence is decreasing:"
    { $example "{ 9 8 6 7 } [ < ] monotonic? ." "f" }
} ;

{ monotonic? all-eq? all-equal? } related-words

HELP: interleave
{ $values { "seq" sequence } { "between" "a quotation" } { "quot" "a quotation with stack effect " { $snippet "( elt -- )" } } }
{ $description "Applies " { $snippet "quot" } " to each element in turn, also invoking " { $snippet "between" } " in-between each pair of elements." }
{ $example "{ \"a\" \"b\" \"c\" } [ \"X\" write ] [ write ] interleave" "aXbXc" } ;

HELP: cache-nth
{ $values { "i" "a non-negative integer" } { "seq" "a mutable sequence" } { "quot" "a quotation with stack effect " { $snippet "( i -- elt )" } } { "elt" object } }
{ $description "If the sequence does not contain at least " { $snippet "i" } " elements or if the " { $snippet "i" } "th element of the sequence is " { $link f } ", calls the quotation to produce a new value, and stores it back into the sequence. Otherwise, this word outputs the " { $snippet "i" } "th element of the sequence." }
{ $side-effects "seq" } ;

HELP: index
{ $values { "obj" object } { "seq" sequence } { "n" "an index" } }
{ $description "Outputs the index of the first element in the sequence equal to " { $snippet "obj" } ". If no element is found, outputs " { $link f } "." } ;

{ index index* last-index last-index* member? memq? } related-words

HELP: index*
{ $values { "obj" object } { "i" "a start index" } { "seq" sequence } { "n" "an index" } }
{ $description "Outputs the index of the first element in the sequence equal to " { $snippet "obj" } ", starting the search from the " { $snippet "i" } "th element. If no element is found, outputs " { $link f } "." } ;

HELP: last-index
{ $values { "obj" object } { "seq" sequence } { "n" "an index" } }
{ $description "Outputs the index of the last element in the sequence equal to " { $snippet "obj" } "; the sequence is traversed back to front. If no element is found, outputs " { $link f } "." } ;

HELP: last-index*
{ $values { "obj" object } { "i" "a start index" } { "seq" sequence } { "n" "an index" } }
{ $description "Outputs the index of the last element in the sequence equal to " { $snippet "obj" } ", traversing the sequence backwards starting from the " { $snippet "i" } "th element and finishing at the first. If no element is found, outputs " { $link f } "." } ;

HELP: member?
{ $values { "obj" object } { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if the sequence contains an element equal to the object." } ;

HELP: memq?
{ $values { "obj" object } { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if the sequence contains the object." }
{ $examples
    "This word uses identity comparison, so the following will most likely print " { $link f } ":"
    { $example "\"hello\" { \"hello\" } memq? ." "f" }
} ;

HELP: remove
{ $values { "obj" object } { "seq" sequence } { "newseq" "a new sequence" } }
{ $description "Outputs a new sequence containing all elements of the input sequence except those equal to the given element." } ;

HELP: move
{ $values { "from" "an index in " { $snippet "seq" } } { "to" "an index in " { $snippet "seq" } } { "seq" "a mutable sequence" } }
{ $description "Sets the element with index " { $snippet "m" } " to the element with index " { $snippet "n" } "." }
{ $side-effects "seq" } ;

HELP: delete
{ $values { "elt" object } { "seq" "a resizable mutable sequence" } }
{ $description "Removes all elements equal to " { $snippet "elt" } " from " { $snippet "seq" } "." }
{ $side-effects "seq" } ;

HELP: delete-nth
{ $values { "n" "a non-negative integer" } { "seq" "a resizable mutable sequence" } }
{ $description "Removes the " { $snippet "n" } "th element from the sequence, shifting all other elements down and reducing its length by one." }
{ $side-effects "seq" } ;

HELP: delete-slice
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" "a resizable mutable sequence" } }
{ $description "Removes a range of elements beginning at index " { $snippet "from" } " and ending before index " { $snippet "to" } "." }
{ $side-effects "seq" } ;

HELP: replace-slice
{ $values { "new" sequence } { "seq" "a mutable sequence" } { "from" "a non-negative integer" } { "to" "a non-negative integer" } }
{ $description "Replaces a range of elements beginning at index " { $snippet "from" } " and ending before index " { $snippet "to" } " with a new sequence." }
{ $notes "If the " { $snippet "to - from" } " is equal to the length of " { $snippet "new" } ", the sequence remains the same size, and does not have to support resizing. However, if " { $snippet "to - from" } " is not equal to the length of " { $snippet "new" } ", the " { $link set-length } " word is called on " { $snippet "seq" } ", so fixed-size sequences should not be passed in this case." }
{ $errors "Throws an error if " { $snippet "new" } " contains elements whose types are not permissible in " { $snippet "seq" } "." }
{ $side-effects "seq" } ;

HELP: push-new
{ $values { "elt" object } { "seq" "a resizable mutable sequence" } }
{ $description "Removes all elements equal to " { $snippet "elt" } ", and adds " { $snippet "elt" } " at the end of the sequence." }
{ $examples
    { $example
        "V{ \"beans\" \"salsa\" \"cheese\" } \"v\" set"
        "\"nachos\" \"v\" get push-new"
        "\"salsa\" \"v\" get push-new"
        "\"v\" get ."
        "V{ \"beans\" \"cheese\" \"nachos\" \"salsa\" }"
    }
}
{ $side-effects "seq" } ;

{ push push-new add add* } related-words

HELP: add
{ $values { "seq" sequence } { "elt" object } { "newseq" sequence } }
{ $description "Outputs a new sequence obtained by adding " { $snippet "elt" } " at the end of " { $snippet "seq" } "." }
{ $errors "Throws an error if the type of " { $snippet "elt" } " is not permitted in sequences of the same class as " { $snippet "seq1" } "." }
{ $examples
    { $example "{ 1 2 3 } 4 add ." "{ 1 2 3 4 }" }
} ;

HELP: add*
{ $values { "seq" sequence } { "elt" object } { "newseq" sequence } }
{ $description "Outputs a new sequence obtained by adding " { $snippet "elt" } " at the beginning of " { $snippet "seq" } "." }
{ $errors "Throws an error if the type of " { $snippet "elt" } " is not permitted in sequences of the same class as " { $snippet "seq1" } "." } 
{ $examples
    { $example "{ 1 2 3 } 0 add* ." "{ 0 1 2 3 }" }
} ;

HELP: seq-diff
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a sequence consisting of elements present in " { $snippet "seq2" } " but not " { $snippet "seq1" } ", comparing elements for equality." } ;

HELP: sum-lengths
{ $values { "seq" "a sequence of sequences" } { "n" integer } }
{ $description "Outputs the sum of the lengths of all sequences in " { $snippet "seq" } "." } ;

HELP: concat
{ $values { "seq" sequence } { "newseq" sequence } }
{ $description "Concatenates a sequence of sequences together into one sequence. If " { $snippet "seq" } " is empty, outputs " { $snippet "{ }" } ", otherwise the resulting sequence is of the same class as the first element of " { $snippet "seq" } "." }
{ $errors "Throws an error if one of the sequences in " { $snippet "seq" } " contains elements not permitted in sequences of the same class as the first element of " { $snippet "seq" } "." } ;

HELP: join
{ $values { "seq" sequence } { "glue" sequence } { "newseq" sequence } }
{ $description "Concatenates a sequence of sequences together into one sequence, placing a copy of " { $snippet "glue" } " between each pair of sequences. The resulting sequence is of the same class as " { $snippet "glue" } "." }
{ $errors "Throws an error if one of the sequences in " { $snippet "seq" } " contains elements not permitted in sequences of the same class as " { $snippet "glue" } "." } ;

{ join concat } related-words

HELP: peek
{ $values { "seq" sequence } { "elt" object } }
{ $description "Outputs the last element of a sequence." }
{ $errors "Throws an error if the sequence is empty." } ;

{ peek pop pop* } related-words

HELP: pop*
{ $values { "seq" "a resizable mutable sequence" } }
{ $description "Removes the last element and shortens the sequence." }
{ $side-effects "seq" }
{ $errors "Throws an error if the sequence is empty." } ;

HELP: pop
{ $values { "seq" "a resizable mutable sequence" } { "elt" object } }
{ $description "Outputs the last element after removing it and shortening the sequence." }
{ $side-effects "seq" }
{ $errors "Throws an error if the sequence is empty." } ;

HELP: all-equal?
{ $values { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if all elements in the sequence are equal. Yields true with an empty sequence." } ;

HELP: all-eq?
{ $values { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if all elements in the sequence are the same identical object. Yields true with an empty sequence." } ;

HELP: mismatch
{ $values { "seq1" sequence } { "seq2" sequence } { "i" "an index" } }
{ $description "Compares pairs of elements up to the minimum of the sequences' lengths, outputting the first index where the two sequences have non-equal elements, or " { $link f } " if all tested elements were equal." } ;

HELP: flip
{ $values { "matrix" "a sequence of equal-length sequences" } { "newmatrix" "a sequence of equal-length sequences" } }
{ $description "Transposes the matrix; that is, rows become columns and columns become rows." }
{ $examples { $example "{ { 1 2 3 } { 4 5 6 } } flip ." "{ { 1 4 } { 2 5 } { 3 6 } }" } } ;

HELP: exchange
{ $values { "m" "a non-negative integer" } { "n" "a non-negative integer" } { "seq" "a mutable sequence" } }
{ $description "Exchanges the " { $snippet "m" } "th and " { $snippet "n" } "th elements of " { $snippet "seq" } "." } ;

HELP: reverse-here
{ $values { "seq" "a mutable sequence" } }
{ $description "Reverses a sequence in-place." }
{ $side-effects "seq" } ;

HELP: padding
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "elt" object } { "quot" "a quotation with stack effect " { $snippet "( seq1 seq2 -- newseq )" } } { "newseq" "a new sequence" } }
{ $description "Outputs a new string sequence of " { $snippet "elt" } " repeated, that when appended to " { $snippet "seq" } ", yields a sequence of length " { $snippet "n" } ". If the length of { " { $snippet "seq" } " is greater than " { $snippet "n" } ", this word outputs an empty sequence." } ;

HELP: pad-left
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "elt" object } { "padded" "a new sequence" } }
{ $description "Outputs a new sequence consisting of " { $snippet "seq" } " padded on the left with enough repetitions of " { $snippet "elt" } " to have the result be of length " { $snippet "n" } "." }
{ $examples { $example "{ \"ab\" \"quux\" } [ 5 CHAR: - pad-left print ] each" "---ab\n-quux" } } ;

HELP: pad-right
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "elt" object } { "padded" "a new sequence" } }
{ $description "Outputs a new sequence consisting of " { $snippet "seq" } " padded on the right with enough repetitions of " { $snippet "elt" } " to have the result be of length " { $snippet "n" } "." }
{ $examples { $example "{ \"ab\" \"quux\" } [ 5 CHAR: - pad-right print ] each" "ab---\nquux-" } } ;

HELP: sequence=
{ $values { "seq1" sequence } { "seq2" sequence } { "?" "a boolean" } }
{ $description "Tests if the two sequences have the same length and elements. This is weaker than " { $link = } ", since it does not ensure that the sequences are instances of the same class." } ;

HELP: reversed
{ $class-description "A virtual sequence which presents a reversed view of an underlying sequence. New instances can be created by calling " { $link <reversed> } "." } ;

HELP: reverse
{ $values { "seq" sequence } { "newseq" "a new sequence" } }
{ $description "Outputs a new sequence having the same elements as " { $snippet "seq" } " but in reverse order." } ;

{ reverse <reversed> } related-words

HELP: <reversed> ( seq -- reversed )
{ $values { "seq" sequence } { "reversed" "a new sequence" } }
{ $description "Creates an instance of the " { $link reversed } " virtual sequence." } ;

HELP: slice-error
{ $values { "str" "a reason" } }
{ $description "Throws a " { $link slice-error } "." }
{ $error-description "Thrown by " { $link <slice> } " if one of the following invalid conditions holds:"
    { $list
        "The start index is negative"
        "The end index is greater than the length of the sequence"
        "The start index is greater than the end index"
    }
} ;

HELP: slice
{ $class-description "A virtual sequence which presents a subrange of the elements of an underlying sequence. New instances can be created by calling " { $link <slice> } ". Slices are mutable if the underlying sequence is mutable, and mutating a slice changes the underlying sequence." }
{ $notes "The slots of a slice should not be changed after the slice has been created, because this can break invariants." } ;

HELP: check-slice
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" sequence } }
{ $description "Ensures that " { $snippet "m" } " is less than or equal to " { $snippet "m" } ", and that both indices are within bounds for " { $snippet "seq" } "." }
{ $errors "Throws a " { $link slice-error } " if the preconditions are not met." } ;

HELP: collapse-slice
{ $values { "m" "a non-negative integer" } { "n" "a non-negative integer" } { "slice" slice } { "m'" "a non-negative integer" } { "n'" "a non-negative integer" } { "seq" sequence } }
{ $description "Prepares to take the slice of a slice by adjusting the start and end indices accordingly, and replacing the slice with its underlying sequence." }
;

HELP: <flat-slice>
{ $values { "seq" sequence } { "slice" slice } }
{ $description "Outputs a slice with the same elements as " { $snippet "seq" } ", and " { $link slice-from } " equal to 0 and " { $link slice-to } " equal to the length of " { $snippet "seq" } "." }
{ $notes "Some words create slices then proceed to read and write the " { $link slice-from } " and " { $link slice-to } " slots of the slice. To behave predictably when they are themselves given a slice as input, they apply this word first to get a canonical slice." } ;

HELP: <slice>
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" sequence } { "slice" "a slice" } }
{ $description "Outputs a new virtual sequence sharing storage with the subrange of elements in " { $snippet "seq" } " with indices starting from and including " { $snippet "m" } ", and up to but not including " { $snippet "n" } "." }
{ $errors "Throws an error if " { $snippet "m" } " or " { $snippet "n" } " is out of bounds." }
{ $notes "Taking the slice of a slice outputs a slice of the underlying sequence of the original slice. Keep this in mind when writing code which depends on the values of " { $link slice-from } " and " { $link slice-to } " being equal to the inputs to this word. The " { $link <flat-slice> } " word might be helpful in such situations." } ;

{ <slice> subseq } related-words

HELP: column
{ $class-description "A virtual sequence which presents a fixed column of a matrix represented as a sequence of rows. New instances can be created by calling " { $link <column> } "." } ;

HELP: <column> ( seq n -- column )
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "column" column } }
{ $description "Outputs a new virtual sequence which presents a fixed column of a matrix represented as a sequence of rows." "The " { $snippet "i" } "th element of a column is the " { $snippet "n" } "th element of the " { $snippet "i" } "th element of" { $snippet "seq" } ". Every element of " { $snippet "seq" } " must be a sequence, and all sequences must have equal length." }
{ $examples
    { $example
        "{ { 1 2 3 } { 4 5 6 } { 7 8 9 } } 0 <column> >array ."
        "{ 1 4 7 }"
    }
}
{ $notes
    "In the same sense that " { $link <reversed> } " is a virtual variant of " { $link reverse } ", " { $link <column> } " is a virtual variant of " { $snippet "swap [ nth ] curry map" } "."
} ;

HELP: repetition
{ $class-description "A virtual sequence consisting of " { $link repetition-elt } " repeated " { $link repetition-len } " times. Repetitions are created by calling " { $link <repetition> } "." } ;

HELP: <repetition> ( len elt -- repetition )
{ $values { "len" "a non-negative integer" } { "elt" object } { "repetition" repetition } }
{ $description "Creates a new " { $link repetition } "." }
{ $examples
    { $example "10 \"X\" <repetition> >array ." "{ \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" }" }
    { $example "10 \"X\" <repetition> >array concat ." "\"XXXXXXXXXX\"" }
} ;
HELP: copy
{ $values { "src" sequence } { "i" "an index in " { $snippet "dest" } } { "dst" "a mutable sequence" } }
{ $description "Copies all elements of " { $snippet "src" } " to " { $snippet "dest" } ", with destination indices starting from " { $snippet "i" } ". Grows " { $snippet "to" } " first if necessary." }
{ $side-effects "dest" }
{ $errors "An error is thrown if " { $snippet "to" } " is not resizable, and not large enough to hold the copied elements." } ;

HELP: push-all
{ $values { "src" sequence } { "dest" "a resizable mutable sequence" } }
{ $description "Appends " { $snippet "src" } " to the end of " { $snippet "dest" } "." }
{ $side-effects "dest" }
{ $errors "Throws an error if " { $snippet "src" } " contains elements not permitted in " { $snippet "dest" } "." } ;

HELP: append
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence of the same type as " { $snippet "seq1" } " consisting of the elements of " { $snippet "seq1" } " followed by " { $snippet "seq2" } "." }
{ $errors "Throws an error if " { $snippet "seq2" } " contains elements not permitted in sequences of the same class as " { $snippet "seq1" } "." } ;

HELP: 3append
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence consisting of the elements of " { $snippet "seq1" } ", " { $snippet "seq2" } " and " { $snippet "seq3" } " in turn." }
{ $errors "Throws an error if " { $snippet "seq2" } " or " { $snippet "seq3" } " contain elements not permitted in sequences of the same class as " { $snippet "seq1" } "." } ;

HELP: subseq
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" sequence } { "subseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of all elements starting from and including " { $snippet "m" } ", and up to but not including " { $snippet "n" } "." }
{ $errors "Throws an error if " { $snippet "m" } " or " { $snippet "n" } " is out of bounds." } ;

HELP: clone-like
{ $values { "seq" sequence } { "exemplar" sequence } { "newseq" "a new sequence" } }
{ $description "Outputs a newly-allocated sequence with the same elements as " { $snippet "seq" } " but of the same type as " { $snippet "exemplar" } "." }
{ $notes "Unlike " { $link like } ", this word always creates a new sequence which never shares storage with the original." } ;

HELP: head-slice
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "slice" "a slice" } }
{ $description "Outputs a virtual sequence sharing storage with the first " { $snippet "n" } " elements of the input sequence." }
{ $errors "Throws an error if the index is out of bounds." } ;

HELP: tail-slice
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "slice" "a slice" } }
{ $description "Outputs a virtual sequence sharing storage with all elements from the " { $snippet "n" } "th index until the end of the input sequence." }
{ $errors "Throws an error if the index is out of bounds." } ;

HELP: head-slice*
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "slice" "a slice" } }
{ $description "Outputs a virtual sequence sharing storage with all elements of " { $snippet "seq" } " until the " { $snippet "n" } "th element from the end. In other words, it outputs a sequence of the first " { $snippet "l-n" } " elements of the input sequence, where " { $snippet "l" } " is its length." }
{ $errors "Throws an error if the index is out of bounds." } ;

HELP: tail-slice*
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "slice" "a slice" } }
{ $description "Outputs a virtual sequence sharing storage with the last " { $snippet "n" } " elements of the input sequence." }
{ $errors "Throws an error if the index is out of bounds." } ;

HELP: head
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "headseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of the first " { $snippet "n" } " elements of the input sequence." }
{ $errors "Throws an error if the index is out of bounds." } ;

HELP: tail
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "tailseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of the input sequence with the first n items removed." }
{ $errors "Throws an error if the index is out of bounds." } ;

HELP: head*
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "headseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of all elements of " { $snippet "seq" } " until the " { $snippet "n" } "th element from the end. In other words, it outputs a sequence of the first " { $snippet "l-n" } " elements of the input sequence, where " { $snippet "l" } " is its length." }
{ $errors "Throws an error if the index is out of bounds." } ;

HELP: tail*
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "tailseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of the last " { $snippet "n" } " elements of the input sequence." }
{ $errors "Throws an error if the index is out of bounds." } ;

HELP: shorter?
{ $values { "seq1" sequence } { "seq2" sequence } { "?" "a boolean" } }
{ $description "Tets if the length of " { $snippet "seq1" } " is smaller than the length of " { $snippet "seq2" } "." } ;

HELP: head?
{ $values { "seq" sequence } { "begin" sequence } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "seq" } " starts with " { $snippet "begin" } ". If " { $snippet "begin" } " is longer than " { $snippet "seq" } ", this word outputs " { $link f } "." } ;

HELP: tail?
{ $values { "seq" sequence } { "end" sequence } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "seq" } " ends with " { $snippet "end" } ". If " { $snippet "end" } " is longer than " { $snippet "seq" } ", this word outputs " { $link f } "." } ;

{ delete-nth remove delete } related-words

HELP: cut-slice
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "before" sequence } { "after" "a slice" } }
{ $description "Outputs a pair of sequences, where " { $snippet "before" } " consists of the first " { $snippet "n" } " elements of " { $snippet "seq" } " and has the same type, while " { $snippet "after" } " is a slice of the remaining elements." }
{ $notes "Unlike " { $link cut } ", the run time of this word is proportional to the length of " { $snippet "before" } ", not " { $snippet "after" } ", so it is suitable for use in an iterative algorithm which cuts successive pieces off a sequence." } ;

HELP: cut
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "before" sequence } { "after" sequence } }
{ $description "Outputs a pair of sequences, where " { $snippet "before" } " consists of the first " { $snippet "n" } " elements of " { $snippet "seq" } ", while " { $snippet "after" } " holds the remaining elements. Both output sequences have the same type as " { $snippet "seq" } "." }
{ $notes "Since this word copies the entire tail of the sequence, it should not be used in a loop. If this is important, consider using " { $link cut-slice } " instead, since it returns a slice for the tail instead of copying." } ;

HELP: cut*
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "before" sequence } { "after" sequence } }
{ $description "Outputs a pair of sequences, where " { $snippet "after" } " consists of the last " { $snippet "n" } " elements of " { $snippet "seq" } ", while " { $snippet "before" } " holds the remaining elements. Both output sequences have the same type as " { $snippet "seq" } "." } ;

HELP: start*
{ $values { "subseq" sequence } { "seq" sequence } { "n" "a start index" } { "i" "a start index" } }
{ $description "Outputs the start index of the first contiguous subsequence equal to " { $snippet "subseq" } ", starting the search from the " { $snippet "n" } "th element. If no matching subsequence is found, outputs " { $link f } "." } ;

HELP: start
{ $values { "subseq" sequence } { "seq" sequence } { "i" "a start index" } }
{ $description "Outputs the start index of the first contiguous subsequence equal to " { $snippet "subseq" } ", or " { $link f } " if no matching subsequence is found." } ;

HELP: subseq?
{ $values { "subseq" sequence } { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "seq" } " contains the elements of " { $snippet "subseq" } " as a contiguous subsequence." } ;

HELP: drop-prefix
{ $values { "seq1" sequence } { "seq2" sequence } { "slice1" "a slice" } { "slice2" "a slice" } }
{ $description "Outputs a pair of virtual sequences with the common prefix of " { $snippet "seq1" } " and " { $snippet "seq2" } " removed." } ;

HELP: unclip
{ $values { "seq" sequence } { "rest" sequence } { "first" object } }
{ $description "Outputs a tail sequence and the first element of " { $snippet "seq" } "; the tail sequence consists of all elements of " { $snippet "seq" } " but the first." }
{ $examples
    { $example "{ 1 2 3 } unclip add ." "{ 2 3 1 }" }
} ;

HELP: unclip-slice
{ $values { "seq" sequence } { "rest" slice } { "first" object } }
{ $description "Outputs a tail sequence and the first element of " { $snippet "seq" } "; the tail sequence consists of all elements of " { $snippet "seq" } " but the first. Unlike " { $link unclip } ", this word does not make a copy of the input sequence, and runs in constant time." } ;
