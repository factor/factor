USING: assocs debugger hashtables help.markup help.syntax
quotations sequences math ;
IN: math.statistics

HELP: geometric-mean
{ $values { "seq" sequence } { "x" "a non-negative real number"} }
{ $description "Computes the geometric mean of all elements in " { $snippet "seq" } ". The geometric mean measures the central tendency of a data set and minimizes the effects of extreme values." }
{ $examples { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } geometric-mean ." "1.81712059283214" } }
{ $errors "Throws a " { $link signal-error. } " (square-root of 0) if the sequence is empty." } ;

HELP: harmonic-mean
{ $values { "seq" sequence } { "x" "a non-negative real number"} }
{ $description "Computes the harmonic mean of the elements in " { $snippet "seq" } ". The harmonic mean is appropriate when the average of rates is desired." }
{ $notes "Positive reals only." }
{ $examples { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } harmonic-mean ." "6/11" } }
{ $errors "Throws a " { $link signal-error. } " (divide by zero) if the sequence is empty." } ;

HELP: mean
{ $values { "seq" sequence } { "x" "a non-negative real number"} }
{ $description "Computes the arithmetic mean of the elements in " { $snippet "seq" } "." }
{ $examples { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } mean ." "2" } }
{ $errors "Throws a " { $link signal-error. } " (divide by zero) if the sequence is empty." } ;

HELP: median
{ $values { "seq" sequence } { "x" "a non-negative real number"} }
{ $description "Computes the median of " { $snippet "seq" } " by finding the middle element of the sequence using " { $link kth-smallest } ". If there is an even number of elements in the sequence, the median is not unique, so the mean of the two middle values is output." }
{ $examples
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } median ." "2" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 4 } median ." "2+1/2" } }
{ $errors "Throws a " { $link signal-error. } " (divide by zero) if the sequence is empty." } ;

HELP: range
{ $values { "seq" sequence } { "x" "a non-negative real number"} }
{ $description "Computes the difference of the maximum and minimum values in " { $snippet "seq" } "." }
{ $examples
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } range ." "2" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 4 } range ." "3" } }  ;

HELP: minmax
{ $values { "seq" sequence } { "min" real } { "max" real } }
{ $description "Finds the minimum and maximum elements of " { $snippet "seq" } " in one pass." }
{ $examples
    { $example "USING: arrays math.statistics prettyprint ;"
        "{ 1 2 3 } minmax 2array ."
        "{ 1 3 }"
    }
} ;

HELP: std
{ $values { "seq" sequence } { "x" "a non-negative real number"} }
{ $description "Computes the standard deviation of " { $snippet "seq" } ", which is the square root of the variance. It measures how widely spread the values in a sequence are about the mean." }
{ $examples
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } std ." "1.0" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 4 } std ." "1.290994448735806" } } ;

HELP: ste
  { $values { "seq" sequence } { "x" "a non-negative real number"} }
  { $description "Computes the standard error of the mean for " { $snippet "seq" } ". It's defined as the standard deviation divided by the square root of the length of the sequence, and measures uncertainty associated with the estimate of the mean." }
  { $examples
    { $example "USING: math.statistics prettyprint ;" "{ -2 2 } ste ." "2.0" }
    { $example "USING: math.statistics prettyprint ;" "{ -2 2 2 } ste ." "1.333333333333333" } } ;

HELP: var
{ $values { "seq" sequence } { "x" "a non-negative real number"} }
{ $description "Computes the variance of " { $snippet "seq" } ". It's a measurement of the spread of values in a sequence. The larger the variance, the larger the distance of values from the mean." }
{ $notes "If the number of elements in " { $snippet "seq" } " is 1 or less, it outputs 0." }
{ $examples
  { $example "USING: math.statistics prettyprint ;" "{ 1 } var ." "0" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } var ." "1" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 4 } var ." "1+2/3" } } ;


HELP: histogram
{ $values
    { "seq" sequence }
    { "hashtable" hashtable }
}
{ $examples 
    { $example "! Count the number of times an element appears in a sequence."
               "USING: prettyprint math.statistics ;"
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
               "USING: prettyprint math.statistics ;"
               "\"aaabc\" histogram \"aaaaaabc\" histogram* ."
               "H{ { 97 9 } { 98 2 } { 99 2 } }"
    }
}
{ $description "Takes an existing hashtable and uses " { $link histogram } " to continue counting the number of occurences of each element." } ;

HELP: sorted-histogram
{ $values
    { "seq" sequence }
    { "alist" "an array of key/value pairs" }
}
{ $description "Outputs a " { $link histogram } " of a sequence sorted by number of occurences from lowest to highest." }
{ $examples
    { $example "USING: prettyprint math.statistics ;"
        """"abababbbbbbc" sorted-histogram ."""
        "{ { 99 1 } { 97 3 } { 98 8 } }"
    }
} ;

HELP: sequence>assoc
{ $values
    { "seq" sequence } { "quot" quotation } { "exemplar" "an exemplar assoc" }
    { "assoc" assoc }
}
{ $examples 
    { $example "! Iterate over a sequence and increment the count at each element"
               "USING: assocs prettyprint math.statistics ;"
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
               "USING: assocs prettyprint math.statistics kernel ;"
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
               "USING: assocs prettyprint math.statistics ;"
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
    sorted-histogram
}
"Combinators for implementing histogram:"
{ $subsections
    sequence>assoc
    sequence>assoc*
    sequence>hashtable
} ;

ARTICLE: "math.statistics" "Statistics"
"Computing the mean:"
{ $subsections mean geometric-mean harmonic-mean }
"Computing the median:"
{ $subsections median lower-median upper-median medians }
"Computing the mode:"
{ $subsections mode }
"Computing the standard deviation, standard error, and variance:"
{ $subsections std ste var }
"Computing the range and minimum and maximum elements:"
{ $subsections range minmax }
"Computing the kth smallest element:"
{ $subsections kth-smallest }
"Counting the frequency of occurrence of elements:"
{ $subsection "histogram" } ;

ABOUT: "math.statistics"
