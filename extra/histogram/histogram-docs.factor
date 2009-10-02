IN: histogram
USING: help.markup help.syntax sequences hashtables quotations assocs ;

HELP: histogram
{ $values
    { "seq" sequence }
    { "hashtable" hashtable }
}
{ $examples 
    { $example "! Count the number of times an element appears in a sequence."
               "USING: prettyprint histogram ;"
               "\"aaabc\" histogram ."
               "H{ { 97 3 } { 98 1 } { 99 1 } }"
    }
}
{ $description "Returns a hashtable where the keys are the elements of the sequence and the values are the number of times they appeared in that sequence." } ;

HELP: histogram*
{ $values
    { "hashtable" hashtable } { "seq" sequence }
    { "hashtable" hashtable }
}
{ $examples 
    { $example "! Count the number of times the elements of two sequences appear."
               "USING: prettyprint histogram ;"
               "\"aaabc\" histogram \"aaaaaabc\" histogram* ."
               "H{ { 97 9 } { 98 2 } { 99 2 } }"
    }
}
{ $description "Takes an existing hashtable and uses " { $link histogram } " to continue counting the number of occurences of each element." } ;

HELP: sequence>assoc
{ $values
    { "seq" sequence } { "quot" quotation } { "exemplar" "an exemplar assoc" }
    { "assoc" assoc }
}
{ $examples 
    { $example "! Iterate over a sequence and increment the count at each element"
               "USING: assocs prettyprint histogram ;"
               "\"aaabc\" [ inc-at ] H{ } sequence>assoc ."
               "H{ { 97 3 } { 98 1 } { 99 1 } }"
    }
}
{ $description "Iterates over a sequence, allowing elements of the sequence to be added to a newly created " { $snippet "assoc" } " according to the passed quotation." } ;

HELP: sequence>assoc*
{ $values
    { "assoc" assoc } { "seq" sequence } { "quot" quotation }
    { "assoc" assoc }
}
{ $examples 
    { $example "! Iterate over a sequence and add the counts to an existing assoc"
               "USING: assocs prettyprint histogram kernel ;"
               "H{ { 97 2 } { 98 1 } } clone \"aaabc\" [ inc-at ] sequence>assoc* ."
               "H{ { 97 5 } { 98 2 } { 99 1 } }"
    }
}
{ $description "Iterates over a sequence, allowing elements of the sequence to be added to an existing " { $snippet "assoc" } " according to the passed quotation." } ;

HELP: sequence>hashtable
{ $values
    { "seq" sequence } { "quot" quotation }
    { "hashtable" hashtable }
}
{ $examples 
    { $example "! Count the number of times an element occurs in a sequence"
               "USING: assocs prettyprint histogram ;"
               "\"aaabc\" [ inc-at ] sequence>hashtable ."
               "H{ { 97 3 } { 98 1 } { 99 1 } }"
    }
}
{ $description "Iterates over a sequence, allowing elements of the sequence to be added to a hashtable according to the passed quotation." } ;

ARTICLE: "histogram" "Computing histograms"
"Counting elements in a sequence:"
{ $subsections
    histogram
    histogram*
}
"Combinators for implementing histogram:"
{ $subsections
    sequence>assoc
    sequence>assoc*
    sequence>hashtable
} ;

ABOUT: "histogram"
