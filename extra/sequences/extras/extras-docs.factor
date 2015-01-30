USING: help.markup help.syntax kernel math sequences ;
IN: sequences.extras

HELP: count*
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "%" rational } }
{ $description "Outputs the fraction of elements in the sequence for which the predicate quotation matches." }
{ $examples { $example "USING: math math.ranges prettyprint sequences.extras ;" "100 [1,b] [ even? ] count* ." "1/2" } } ;

HELP: collapse
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "elt" object }
    { "seq'" sequence } }
{ $description "Generate a new sequence where all runs of elements for which the predicate returns true are replaced by a single instance of " { $snippet "elt" } "." }
{ $see-also compact }
{ $examples
    "Collapse multiple spaces in a string down to a single space"
    { $example "USING: kernel prettyprint sequences.extras ;" "\"   Hello,    crazy    world   \" [ CHAR: \\s = ] \" \" collapse ." "\" Hello, crazy world \"" } } ;

HELP: compact
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( ... elt -- ... ? ) } }
    { "elt" object }
    { "seq'" sequence } }
{ $description "Generate a new sequence where all runs of elements for which the predicate returns true are replaced by a single instance of " { $snippet "elt" } ".  Runs at the beginning or end of the sequence for which the predicate returns true are removed." }
{ $see-also collapse }
{ $examples
    "Collapse multiple spaces in a string down to a single space"
    { $example "USING: kernel prettyprint sequences.extras ;" "\"   Hello,    crazy    world   \" [ CHAR: \\s = ] \" \" compact ." "\"Hello, crazy world\"" } } ;

HELP: combos
{ $values
    { "list1" sequence }
    { "list2" sequence }
    { "result" sequence } }
{ $description "Returns all combinations of the first sequence with the second sequence.  The result is not uniquified: if the sequences contain duplicate elements, then the same pair may appear multiple times in the result sequence." } ;

HELP: <evens>
{ $values { "seq" sequence } { "evens" evens } }
{ $description "Create a virtual sequence whose elements consist of the even-indexed elements from the original sequence." }
{ $notes "Because sequences are zero-indexed, this collection includes the first, third, fifth, etc. elements of the actual sequence which can be counterintuitive." }
{ $see-also <odds> } ;

HELP: find-all
{ $values
    { "seq" sequence }
    { "quot" { $quotation ( elt -- ? ) } }
    { "elts" "the indices of the matching elements" } }
{ $description "Similar to " { $link find } ", but finds all of the indices and elements that match the provided quotation, not just the first." }
{ $notes "The result is provided as an array of arrays, whose first value is the index and whose second value is teh element." } ;

HELP: <odds>
{ $values { "seq" sequence } { "odds" odds } }
{ $description "Create a virtual sequence whose elements consist of the odd-indexed elements from the original sequence." }
{ $notes "Because sequences are zero-indexed, this collection includes the second, fourth, sixth, etc. elements of the actual sequence which can be counterintuitive." }
{ $see-also <evens> } ;

HELP: >resizable
{ $values { "seq" sequence } { "accum" sequence } }
{ $description "Converts a sequence into the nearest resizable equivalent, preserving its contents." } ;

HELP: subseq*
{ $values
     { "from" integer } { "to" integer } { "seq" sequence } { "subseq" sequence } }
{ $description "Outputs a new sequence using positions relative to one or both ends of the sequence. Positive values describes offsets relative to the start of the sequence, negative values relative to the end. Values of " { $link f } " for " { $snippet "from" } " indicate the beginning of the sequence, while an " { $link f } " for " { $snippet "to" } " indicates the end of the sequence." }
{ $notes "Both " { $snippet "from" } " and " { $snippet "to" } " can be safely set to values outside the length of the sequence. Also, " { $snippet "from" } " can safely reference a smaller or greater index position than " { $snippet "to" } "." }
{ $examples
    "Using a negative relative index:"
    { $example "USING: prettyprint sequences.extras ; 2 -1 \"abcdefg\" subseq* ."
               "\"cdef\""
    }
    "Using optional indices:"
    { $example "USING: prettyprint sequences.extras ; f -4 \"abcdefg\" subseq* ."
               "\"abc\""
    }
    "Using larger-than-necessary indices:"
    { $example "USING: prettyprint sequences.extras ; 0 10 \"abcdefg\" subseq* ."
               "\"abcdefg\""
    }
    "Trimming from either end of the sequence."
    { $example "USING: prettyprint sequences.extras ; 1 -1 \"abcdefg\" subseq* ."
               "\"bcdef\""
    }
} ;

HELP: unsurround
{ $values
    { "newseq" sequence }
    { "seq2" sequence }
    { "seq3" sequence }
    { "seq1" sequence } }
{ $description "Reverses the result of a " { $link surround } " call, stripping off the prefix " { $snippet "seq2" } " and suffix " { $snippet "seq3" } " to restore the original sequence " { $snippet "seq" } "." }
{ $see-also surround } ;
