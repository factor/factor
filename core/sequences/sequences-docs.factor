USING: arrays help.markup help.syntax math
sequences.private vectors strings kernel math.order layouts
quotations generic.single ;
IN: sequences

HELP: sequence
{ $class-description "A mixin class whose instances are sequences. Custom implementations of the sequence protocol should be declared as instances of this mixin for all sequence functionality to work correctly:"
    { $code "INSTANCE: my-sequence sequence" }
} ;

HELP: length
{ $values { "seq" sequence } { "n" "a non-negative integer" } }
{ $contract "Outputs the length of the sequence. All sequences support this operation." } ;

HELP: set-length
{ $values { "n" "a non-negative integer" } { "seq" "a resizable sequence" } }
{ $contract "Resizes a sequence. The initial contents of the new area is undefined." }
{ $errors "Throws a " { $link no-method  } " error if the sequence is not resizable, and a " { $link bounds-error } " if the new length is negative." }
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

HELP: nths
{ $values
     { "indices" sequence } { "seq" sequence }
     { "seq'" sequence } }
{ $description "Ouptuts a sequence of elements from the input sequence indexed by the indices." }
{ $examples 
    { $example "USING: prettyprint sequences ;"
               "{ 0 2 } { \"a\" \"b\" \"c\" } nths ."
               "{ \"a\" \"c\" }"
    }
} ;

HELP: immutable
{ $values { "seq" sequence } }
{ $description "Throws an " { $link immutable } " error." }
{ $error-description "Thrown if an attempt is made to modify an immutable sequence." } ;

HELP: new-sequence
{ $values { "len" "a non-negative integer" } { "seq" sequence } { "newseq" "a mutable sequence" } }
{ $contract "Outputs a mutable sequence of length " { $snippet "n" } " which can hold the elements of " { $snippet "seq" } ". The initial contents of the sequence are undefined." } ;

HELP: new-resizable
{ $values { "len" "a non-negative integer" } { "seq" sequence } { "newseq" "a resizable mutable sequence" } }
{ $contract "Outputs a resizable mutable sequence with an initial capacity of " { $snippet "n" } " elements and zero length, which can hold the elements of " { $snippet "seq" } "." }
{ $examples
    { $example "USING: prettyprint sequences ;" "300 V{ } new-resizable ." "V{ }" }
    { $example "USING: prettyprint sequences ;" "300 SBUF\" \" new-resizable ." "SBUF\" \"" }
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

HELP: if-empty
{ $values { "seq" sequence } { "quot1" quotation } { "quot2" quotation } }
{ $description "Makes an implicit check if the sequence is empty. An empty sequence is dropped and " { $snippet "quot1" } " is called. Otherwise, if the sequence has any elements, " { $snippet "quot2" } " is called on it." }
{ $example
    "USING: kernel prettyprint sequences ;"
    "{ 1 2 3 } [ \"empty sequence\" ] [ sum ] if-empty ."
    "6"
} ;

HELP: when-empty
{ $values
     { "seq" sequence } { "quot" "the first quotation of an " { $link if-empty } } }
{ $description "Makes an implicit check if the sequence is empty. An empty sequence is dropped and the " { $snippet "quot" } " is called." }
{ $examples "This word is equivalent to " { $link if-empty } " with an empty second quotation:"
    { $example
    "USING: sequences prettyprint ;"
    "{ } [ { 4 5 6 } ] [ ] if-empty ."
    "{ 4 5 6 }"
    }
    { $example
    "USING: sequences prettyprint ;"
    "{ } [ { 4 5 6 } ] when-empty ."
    "{ 4 5 6 }"
    }
} ;

HELP: unless-empty
{ $values
     { "seq" sequence } { "quot" "the second quotation of an " { $link if-empty } } }
{ $description "Makes an implicit check if the sequence is empty. An empty sequence is dropped. Otherwise, the " { $snippet "quot" } " is called on the sequence." }
{ $examples "This word is equivalent to " { $link if-empty } " with an empty first quotation:"
    { $example
    "USING: sequences prettyprint ;"
    "{ 4 5 6 } [ ] [ sum ] if-empty ."
    "15"
    }
    { $example
    "USING: sequences prettyprint ;"
    "{ 4 5 6 } [ sum ] unless-empty ."
    "15"
    }
} ;

{ if-empty when-empty unless-empty } related-words

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

HELP: first-unsafe
{ $values { "seq" sequence } { "first" "the first element" } }
{ $contract "Unsafe variant of " { $link first } " that does not perform bounds checks." } ;

HELP: first2-unsafe
{ $values { "seq" sequence } { "first" "the first element" } { "second" "the second element" } }
{ $contract "Unsafe variant of " { $link first2 } " that does not perform bounds checks." } ;

HELP: first3-unsafe
{ $values { "seq" sequence } { "first" "the first element" } { "second" "the second element" } { "third" "the third element" } }
{ $contract "Unsafe variant of " { $link first3 } " that does not perform bounds checks." } ;

HELP: first4-unsafe
{ $values { "seq" sequence } { "first" "the first element" } { "second" "the second element" } { "third" "the third element" } { "fourth" "the fourth element" } }
{ $contract "Unsafe variant of " { $link first4 } " that does not perform bounds checks." } ;

HELP: 1sequence
{ $values { "obj" object } { "exemplar" sequence } { "seq" sequence } }
{ $description "Creates a one-element sequence of the same type as " { $snippet "exemplar" } "." } ;

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
{ $class-description "A predicate class whose instances are valid array sizes for the current architecture. The minimum value is zero and the maximum value is " { $link max-array-capacity } "." }
{ $description "Low-level array length accessor." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is unsafe. It does not check types, so improper use can corrupt memory." } ;

HELP: array-nth
{ $values { "n" "a non-negative fixnum" } { "array" "an array" }  { "elt" object } }
{ $description "Low-level array element accessor." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is unsafe. It does not check types or array bounds, and improper use can corrupt memory. User code must use " { $link nth } " instead." } ;

HELP: set-array-nth
{ $values { "elt" object } { "n" "a non-negative fixnum" } { "array" "an array" }  }
{ $description "Low-level array element mutator." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is unsafe. It does not check types or array bounds, and improper use can corrupt memory. User code must use " { $link set-nth } " instead." } ;

HELP: collect
{ $values { "n" "a non-negative integer" } { "quot" { $quotation "( n -- value )" } } { "into" "a sequence of length at least " { $snippet "n" } } }
{ $description "A primitive mapping operation that applies a quotation to all integers from 0 up to but not including " { $snippet "n" } ", and collects the results in a new array. User code should use " { $link map } " instead." } ;

HELP: each
{ $values { "seq" sequence } { "quot" { $quotation "( elt -- )" } } }
{ $description "Applies the quotation to each element of the sequence in order." } ;

HELP: reduce
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation "( prev elt -- next )" } } { "result" "the final result" } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs the final result. On the first iteration, the two inputs to the quotation are " { $snippet "identity" } ", and the first element of the sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the corresponding element of the sequence." }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 1 5 3 } 0 [ + ] reduce ." "9" }
} ;

HELP: reduce-index
{ $values
     { "seq" sequence } { "identity" object } { "quot" quotation } }
{ $description "Combines successive elements of the sequence and their indices binary operations, and outputs the final result. On the first iteration, the three inputs to the quotation are " { $snippet "identity" } ", the first element of the sequence, and its index, 0. On successive iterations, the first input is the result of the previous iteration, the second input is the corresponding element of the sequence, and the third is its index." }
{ $examples { $example "USING: sequences prettyprint math ;"
    "{ 10 50 90 } 0 [ + + ] reduce-index ."
    "153"
} } ;

HELP: accumulate
{ $values { "identity" object } { "seq" sequence } { "quot" { $quotation "( prev elt -- next )" } } { "final" "the final result" } { "newseq" "a new sequence" } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs a sequence of intermediate results together with the final result. On the first iteration, the two inputs to the quotation are " { $snippet "identity" } ", and the first element of the sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the corresponding element of the sequence."
$nl
"When given the empty sequence, outputs an empty sequence together with the " { $snippet "identity" } "." }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 2 2 2 2 2 } 0 [ + ] accumulate . ." "{ 0 2 4 6 8 }\n10" }
} ;

HELP: map
{ $values { "seq" sequence } { "quot" { $quotation "( old -- new )" } } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each element of the sequence in order. The new elements are collected into a sequence of the same class as the input sequence." } ;

HELP: map-as
{ $values { "seq" sequence } { "quot" { $quotation "( old -- new )" } } { "newseq" "a new sequence" } { "exemplar" sequence } }
{ $description "Applies the quotation to each element of the sequence in order. The new elements are collected into a sequence of the same class as " { $snippet "exemplar" } "." }
{ $examples
    "The following example converts a string into an array of one-element strings:"
    { $example "USING: prettyprint strings sequences ;" "\"Hello\" [ 1string ] { } map-as ." "{ \"H\" \"e\" \"l\" \"l\" \"o\" }" }
    "Note that " { $link map } " could not be used here, because it would create another string to hold results, and one-element strings cannot themselves be elements of strings."
} ;

HELP: each-index
{ $values
     { "seq" sequence } { "quot" quotation } }
{ $description "Calls the quotation with the element of the sequence and its index on the stack, with the index on the top of the stack." }
{ $examples { $example "USING: sequences prettyprint math ;"
"{ 10 20 30 } [ + . ] each-index"
"10\n21\n32"
} } ;

HELP: map-index
{ $values
  { "seq" sequence } { "quot" quotation } { "newseq" sequence } }
{ $description "Calls the quotation with the element of the sequence and its index on the stack, with the index on the top of the stack. Collects the outputs of the quotation and outputs them in a sequence of the same type as the input sequence." }
{ $examples { $example "USING: sequences prettyprint math ;"
"{ 10 20 30 } [ + ] map-index ."
"{ 10 21 32 }"
} } ;

HELP: change-nth
{ $values { "i" "a non-negative integer" } { "seq" "a mutable sequence" } { "quot" { $quotation "( elt -- newelt )" } } }
{ $description "Applies the quotation to the " { $snippet "i" } "th element of the sequence, storing the result back into the sequence." }
{ $errors "Throws an error if the sequence is immutable, if the index is out of bounds, or the sequence cannot hold elements of the type output by " { $snippet "quot" } "." }
{ $side-effects "seq" } ;

HELP: change-each
{ $values { "seq" "a mutable sequence" } { "quot" { $quotation "( old -- new )" } } }
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
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation "( elt1 elt2 -- )" } } }
{ $description "Applies the quotation to pairs of elements from " { $snippet "seq1" } " and " { $snippet "seq2" } "." } ;

HELP: 3each
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" { $quotation "( elt1 elt2 elt3 -- )" } } }
{ $description "Applies the quotation to triples of elements from " { $snippet "seq1" } ", " { $snippet "seq2" } " and " { $snippet "seq3" } "." } ;

HELP: 2reduce
{ $values { "seq1" sequence }
          { "seq2" sequence }
          { "identity" object }
          { "quot" { $quotation "( prev elt1 elt2 -- next )" } }
          { "result" "the final result" } }
{ $description "Combines successive pairs of elements from the two sequences using a ternary operation. The first input value at each iteration except the first one is the result of the previous iteration. The first input value at the first iteration is " { $snippet "identity" } "." } ;

HELP: 2map
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation "( elt1 elt2 -- new )" } } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each pair of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "seq1" } "." } ;

HELP: 3map
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" { $quotation "( elt1 elt2 elt3 -- new )" } } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each triple of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "seq1" } "." } ;

HELP: 2map-as
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation "( elt1 elt2 -- new )" } } { "exemplar" sequence } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each pair of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "exemplar" } "." } ;

HELP: 3map-as
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" { $quotation "( elt1 elt2 elt3 -- new )" } } { "exemplar" sequence } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each triple of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "exemplar" } "." } ;

HELP: 2all?
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation "( elt1 elt2 -- ? )" } } { "?" "a boolean" } }
{ $description "Tests the predicate pairwise against elements of " { $snippet "seq1" } " and " { $snippet "seq2" } "." } ;

HELP: find
{ $values { "seq" sequence }
          { "quot" { $quotation "( elt -- ? )" } }
          { "i" "the index of the first match, or " { $link f } }
          { "elt" "the first matching element, or " { $link f } } }
{ $description "A simpler variant of " { $link find-from } " where the starting index is 0." } ;

HELP: find-from
{ $values { "n" "a starting index" }
          { "seq" sequence }
          { "quot" { $quotation "( elt -- ? )" } }
          { "i" "the index of the first match, or " { $link f } }
          { "elt" "the first matching element, or " { $link f } } }
{ $description "Applies the quotation to each element of the sequence in turn, until it outputs a true value or the end of the sequence is reached. If the quotation yields a true value for some sequence element, the word outputs the element index and the element itself. Otherwise, the word outputs an index of f and " { $link f } " as the element." } ;

HELP: find-last
{ $values { "seq" sequence } { "quot" { $quotation "( elt -- ? )" } } { "i" "the index of the first match, or f" } { "elt" "the first matching element, or " { $link f } } }
{ $description "A simpler variant of " { $link find-last-from } " where the starting index is one less than the length of the sequence." } ;

HELP: find-last-from
{ $values { "n" "a starting index" } { "seq" sequence } { "quot" { $quotation "( elt -- ? )" } } { "i" "the index of the first match, or f" } { "elt" "the first matching element, or " { $link f } } }
{ $description "Applies the quotation to each element of the sequence in reverse order, until it outputs a true value or the start of the sequence is reached. If the quotation yields a true value for some sequence element, the word outputs the element index and the element itself. Otherwise, the word outputs an index of f and " { $link f } " as the element." } ;

HELP: map-find
{ $values { "seq" sequence } { "quot" { $quotation "( elt -- result/f )" } } { "result" "the first non-false result of the quotation" } { "elt" "the first matching element, or " { $link f } } }
{ $description "Applies the quotation to each element of the sequence, until the quotation outputs a true value. If the quotation ever yields a result which is not " { $link f } ", then the value is output, along with the element of the sequence which yielded this." } ;

HELP: any?
{ $values { "seq" sequence } { "quot" { $quotation "( elt -- ? )" } } { "?" "a boolean" } }
{ $description "Tests if the sequence contains an element satisfying the predicate, by applying the predicate to each element in turn until a true value is found. If the sequence is empty or if the end of the sequence is reached, outputs " { $link f } "." } ;

HELP: all?
{ $values { "seq" sequence } { "quot" { $quotation "( elt -- ? )" } } { "?" "a boolean" } }
{ $description "Tests if all elements in the sequence satisfy the predicate by checking each element in turn. Given an empty sequence, vacuously outputs " { $link t } "." } ;

HELP: push-if
{ $values { "elt" object } { "quot" { $quotation "( elt -- ? )" } } { "accum" "a resizable mutable sequence" } }
{ $description "Adds the element at the end of the sequence if the quotation yields a true value." } 
{ $notes "This word is a factor of " { $link filter } "." } ;

HELP: filter
{ $values { "seq" sequence } { "quot" { $quotation "( elt -- ? )" } } { "subseq" "a new sequence" } }
{ $description "Applies the quotation to each element in turn, and outputs a new sequence containing the elements of the original sequence for which the quotation output a true value." } ;

HELP: filter-here
{ $values { "seq" "a resizable mutable sequence" } { "quot" { $quotation "( elt -- ? )" } } }
{ $description "Applies the quotation to each element in turn, and removes elements for which the quotation outputs a false value." }
{ $side-effects "seq" } ;

HELP: interleave
{ $values { "seq" sequence } { "between" "a quotation" } { "quot" { $quotation "( elt -- )" } } }
{ $description "Applies " { $snippet "quot" } " to each element in turn, also invoking " { $snippet "between" } " in-between each pair of elements." }
{ $example "USING: io sequences ;" "{ \"a\" \"b\" \"c\" } [ \"X\" write ] [ write ] interleave" "aXbXc" } ;

HELP: index
{ $values { "obj" object } { "seq" sequence } { "n" "an index" } }
{ $description "Outputs the index of the first element in the sequence equal to " { $snippet "obj" } ". If no element is found, outputs " { $link f } "." } ;

HELP: index-from
{ $values { "obj" object } { "i" "a start index" } { "seq" sequence } { "n" "an index" } }
{ $description "Outputs the index of the first element in the sequence equal to " { $snippet "obj" } ", starting the search from the " { $snippet "i" } "th element. If no element is found, outputs " { $link f } "." } ;

HELP: last-index
{ $values { "obj" object } { "seq" sequence } { "n" "an index" } }
{ $description "Outputs the index of the last element in the sequence equal to " { $snippet "obj" } "; the sequence is traversed back to front. If no element is found, outputs " { $link f } "." } ;

HELP: last-index-from
{ $values { "obj" object } { "i" "a start index" } { "seq" sequence } { "n" "an index" } }
{ $description "Outputs the index of the last element in the sequence equal to " { $snippet "obj" } ", traversing the sequence backwards starting from the " { $snippet "i" } "th element and finishing at the first. If no element is found, outputs " { $link f } "." } ;

HELP: member?
{ $values { "elt" object } { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if the sequence contains an element equal to the object." }
{ $notes "This word uses equality comparison (" { $link = } ")." } ;

HELP: memq?
{ $values { "elt" object } { "seq" sequence } { "?" "a boolean" } }
{ $description "Tests if the sequence contains the object." }
{ $notes "This word uses identity comparison (" { $link eq? } ")." } ;

HELP: remove
{ $values { "elt" object } { "seq" sequence } { "newseq" "a new sequence" } }
{ $description "Outputs a new sequence containing all elements of the input sequence except for given element." }
{ $notes "This word uses equality comparison (" { $link = } ")." } ;

HELP: remq
{ $values { "elt" object } { "seq" sequence } { "newseq" "a new sequence" } }
{ $description "Outputs a new sequence containing all elements of the input sequence except those equal to the given element." }
{ $notes "This word uses identity comparison (" { $link eq? } ")." } ;

HELP: remove-nth
{ $values
     { "n" integer } { "seq" sequence }
     { "seq'" sequence } }
{ $description "Creates a new sequence without the element at index " { $snippet "n" } "." }
{ $examples "Notice that the original sequence is left intact:" { $example "USING: sequences prettyprint kernel ;"
    "{ 1 2 3 } 1 over remove-nth . ."
    "{ 1 3 }\n{ 1 2 3 }"
} } ;

HELP: move
{ $values { "from" "an index in " { $snippet "seq" } } { "to" "an index in " { $snippet "seq" } } { "seq" "a mutable sequence" } }
{ $description "Sets the element with index " { $snippet "m" } " to the element with index " { $snippet "n" } "." }
{ $side-effects "seq" } ;

HELP: delete
{ $values { "elt" object } { "seq" "a resizable mutable sequence" } }
{ $description "Removes all elements equal to " { $snippet "elt" } " from " { $snippet "seq" } "." }
{ $notes "This word uses equality comparison (" { $link = } ")." }
{ $side-effects "seq" } ;

HELP: delq
{ $values { "elt" object } { "seq" "a resizable mutable sequence" } }
{ $description "Outputs a new sequence containing all elements of the input sequence except the given element." }
{ $notes "This word uses identity comparison (" { $link eq? } ")." }
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
{ $values { "new" sequence } { "seq" sequence } { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq'" sequence } }
{ $description "Replaces a range of elements beginning at index " { $snippet "from" } " and ending before index " { $snippet "to" } " with a new sequence." }
{ $errors "Throws an error if " { $snippet "new" } " contains elements whose types are not permissible in " { $snippet "seq" } "." } ;

{ push prefix suffix } related-words

HELP: suffix
{ $values { "seq" sequence } { "elt" object } { "newseq" sequence } }
{ $description "Outputs a new sequence obtained by adding " { $snippet "elt" } " at the end of " { $snippet "seq" } "." }
{ $errors "Throws an error if the type of " { $snippet "elt" } " is not permitted in sequences of the same class as " { $snippet "seq1" } "." }
{ $examples
    { $example "USING: prettyprint sequences ;" "{ 1 2 3 } 4 suffix ." "{ 1 2 3 4 }" }
} ;

HELP: prefix
{ $values { "seq" sequence } { "elt" object } { "newseq" sequence } }
{ $description "Outputs a new sequence obtained by adding " { $snippet "elt" } " at the beginning of " { $snippet "seq" } "." }
{ $errors "Throws an error if the type of " { $snippet "elt" } " is not permitted in sequences of the same class as " { $snippet "seq1" } "." } 
{ $examples
{ $example "USING: prettyprint sequences ;" "{ 1 2 3 } 0 prefix ." "{ 0 1 2 3 }" }
} ;

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

HELP: mismatch
{ $values { "seq1" sequence } { "seq2" sequence } { "i" "an index" } }
{ $description "Compares pairs of elements up to the minimum of the sequences' lengths, outputting the first index where the two sequences have non-equal elements, or " { $link f } " if all tested elements were equal." } ;

HELP: flip
{ $values { "matrix" "a sequence of equal-length sequences" } { "newmatrix" "a sequence of equal-length sequences" } }
{ $description "Transposes the matrix; that is, rows become columns and columns become rows." }
{ $examples { $example "USING: prettyprint sequences ;" "{ { 1 2 3 } { 4 5 6 } } flip ." "{ { 1 4 } { 2 5 } { 3 6 } }" } } ;

HELP: exchange
{ $values { "m" "a non-negative integer" } { "n" "a non-negative integer" } { "seq" "a mutable sequence" } }
{ $description "Exchanges the " { $snippet "m" } "th and " { $snippet "n" } "th elements of " { $snippet "seq" } "." } ;

HELP: reverse-here
{ $values { "seq" "a mutable sequence" } }
{ $description "Reverses a sequence in-place." }
{ $side-effects "seq" } ;

HELP: padding
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "elt" object } { "quot" { $quotation "( seq1 seq2 -- newseq )" } } { "newseq" "a new sequence" } }
{ $description "Outputs a new string sequence of " { $snippet "elt" } " repeated, that when appended to " { $snippet "seq" } ", yields a sequence of length " { $snippet "n" } ". If the length of " { $snippet "seq" } " is greater than " { $snippet "n" } ", this word outputs an empty sequence." } ;

HELP: pad-head
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "elt" object } { "padded" "a new sequence" } }
{ $description "Outputs a new sequence consisting of " { $snippet "seq" } " padded on the left with enough repetitions of " { $snippet "elt" } " to have the result be of length " { $snippet "n" } "." }
{ $examples { $example "USING: io sequences ;" "{ \"ab\" \"quux\" } [ 5 CHAR: - pad-head print ] each" "---ab\n-quux" } } ;

HELP: pad-tail
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "elt" object } { "padded" "a new sequence" } }
{ $description "Outputs a new sequence consisting of " { $snippet "seq" } " padded on the right with enough repetitions of " { $snippet "elt" } " to have the result be of length " { $snippet "n" } "." }
{ $examples { $example "USING: io sequences ;" "{ \"ab\" \"quux\" } [ 5 CHAR: - pad-tail print ] each" "ab---\nquux-" } } ;

HELP: sequence=
{ $values { "seq1" sequence } { "seq2" sequence } { "?" "a boolean" } }
{ $description "Tests if the two sequences have the same length and elements. This is weaker than " { $link = } ", since it does not ensure that the sequences are instances of the same class." } ;

HELP: reversed
{ $class-description "A virtual sequence which presents a reversed view of an underlying sequence. New instances can be created by calling " { $link <reversed> } "." } ;

HELP: reverse
{ $values { "seq" sequence } { "newseq" "a new sequence" } }
{ $description "Outputs a new sequence having the same elements as " { $snippet "seq" } " but in reverse order." } ;

{ reverse <reversed> reverse-here } related-words

HELP: <reversed>
{ $values { "seq" sequence } { "reversed" "a new sequence" } }
{ $description "Creates an instance of the " { $link reversed } " class." }
{ $see-also "virtual-sequences" } ;

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
{ $class-description "A virtual sequence which presents a subrange of the elements of an underlying sequence. New instances can be created by calling " { $link <slice> } "."
$nl
"Slices are mutable if the underlying sequence is mutable, and mutating a slice changes the underlying sequence. However, slices cannot be resized after creation." } ;

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
{ $description "Outputs a slice with the same elements as " { $snippet "seq" } ", and " { $snippet "from" } " equal to 0 and " { $snippet "to" } " equal to the length of " { $snippet "seq" } "." }
{ $notes "Some words create slices then proceed to read the " { $snippet "to" } " and " { $snippet "from" } " slots of the slice. To behave predictably when they are themselves given a slice as input, they apply this word first to get a canonical slice." } ;

HELP: <slice>
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" sequence } { "slice" slice } }
{ $description "Outputs a new virtual sequence sharing storage with the subrange of elements in " { $snippet "seq" } " with indices starting from and including " { $snippet "m" } ", and up to but not including " { $snippet "n" } "." }
{ $errors "Throws an error if " { $snippet "m" } " or " { $snippet "n" } " is out of bounds." }
{ $notes "Taking the slice of a slice outputs a slice of the underlying sequence of the original slice. Keep this in mind when writing code which depends on the values of " { $snippet "from" } " and " { $snippet "to" } " being equal to the inputs to this word. The " { $link <flat-slice> } " word might be helpful in such situations." } ;

{ <slice> subseq } related-words

HELP: repetition
{ $class-description "A virtual sequence consisting of " { $snippet "elt" } " repeated " { $snippet "len" } " times. Repetitions are created by calling " { $link <repetition> } "." } ;

HELP: <repetition>
{ $values { "len" "a non-negative integer" } { "elt" object } { "repetition" repetition } }
{ $description "Creates a new " { $link repetition } "." }
{ $examples
    { $example "USING: arrays prettyprint sequences ;" "10 \"X\" <repetition> >array ." "{ \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" \"X\" }" }
    { $example "USING: prettyprint sequences ;" "10 \"X\" <repetition> concat ." "\"XXXXXXXXXX\"" }
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
{ $errors "Throws an error if " { $snippet "seq2" } " contains elements not permitted in sequences of the same class as " { $snippet "seq1" } "." }
{ $examples 
    { $example "USING: prettyprint sequences ;"
        "{ 1 2 } B{ 3 4 } append ."
        "{ 1 2 3 4 }"
    }
    { $example "USING: prettyprint sequences strings ;"
        "\"go\" \"ing\" append ."
        "\"going\""
    }
} ;

HELP: append-as
{ $values { "seq1" sequence } { "seq2" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence of the same type as " { $snippet "exemplar" } " consisting of the elements of " { $snippet "seq1" } " followed by " { $snippet "seq2" } "." }
{ $errors "Throws an error if " { $snippet "seq1" } " or " { $snippet "seq2" } " contain elements not permitted in sequences of the same class as " { $snippet "exemplar" } "." }
{ $examples 
    { $example "USING: prettyprint sequences ;"
        "{ 1 2 } B{ 3 4 } B{ } append-as ."
        "B{ 1 2 3 4 }"
    }
    { $example "USING: prettyprint sequences strings ;"
        "\"go\" \"ing\" SBUF\" \" append-as ."
        "SBUF\" going\""
    }
} ;

{ append append-as } related-words

HELP: prepend
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence of the same type as " { $snippet "seq2" } " consisting of the elements of " { $snippet "seq2" } " followed by " { $snippet "seq1" } "." }
{ $errors "Throws an error if " { $snippet "seq1" } " contains elements not permitted in sequences of the same class as " { $snippet "seq2" } "." }
{ $examples { $example "USING: prettyprint sequences ;"
        "{ 1 2 } B{ 3 4 } prepend ."
        "B{ 3 4 1 2 }"
    }
    { $example "USING: prettyprint sequences strings ;"
        "\"go\" \"car\" prepend ."
        "\"cargo\""
    }
} ;

HELP: 3append
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence consisting of the elements of " { $snippet "seq1" } ", " { $snippet "seq2" } " and " { $snippet "seq3" } " in turn." }
{ $errors "Throws an error if " { $snippet "seq2" } " or " { $snippet "seq3" } " contain elements not permitted in sequences of the same class as " { $snippet "seq1" } "." }
{ $examples
    { $example "USING: prettyprint sequences ;"
        "\"a\" \"b\" \"c\" 3append ."
        "\"abc\""
    }
} ;

HELP: 3append-as
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence consisting of the elements of " { $snippet "seq1" } ", " { $snippet "seq2" } " and " { $snippet "seq3" } " in turn of the same type as " { $snippet "exemplar" } "." }
{ $errors "Throws an error if " { $snippet "seq1" } ", " { $snippet "seq2" } ", or " { $snippet "seq3" } " contain elements not permitted in sequences of the same class as " { $snippet "exemplar" } "." }
{ $examples
    { $example "USING: prettyprint sequences ;"
        "\"a\" \"b\" \"c\" SBUF\" \" 3append-as ."
        "SBUF\" abc\""
    }
} ;

{ 3append 3append-as } related-words

HELP: surround
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence with " { $snippet "seq1" } " inserted between " { $snippet "seq2" } " and " { $snippet "seq3" } "." }
{ $examples
    { $example "USING: sequences prettyprint ;"
               "\"sssssh\" \"(\" \")\" surround ."
               "\"(sssssh)\""
    }
} ;

HELP: glue
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence with " { $snippet "seq3" } " inserted between " { $snippet "seq1" } " and " { $snippet "seq2" } "." }
{ $examples
    { $example "USING: sequences prettyprint ;"
               "\"a\" \"b\" \",\" glue ."
               "\"a,b\""
    }
} ;

HELP: subseq
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" sequence } { "subseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of all elements starting from and including " { $snippet "from" } ", and up to but not including " { $snippet "to" } "." }
{ $errors "Throws an error if " { $snippet "from" } " or " { $snippet "to" } " is out of bounds." } ;

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

HELP: but-last-slice
{ $values { "seq" sequence } { "slice" "a slice" } }
{ $description "Outputs a virtual sequence sharing storage with all but the last element of the input sequence." }
{ $errors "Throws an error on an empty sequence." } ;

HELP: rest-slice
{ $values { "seq" sequence } { "slice" "a slice" } }
{ $description "Outputs a virtual sequence sharing storage with all elements from the 1st index until the end of the input sequence." }
{ $notes "Equivalent to " { $snippet "1 tail" } }
{ $errors "Throws an error on an empty sequence." } ;

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

HELP: but-last
{ $values { "seq" sequence } { "headseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of the input sequence with the last item removed." }
{ $errors "Throws an error on an empty sequence." } ;

HELP: rest
{ $values { "seq" sequence } { "tailseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of the input sequence with the first item removed." }
{ $errors "Throws an error on an empty sequence." } ;

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

{ remove remove-nth remq delq delete delete-nth } related-words

HELP: cut-slice
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "before-slice" sequence } { "after-slice" "a slice" } }
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
    { $example "USING: prettyprint sequences ;" "{ 1 2 3 } unclip suffix ." "{ 2 3 1 }" }
} ;

HELP: unclip-slice
{ $values { "seq" sequence } { "rest-slice" slice } { "first" object } }
{ $description "Outputs a tail sequence and the first element of " { $snippet "seq" } "; the tail sequence consists of all elements of " { $snippet "seq" } " but the first. Unlike " { $link unclip } ", this word does not make a copy of the input sequence, and runs in constant time." }
{ $examples { $example "USING: math.order prettyprint sequences ;" "{ 3 -1 -10 5 7 } unclip-slice [ min ] reduce ." "-10" } } ;

HELP: unclip-last
{ $values { "seq" sequence } { "butlast" sequence } { "last" object } }
{ $description "Outputs a head sequence and the last element of " { $snippet "seq" } "; the head sequence consists of all elements of " { $snippet "seq" } " but the last." }
{ $examples
    { $example "USING: prettyprint sequences ;" "{ 1 2 3 } unclip-last prefix ." "{ 3 1 2 }" }
} ;

HELP: unclip-last-slice
{ $values { "seq" sequence } { "butlast-slice" slice } { "last" object } }
{ $description "Outputs a head sequence and the last element of " { $snippet "seq" } "; the head sequence consists of all elements of " { $snippet "seq" } " but the last Unlike " { $link unclip-last } ", this word does not make a copy of the input sequence, and runs in constant time." } ;

HELP: sum
{ $values { "seq" "a sequence of numbers" } { "n" "a number" } }
{ $description "Outputs the sum of all elements of " { $snippet "seq" } ". Outputs zero given an empty sequence." } ;

HELP: product
{ $values { "seq" "a sequence of numbers" } { "n" "a number" } }
{ $description "Outputs the product of all elements of " { $snippet "seq" } ". Outputs one given an empty sequence." } ;

HELP: infimum
{ $values { "seq" "a sequence of real numbers" } { "n" "a number" } }
{ $description "Outputs the least element of " { $snippet "seq" } "." }
{ $errors "Throws an error if the sequence is empty." } ;

HELP: supremum
{ $values { "seq" "a sequence of real numbers" } { "n" "a number" } }
{ $description "Outputs the greatest element of " { $snippet "seq" } "." }
{ $errors "Throws an error if the sequence is empty." } ;

HELP: produce
{ $values { "pred" { $quotation "( -- ? )" } } { "quot" { $quotation "( -- obj )" } } { "seq" "a sequence" } }
{ $description "Calls " { $snippet "pred" } " repeatedly. If the predicate yields " { $link f } ", stops, otherwise, calls " { $snippet "quot" } " to yield a value. Values are accumulated and returned in a sequence at the end." }
{ $examples
    "The following example divides a number by two until we reach zero, and accumulates intermediate results:"
    { $example "USING: kernel math prettyprint sequences ;" "1337 [ dup 0 > ] [ 2/ dup ] produce nip ." "{ 668 334 167 83 41 20 10 5 2 1 0 }" }
    "The following example collects random numbers as long as they are greater than 1:"
    { $unchecked-example "USING: kernel prettyprint random sequences ;" "[ 10 random dup 1 > ] [ ] produce nip ." "{ 8 2 2 9 }" }
} ;

HELP: produce-as
{ $values { "pred" { $quotation "( -- ? )" } } { "quot" { $quotation "( -- obj )" } } { "exemplar" sequence } { "seq" "a sequence" } }
{ $description "Calls " { $snippet "pred" } " repeatedly. If the predicate yields " { $link f } ", stops, otherwise, calls " { $snippet "quot" } " to yield a value. Values are accumulated and returned in a sequence of type " { $snippet "exemplar" } " at the end." }
{ $examples "See " { $link produce } " for examples." } ;

HELP: sigma
{ $values { "seq" sequence } { "quot" quotation } { "n" number } }
{ $description "Like map sum, but without creating an intermediate sequence." }
{ $example
    "! Find the sum of the squares [0,99]"
    "USING: math math.ranges sequences prettyprint ;"
    "100 [1,b] [ sq ] sigma ."
    "338350"
} ;

HELP: count
{ $values { "seq" sequence } { "quot" quotation } { "n" integer } }
{ $description "Efficiently returns the number of elements that the predicate quotation matches." }
{ $example
    "USING: math math.ranges sequences prettyprint ;"
    "100 [1,b] [ even? ] count ."
    "50"
} ;

HELP: pusher
{ $values
     { "quot" "a predicate quotation" }
     { "quot" quotation } { "accum" vector } }
{ $description "Creates a new vector to accumulate the values which return true for a predicate.  Returns a new quotation which accepts an object to be tested and stored in the accumulator if the test yields true. The accumulator is left on the stack for convenience." }
{ $example "! Find all the even numbers:" "USING: prettyprint sequences math kernel ;"
           "10 [ even? ] pusher [ each ] dip ."
           "V{ 0 2 4 6 8 }"
}
{ $notes "Used to implement the " { $link filter } " word." } ;

HELP: trim-head
{ $values
     { "seq" sequence } { "quot" quotation }
     { "newseq" sequence } }
{ $description "Removes elements starting from the left side of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a new sequence." }
{ $example "" "USING: prettyprint math sequences ;"
           "{ 0 0 1 2 3 0 0 } [ zero? ] trim-head ."
           "{ 1 2 3 0 0 }"
} ;

HELP: trim-head-slice
{ $values
     { "seq" sequence } { "quot" quotation }
     { "slice" slice } }
{ $description "Removes elements starting from the left side of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a slice" }
{ $example "" "USING: prettyprint math sequences ;"
           "{ 0 0 1 2 3 0 0 } [ zero? ] trim-head-slice ."
           "T{ slice { from 2 } { to 7 } { seq { 0 0 1 2 3 0 0 } } }"
} ;

HELP: trim-tail
{ $values
     { "seq" sequence } { "quot" quotation }
     { "newseq" sequence } }
{ $description "Removes elements starting from the right side of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a new sequence." }
{ $example "" "USING: prettyprint math sequences ;"
           "{ 0 0 1 2 3 0 0 } [ zero? ] trim-tail ."
           "{ 0 0 1 2 3 }"
} ;

HELP: trim-tail-slice
{ $values
     { "seq" sequence } { "quot" quotation }
     { "slice" slice } }
{ $description "Removes elements starting from the right side of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a slice." }
{ $example "" "USING: prettyprint math sequences ;"
           "{ 0 0 1 2 3 0 0 } [ zero? ] trim-tail-slice ."
           "T{ slice { from 0 } { to 5 } { seq { 0 0 1 2 3 0 0 } } }"
} ;

HELP: trim
{ $values
     { "seq" sequence } { "quot" quotation }
     { "newseq" sequence } }
{ $description "Removes elements starting from the left and right sides of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a new sequence." }
{ $example "" "USING: prettyprint math sequences ;"
           "{ 0 0 1 2 3 0 0 } [ zero? ] trim ."
           "{ 1 2 3 }"
} ;

HELP: trim-slice
{ $values
     { "seq" sequence } { "quot" quotation }
     { "slice" slice } }
{ $description "Removes elements starting from the left and right sides of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a slice." }
{ $example "" "USING: prettyprint math sequences ;"
           "{ 0 0 1 2 3 0 0 } [ zero? ] trim-slice ."
           "T{ slice { from 2 } { to 5 } { seq { 0 0 1 2 3 0 0 } } }"
} ;

{ trim trim-slice trim-head trim-head-slice trim-tail trim-tail-slice } related-words

HELP: sift
{ $values
     { "seq" sequence }
     { "newseq" sequence } }
 { $description "Outputs a new sequence with all instance of " { $link f  } " removed." }
 { $examples 
    { $example "USING: prettyprint sequences ;"
        "{ \"a\" 3 { } f } sift ."
        "{ \"a\" 3 { } }"
    }
} ;

HELP: harvest
{ $values
     { "seq" sequence }
     { "newseq" sequence } }
{ $description "Outputs a new sequence with all empty sequences removed." }
{ $examples 
    { $example "USING: prettyprint sequences ;"
               "{ { } { 2 3 } { 5 } { } } harvest ."
               "{ { 2 3 } { 5 } }"
    }
} ;

{ filter filter-here sift harvest } related-words

HELP: set-first
{ $values
     { "first" object } { "seq" sequence } }
{ $description "Sets the first element of a sequence." }
{ $examples 
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4  } 5 over set-first ."
        "{ 5 2 3 4 }"
    }
} ;

HELP: set-second
{ $values
     { "second" object } { "seq" sequence } }
{ $description "Sets the second element of a sequence." }
{ $examples 
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4  } 5 over set-second ."
        "{ 1 5 3 4 }"
    }
} ;

HELP: set-third
{ $values
     { "third" object } { "seq" sequence } }
{ $description "Sets the third element of a sequence." }
{ $examples 
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4  } 5 over set-third ."
        "{ 1 2 5 4 }"
    }
} ;

HELP: set-fourth
{ $values
     { "fourth" object } { "seq" sequence } }
{ $description "Sets the fourth element of a sequence." }
{ $examples 
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4  } 5 over set-fourth ."
        "{ 1 2 3 5 }"
    }
} ;

{ set-first set-second set-third set-fourth } related-words

HELP: replicate
{ $values
     { "seq" sequence } { "quot" { $quotation "( -- elt )" } }
     { "newseq" sequence } }
{ $description "Calls the quotation for every element of the sequence in order. However, the element is not passed to the quotation -- it is dropped, and the quotation produces an element of its own that is collected into a sequence of the same class as the input sequence." }
{ $examples 
    { $unchecked-example "USING: prettyprint kernel sequences ;"
        "5 [ 100 random ] replicate ."
        "{ 52 10 45 81 30 }"
    }
} ;

HELP: replicate-as
{ $values
     { "seq" sequence } { "quot" quotation } { "exemplar" sequence }
     { "newseq" sequence } }
{ $description "Calls the quotation for every element of the sequence in order. However, the element is not passed to the quotation -- it is dropped, and the quotation produces an element of its own that is collected into a sequence of the same class as the exemplar sequence." }
{ $examples 
    { $unchecked-example "USING: prettyprint kernel sequences ;"
        "5 [ 100 random ] B{ } replicate-as ."
        "B{ 44 8 2 33 18 }"
    }
} ;
{ replicate replicate-as } related-words

HELP: partition
{ $values
     { "seq" sequence } { "quot" quotation }
     { "trueseq" sequence } { "falseseq" sequence } }
     { $description "Calls a predicate quotation on each element of the input sequence.  If the test yields true, the element is added to " { $snippet "trueseq" } "; if false, it's added to " { $snippet "falseseq" } "." }
{ $examples 
    { $example "USING: prettyprint kernel math sequences ;"
        "{ 1 2 3 4 5 } [ even? ] partition [ . ] bi@"
        "{ 2 4 }\n{ 1 3 5 }"
    }
} ;

HELP: virtual-seq
{ $values
     { "seq" sequence }
     { "seq'" sequence } }
{ $description "Part of the virtual sequence protocol, this word is used to return an underlying array from which to look up a value at an index given by " { $link virtual@ } "." } ;

HELP: virtual@
{ $values
     { "n" integer } { "seq" sequence }
     { "n'" integer } { "seq'" sequence } }
{ $description "Part of the sequence protocol, this word translates the input index " { $snippet "n" } " into an index into the underlying storage returned by " { $link virtual-seq } "." } ;

HELP: 2map-reduce
{ $values
     { "seq1" sequence } { "seq2" sequence } { "map-quot" quotation } { "reduce-quot" quotation }
     { "result" object } }
{ $description "Unclips the first element of each sequence and calls " { $snippet "map-quot" } " on both objects. The result of this calculation is passed, along with the rest of both sequences, to " { $link 2reduce } ", with the computed object as the identity." }
{ $examples { $example "USING: sequences prettyprint math ;"
    "{ 10 30 50 } { 200 400 600 } [ + ] [ + ] 2map-reduce ."
    "1290"
} } ;

HELP: 2pusher
{ $values
     { "quot" quotation }
     { "quot" quotation } { "accum1" vector } { "accum2" vector } }
{ $description "Creates two new vectors to accumultate values based on a predicate. The first vector accumulates values for which the predicate yields true; the second for false." } ;

HELP: 2reverse-each
{ $values
     { "seq1" sequence } { "seq2" sequence } { "quot" quotation } }
{ $description "Reverse the sequences using the " { $link <reversed> } " word and calls " { $link 2each } " on the reversed sequences." }
{ $examples { $example "USING: sequences math prettyprint ;"
    "{ 10 20 30 } { 1 2 3 } [ + . ] 2reverse-each"
    "33\n22\n11"
} } ;

HELP: 2unclip-slice
{ $values
     { "seq1" sequence } { "seq2" sequence }
     { "rest-slice1" sequence } { "rest-slice2" sequence } { "first1" object } { "first2" object } }
{ $description "Unclips the first element of each sequence and leaves two slice elements and the two unclipped objects on the stack." }
{ $examples { $example "USING: sequences prettyprint kernel arrays ;"
    "{ 1 2 } { 3 4 } 2unclip-slice 4array [ . ] each"
    "T{ slice { from 1 } { to 2 } { seq { 1 2 } } }\nT{ slice { from 1 } { to 2 } { seq { 3 4 } } }\n1\n3"
} } ;

HELP: accumulator
{ $values
     { "quot" quotation }
     { "quot'" quotation } { "vec" vector } }
{ $description "Creates a new quotation that pushes its result to a vector and outputs that vector on the stack." }
{ $examples { $example "USING: sequences prettyprint kernel math ;"
    "{ 1 2 } [ 30 + ] accumulator [ each ] dip ."
    "V{ 31 32 }"
} } ;

HELP: binary-reduce
{ $values
     { "seq" sequence } { "start" integer } { "quot" quotation }
     { "value" object } }
{ $description "Like " { $link reduce } ", but splits the sequence in half recursively until each sequence is small enough, and calls the quotation on these smaller sequences. If the quotation computes values that depend on the size of their input, such as bignum arithmetic, then this algorithm can be more efficient than using " { $link reduce } "." }
{ $examples "Computing factorial:"
    { $example "USING: prettyprint sequences math ;"
    "40 rest-slice 1 [ * ] binary-reduce ."
    "20397882081197443358640281739902897356800000000" }
} ;

HELP: follow
{ $values
     { "obj" object } { "quot" quotation }
     { "seq" sequence } }
{ $description "Outputs a sequence containing the input object and all of the objects generated by successively feeding the result of the quotation called on the input object to the quotation recursuively. Objects yielded by the quotation are added to the output sequence until the quotation yields " { $link f } ", at which point the recursion terminates." }
{ $examples "Get random numbers until zero is reached:"
    { $unchecked-example
    "USING: random sequences prettyprint math ;"
    "100 [ random dup zero? [ drop f ] when ] follow ."
    "{ 100 86 34 32 24 11 7 2 }"
} } ;

HELP: halves
{ $values
     { "seq" sequence }
     { "first-slice" slice } { "second-slice" slice } }
{ $description "Splits a sequence into two slices at the midpoint. If the sequence has an odd number of elements, the extra element is returned in the second slice." }
{ $examples { $example "USING: arrays sequences prettyprint kernel ;"
    "{ 1 2 3 4 5 } halves [ >array . ] bi@"
    "{ 1 2 }\n{ 3 4 5 }"
} } ;

HELP: indices
{ $values
     { "obj" object } { "seq" sequence }
     { "indices" sequence } }
{ $description "Compares the input object to every element in the sequence and returns a vector containing the index of every position where the element was found." }
{ $examples { $example "USING: sequences prettyprint ;"
    "2 { 2 4 2 6 2 8 2 10 } indices ."
    "V{ 0 2 4 6 }"
} } ;

HELP: insert-nth
{ $values
     { "elt" object } { "n" integer } { "seq" sequence }
     { "seq'" sequence } }
{ $description "Creates a new sequence where the " { $snippet "n" } "th index is set to the input object." }
{ $examples { $example "USING: prettyprint sequences ;"
    "40 3 { 10 20 30 50 } insert-nth ."
    "{ 10 20 30 40 50 }"
} } ;

HELP: map-reduce
{ $values
     { "seq" sequence } { "map-quot" quotation } { "reduce-quot" quotation }
     { "result" object } }
{ $description "Unclips the first element of the sequence, calls " { $snippet "map-quot" } " on that element, and proceeds like a " { $link reduce } ", where the calculated element is the identity element and the rest of the sequence is the sequence to reduce." }
{ $examples { $example "USING: sequences prettyprint math ;"
    "{ 1 3 5 } [ sq ] [ + ] map-reduce ."
    "35"
} } ;

HELP: new-like
{ $values
     { "len" integer } { "exemplar" "an exemplar sequence" } { "quot" quotation }
     { "seq" sequence } }
{ $description "Creates a new sequence of length " { $snippet "len" } " and calls the quotation with this sequence on the stack. The output of the quotation and the original exemplar are then passed to " { $link like } " so that the output sequence is the exemplar's type." } ;

HELP: push-either
{ $values
     { "elt" object } { "quot" quotation } { "accum1" vector } { "accum2" vector } }
{ $description "Pushes the input object onto one of the accumualators; the first if the quotation yields true, the second if false." } ;

HELP: sequence-hashcode
{ $values
     { "n" integer } { "seq" sequence }
     { "x" integer } }
{ $description "Iterates over a sequence, computes a hashcode with " { $link hashcode* } " for each element, and combines them using " { $link sequence-hashcode-step } "." } ;

HELP: sequence-hashcode-step
{ $values
     { "oldhash" integer } { "newpart" integer }
     { "newhash" integer } }
{ $description "An implementation word that computes a running hashcode of a sequence using some bit-twiddling. The resulting hashcode is always a fixnum." } ;

HELP: short
{ $values
     { "seq" sequence } { "n" integer }
     { "seq" sequence } { "n'" integer } }
{ $description "Returns the input sequence and its length or " { $snippet "n" } ", whichever is less." }
{ $examples { $example "USING: sequences kernel prettyprint ;"
    "\"abcd\" 3 short [ . ] bi@"
    "\"abcd\"\n3"
} } ;

HELP: shorten
{ $values
     { "n" integer } { "seq" sequence } }
{ $description "Shortens a " { $link "growable" } " sequence to by " { $snippet "n" } " elements long." }
{ $examples { $example "USING: sequences prettyprint kernel ;"
    "V{ 1 2 3 4 5 } 3 over shorten ."
    "V{ 1 2 3 }"
} } ;

HELP: iota
{ $values { "n" integer } { "iota" iota } }
{ $description "Creates an immutable virtual sequence containing the integers from 0 to " { $snippet "n-1" } "." }
{ $examples
  { $example
    "USING: math sequences prettyprint ;"
    "3 iota [ sq ] map ."
    "{ 0 1 4 }"
  }
} ;

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
"Note that sequences are always indexed starting from zero."
$nl
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
{ $subsection new-sequence }
{ $subsection new-resizable }
{ $see-also "sequences-unsafe" } ;

ARTICLE: "virtual-sequences-protocol" "Virtual sequence protocol"
"Virtual sequences must know their length:"
{ $subsection length }
"The underlying sequence to look up a value in:"
{ $subsection virtual-seq }
"The index of the value in the underlying sequence:"
{ $subsection virtual@ } ;

ARTICLE: "virtual-sequences" "Virtual sequences"
"Virtual sequences allow different ways of accessing a sequence without having to create a new sequence or a new data structure altogether. To do this, they translate the virtual index into a normal index into an underlying sequence using the " { $link "virtual-sequences-protocol" } "."
{ $subsection "virtual-sequences-protocol" } ;

ARTICLE: "sequences-integers" "Counted loops"
"Integers support the sequence protocol in a trivial fashion; a non-negative integer presents its non-negative predecessors as elements. For example, the integer 3, when viewed as a sequence, contains the elements 0, 1, and 2. This is very useful for performing counted loops."
$nl
"For example, the " { $link each } " combinator, given an integer, simply calls a quotation that number of times, pushing a counter on each iteration that ranges from 0 up to that integer:"
{ $example "3 [ . ] each" "0\n1\n2" }
"A common idiom is to iterate over a sequence, while also maintaining a loop counter. This can be done using " { $link each-index } ", " { $link map-index } " and " { $link reduce-index } "."
$nl
"Combinators that produce new sequences, such as " { $link map } ", will output an array if the input is an integer."
$nl
"More elaborate counted loops can be performed with " { $link "math.ranges" } "." ;

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
{ $subsection prefix }
{ $subsection suffix }
"Removing elements:"
{ $subsection remove }
{ $subsection remq }
{ $subsection remove-nth } ;

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
{ $subsection flip } ;

ARTICLE: "sequences-appending" "Appending sequences"
{ $subsection append }
{ $subsection append-as }
{ $subsection prepend }
{ $subsection 3append }
{ $subsection 3append-as }
{ $subsection surround }
{ $subsection glue }
{ $subsection concat }
{ $subsection join }
"A pair of words useful for aligning strings:"
{ $subsection pad-head }
{ $subsection pad-tail } ;

ARTICLE: "sequences-slices" "Subsequences and slices"
"Extracting a subsequence:"
{ $subsection subseq }
{ $subsection head }
{ $subsection tail }
{ $subsection head* }
{ $subsection tail* }
"Removing the first or last element:"
{ $subsection rest }
{ $subsection but-last }
"Taking a sequence apart into a head and a tail:"
{ $subsection unclip }
{ $subsection unclip-last }
{ $subsection cut }
{ $subsection cut* }
"A " { $emphasis "slice" } " is a virtual sequence which presents as view of a subsequence of an underlying sequence:"
{ $subsection slice }
{ $subsection slice? }
"Extracting a slice:"
{ $subsection <slice> }
{ $subsection head-slice }
{ $subsection tail-slice }
{ $subsection head-slice* }
{ $subsection tail-slice* }
"Removing the first or last element:"
{ $subsection rest-slice }
{ $subsection but-last-slice }
"Taking a sequence apart into a head and a tail:"
{ $subsection unclip-slice }
{ $subsection unclip-last-slice }
{ $subsection cut-slice }
"A utility for words which use slices as iterators:"
{ $subsection <flat-slice> }
"Replacing slices with new elements:"
{ $subsection replace-slice } ;

ARTICLE: "sequences-combinators" "Sequence combinators"
"Iteration:"
{ $subsection each }
{ $subsection each-index }
{ $subsection reduce }
{ $subsection interleave }
{ $subsection replicate }
{ $subsection replicate-as }
"Mapping:"
{ $subsection map }
{ $subsection map-as }
{ $subsection map-index }
{ $subsection map-reduce }
{ $subsection accumulate }
{ $subsection produce }
{ $subsection produce-as }
"Filtering:"
{ $subsection filter }
{ $subsection partition }
"Testing if a sequence contains elements satisfying a predicate:"
{ $subsection any? }
{ $subsection all? }
{ $subsection "sequence-2combinators" }
{ $subsection "sequence-3combinators" } ;

ARTICLE: "sequence-2combinators" "Pair-wise sequence combinators"
"There is a set of combinators which traverse two sequences pairwise. If one sequence is shorter than the other, then only the prefix having the length of the minimum of the two is examined."
{ $subsection 2each }
{ $subsection 2reduce }
{ $subsection 2map }
{ $subsection 2map-as }
{ $subsection 2map-reduce }
{ $subsection 2all? } ;

ARTICLE: "sequence-3combinators" "Triple-wise sequence combinators"
"There is a set of combinators which traverse three sequences triple-wise. If one sequence is shorter than the others, then only the prefix having the length of the minimum of the three is examined."
{ $subsection 3each }
{ $subsection 3map }
{ $subsection 3map-as } ;

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
{ $subsection subseq? } ;

ARTICLE: "sequences-search" "Searching sequences"
"Finding the index of an element:"
{ $subsection index }
{ $subsection index-from }
{ $subsection last-index }
{ $subsection last-index-from }
"Finding the start of a subsequence:"
{ $subsection start }
{ $subsection start* }
"Finding the index of an element satisfying a predicate:"
{ $subsection find }
{ $subsection find-from }
{ $subsection find-last }
{ $subsection find-last-from }
{ $subsection map-find } ;

ARTICLE: "sequences-trimming" "Trimming sequences"
"Trimming words:"
{ $subsection trim }
{ $subsection trim-head }
{ $subsection trim-tail }
"Potentially more efficient trim:"
{ $subsection trim-slice }
{ $subsection trim-head-slice }
{ $subsection trim-tail-slice } ;

ARTICLE: "sequences-destructive-discussion" "When to use destructive operations"
"Constructive (non-destructive) operations should be preferred where possible because code without side-effects is usually more re-usable and easier to reason about. There are two main reasons to use destructive operations:"
{ $list
    "For the side-effect. Some code is simpler to express with destructive operations; constructive operations return new objects, and sometimes ``threading'' the objects through the program manually complicates stack shuffling."
    { "As an optimization. Some code can be written to use constructive operations, however would suffer from worse performance. An example is a loop which adds an element to a sequence on each iteration; one could use either " { $link suffix } " or " { $link push } ", however the former copies the entire sequence first, which would cause the loop to run in quadratic time." }
}
"The second reason is much weaker than the first one. In particular, many combinators (see " { $link map } ", " { $link produce } " and " { $link "namespaces-make" } ") as well as more advanced data structures (such as " { $vocab-link "persistent.vectors" } ") alleviate the need for explicit use of side effects." ;

ARTICLE: "sequences-destructive" "Destructive operations"
"These words modify their input, instead of creating a new sequence."
{ $subsection "sequences-destructive-discussion" }
"Changing elements:"
{ $subsection change-each }
{ $subsection change-nth }
"Deleting elements:"
{ $subsection delete }
{ $subsection delq }
{ $subsection delete-nth }
{ $subsection delete-slice }
{ $subsection delete-all }
{ $subsection filter-here }
"Other destructive words:"
{ $subsection reverse-here }
{ $subsection push-all }
{ $subsection move }
{ $subsection exchange }
{ $subsection copy }
"Many operations have constructive and destructive variants:"
{ $table
    { "Constructive" "Destructive" }
    { { $link suffix } { $link push } }
    { { $link but-last } { $link pop* } }
    { { $link unclip-last } { $link pop } }
    { { $link remove } { $link delete } }
    { { $link remq } { $link delq } }
    { { $link remove-nth } { $link delete-nth } }
    { { $link reverse } { $link reverse-here } }
    { { $link append } { $link push-all } }
    { { $link map } { $link change-each } }
    { { $link filter } { $link filter-here } }
}
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
"Sequence utility words can operate on any object whose class implements the sequence protocol. Most implementations are backed by storage. Some implementations obtain their elements from an underlying sequence, or compute them on the fly. These are known as " { $link "virtual-sequences" } "."
{ $subsection "sequences-access" }
{ $subsection "sequences-combinators" }
{ $subsection "sequences-add-remove" }
{ $subsection "sequences-appending" }
{ $subsection "sequences-slices" }
{ $subsection "sequences-reshape" }
{ $subsection "sequences-tests" }
{ $subsection "sequences-search" }
{ $subsection "sequences-comparing" }
{ $subsection "sequences-split" }
{ $subsection "grouping" }
{ $subsection "sequences-destructive" }
{ $subsection "sequences-stacks" }
{ $subsection "sequences-sorting" }
{ $subsection "binary-search" }
{ $subsection "sets" }
{ $subsection "sequences-trimming" }
{ $subsection "sequences.deep" }
"Using sequences for looping:"
{ $subsection "sequences-integers" }
{ $subsection "math.ranges" }
"For inner loops:"
{ $subsection "sequences-unsafe" } ;

ABOUT: "sequences"
