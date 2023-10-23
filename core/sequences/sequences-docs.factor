USING: arrays generic.single help.markup help.syntax kernel
layouts math math.order multiline quotations sequences.private
vectors ;
IN: sequences

HELP: sequence
{ $class-description "A mixin class whose instances are sequences. Custom implementations of the sequence protocol should be declared as instances of this mixin for all sequence functionality to work correctly:"
    { $code "INSTANCE: my-sequence sequence" }
} ;

HELP: length
{ $values { "seq" sequence } { "n" "a non-negative integer" } }
{ $contract "Outputs the length of the sequence. All sequences support this operation." }
{ $examples
    [=[
        USING: prettyprint sequences ;
        { 1 "a" { 2 3 } f } length .
        4
    ]=]
    [=[
        USING: prettyprint sequences ;
        "Hello, world!" length .
        13
    ]=]
} ;

HELP: set-length
{ $values { "n" "a non-negative integer" } { "seq" "a resizable sequence" } }
{ $contract "Resizes a sequence. The initial contents of the new area is undefined." }
{ $errors "Throws a " { $link no-method } " error if the sequence is not resizable, and a " { $link bounds-error } " if the new length is negative." }
{ $side-effects "seq" }
{ $examples
    [=[
        USING: kernel prettyprint sequences ;
        6 V{ 1 2 3 } [ set-length ] keep .
        V{ 1 2 3 0 0 0 }
    ]=]
    [=[
        USING: kernel prettyprint sequences ;
        3 V{ 1 2 3 4 5 6 } [ set-length ] keep .
        V{ 1 2 3 }
    ]=]
} ;

HELP: lengthen
{ $values { "n" "a non-negative integer" } { "seq" "a resizable sequence" } }
{ $contract "Ensures the sequence has a length of at least " { $snippet "n" } " elements. This word differs from " { $link set-length } " in two respects:"
    { $list
        { "This word does not shrink the sequence if " { $snippet "n" } " is less than its length." }
        { "The word doubles the underlying storage of " { $snippet "seq" } ", whereas " { $link set-length } " is permitted to set it to equal " { $snippet "n" } ". This ensures that repeated calls to this word with constant increments of " { $snippet "n" } " do not result in a quadratic amount of copying, so that for example " { $link push-all } " can run efficiently when used in a loop." }
    }
}
{ $examples
    { $example
        "USING: kernel prettyprint sequences ;"
        "6 V{ 1 1 1 1 } [ lengthen ] keep ."
        "V{ 1 1 1 1 0 0 }"
    }
    "Showing how the underlying storage grows:"
    { $example
        "USING: accessors kernel prettyprint sequences ;"
        "6 V{ 1 1 1 1 } [ lengthen ] keep underlying>> ."
        "{ 1 1 1 1 0 0 0 0 0 0 0 0 0 0 }"
    }
    "When " { $snippet "n" } " is less than the length of " { $snippet "seq" } ":"
    { $example
        "USING: kernel prettyprint sequences ;"
        "2 V{ 1 2 3 4 5 6 7 8 } [ lengthen ] keep ."
        "V{ 1 2 3 4 5 6 7 8 }"
    }
} ;

HELP: nth
{ $values { "n" "a non-negative integer" } { "seq" sequence } { "elt" "the element at the " { $snippet "n" } "th index" } }
{ $contract "Outputs the " { $snippet "n" } "th element of the sequence. Elements are numbered from zero, so the last element has an index one less than the length of the sequence. All sequences support this operation." }
{ $errors "Throws a " { $link bounds-error } " if the index is negative, or greater than or equal to the length of the sequence." }
{ $examples
    [=[
        USING: prettyprint sequences ;
        1 { "a" "b" "c" } nth .
        "b"
    ]=]
} ;

HELP: set-nth
{ $values { "elt" object } { "n" "a non-negative integer" } { "seq" "a mutable sequence" } }
{ $contract "Sets the " { $snippet "n" } "th element of the sequence. Storing beyond the end of a resizable sequence such as a vector or string buffer grows the sequence." }
{ $errors "Throws an error if the index is negative, or if the sequence is not resizable and the index is greater than or equal to the length of the sequence."
$nl
"Throws an error if the sequence cannot hold elements of the given type." }
{ $side-effects "seq" }
{ $examples
    [=[
        USING: kernel prettyprint sequences ;
        99 0 { 1 1 1 } [ set-nth ] keep .
        { 99 1 1 }
    ]=]
    [=[
        USING: kernel prettyprint sequences ;
        99 8 V{ 1 1 1 } [ set-nth ] keep .
        V{ 1 1 1 0 0 0 0 0 99 }
    ]=]
} ;

HELP: nths
{ $values
    { "indices" sequence } { "seq" sequence }
    { "seq'" sequence } }
{ $description "Outputs a sequence of elements from the input sequence indexed by the indices." }
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
{ $contract "Outputs a mutable sequence of length " { $snippet "len" } " which can hold the elements of " { $snippet "seq" } ". The initial contents of the sequence are undefined." }
{ $examples
    [=[
        USING: prettyprint sequences ;
        6 { 1 2 3 } new-sequence .
        { 0 0 0 0 0 0 }
    ]=]
} ;

HELP: new-resizable
{ $values { "len" "a non-negative integer" } { "seq" sequence } { "newseq" "a resizable mutable sequence" } }
{ $contract "Outputs a resizable mutable sequence with an initial capacity of " { $snippet "len" } " elements and zero length, which can hold the elements of " { $snippet "seq" } "." }
{ $examples
    { $example "USING: prettyprint sequences ;" "300 V{ } new-resizable ." "V{ }" }
    { $example "USING: prettyprint sequences ;" "300 SBUF\" \" new-resizable ." "SBUF\" \"" }
} ;

HELP: like
{ $values { "seq" sequence } { "exemplar" sequence } { "newseq" "a new sequence" } }
{ $contract "Outputs a sequence with the same elements as " { $snippet "seq" } ", but " { $emphasis "like" } " the template sequence, in the sense that it either has the same class as the template sequence, or if the template sequence is a virtual sequence, the same class as the template sequence's underlying sequence."
$nl
"The default implementation does nothing." }
{ $notes "Unlike " { $link clone-like } ", the output sequence might share storage with the input sequence." }
{ $examples
    { $example
        "USING: prettyprint sequences ;"
        "{ 1 2 3 } V{ } like ."
        "V{ 1 2 3 }"
    }
    "Demonstrating the shared storage:"
    { $example
        "USING: kernel prettyprint sequences ;"
        "{ 1 2 3 } dup V{ } like reverse! [ . ] bi@"
        "{ 3 2 1 }\nV{ 3 2 1 }"
    }
} ;

HELP: empty?
{ $values { "seq" sequence } { "?" boolean } }
{ $description "Tests if the sequence has zero length." } ;

HELP: if-empty
{ $values { "seq" sequence } { "quot1" quotation } { "quot2" quotation } }
{ $description "Makes an implicit check if the sequence is empty. An empty sequence is dropped and " { $snippet "quot1" } " is called. Otherwise, if the sequence has any elements, " { $snippet "quot2" } " is called on it." }
{ $examples
    { $example
        "USING: kernel prettyprint sequences ;"
        "{ 1 2 3 } [ \"empty sequence\" ] [ sum ] if-empty ."
        "6"
    }
} ;

HELP: when-empty
{ $values
    { "seq" sequence } { "quot" "the first quotation of an " { $link if-empty } }
    { "seq/obj" object }
}
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
    "{ 4 5 6 } [ ] [ sum . ] if-empty"
    "15"
    }
    { $example
    "USING: sequences prettyprint ;"
    "{ 4 5 6 } [ sum . ] unless-empty"
    "15"
    }
} ;

HELP: delete-all
{ $values { "seq" "a resizable sequence" } }
{ $description "Resizes the sequence to zero length, removing all elements. Not all sequences are resizable." }
{ $errors "Throws an error if the sequence is not resizable." }
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
{ $values { "n" integer } { "seq" sequence } { "?" boolean } }
{ $description "Tests if the index is within the bounds of the sequence." }
{ $examples
    [=[
        USING: prettyprint sequences ;
        5 { 1 2 3 } bounds-check? .
        f
    ]=]
} ;

HELP: bounds-error
{ $values { "n" integer } { "seq" sequence } }
{ $description "Throws a " { $link bounds-error } "." }
{ $error-description "Thrown by " { $link nth } ", " { $link set-nth } " and " { $link set-length } " if the given index lies beyond the bounds of the sequence." } ;

HELP: bounds-check
{ $values { "n" integer } { "seq" sequence } }
{ $description "Throws an error if " { $snippet "n" } " is negative or if it is greater than or equal to the length of " { $snippet "seq" } ". Otherwise the two inputs remain on the stack." } ;

HELP: ?nth
{ $values { "n" integer } { "seq" sequence } { "elt/f" { $maybe object } } }
{ $description "A forgiving version of " { $link nth } ". If the index is out of bounds, or if the sequence is " { $link f } ", simply outputs " { $link f } "." } ;

{ nth ?nth } related-words

HELP: ?set-nth
{ $values { "elt" object } { "n" integer } { "seq" sequence } }
{ $description "A forgiving version of " { $link set-nth } ". If the index is out of bounds, does nothing." } ;

HELP: ?first
{ $values { "seq" sequence } { "elt/f" { $maybe object } } }
{ $description "A forgiving version of " { $link first } ". If the sequence is empty, or if the sequence is " { $link f } ", simply outputs " { $link f } "." }
{ $examples
    "On an empty sequence:"
    { $example "USING: sequences prettyprint ;"
               "{ } ?first ."
               "f"
    }
    "Works like first on sequences with elements:"
    { $example "USING: sequences prettyprint ;"
               "{ 1 2 3 } ?first ."
               "1"
    }
} ;


HELP: ?second
{ $values { "seq" sequence } { "elt/f" { $maybe object } } }
{ $description "A forgiving version of " { $link second } ". If the sequence has less than two elements, or if the sequence is " { $link f } ", simply outputs " { $link f } "." } ;

HELP: ?last
{ $values { "seq" sequence } { "elt/f" { $maybe object } } }
{ $description "A forgiving version of " { $link last } ". If the sequence is empty, or if the sequence is " { $link f } ", simply outputs " { $link f } "." } ;

HELP: nth-unsafe
{ $values { "n" integer } { "seq" sequence } { "elt" object } }
{ $contract "Unsafe variant of " { $link nth } " that does not perform bounds checks." } ;

HELP: set-nth-unsafe
{ $values { "elt" object } { "n" integer } { "seq" sequence } }
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
{ $values { "obj1" object } { "obj2" object } { "obj3" object } { "obj4" object } { "exemplar" sequence } { "seq" sequence } }
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
{ $class-description "A predicate class whose instances are fixnums of valid array sizes for the current architecture. The minimum value is zero and the maximum value is " { $link max-array-capacity } "." }
{ $description "Low-level array length accessor." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is unsafe. It does not check types, so improper use can corrupt memory." }
{ $see-also integer-array-capacity } ;

HELP: integer-array-capacity
{ $class-description "A predicate class whose instances are integer of valid array sizes for the current architecture. The minimum value is zero and the maximum value is " { $link max-array-capacity } "." }
{ $description "Low-level array length accessor." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is unsafe. It does not check types, so improper use can corrupt memory." }
{ $see-also array-capacity } ;

HELP: array-nth
{ $values { "n" "a non-negative fixnum" } { "array" array } { "elt" object } }
{ $description "Low-level array element accessor." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is unsafe. It does not check types or array bounds, and improper use can corrupt memory. User code must use " { $link nth } " instead." } ;

HELP: set-array-nth
{ $values { "elt" object } { "n" "a non-negative fixnum" } { "array" array } }
{ $description "Low-level array element mutator." }
{ $warning "This word is in the " { $vocab-link "sequences.private" } " vocabulary because it is unsafe. It does not check types or array bounds, and improper use can corrupt memory. User code must use " { $link set-nth } " instead." } ;

HELP: collect
{ $values { "n" "a non-negative integer" } { "quot" { $quotation ( ... n -- ... value ) } } { "into" "a sequence of length at least " { $snippet "n" } } }
{ $description "A primitive mapping operation that applies a quotation to all integers from 0 up to but not including " { $snippet "n" } ", and collects the results in a new array. User code should use " { $link map } " instead." }
{ $examples
  { $example
    "USING: kernel math.parser prettyprint sequences sequences.private ;"
    "10 [ number>string ] 10 f new-sequence [ collect ] keep ."
    "{ \"0\" \"1\" \"2\" \"3\" \"4\" \"5\" \"6\" \"7\" \"8\" \"9\" }"
  }
} ;

HELP: each
{ $values { "seq" sequence } { "quot" { $quotation ( ... x -- ... ) } } }
{ $description "Applies the quotation to each element of the sequence in order." } ;

HELP: reduce
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "result" "the final result" } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs the final result. On the first iteration, the two inputs to the quotation are " { $snippet "identity" } ", and the first element of the sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the corresponding element of the sequence." }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 1 5 3 } 0 [ + ] reduce ." "9" }
} ;

HELP: reduce-index
{ $values
    { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt index -- ... next ) } } { "result" object } }
{ $description "Combines successive elements of the sequence and their indices binary operations, and outputs the final result. On the first iteration, the three inputs to the quotation are " { $snippet "identity" } ", the first element of the sequence, and its index, 0. On successive iterations, the first input is the result of the previous iteration, the second input is the corresponding element of the sequence, and the third is its index." }
{ $examples { $example "USING: sequences prettyprint math ;"
    "{ 10 50 90 } 0 [ + + ] reduce-index ."
    "153"
} } ;

HELP: accumulate-as
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "exemplar" sequence } { "final" "the final result" } { "newseq" "a new sequence" } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs a sequence of the same type as " { $snippet "exemplar" } " containing intermediate results, together with the final result."
$nl
"The first element of the output sequence is " { $snippet "identity" } ". Then, on the first iteration, the two inputs to the quotation are " { $snippet "identity" } " and the first element of the input sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the next element of the input sequence."
$nl
"When given the empty sequence, outputs a new empty sequence together with the " { $snippet "identity" } "." }
{ $notes "May be named " { $snippet "scan" } " or " { $snippet "prefix sum" } " in other languages." } ;

HELP: accumulate
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "final" "the final result" } { "newseq" "a new sequence" } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs a sequence of intermediate results, together with the final result."
$nl
"The first element of the output sequence is " { $snippet "identity" } ". Then, on the first iteration, the two inputs to the quotation are " { $snippet "identity" } " and the first element of the input sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the next element of the input sequence."
$nl
"When given the empty sequence, outputs a new empty sequence together with the " { $snippet "identity" } "." }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 2 2 2 2 2 } 0 [ + ] accumulate . ." "{ 0 2 4 6 8 }\n10" }
}
{ $notes "May be named " { $snippet "scan" } " or " { $snippet "prefix sum" } " in other languages." } ;

HELP: accumulate!
{ $values { "seq" "a mutable sequence" } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "final" "the final result" } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs the original sequence of intermediate results, together with the final result."
$nl
"The first element of the new sequence is " { $snippet "identity" } ". Then, on the first iteration, the two inputs to the quotation are " { $snippet "identity" } ", and the first element of the old sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the corresponding element of the old sequence."
$nl
"When given the empty sequence, outputs the same empty sequence together with the " { $snippet "identity" } "." }
{ $errors "Throws an error if the sequence is immutable, or the sequence cannot hold elements of the type output by " { $snippet "quot" } "." }
{ $side-effects "seq" }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 2 2 2 2 2 } 0 [ + ] accumulate! . ." "{ 0 2 4 6 8 }\n10" }
}
{ $notes "May be named " { $snippet "scan" } " or " { $snippet "prefix sum" } " in other languages." } ;

HELP: accumulate*-as
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "exemplar" sequence } { "newseq" "a new sequence" } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs a sequence of the same type as " { $snippet "exemplar" } " containing all results."
$nl
"On the first iteration, the two inputs to the quotation are " { $snippet "identity" } " and the first element of the input sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the next element of the input sequence."
$nl
"When given the empty sequence, outputs a new empty sequence" }
{ $notes "May be named " { $snippet "scan" } " or " { $snippet "prefix sum" } " in other languages." } ;

HELP: accumulate*
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "newseq" sequence } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs a sequence of all results."
$nl
"On the first iteration, the two inputs to the quotation are " { $snippet "identity" } " and the first element of the input sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the next element of the input sequence."
$nl
"When given the empty sequence, outputs a new empty sequence." }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 2 2 2 2 2 } 0 [ + ] accumulate* ." "{ 2 4 6 8 10 }" }
}
{ $notes "May be named " { $snippet "scan" } " or " { $snippet "prefix sum" } " in other languages." } ;

HELP: accumulate*!
{ $values { "seq" sequence } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } }
{ $description "Combines successive elements of the sequence using a binary operation, and outputs the original sequence of all results."
$nl
"On the first iteration, the two inputs to the quotation are " { $snippet "identity" } " and the first element of the input sequence. On successive iterations, the first input is the result of the previous iteration, and the second input is the next element of the input sequence."
$nl
"When given the empty sequence, outputs the same empty sequence." }
{ $errors "Throws an error if the sequence is immutable, or the sequence cannot hold elements of the type output by " { $snippet "quot" } "." }
{ $side-effects "seq" }
{ $examples
    { $example "USING: math prettyprint sequences ;" "{ 2 2 2 2 2 } 0 [ + ] accumulate*! ." "{ 2 4 6 8 10 }" }
}
{ $notes "May be named " { $snippet "scan" } " or " { $snippet "prefix sum" } " in other languages." } ;

{ accumulate accumulate! accumulate-as accumulate* accumulate*! accumulate*-as } related-words

HELP: map
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... newelt ) } } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each element of the sequence in order. The new elements are collected into a sequence of the same class as the input sequence." } ;

HELP: map-as
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... newelt ) } } { "exemplar" sequence } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each element of the sequence in order. The new elements are collected into a sequence of the same class as " { $snippet "exemplar" } "." }
{ $examples
    "The following example converts a string into an array of one-element strings:"
    { $example "USING: prettyprint strings sequences ;" "\"Hello\" [ 1string ] { } map-as ." "{ \"H\" \"e\" \"l\" \"l\" \"o\" }" }
    "Note that " { $link map } " could not be used here, because it would create another string to hold results, and one-element strings cannot themselves be elements of strings."
} ;

HELP: each-index
{ $values
    { "seq" sequence } { "quot" { $quotation ( ... elt index -- ... ) } } }
{ $description "Calls the quotation with the element of the sequence and its index on the stack, with the index on the top of the stack." }
{ $examples { $example "USING: arrays sequences prettyprint ;"
"{ 10 20 30 } [ 2array . ] each-index"
"{ 10 0 }\n{ 20 1 }\n{ 30 2 }"
} } ;

HELP: map-index
{ $values
  { "seq" sequence } { "quot" { $quotation ( ... elt index -- ... newelt ) } } { "newseq" sequence } }
{ $description "Calls the quotation with the element of the sequence and its index on the stack, with the index on the top of the stack. Collects the outputs of the quotation and outputs them in a sequence of the same type as the input sequence." }
{ $examples
    { $example "USING: arrays sequences prettyprint ;"
        "{ 10 20 30 } [ 2array ] map-index ."
        "{ { 10 0 } { 20 1 } { 30 2 } }"
    }
} ;

HELP: map-index-as
{ $values
  { "seq" sequence } { "quot" { $quotation ( ... elt index -- ... newelt ) } } { "exemplar" sequence } { "newseq" sequence } }
{ $description "Calls the quotation with the element of the sequence and its index on the stack, with the index on the top of the stack. Collects the outputs of the quotation and outputs them in a sequence of the same type as the " { $snippet "exemplar" } " sequence." }
{ $examples
    { $example "USING: arrays sequences prettyprint ;"
        "{ 10 20 30 } [ 2array ] V{ } map-index-as ."
        "V{ { 10 0 } { 20 1 } { 30 2 } }"
    }
} ;

{ map map! map-as map-index map-index-as } related-words

HELP: change-nth
{ $values { "i" "a non-negative integer" } { "seq" "a mutable sequence" } { "quot" { $quotation ( ..a elt -- ..b newelt ) } } }
{ $description "Applies the quotation to the " { $snippet "i" } "th element of the sequence, storing the result back into the sequence." }
{ $errors "Throws an error if the sequence is immutable, if the index is out of bounds, or the sequence cannot hold elements of the type output by " { $snippet "quot" } "." }
{ $side-effects "seq" } ;

HELP: map!
{ $values { "seq" "a mutable sequence" } { "quot" { $quotation ( ... elt -- ... newelt ) } } }
{ $description "Applies the quotation to each element yielding a new element, storing the new elements back in the original sequence. Returns the original sequence." }
{ $errors "Throws an error if the sequence is immutable, or the sequence cannot hold elements of the type output by " { $snippet "quot" } "." }
{ $side-effects "seq" } ;

HELP: min-length
{ $values { "seq1" sequence } { "seq2" sequence } { "n" "a non-negative integer" } }
{ $description "Outputs the minimum of the lengths of the two sequences." } ;

HELP: max-length
{ $values { "seq1" sequence } { "seq2" sequence } { "n" "a non-negative integer" } }
{ $description "Outputs the maximum of the lengths of the two sequences." } ;

HELP: 2each
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... ) } } }
{ $description "Applies the quotation to pairs of elements from " { $snippet "seq1" } " and " { $snippet "seq2" } "." } ;

HELP: 3each
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" { $quotation ( ... elt1 elt2 elt3 -- ... ) } } }
{ $description "Applies the quotation to triples of elements from " { $snippet "seq1" } ", " { $snippet "seq2" } " and " { $snippet "seq3" } "." } ;

HELP: 2reduce
{ $values { "seq1" sequence }
          { "seq2" sequence }
          { "identity" object }
          { "quot" { $quotation ( ... prev elt1 elt2 -- ... next ) } }
          { "result" "the final result" } }
{ $description "Combines successive pairs of elements from the two sequences using a ternary operation. The first input value at each iteration except the first one is the result of the previous iteration. The first input value at the first iteration is " { $snippet "identity" } "." } ;

HELP: 2map
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... newelt ) } } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each pair of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "seq1" } "." } ;

HELP: 3map
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" { $quotation ( ... elt1 elt2 elt3 -- ... newelt ) } } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each triple of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "seq1" } "." } ;

HELP: 2map-as
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... newelt ) } } { "exemplar" sequence } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each pair of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "exemplar" } "." } ;

HELP: 3map-as
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "quot" { $quotation ( ... elt1 elt2 elt3 -- ... newelt ) } } { "exemplar" sequence } { "newseq" "a new sequence" } }
{ $description "Applies the quotation to each triple of elements in turn, yielding new elements which are collected into a new sequence having the same class as " { $snippet "exemplar" } "." } ;

HELP: 2all?
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... ? ) } } { "?" boolean } }
{ $description "Tests if all pairwise elements of " { $snippet "seq1" } " and " { $snippet "seq2" } " fulfill the predicate. If the sequences have different lengths, then only the smallest sequences items are compared with the other." }
{ $examples
  { $example
    "USING: math prettyprint sequences ;"
    "{ 1 2 3 4 } { 2 4 6 8 } [ <= ] 2all? ."
    "t"
  }
} ;

HELP: 2any?
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... ? ) } } { "?" boolean } }
{ $description "Tests if any pairwise elements of " { $snippet "seq1" } " and " { $snippet "seq2" } " fulfill the predicate. If the sequences have different lengths, then only the smallest sequences items are compared with the other." }
{ $examples
  { $example
    "USING: math prettyprint sequences ;"
    "{ 2 4 5 8 } { 2 4 6 8 } [ < ] 2any? ."
    "t"
  }
} ;

HELP: find
{ $values { "seq" sequence }
          { "quot" { $quotation ( ... elt -- ... ? ) } }
          { "i" "the index of the first match, or " { $link f } }
          { "elt" "the first matching element, or " { $link f } } }
{ $description "A simpler variant of " { $link find-from } " where the starting index is 0." } ;

HELP: find-from
{ $values { "n" "a starting index" }
          { "seq" sequence }
          { "quot" { $quotation ( ... elt -- ... ? ) } }
          { "i" { $maybe "the index of the first match" } }
          { "elt" { $maybe "the first matching element" } } }
{ $description "Applies the quotation to each element of the sequence in turn, until it outputs a true value or the end of the sequence is reached. If the quotation yields a true value for some sequence element, the word outputs the element index and the element itself. Otherwise, the word outputs an index of " { $link f } " and " { $link f } " as the element." } ;

HELP: find-last
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "i" { $maybe "the index of the first match" } } { "elt" { $maybe "the first matching element" } } }
{ $description "A simpler variant of " { $link find-last-from } " where the starting index is one less than the length of the sequence." } ;

HELP: find-last-from
{ $values { "n" "a starting index" } { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "i" { $maybe "the index of the first match" } } { "elt" { $maybe "the first matching element" } } }
{ $description "Applies the quotation to each element of the sequence in reverse order, until it outputs a true value or the start of the sequence is reached. If the quotation yields a true value for some sequence element, the word outputs the element index and the element itself. Otherwise, the word outputs an index of " { $link f } " and " { $link f } " as the element." } ;

HELP: find-index
{ $values { "seq" sequence }
          { "quot" { $quotation ( ... elt i -- ... ? ) } }
          { "i" { $maybe "the index of the first match" } }
          { "elt" { $maybe "the first matching element" } } }
{ $description "A variant of " { $link find } " where the quotation takes both an element and its index." } ;

HELP: find-index-from
{ $values { "n" "a starting index" }
          { "seq" sequence }
          { "quot" { $quotation ( ... elt i -- ... ? ) } }
          { "i" { $maybe "the index of the first match" } }
          { "elt" { $maybe "the first matching element" } } }
{ $description "A variant of " { $link find-from } " where the quotation takes both an element and its index."
  "The search starts from list index " { $snippet "n" } ", skipping elements up until that index." } ;

HELP: map-find
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... result/f ) } } { "result" "the first non-false result of the quotation" } { "elt" { $maybe "the first matching element" } } }
{ $description "Applies the quotation to each element of the sequence, until the quotation outputs a true value. If the quotation ever yields a result which is not " { $link f } ", then the value is output, along with the element of the sequence which yielded this." } ;

HELP: map-find-last
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... result/f ) } } { "result" "the last non-false result of the quotation" } { "elt" { $maybe "the last matching element" } } }
{ $description "Applies the quotation to each element of the sequence from the tail, until the quotation outputs a true value. If the quotation ever yields a result which is not " { $link f } ", then the value is output, along with the element of the sequence which yielded this." } ;

{ map-find map-find-last } related-words

HELP: any?
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "?" boolean } }
{ $description "Tests if the sequence contains an element satisfying the predicate, by applying the predicate to each element in turn until a true value is found. If the sequence is empty or if the end of the sequence is reached, outputs " { $link f } "." } ;

HELP: none?
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "?" boolean } }
{ $description "Tests if the sequence does not contain any element satisfying the predicate, by applying the predicate to each element in turn until a true value is found. If the sequence is empty or if the end of the sequence is reached, outputs " { $link t } "." } ;

HELP: all?
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "?" boolean } }
{ $description "Tests if all elements in the sequence satisfy the predicate by checking each element in turn. Given an empty sequence, vacuously outputs " { $link t } "." } ;

{ any? all? none? } related-words

HELP: push-when
{ $values { "elt" object } { "quot" { $quotation ( ..a elt -- ..b ? ) } } { "accum" "a resizable mutable sequence" } }
{ $description "Adds the element at the end of the sequence if the quotation yields a true value." }
{ $notes "This word is a factor of " { $link filter } "." } ;

HELP: filter
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "subseq" "a new sequence" } }
{ $description "Applies the quotation to each element in turn, and outputs a new sequence containing the elements of the original sequence for which the quotation output a true value." } ;

HELP: filter-as
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "exemplar" sequence } { "subseq" "a new sequence" } }
{ $description "Applies the quotation to each element in turn, and outputs a new sequence of the same type as " { $snippet "exemplar" } " containing the elements of the original sequence for which the quotation output a true value." } ;

HELP: filter!
{ $values { "seq" "a resizable mutable sequence" } { "quot" { $quotation ( ... elt -- ... ? ) } } }
{ $description "Applies the quotation to each element in turn, and removes elements for which the quotation outputs a false value." }
{ $notes "The sequence " { $snippet "seq" } " MUST be growable. See " { $link "growable" } "." }
{ $side-effects "seq" }
{ $examples
  "Remove the odd numbers"
  { $example
    "USING: kernel math prettyprint sequences ;"
    "V{ 1 2 3 4 5 6 7 8 9 0 } [ odd? not ] filter! ."
    "V{ 2 4 6 8 0 }"
  } } ;


HELP: reject
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "subseq" "a new sequence" } }
{ $description "Applies the quotation to each element in turn, and outputs a new sequence removing the elements of the original sequence for which the quotation outputs a true value." } ;

HELP: reject-as
{ $values { "seq" sequence } { "quot" { $quotation ( ... elt -- ... ? ) } } { "exemplar" sequence } { "subseq" "a new sequence" } }
{ $description "Applies the quotation to each element in turn, and outputs a new sequence of the same type as " { $snippet "exemplar" } " remove the elements of the original sequence for which the quotation output a true value." } ;

HELP: reject!
{ $values { "seq" "a resizable mutable sequence." } { "quot" { $quotation ( ... elt -- ... ? ) } } }
{ $description "Applies the quotation to each element in turn, and removes elements for which the quotation outputs a true value." }
{ $notes "The sequence " { $snippet "seq" } " MUST be growable. See " { $link "growable" } "." }
{ $side-effects "seq" }
{ $examples
  "Remove the odd numbers"
  { $example
    "USING: math prettyprint sequences ;"
    "V{ 1 2 3 4 5 6 7 8 9 0 } [ odd? ] reject! ."
    "V{ 2 4 6 8 0 }"
  } } ;

HELP: interleave
{ $values { "seq" sequence } { "between" quotation } { "quot" { $quotation ( ... elt -- ... ) } } }
{ $description "Applies " { $snippet "quot" } " to each element in turn, also invoking " { $snippet "between" } " in-between each pair of elements." }
{ $examples { $example "USING: io sequences ;" "{ \"a\" \"b\" \"c\" } [ \"X\" write ] [ write ] interleave" "aXbXc" } } ;

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
{ $values { "elt" object } { "seq" sequence } { "?" boolean } }
{ $description "Tests if the sequence contains an element equal to the object." }
{ $examples
    "Is a letter in a string:"
    { $example
        "USING: sequences prettyprint ;"
        "CHAR: a \"abc\" member? ."
        "t"
    } $nl
    "Is a number in a sequence:"
    { $example
        "USING: sequences prettyprint ;"
        "4 { 1 2 3 } member? ."
        "f"
    }
}
{ $notes "This word uses equality comparison (" { $link = } ")." } ;

HELP: member-eq?
{ $values { "elt" object } { "seq" sequence } { "?" boolean } }
{ $description "Tests if the sequence contains the object." }
{ $notes "This word uses identity comparison (" { $link eq? } ")." } ;

HELP: remove
{ $values { "elt" object } { "seq" sequence } { "newseq" "a new sequence" } }
{ $description "Outputs a new sequence containing all elements of the input sequence except for the given element." }
{ $notes "This word uses equality comparison (" { $link = } ")." } ;

HELP: remove-eq
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
{ $values { "to" "an index in " { $snippet "seq" } } { "from" "an index in " { $snippet "seq" } } { "seq" "a mutable sequence" } }
{ $description "Sets the element with index " { $snippet "m" } " to the element with index " { $snippet "n" } "." }
{ $side-effects "seq" } ;

HELP: remove!
{ $values { "elt" object } { "seq" "a resizable mutable sequence" } }
{ $description "Removes all elements equal to " { $snippet "elt" } " from " { $snippet "seq" } " and returns " { $snippet "seq" } "." }
{ $notes "The sequence " { $snippet "seq" } " MUST be growable. See " { $link "growable" } "." }
{ $notes "This word uses equality comparison (" { $link = } ")." }
{ $side-effects "seq" } ;

HELP: remove-eq!
{ $values { "elt" object } { "seq" "a resizable mutable sequence" } }
{ $description "Outputs a new sequence containing all elements of the input sequence except the given element." }
{ $notes "This word uses identity comparison (" { $link eq? } ")." }
{ $side-effects "seq" } ;

HELP: remove-nth!
{ $values { "n" "a non-negative integer" } { "seq" "a resizable mutable sequence" } }
{ $description "Removes the " { $snippet "n" } "th element from the sequence, shifting all other elements down and reducing its length by one." }
{ $notes "The sequence " { $snippet "seq" } " MUST be growable. See " { $link "growable" } "." }
{ $side-effects "seq" } ;

HELP: delete-slice
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" "a resizable mutable sequence" } }
{ $description "Removes a range of elements beginning at index " { $snippet "from" } " and ending before index " { $snippet "to" } "." }
{ $side-effects "seq" } ;

HELP: replace-slice
{ $values { "new" sequence } { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" sequence } { "seq'" sequence } }
{ $description "Replaces a range of elements beginning at index " { $snippet "from" } " and ending before index " { $snippet "to" } " with a new sequence." }
{ $errors "Throws an error if " { $snippet "new" } " contains elements whose types are not permissible in " { $snippet "seq" } "." } ;

{ push push-either push-when pop pop* prefix suffix suffix! } related-words

HELP: suffix
{ $values { "seq" sequence } { "elt" object } { "newseq" sequence } }
{ $description "Outputs a new sequence obtained by adding " { $snippet "elt" } " at the end of " { $snippet "seq" } "." }
{ $errors "Throws an error if the type of " { $snippet "elt" } " is not permitted in sequences of the same class as " { $snippet "seq1" } "." }
{ $examples
    { $example "USING: prettyprint sequences ;" "{ 1 2 3 } 4 suffix ." "{ 1 2 3 4 }" }
} ;

HELP: suffix!
{ $values { "seq" "a resizable mutable sequence." } { "elt" object } }
{ $description "Modifiers a sequence in-place by adding " { $snippet "elt" } " to the end of " { $snippet "seq" } ". Outputs " { $snippet "seq" } "." }
{ $notes "The sequence " { $snippet "seq" } " MUST be growable. See " { $link "growable" } "." }
{ $errors "Throws an error if the type of " { $snippet "elt" } " is not permitted in sequences of the same class as " { $snippet "seq" } "." }
{ $examples
    { $example "USING: prettyprint sequences ;" "V{ 1 2 3 } 4 suffix! ." "V{ 1 2 3 4 }" }
} ;

HELP: append!
{ $values { "seq1" "a resizable mutable sequence." } { "seq2" sequence } }
{ $description "Modifiers " { $snippet "seq1" } " in-place by adding the elements from " { $snippet "seq2" } " to the end and outputs " { $snippet "seq1" } "." }
{ $notes "The sequence " { $snippet "seq1" } " MUST be growable. See " { $link "growable" } "." }
{ $examples
    { $example "USING: prettyprint sequences ;" "V{ 1 2 3 } { 4 5 6 } append! ." "V{ 1 2 3 4 5 6 }" }
} ;

HELP: prefix
{ $values { "seq" sequence } { "elt" object } { "newseq" sequence } }
{ $description "Outputs a new sequence obtained by adding " { $snippet "elt" } " at the beginning of " { $snippet "seq" } "." }
{ $errors "Throws an error if the type of " { $snippet "elt" } " is not permitted in sequences of the same class as " { $snippet "seq1" } "." }
{ $examples
{ $example "USING: prettyprint sequences ;" "{ 1 2 3 } 0 prefix ." "{ 0 1 2 3 }" }
} ;

HELP: sum-lengths
{ $values { "seq" { $sequence sequence } } { "n" integer } }
{ $description "Outputs the sum of the lengths of all sequences in " { $snippet "seq" } "." }
{ $examples
    [=[
        USING: prettyprint sequences ;
        { { 11 43 3.2 } { 1 } { 15 16 } } sum-lengths .
        6
    ]=]
    [=[
        USING: prettyprint sequences ;
        { "hello" f { 1 2 3 } { } } sum-lengths .
        8
    ]=]
} ;

HELP: concat
{ $values { "seq" sequence } { "newseq" sequence } }
{ $description "Concatenates a sequence of sequences together into one sequence. If " { $snippet "seq" } " is empty, outputs " { $snippet "{ }" } ", otherwise the resulting sequence is of the same class as the first element of " { $snippet "seq" } "." }
{ $errors "Throws an error if one of the sequences in " { $snippet "seq" } " contains elements not permitted in sequences of the same class as the first element of " { $snippet "seq" } "." } ;

HELP: concat-as
{ $values { "seq" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "Concatenates a sequence of sequences together into one sequence with the same type as " { $snippet "exemplar" } "." }
{ $errors "Throws an error if one of the sequences in " { $snippet "seq" } " contains elements not permitted in sequences of the same class as " { $snippet "exemplar" } "." } ;

HELP: join
{ $values { "seq" sequence } { "glue" sequence } { "newseq" sequence } }
{ $description "Concatenates a sequence of sequences together into one sequence, placing a copy of " { $snippet "glue" } " between each pair of sequences. The resulting sequence is of the same class as " { $snippet "glue" } "." }
{ $examples
    "Join a list of strings:"
    { $example "USING: sequences prettyprint ;"
        "{ \"cat\" \"dog\" \"ant\" } \" \" join ."
        "\"cat dog ant\""
    }
}
{ $notes "If the " { $snippet "glue" } " sequence is empty, this word calls " { $link concat-as } "." }
{ $errors "Throws an error if one of the sequences in " { $snippet "seq" } " contains elements not permitted in sequences of the same class as " { $snippet "glue" } "." } ;

HELP: join-as
{ $values { "seq" sequence } { "glue" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "Concatenates a sequence of sequences together into one sequence, placing a copy of " { $snippet "glue" } " between each pair of sequences. The resulting sequence is of the same class as " { $snippet "glue" } "." }
{ $notes "If the " { $snippet "glue" } " sequence is empty, this word calls " { $link concat-as } "." }
{ $examples
    "Join a list of strings as a string buffer:"
    { $example "USING: sequences prettyprint ;"
        "{ \"a\" \"b\" \"c\" } \"1\" SBUF\" \" join-as ."
        "SBUF\" a1b1c\""
    }
}
{ $errors "Throws an error if one of the sequences in " { $snippet "seq" } " contains elements not permitted in sequences of the same class as " { $snippet "exemplar" } "." } ;

{ join join-as concat concat-as } related-words

HELP: last
{ $values { "seq" sequence } { "elt" object } }
{ $description "Outputs the last element of a sequence." }
{ $errors "Throws an error if the sequence is empty." } ;

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

HELP: reverse!
{ $values { "seq" "a mutable sequence" } }
{ $description "Reverses a sequence in-place and outputs that sequence." }
{ $side-effects "seq" } ;

HELP: padding
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "elt" object } { "quot" { $quotation ( ... seq1 seq2 -- ... newseq ) } } { "newseq" "a new sequence" } }
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
{ $values { "seq1" sequence } { "seq2" sequence } { "?" boolean } }
{ $description "Tests if the two sequences have the same length and elements. This is weaker than " { $link = } ", since it does not ensure that the sequences are instances of the same class." } ;

HELP: reversed
{ $class-description "A virtual sequence which presents a reversed view of an underlying sequence. New instances can be created by calling " { $link <reversed> } "." } ;

HELP: reverse
{ $values { "seq" sequence } { "newseq" "a new sequence" } }
{ $description "Outputs a new sequence having the same elements as " { $snippet "seq" } " but in reverse order." } ;

{ reverse <reversed> reverse! } related-words

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

HELP: >slice<
{ $values
    { "slice" slice }
    { "from" integer } { "to" integer } { "seq" sequence }
}
{ $description "Sets up the stack for iteration with slots from a " { $link slice } ". Used with iteration in words such as " { $link sequence-operator } "." } ;

HELP: >underlying<
{ $values
    { "slice/seq" { $or slice sequence } }
    { "from" integer } { "to" integer }
}
{ $description "Sets up the stack for iteration with slots from a " { $link sequence } ". Used with iteration in words such as " { $link sequence-operator } "." } ;

HELP: slice
{ $class-description "A virtual sequence which presents a subrange of the elements of an underlying sequence. New instances can be created by calling " { $link <slice> } ". Convenience words are also provided for creating slices where one endpoint is the start or end of the sequence; see " { $link "sequences-slices" } " for a list."
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

HELP: <slice>
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" sequence } { "slice" slice } }
{ $description "Outputs a new virtual sequence sharing storage with the subrange of elements in " { $snippet "seq" } " with indices starting from and including " { $snippet "from" } ", and up to but not including " { $snippet "to" } "." }
{ $errors "Throws an error if " { $snippet "from" } " or " { $snippet "to" } " are out of bounds." }
{ $notes "Taking the slice of a slice outputs a slice of the underlying sequence, instead of a slice of a slice. This means that you cannot assume that the " { $snippet "from" } " and " { $snippet "to" } " slots of the resulting slice will be equal to the values you passed to " { $link <slice> } "." } ;

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
{ $values { "src" sequence } { "i" "an index in " { $snippet "dst" } } { "dst" "a mutable sequence" } }
{ $description "Copies all elements of " { $snippet "src" } " to " { $snippet "dst" } ", with destination indices starting from " { $snippet "i" } ". Grows " { $snippet "dst" } " first if necessary." }
{ $side-effects "dst" }
{ $errors "An error is thrown if " { $snippet "dst" } " is not resizable, and not large enough to hold the copied elements." } ;

HELP: push-all
{ $values { "src" sequence } { "dst" "a resizable mutable sequence" } }
{ $description "Appends " { $snippet "src" } " to the end of " { $snippet "dst" } "." }
{ $side-effects "dst" }
{ $errors "Throws an error if " { $snippet "src" } " contains elements not permitted in " { $snippet "dst" } "." } ;

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

{ append append-as append! 3append 3append-as push-all } related-words

HELP: prepend
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence of the same type as " { $snippet "seq1" } " consisting of the elements of " { $snippet "seq2" } " followed by " { $snippet "seq1" } "." }
{ $errors "Throws an error if " { $snippet "seq2" } " contains elements not permitted in sequences of the same class as " { $snippet "seq1" } "." }
{ $examples { $example "USING: prettyprint sequences ;"
        "{ 1 2 } B{ 3 4 } prepend ."
        "{ 3 4 1 2 }"
    }
    { $example "USING: prettyprint sequences strings ;"
        "\"go\" \"car\" prepend ."
        "\"cargo\""
    }
} ;

HELP: prepend-as
{ $values { "seq1" sequence } { "seq2" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence of the same type as " { $snippet "exemplar" } " consisting of the elements of " { $snippet "seq2" } " followed by " { $snippet "seq1" } "." }
{ $errors "Throws an error if " { $snippet "seq1" } " or " { $snippet "seq2" } " contain elements not permitted in sequences of the same class as " { $snippet "exemplar" } "." }
{ $examples
    { $example "USING: prettyprint sequences ;"
        "{ 3 4 } B{ 1 2 } B{ } prepend-as ."
        "B{ 1 2 3 4 }"
    }
    { $example "USING: prettyprint sequences strings ;"
        "\"ing\" \"go\" SBUF\" \" prepend-as ."
        "SBUF\" going\""
    }
} ;

{ prepend prepend-as } related-words

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

HELP: surround
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence with " { $snippet "seq1" } " inserted between " { $snippet "seq2" } " and " { $snippet "seq3" } "." }
{ $examples
    { $example "USING: sequences prettyprint ;"
               "\"sssssh\" \"(\" \")\" surround ."
               "\"(sssssh)\""
    }
} ;

HELP: surround-as
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence with " { $snippet "seq1" } " inserted between " { $snippet "seq2" } " and " { $snippet "seq3" } " of the same type as " { $snippet "exemplar" } "." }
{ $examples
    { $example "USING: sequences prettyprint ;"
               "\"sssssh\" \"(\" \")\" SBUF\" \" surround-as ."
               "SBUF\" (sssssh)\""
    }
} ;

{ surround surround-as } related-words

HELP: glue
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence with " { $snippet "seq3" } " inserted between " { $snippet "seq1" } " and " { $snippet "seq2" } "." }
{ $examples
    { $example "USING: sequences prettyprint ;"
               "\"a\" \"b\" \",\" glue ."
               "\"a,b\""
    }
} ;

HELP: glue-as
{ $values { "seq1" sequence } { "seq2" sequence } { "seq3" sequence } { "exemplar" sequence } { "newseq" sequence } }
{ $description "Outputs a new sequence with " { $snippet "seq3" } " inserted between " { $snippet "seq1" } " and " { $snippet "seq2" } " of the same type as " { $snippet "exemplar" } "." }
{ $examples
    { $example "USING: sequences prettyprint ;"
               "\"a\" \"b\" \",\" SBUF\" \" glue-as ."
               "SBUF\" a,b\""
    }
} ;

{ glue glue-as } related-words

HELP: subseq
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" sequence } { "subseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of all elements starting from and including " { $snippet "from" } ", and up to but not including " { $snippet "to" } "." }
{ $errors "Throws an error if " { $snippet "from" } " or " { $snippet "to" } " is out of bounds." } ;

HELP: subseq-as
{ $values { "from" "a non-negative integer" } { "to" "a non-negative integer" } { "seq" sequence } { "exemplar" sequence } { "subseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of all elements starting from and including " { $snippet "from" } ", and up to but not including " { $snippet "to" } " of type " { $snippet "exemplar" } "." }
{ $errors "Throws an error if " { $snippet "from" } " or " { $snippet "to" } " is out of bounds." } ;

HELP: clone-like
{ $values { "seq" sequence } { "exemplar" sequence } { "newseq" "a new sequence" } }
{ $description "Outputs a newly-allocated sequence with the same elements as " { $snippet "seq" } " but of the same type as " { $snippet "exemplar" } "." }
{ $notes "Unlike " { $link like } ", this word always creates a new sequence which never shares storage with the original." }
{ $examples
    { $example
        "USING: prettyprint sequences ;"
        "{ 1 2 3 } V{ } clone-like ."
        "V{ 1 2 3 }"
    }
    "Demonstrating the lack of shared storage:"
    { $example
        "USING: kernel prettyprint sequences ;"
        "{ 1 2 3 } dup V{ } clone-like reverse! [ . ] bi@"
        "{ 1 2 3 }\nV{ 3 2 1 }"
    }
} ;

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

{ head-slice head-slice* } related-words

HELP: tail-slice*
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "slice" "a slice" } }
{ $description "Outputs a virtual sequence sharing storage with the last " { $snippet "n" } " elements of the input sequence." }
{ $errors "Throws an error if the index is out of bounds." } ;

{ tail-slice tail-slice* } related-words

HELP: head-to-index
{ $values
    { "seq" sequence } { "to" integer }
    { "zero" object }
}
{ $description "Sets up the stack for the " { $link head } " word." } ;

HELP: head
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "headseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of the first " { $snippet "n" } " elements of the input sequence." }
{ $examples
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 6 7 } 2 head ."
        "{ 1 2 }"
    }
    "When a sequence may not have enough elements:"
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 } 5 index-or-length head ."
        "{ 1 2 }"
    }
}
{ $errors "Throws an error if the index is out of bounds." } ;

HELP: index-to-tail
{ $values
    { "seq" sequence } { "from" integer }
    { "length" object }
}
{ $description "Sets up the stack for the " { $link tail } " word." } ;

HELP: tail
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "tailseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of the input sequence with the first " { $snippet "n" } " items removed." }
{ $examples
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 6 7 } 2 tail ."
        "{ 3 4 5 6 7 }"
    }
    "When a sequence may not have enough elements:"
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 } 5 index-or-length tail ."
        "{ }"
    }
}
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
{ $description "Outputs a new sequence consisting of all elements of " { $snippet "seq" } " until the " { $snippet "n" } "th element from the end. In other words, it removes the last " { $snippet "n" } " elements." }
{ $examples
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 6 7 } 2 head* ."
        "{ 1 2 3 4 5 }"
    }
    "When a sequence may not have enough elements:"
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 } 5 index-or-length head* ."
        "{ }"
    }
}
{ $errors "Throws an error if the index is out of bounds." } ;

HELP: tail*
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "tailseq" "a new sequence" } }
{ $description "Outputs a new sequence consisting of the last " { $snippet "n" } " elements of the input sequence." }
{ $examples
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 6 7 } 2 tail* ."
        "{ 6 7 }"
    }
    "When a sequence may not have enough elements:"
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 } 5 index-or-length tail* ."
        "{ 1 2 }"
    }
}
{ $errors "Throws an error if the index is out of bounds." } ;

{ tail tail* tail-slice tail-slice* } related-words
{ head head* head-slice head-slice* } related-words
{ cut cut* cut-slice cut-slice* } related-words
{ unclip unclip-slice unclip-last unclip-last-slice } related-words
{ first last but-last but-last-slice rest rest-slice } related-words

HELP: shorter?
{ $values { "seq1" sequence } { "seq2" sequence } { "?" boolean } }
{ $description "Tests if the length of " { $snippet "seq1" } " is smaller than the length of " { $snippet "seq2" } "." } ;

HELP: head?
{ $values { "seq" sequence } { "begin" sequence } { "?" boolean } }
{ $description "Tests if " { $snippet "seq" } " starts with " { $snippet "begin" } ". If " { $snippet "begin" } " is longer than " { $snippet "seq" } ", this word outputs " { $link f } "." }
{ $examples
  { $example
    "USING: prettyprint sequences ;"
    "{ \"accept\" \"adept\" \"advance\" \"advice\" \"affect\" } [ \"ad\" head? ] filter ."
    "{ \"adept\" \"advance\" \"advice\" }"
  }
} ;

HELP: tail?
{ $values { "seq" sequence } { "end" sequence } { "?" boolean } }
{ $description "Tests if " { $snippet "seq" } " ends with " { $snippet "end" } ". If " { $snippet "end" } " is longer than " { $snippet "seq" } ", this word outputs " { $link f } "." } ;

{ remove remove-nth remove-eq remove-eq! remove! remove-nth! } related-words

HELP: cut-slice
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "before-slice" "a slice" } { "after-slice" "a slice" } }
{ $description "Outputs a pair of sequences, where " { $snippet "before-slice" } " is a slice of the first " { $snippet "n" } " elements of " { $snippet "seq" } ", while " { $snippet "after-slice" } " is a slice of the remaining elements." }
{ $notes "Unlike " { $link cut } ", this is suitable for use in an iterative algorithm which cuts successive pieces off a sequence." } ;

HELP: cut-slice*
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "before-slice" "a slice" } { "after-slice" "a slice" } }
{ $description "Outputs a pair of sequences, where " { $snippet "after" } " consists of the last " { $snippet "n" } " elements of " { $snippet "seq" } ", while " { $snippet "before-slice" } " is a slice of the remaining elements." }
{ $notes "Unlike " { $link cut* } ", this is suitable for use in an iterative algorithm which cuts successive pieces off a sequence." } ;

HELP: cut
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "before" sequence } { "after" sequence } }
{ $description "Outputs a pair of sequences, where " { $snippet "before" } " consists of the first " { $snippet "n" } " elements of " { $snippet "seq" } ", while " { $snippet "after" } " holds the remaining elements. Both output sequences have the same type as " { $snippet "seq" } "." }
{ $notes "Since this word copies the entire tail of the sequence, it should not be used in a loop. If this is important, consider using " { $link cut-slice } " instead, since it returns a slice for the tail instead of copying." } ;

HELP: cut*
{ $values { "seq" sequence } { "n" "a non-negative integer" } { "before" sequence } { "after" sequence } }
{ $description "Outputs a pair of sequences, where " { $snippet "after" } " consists of the last " { $snippet "n" } " elements of " { $snippet "seq" } ", while " { $snippet "before" } " holds the remaining elements. Both output sequences have the same type as " { $snippet "seq" } "." } ;

HELP: subseq-starts-at?
{ $values { "i" "a start index" } { "seq" sequence } { "subseq" sequence } { "?" boolean } }
{ $description "Outputs " { $snippet "t" } " if the subseq starts at the " { $snippet "i" } "th element or outputs " { $link f } " if the sequence is not at that position." } ;

HELP: subseq-index
{ $values { "seq" sequence } { "subseq" sequence } { "i/f" "a start index or " { $snippet "f" } } }
{ $description "Outputs the start index of the first contiguous subsequence equal to " { $snippet "subseq" } ", starting the search from the " { $snippet "n" } "th element. If no matching subsequence is found, outputs " { $link f } "." } ;

HELP: subseq-index-from
{ $values { "n" "a start index" } { "seq" sequence } { "subseq" sequence } { "i/f" "a start index or " { $snippet "f" } } }
{ $description "Outputs the start index of the first contiguous subsequence equal to " { $snippet "subseq" } ", starting the search from the " { $snippet "n" } "th element. If no matching subsequence is found, outputs " { $link f } "." } ;

HELP: subseq-start-from
{ $values
    { "subseq" object } { "seq" sequence } { "n" integer }
    { "i/f" { $maybe integer } }
}
{ $description "Outputs the start index of the first contiguous subsequence equal to " { $snippet "subseq" } ", or " { $link f } " if no matching subsequence is found starting from " { $snippet "n" } "." } ;

HELP: subseq-start
{ $values { "subseq" sequence } { "seq" sequence } { "i/f" "a start index or " { $snippet "f" } } }
{ $description "Outputs the start index of the first contiguous subsequence equal to " { $snippet "subseq" } ", or " { $link f } " if no matching subsequence is found." } ;

HELP: subseq?
{ $values { "subseq" sequence } { "seq" sequence } { "?" boolean } }
{ $description "Tests if " { $snippet "seq" } " contains the elements of " { $snippet "subseq" } " as a contiguous subsequence." } ;

HELP: subseq-of?
{ $values { "seq" sequence } { "subseq" sequence } { "?" boolean } }
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
{ $description "Outputs a head sequence and the last element of " { $snippet "seq" } "; the head sequence consists of all elements of " { $snippet "seq" } " but the last. Unlike " { $link unclip-last } ", this word does not make a copy of the input sequence, and runs in constant time." } ;

HELP: sum
{ $values { "seq" { $sequence number } } { "n" number } }
{ $description "Outputs the sum of all elements of " { $snippet "seq" } ". Outputs zero given an empty sequence." }
{ $examples
    [=[
        USING: prettyprint sequences ;
        { 3 1 5 } sum .
        9
    ]=]
    [=[
        USING: prettyprint sequences ;
        { } sum .
        0
    ]=]
} ;

HELP: product
{ $values { "seq" { $sequence number } } { "n" number } }
{ $description "Outputs the product of all elements of " { $snippet "seq" } ". Outputs one given an empty sequence." } ;

HELP: minimum
{ $values { "seq" sequence } { "elt" object } }
{ $description "Outputs the least element of " { $snippet "seq" } "." }
{ $examples
    "Example:"
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 } minimum ."
        "1"
    }
    "Example:"
    { $example "USING: sequences prettyprint ;"
        "{ \"c\" \"b\" \"a\" } minimum ."
        "\"a\""
    }
}
{ $errors "Throws an error if the sequence is empty." } ;

HELP: minimum-by
{ $values
    { "seq" sequence } { "quot" quotation }
    { "elt" object }
}
{ $description "Outputs the least element of " { $snippet "seq" } " according to the " { $snippet "quot" } "." }
{ $examples
    "Example:"
    { $example "USING: sequences prettyprint ;"
        "{ { 1 2 } { 1 2 3 } { 1 2 3 4 } } [ length ] minimum-by ."
        "{ 1 2 }"
    }
}
{ $errors "Throws an error if the sequence is empty." } ;

HELP: maximum
{ $values { "seq" sequence } { "elt" object } }
{ $description "Outputs the greatest element of " { $snippet "seq" } "." }
{ $examples
    "Example:"
    { $example "USING: sequences prettyprint ;"
        "{ 1 2 3 4 5 } maximum ."
        "5"
    }
    "Example:"
    { $example "USING: sequences prettyprint ;"
        "{ \"c\" \"b\" \"a\" } maximum ."
        "\"c\""
    }
}
{ $errors "Throws an error if the sequence is empty." } ;

HELP: maximum-by
{ $values
    { "seq" sequence } { "quot" quotation }
    { "elt" object }
}
{ $description "Outputs the greatest element of " { $snippet "seq" } " according to the " { $snippet "quot" } "." }
{ $examples
    "Example:"
    { $example "USING: sequences prettyprint ;"
        "{ { 1 2 } { 1 2 3 } { 1 2 3 4 } } [ length ] maximum-by ."
        "{ 1 2 3 4 }"
    }
}
{ $errors "Throws an error if the sequence is empty." } ;

{ min max minimum minimum-by maximum maximum-by } related-words

HELP: shortest
{ $values { "seqs" sequence } { "elt" object } }
{ $description "Outputs the shortest sequence from " { $snippet "seqs" } "." } ;

HELP: longest
{ $values { "seqs" sequence } { "elt" object } }
{ $description "Outputs the longest sequence from " { $snippet "seqs" } "." } ;

{ shortest longest } related-words

HELP: produce
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "quot" { $quotation ( ..b -- ..a obj ) } } { "seq" sequence } }
{ $description "Calls " { $snippet "pred" } " repeatedly. If the predicate yields " { $link f } ", stops, otherwise, calls " { $snippet "quot" } " to yield a value. Values are accumulated and returned in a sequence at the end." }
{ $examples
    "The following example divides a number by two until we reach zero, and accumulates intermediate results:"
    { $example "USING: kernel math prettyprint sequences ;" "1337 [ dup 0 > ] [ 2/ dup ] produce nip ." "{ 668 334 167 83 41 20 10 5 2 1 0 }" }
    "The following example collects random numbers as long as they are greater than 1:"
    { $unchecked-example "USING: kernel prettyprint random sequences ;" "[ 10 random dup 1 > ] [ ] produce nip ." "{ 8 2 2 9 }" }
} ;

HELP: produce-as
{ $values { "pred" { $quotation ( ..a -- ..b ? ) } } { "quot" { $quotation ( ..b -- ..a obj ) } } { "exemplar" sequence } { "seq" sequence } }
{ $description "Calls " { $snippet "pred" } " repeatedly. If the predicate yields " { $link f } ", stops, otherwise, calls " { $snippet "quot" } " to yield a value. Values are accumulated and returned in a sequence of type " { $snippet "exemplar" } " at the end." }
{ $examples "See " { $link produce } " for examples." } ;

HELP: map-sum
{ $values { "seq" sequence } { "quot" quotation } { "n" number } }
{ $description "Like " { $snippet "map sum" } ", but without creating an intermediate sequence." }
{ $examples
    { $example
        "USING: math ranges sequences prettyprint ;"
        "100 [1..b] [ sq ] map-sum ."
        "338350"
    }
} ;

HELP: count
{ $values { "seq" sequence } { "quot" quotation } { "n" integer } }
{ $description "Efficiently returns the number of elements that the predicate quotation matches." }
{ $examples
    { $example
        "USING: math ranges sequences prettyprint ;"
        "100 [1..b] [ even? ] count ."
        "50"
    }
} ;

HELP: selector
{ $values
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "selector" { $quotation ( ... elt -- ... ) } } { "accum" vector } }
{ $description "Creates a new vector to accumulate the values which return true for a predicate. Returns a new quotation which accepts an object to be tested and stored in the collector if the test yields true. The collector is left on the stack for convenience." }
{ $examples
    { $example "! Find all the even numbers:" "USING: prettyprint sequences math kernel ;"
               "10 <iota> [ even? ] selector [ each ] dip ."
               "V{ 0 2 4 6 8 }"
    }
}
{ $notes "Used to implement the " { $link filter } " word. Compare this word with " { $link collector } ", which is an unfiltering version." } ;

HELP: trim-head
{ $values
    { "seq" sequence } { "quot" quotation }
    { "newseq" sequence } }
{ $description "Removes elements starting from the left side of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a new sequence." }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim-head ."
               "{ 1 2 3 0 0 }"
    }
} ;

HELP: trim-head-slice
{ $values
    { "seq" sequence } { "quot" quotation }
    { "slice" slice } }
{ $description "Removes elements starting from the left side of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a slice." }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim-head-slice ."
               "T{ slice { from 2 } { to 7 } { seq { 0 0 1 2 3 0 0 } } }"
    }
} ;

HELP: trim-tail
{ $values
    { "seq" sequence } { "quot" quotation }
    { "newseq" sequence } }
{ $description "Removes elements starting from the right side of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a new sequence." }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim-tail ."
               "{ 0 0 1 2 3 }"
    }
} ;

HELP: trim-tail-slice
{ $values
    { "seq" sequence } { "quot" quotation }
    { "slice" slice } }
{ $description "Removes elements starting from the right side of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a slice." }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim-tail-slice ."
               "T{ slice { to 5 } { seq { 0 0 1 2 3 0 0 } } }"
    }
} ;

HELP: trim
{ $values
    { "seq" sequence } { "quot" quotation }
    { "newseq" sequence } }
{ $description "Removes elements starting from the left and right sides of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a new sequence." }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim ."
               "{ 1 2 3 }"
    }
} ;

HELP: trim-slice
{ $values
    { "seq" sequence } { "quot" quotation }
    { "slice" slice } }
{ $description "Removes elements starting from the left and right sides of a sequence if they match a predicate. Once an element does not match, the test stops and the rest of the sequence is left on the stack as a slice." }
{ $examples
    { $example "USING: prettyprint math sequences ;"
               "{ 0 0 1 2 3 0 0 } [ zero? ] trim-slice ."
               "T{ slice { from 2 } { to 5 } { seq { 0 0 1 2 3 0 0 } } }"
    }
} ;

{ trim trim-slice trim-head trim-head-slice trim-tail trim-tail-slice } related-words

HELP: sift
{ $values
    { "seq" sequence }
    { "newseq" sequence } }
{ $description "Outputs a new sequence with all instances of " { $link f } " removed." }
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

{ filter filter-as filter! reject reject-as reject! sift harvest } related-words

HELP: set-first
{ $values
    { "first" object } { "seq" sequence } }
{ $description "Sets the first element of a sequence." }
{ $examples
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4 } 5 over set-first ."
        "{ 5 2 3 4 }"
    }
} ;

HELP: set-second
{ $values
    { "second" object } { "seq" sequence } }
{ $description "Sets the second element of a sequence." }
{ $examples
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4 } 5 over set-second ."
        "{ 1 5 3 4 }"
    }
} ;

HELP: set-third
{ $values
    { "third" object } { "seq" sequence } }
{ $description "Sets the third element of a sequence." }
{ $examples
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4 } 5 over set-third ."
        "{ 1 2 5 4 }"
    }
} ;

HELP: set-fourth
{ $values
    { "fourth" object } { "seq" sequence } }
{ $description "Sets the fourth element of a sequence." }
{ $examples
    { $example "USING: prettyprint kernel sequences ;"
        "{ 1 2 3 4 } 5 over set-fourth ."
        "{ 1 2 3 5 }"
    }
} ;

{ set-first set-second set-third set-fourth } related-words

HELP: replicate
{ $values
    { "len" integer } { "quot" { $quotation ( ... -- ... newelt ) } }
    { "newseq" sequence } }
    { $description "Calls the quotation " { $snippet "len" } " times, collecting results into a new array." }
{ $examples
    { $unchecked-example "USING: kernel prettyprint random sequences ;"
        "5 [ 100 random ] replicate ."
        "{ 52 10 45 81 30 }"
    }
} ;

HELP: replicate-as
{ $values
    { "len" integer } { "quot" { $quotation ( ... -- ... newelt ) } } { "exemplar" sequence }
    { "newseq" sequence } }
{ $description "Calls the quotation " { $snippet "len" } " times, collecting results into a new sequence of the same type as the exemplar sequence." }
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
    { $description "Calls a predicate quotation on each element of the input sequence. If the test yields true, the element is added to " { $snippet "trueseq" } "; if false, it's added to " { $snippet "falseseq" } "." }
{ $examples
    { $example "USING: prettyprint kernel math sequences ;"
        "{ 1 2 3 4 5 } [ even? ] partition [ . ] bi@"
        "{ 2 4 }\n{ 1 3 5 }"
    }
} ;

HELP: virtual-exemplar
{ $values
    { "seq" sequence }
    { "seq'" sequence } }
{ $description "Part of the virtual sequence protocol, this word is used to return an exemplar of the underlying storage. This is used in words like " { $link new-sequence } "." }
{ $examples
    [=[
        USING: prettyprint sequences ;
        1 3 { 14 15 16 17 } <slice> virtual-exemplar .
        { 14 15 16 17 }
    ]=]
} ;

HELP: virtual@
{ $values
    { "n" integer } { "seq" sequence }
    { "n'" integer } { "seq'" sequence } }
{ $description "Part of the sequence protocol, this word translates the input index " { $snippet "n" } " into an index and the underlying storage this index points into." }
{ $examples
    { $example
        "USING: kernel prettyprint sequences ;"
        "0 { 1 2 3 4 5 6 } <reversed> virtual@ [ . ] bi@"
        "5\n{ 1 2 3 4 5 6 }"
    }
} ;

HELP: 2map-reduce
{ $values
    { "seq1" sequence } { "seq2" sequence } { "map-quot" { $quotation ( ..a elt1 elt2 -- ..a intermediate ) } } { "reduce-quot" { $quotation ( ..a prev intermediate -- ..a next ) } }
    { "result" object } }
{ $description "Calls " { $snippet "map-quot" } " on each pair of elements from " { $snippet "seq1" } " and " { $snippet "seq2" } " and combines the results using " { $snippet "reduce-quot" } " in the same manner as " { $link reduce } ", except that there is no identity element, and the sequence must have a length of at least 1." }
{ $errors "Throws an error if the sequence is empty." }
{ $examples { $example "USING: sequences prettyprint math ;"
    "{ 10 30 50 } { 200 400 600 } [ + ] [ + ] 2map-reduce ."
    "1290"
} } ;

HELP: 2selector
{ $values
    { "quot" quotation }
    { "selector" quotation } { "accum1" vector } { "accum2" vector } }
{ $description "Creates two new vectors to accumulate values based on a predicate. The first vector accumulates values for which the predicate yields true; the second for false." } ;

HELP: collector
{ $values
    { "quot" quotation }
    { "quot'" quotation } { "vec" vector } }
{ $description "Creates a new quotation that pushes its result to a vector and outputs that vector on the stack." }
{ $examples { $example "USING: sequences prettyprint kernel math ;"
    "{ 1 2 } [ 30 + ] collector [ each ] dip ."
    "V{ 31 32 }"
} } ;

HELP: binary-reduce
{ $values
    { "seq" sequence } { "start" integer } { "quot" { $quotation ( elt1 elt2 -- newelt ) } }
    { "value" object } }
{ $description "Like " { $link reduce } ", but splits the sequence in half recursively until each sequence is small enough, and calls the quotation on these smaller sequences. If the quotation computes values that depend on the size of their input, such as bignum arithmetic, then this algorithm can be more efficient than using " { $link reduce } "." }
{ $examples "Computing factorial:"
    { $example "USING: prettyprint sequences math ;"
    "40 <iota> rest-slice 1 [ * ] binary-reduce ."
    "20397882081197443358640281739902897356800000000" }
} ;

HELP: follow
{ $values
    { "obj" object } { "quot" { $quotation ( ... prev -- ... result/f ) } }
    { "seq" sequence } }
{ $description "Outputs a sequence containing the input object and all of the objects generated by successively feeding the result of the quotation called on the input object to the quotation recursively. Objects yielded by the quotation are added to the output sequence until the quotation yields " { $link f } ", at which point the recursion terminates." }
{ $examples "Get random numbers until zero is reached:"
    { $unchecked-example
    "USING: random sequences prettyprint math ;"
    "100 [ random [ f ] when-zero ] follow ."
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
    { "seq" sequence } { "map-quot" { $quotation ( ..a elt -- ..a intermediate ) } } { "reduce-quot" { $quotation ( ..a prev intermediate -- ..a next ) } }
    { "result" object } }
{ $description "Calls " { $snippet "map-quot" } " on each element and combines the results using " { $snippet "reduce-quot" } " in the same manner as " { $link reduce } ", except that there is no identity element, and the sequence must have a length of at least 1." }
{ $errors "Throws an error if the sequence is empty." }
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
{ $description "Pushes the input object onto one of the accumulators; the first if the quotation yields true, the second if false." } ;

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

HELP: index-or-length
{ $values
    { "seq" sequence } { "n" integer } { "n'" integer } }
{ $description "Returns the input sequence and its length or " { $snippet "n" } ", whichever is less." }
{ $examples { $example "USING: sequences kernel prettyprint ;"
    "\"abcd\" 3 index-or-length [ . ] bi@"
    "\"abcd\"\n3"
} } ;

HELP: shorten
{ $values
    { "n" integer } { "seq" sequence } }
{ $description "Shortens a " { $link "growable" } " sequence to be " { $snippet "n" } " elements long." }
{ $examples { $example "USING: sequences prettyprint kernel ;"
    "V{ 1 2 3 4 5 } 3 over shorten ."
    "V{ 1 2 3 }"
} } ;

HELP: <iota>
{ $values { "n" integer } { "iota" iota } }
{ $description "Creates an immutable virtual sequence containing the integers from 0 to " { $snippet "n-1" } "." }
{ $examples
  { $example
    "USING: math sequences prettyprint ;"
    "3 <iota> [ sq ] map ."
    "{ 0 1 4 }"
  }
} ;

HELP: assert-sequence=
{ $values
    { "a" sequence } { "b" sequence }
}
{ $description "Throws an error if all the elements of two sequences, taken pairwise, are not equal." }
{ $notes "The sequences need not be of the same type." }
{ $examples
  { $code
    "USING: prettyprint sequences ;"
    "{ 1 2 3 } V{ 1 2 3 } assert-sequence="
  }
} ;

HELP: cartesian-find
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... ? ) } } { "elt1" object } { "elt2" object } }
{ $description "Applies the quotation to every possible pairing of elements from the two sequences, returning the first two elements where the quotation returns a true value." } ;

HELP: cartesian-each
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... ) } } }
{ $description "Applies the quotation to every possible pairing of elements from the two sequences." } ;

HELP: cartesian-map
{ $values { "seq1" sequence } { "seq2" sequence } { "quot" { $quotation ( ... elt1 elt2 -- ... newelt ) } } { "newseq" "a new sequence of sequences" } }
{ $description "Applies the quotation to every possible pairing of elements from the two sequences, collecting results into a new sequence of sequences." } ;

HELP: cartesian-product-as
{ $values { "seq1" sequence } { "seq2" sequence } { "exemplar" sequence } { "newseq" "a new sequence of sequences of pairs" } }
{ $description "Outputs a sequence of all possible pairings of elements from the two sequences so that the output sequence is the exemplar's type." }
{ $examples
    { $example
        "USING: bit-arrays prettyprint sequences ;"
        "\"ab\" ?{ t f } { } cartesian-product-as ."
        "{ { { 97 t } { 97 f } } { { 98 t } { 98 f } } }"
    }
} ;

HELP: cartesian-product
{ $values { "seq1" sequence } { "seq2" sequence } { "newseq" "a new sequence of sequences of pairs" } }
{ $description "Outputs a sequence of all possible pairings of elements from the two sequences, using the type of " { $snippet "seq2" } "." }
{ $examples
    { $example
        "USING: prettyprint sequences ;"
        "{ 1 2 } { 3 4 } cartesian-product ."
        "{ { { 1 3 } { 1 4 } } { { 2 3 } { 2 4 } } }"
    }
    { $example
        "USING: prettyprint sequences ;"
        "\"abc\" \"def\" cartesian-product ."
        "{ { \"ad\" \"ae\" \"af\" } { \"bd\" \"be\" \"bf\" } { \"cd\" \"ce\" \"cf\" } }"
    }
} ;

{ cartesian-find cartesian-each cartesian-map cartesian-product cartesian-product-as } related-words

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
{ $subsections sequence sequence? }
"All sequences must know their length:"
{ $subsections length }
"At least one of the following two generic words must have a method for accessing elements; the " { $link sequence } " mixin has default definitions which are mutually recursive:"
{ $subsections nth nth-unsafe ?nth }
"Note that sequences are always indexed starting from zero."
$nl
"At least one of the following two generic words must have a method for storing elements; the " { $link sequence } " mixin has default definitions which are mutually recursive:"
{ $subsections set-nth set-nth-unsafe ?set-nth }
"If your sequence is immutable, then you must implement either " { $link set-nth } " or " { $link set-nth-unsafe } " to simply call " { $link immutable } " to signal an error."
$nl
"The following two generic words are optional, as not all sequences are resizable:"
{ $subsections set-length lengthen }
"An optional generic word for creating sequences of the same class as a given sequence:"
{ $subsections like }
"Optional generic words for optimization purposes:"
{ $subsections new-sequence new-resizable }
{ $see-also "sequences-unsafe" } ;

ARTICLE: "virtual-sequences-protocol" "Virtual sequence protocol"
"Virtual sequences must know their length:"
{ $subsections length }
"An exemplar of the underlying storage:"
{ $subsections virtual-exemplar }
"The index and the underlying storage where the value is located:"
{ $subsections virtual@ } ;

ARTICLE: "virtual-sequences" "Virtual sequences"
"A virtual sequence is an implementation of the " { $link "sequence-protocol" } " which does not store its own elements, and instead computes them, either from scratch or by retrieving them from another sequence."
$nl
"Implementations include the following:"
{ $subsections reversed slice }
"Virtual sequences can be implemented with the " { $link "virtual-sequences-protocol" } ", by translating an index in the virtual sequence into an index in another sequence."
{ $see-also "sequences-integers" } ;

ARTICLE: "sequences-integers" "Counted loops"
"A virtual sequence is defined for iterating over integers from zero."
{ $subsection <iota> }
"For example, calling " { $link <iota> } " on the integer 3 produces a sequence containing the elements 0, 1, and 2. This is very useful for performing counted loops using words such as " { $link each } ":"
{ $example "USING: sequences prettyprint ; 3 <iota> [ . ] each" "0\n1\n2" }
"A common idiom is to iterate over a sequence, while also maintaining a loop counter. This can be done using " { $link each-index } ", " { $link map-index } " and " { $link reduce-index } "."
$nl
"Combinators that produce new sequences, such as " { $link map } ", will output an array if the input is an instance of " { $link <iota> } "."
$nl
"More elaborate counted loops can be performed with " { $link "ranges" } "." ;

ARTICLE: "sequences-if" "Control flow with sequences"
"To reduce the boilerplate of checking if a sequence is empty, several combinators are provided."
$nl
"Checking if a sequence is empty:"
{ $subsections if-empty when-empty unless-empty } ;

ARTICLE: "sequences-access" "Accessing sequence elements"
"Element access by index, without raising exceptions:"
{ $subsections ?nth }
"Concise way of extracting one of the first four elements:"
{ $subsections first second third fourth ?first ?second }
"Extracting the last element:"
{ $subsections last ?last }
"Unpacking sequences:"
{ $subsections first2 first3 first4 }
{ $see-also nth } ;

ARTICLE: "sequences-add-remove" "Adding and removing sequence elements"
"Adding elements:"
{ $subsections prefix suffix insert-nth }
"Removing elements:"
{ $subsections remove remove-eq remove-nth } ;

ARTICLE: "sequences-reshape" "Reshaping sequences"
"A " { $emphasis "repetition" } " is a virtual sequence consisting of a single element repeated multiple times:"
{ $subsections repetition <repetition> }
"Reversing a sequence:"
{ $subsections reverse }
"A " { $emphasis "reversed" } " is a virtual sequence presenting a reversed view of an underlying sequence:"
{ $subsections reversed <reversed> }
"Transposing a matrix:"
{ $subsections flip } ;

ARTICLE: "sequences-appending" "Appending sequences"
"Basic append operations:"
{ $subsections
    append
    append-as
    prepend
    3append
    3append-as
    surround
    surround-as
    glue
    glue-as
}
"Collapse a sequence unto itself:"
{ $subsections concat concat-as join join-as }
"A pair of words useful for aligning strings:"
{ $subsections pad-head pad-tail } ;

ARTICLE: "sequences-slices" "Subsequences and slices"
"There are two ways to extract a subrange of elements from a sequence. The first approach creates a new sequence of the same type as the input, which does not share storage with the underlying sequence. This takes time proportional to the number of elements being extracted. The second approach creates a " { $emphasis "slice" } ", which is a virtual sequence (see " { $link "virtual-sequences" } ") sharing storage with the original sequence. Slices are constructed in constant time."
$nl
"Some general guidelines for choosing between the two approaches:"
{ $list
  "If you are using mutable state, the choice has to be made one way or another because of semantics; mutating a slice will change the underlying sequence."
  { "Using a slice can improve algorithmic complexity. For example, if each iteration of a loop decomposes a sequence using " { $link first } " and " { $link rest } ", then the loop will run in quadratic time, relative to the length of the sequence. Using " { $link rest-slice } " changes the loop to run in linear time, since " { $link rest-slice } " does not copy any elements. Taking a slice of a slice will “collapse” the slice so to avoid the double indirection, so it is safe to use slices in recursive code." }
  "Accessing elements from a concrete sequence (such as a string or an array) is often faster than accessing elements from a slice, because slice access entails additional indirection. However, in some cases, if the slice is immediately consumed by an iteration combinator, the compiler can eliminate the slice allocation and indirection altogether."
  "If the slice outlives the original sequence, the original sequence will still remain in memory, since the slice will reference it. This can increase memory consumption unnecessarily."
}
{ $heading "Subsequence operations" }
"Extracting a subsequence:"
{ $subsections
    subseq
    subseq-as
    head
    tail
    head*
    tail*
}
"Removing the first or last element:"
{ $subsections rest but-last }
"Taking a sequence apart into a head and a tail:"
{ $subsections
    unclip
    unclip-last
    cut
    cut*
}
{ $heading "Slice operations" }
"The slice data type:"
{ $subsections slice slice? }
"Extracting a slice:"
{ $subsections
    <slice>
    head-slice
    tail-slice
    head-slice*
    tail-slice*
}
"Removing the first or last element:"
{ $subsections rest-slice but-last-slice }
"Taking a sequence apart into a head and a tail:"
{ $subsections unclip-slice unclip-last-slice cut-slice }
"Replacing slices with new elements:"
{ $subsections replace-slice } ;

ARTICLE: "sequences-combinators" "Sequence combinators"
"Iteration:"
{ $subsections
    each
    each-index
    reduce
    interleave
}
"Mapping:"
{ $subsections
    map
    map-as
    map-index
    map-index-as
    map-reduce
    accumulate
    accumulate-as
    accumulate*
    accumulate*-as
}
"Filtering:"
{ $subsections
    filter
    filter-as
    partition
}
"Counting:"
{ $subsections
    count
}
"Superlatives with " { $link min } " and " { $link max } ":"
{ $subsections
    minimum
    minimum-by
    maximum
    maximum-by
    shorter
    longer
    shorter?
    longer?
    shortest
    longest
}
"Generating:"
{ $subsections
    replicate
    replicate-as
    produce
    produce-as
}
"Math:"
{ $subsections
    sum
    product
}
"Testing if a sequence contains elements satisfying a predicate:"
{ $subsections
    any?
    all?
    none?
}
{ $heading "Related Articles" }
{ $subsections
    "sequence-2combinators"
    "sequence-3combinators"
} ;

ARTICLE: "sequence-2combinators" "Pair-wise sequence combinators"
"There is a set of combinators which traverse two sequences pairwise. If one sequence is shorter than the other, then only the prefix having the length of the minimum of the two is examined."
{ $subsections
    2each
    2reduce
    2map
    2map-as
    2map-reduce
    2all?
} ;

ARTICLE: "sequence-3combinators" "Triple-wise sequence combinators"
"There is a set of combinators which traverse three sequences triple-wise. If one sequence is shorter than the others, then only the prefix having the length of the minimum of the three is examined."
{ $subsections 3each 3map 3map-as } ;

ARTICLE: "sequences-tests" "Testing sequences"
"Testing for an empty sequence:"
{ $subsections empty? }
"Testing indices:"
{ $subsections bounds-check? }
"Testing if a sequence contains an object:"
{ $subsections member? member-eq? }
"Testing if a sequence contains a subsequence:"
{ $subsections head? tail? subseq? subseq-of? } ;

ARTICLE: "sequences-search" "Searching sequences"
"Finding the index of an element:"
{ $subsections
    index
    index-from
    last-index
    last-index-from
}
"Finding the start of a subsequence:"
{ $subsections
    subseq-start
    subseq-start-from
    subseq-index
    subseq-index-from
    subseq-starts-at?
}
"Finding the index of an element satisfying a predicate:"
{ $subsections
    find
    find-from
    find-last
    find-last-from
    map-find
    map-find-last
} ;

ARTICLE: "sequences-trimming" "Trimming sequences"
"Trimming words:"
{ $subsections trim trim-head trim-tail }
"Potentially more efficient trim:"
{ $subsections trim-slice trim-head-slice trim-tail-slice } ;

ARTICLE: "sequences-destructive-discussion" "When to use destructive operations"
"Constructive (non-destructive) operations should be preferred where possible because code without side-effects is usually more reusable and easier to reason about. There are two main reasons to use destructive operations:"
{ $list
    "For the side-effect. Some code is simpler to express with destructive operations; constructive operations return new objects, and sometimes ``threading'' the objects through the program manually complicates stack shuffling."
    { "As an optimization. Some code written to use constructive operations suffers from worse performance. An example is a loop which adds an element to a sequence on each iteration. Either " { $link suffix } " or " { $link suffix! } " could be used; however, the former copies the entire sequence each time, which would cause the loop to run in quadratic time." }
}
"The second reason is much weaker than the first one. In particular, many combinators (see " { $link map } ", " { $link produce } " and " { $link "namespaces-make" } ") as well as more advanced data structures (such as " { $vocab-link "persistent.vectors" } ") alleviate the need for explicit use of side effects." ;

ARTICLE: "sequences-destructive" "Destructive sequence operations"
"Many operations have destructive variants that side effect an input sequence, instead of creating a new sequence:"
{ $table
    { { $strong "Constructive" } { $strong "Destructive" } }
    { { $link suffix } { $link suffix! } }
    { { $link remove } { $link remove! } }
    { { $link remove-eq } { $link remove-eq! } }
    { { $link remove-nth } { $link remove-nth! } }
    { { $link reverse } { $link reverse! } }
    { { $link append } { $link append! } }
    { { $link map } { $link map! } }
    { { $link accumulate } { $link accumulate! } }
    { { $link accumulate* } { $link accumulate*! } }
    { { $link filter } { $link filter! } }
}
"Changing elements:"
{ $subsections map! accumulate! accumulate*! change-nth }
"Deleting elements:"
{ $subsections
    remove!
    remove-eq!
    remove-nth!
    delete-slice
    delete-all
    filter!
}
"Adding elements:"
{ $subsections
    suffix!
    append!
}
"Other destructive words:"
{ $subsections
    reverse!
    move
    exchange
    copy
}
{ $heading "Related Articles" }
{ $subsections
    "sequences-destructive-discussion"
    "sequences-stacks"
}
{ $see-also set-nth push push-all pop pop* } ;

ARTICLE: "sequences-stacks" "Treating sequences as stacks"
"The classical stack operations, modifying a sequence in place:"
{ $subsections push push-all pop pop* }
{ $see-also empty? } ;

ARTICLE: "sequences-comparing" "Comparing sequences"
"Element equality testing:"
{ $subsections
    sequence=
    mismatch
    drop-prefix
    assert-sequence=
}
"The " { $link <=> } " generic word performs lexicographic comparison when applied to sequences." ;

ARTICLE: "sequences-f" "The f object as a sequence"
"The " { $link f } " object supports the sequence protocol in a trivial way. It responds with a length of zero and throws an out of bounds error when an attempt is made to access elements." ;

ARTICLE: "sequences-combinator-implementation" "Implementing sequence combinators"
"Creating a new sequence unconditionally:"
{ $subsections
    collector
    collector-as
}
"Creating a new sequence conditionally:"
{ $subsections
    selector
    selector-as
    2selector
} ;

ARTICLE: "sequences-cartesian" "Cartesian product operations"
"The cartesian product of two sequences is a sequence of all pairs where the first element of each pair is from the first sequence, and the second element of each pair is from the second sequence. The number of elements in the cartesian product is the product of the lengths of the two sequences."
$nl
"Combinators which pair every element of the first sequence with every element of the second:"
{ $subsections
    cartesian-each
    cartesian-map
    cartesian-find
}
"Computing the cartesian product of two sequences:"
{ $subsections
    cartesian-product
    cartesian-product-as
} ;

ARTICLE: "sequences" "Sequence operations"
"A " { $emphasis "sequence" } " is a finite, linearly-ordered collection of elements. Words for working with sequences are in the " { $vocab-link "sequences" } " vocabulary."
$nl
"Sequences implement a protocol:"
{ $subsections
    "sequence-protocol"
    "sequences-f"
}
"Sequence utility words can operate on any object whose class implements the sequence protocol. Most implementations are backed by storage. Some implementations obtain their elements from an underlying sequence, or compute them on the fly. These are known as " { $link "virtual-sequences" } "."
{ $subsections
    "sequences-access"
    "sequences-combinators"
    "sequences-add-remove"
    "sequences-appending"
    "sequences-slices"
    "sequences-reshape"
    "sequences-tests"
    "sequences-search"
    "sequences-comparing"
    "sequences-split"
    "grouping"
    "sequences-destructive"
    "sequences-stacks"
    "sequences-sorting"
    "binary-search"
    "sets"
    "sequences-trimming"
    "sequences-cartesian"
    "sequences.deep"
}
"Using sequences for looping:"
{ $subsections
    "sequences-integers"
    "ranges"
}
"Using sequences for control flow:"
{ $subsections "sequences-if" }
"For inner loops:"
{ $subsections "sequences-unsafe" }
"Implementing sequence combinators:"
{ $subsections "sequences-combinator-implementation" } ;

ABOUT: "sequences"
