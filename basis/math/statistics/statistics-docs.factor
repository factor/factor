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
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 4 } range ." "3" } } ;

HELP: minmax
{ $values { "seq" sequence } { "min" real } { "max" real } }
{ $description "Finds the minimum and maximum elements of " { $snippet "seq" } " in one pass. Throws an error on an empty sequence." }
{ $examples
    { $example "USING: arrays math.statistics prettyprint ;"
        "{ 1 2 3 } minmax 2array ."
        "{ 1 3 }"
    }
} ;

HELP: sample-std
{ $values { "seq" sequence } { "x" "a non-negative real number"} }
{ $description "Computes the sample standard deviation of " { $snippet "seq" } ", which is the square root of the sample variance. It measures how widely spread the values in a sequence are about the mean for a random subset of a dataset." }
{ $examples
  { $example "USING: math.statistics prettyprint ;" "{ 7 8 9 } sample-std ." "1.0" } } ;

HELP: sample-ste
  { $values { "seq" sequence } { "x" "a non-negative real number"} }
  { $description "Computes the standard error of the mean for " { $snippet "seq" } ". It's defined as the standard deviation divided by the square root of the length of the sequence, and measures uncertainty associated with the estimate of the mean." }
  { $examples
    { $example "USING: math.statistics prettyprint ;" "{ -2 2 } sample-ste ." "2.0" }
  } ;

HELP: sample-var
{ $values { "seq" sequence } { "x" "a non-negative real number"} }
{ $description "Computes the variance of " { $snippet "seq" } ". It's a measurement of the spread of values in a sequence." }
{ $notes "If the number of elements in " { $snippet "seq" } " is 1 or less, it outputs 0." }
{ $examples
  { $example "USING: math.statistics prettyprint ;" "{ 1 } sample-var ." "0" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } sample-var ." "1" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 4 } sample-var ." "1+2/3" } } ;

HELP: population-cov 
{ $values { "{x}" sequence } { "{y}" sequence } { "cov" "a real number" } }
{ $description "Computes the covariance of two sequences, " { $snippet "{x}" } " and " { $snippet "{y}" } "." } ;

HELP: population-corr
{ $values { "{x}" sequence } { "{y}" sequence } { "corr" "a real number" } }
{ $description "Computes the correlation of two sequences, " { $snippet "{x}" } " and " { $snippet "{y}" } "." } ;

HELP: histogram
{ $values
    { "seq" sequence }
    { "hashtable" hashtable }
}
{ $description "Returns a hashtable where the keys are the elements of the sequence and the values are the number of times they appeared in that sequence." }
{ $examples
    { $example "! Count the number of times an element appears in a sequence."
               "USING: prettyprint math.statistics ;"
               "\"aaabc\" histogram ."
               "H{ { 97 3 } { 98 1 } { 99 1 } }"
    }
} ;


HELP: histogram-by
{ $values
    { "seq" sequence }
    { "quot" { $quotation "( x -- bin )" } }
    { "hashtable" hashtable }
}
{ $description "Returns a hashtable where the keys are the elements of the sequence binned by being passed through " { $snippet "quot" } ", and the values are the number of times members of each bin appeared in that sequence." }
{ $examples
    { $unchecked-example "! Count the number of times letters and non-letters appear in a sequence."
               "USING: prettyprint math.statistics unicode.categories ;"
               "\"aaa123bc\" [ letter? ] histogram-by ."
               "H{ { t 5 } { f 3 } }"
    }
} ;

HELP: histogram!
{ $values
    { "hashtable" hashtable } { "seq" sequence }
}
{ $description "Takes an existing hashtable and uses " { $link histogram } " to continue counting the number of occurrences of each element." }
{ $examples
    { $example "! Count the number of times the elements of two sequences appear."
               "USING: prettyprint math.statistics ;"
               "\"aaabc\" histogram \"aaaaaabc\" histogram! ."
               "H{ { 97 9 } { 98 2 } { 99 2 } }"
    }
} ;

HELP: sorted-histogram
{ $values
    { "seq" sequence }
    { "alist" "an array of key/value pairs" }
}
{ $description "Outputs a " { $link histogram } " of a sequence sorted by number of occurrences from lowest to highest." }
{ $examples
    { $example "USING: prettyprint math.statistics ;"
        """"abababbbbbbc" sorted-histogram ."""
        "{ { 99 1 } { 97 3 } { 98 8 } }"
    }
} ;

HELP: sequence>assoc
{ $values
    { "seq" sequence } { "map-quot" $quotation } { "insert-quot" quotation } { "exemplar" "an exemplar assoc" }
    { "assoc" assoc }
}
{ $description "Iterates over a sequence, allowing elements of the sequence to be added to a newly created " { $snippet "assoc" } ". The " { $snippet "map-quot" } " gets passed each element from the sequence. Its outputs are passed along with the assoc being constructed to the " { $snippet "insert-quot" } ", which can modify the assoc in response." }
{ $examples
    { $example "! Iterate over a sequence and increment the count at each element"
               "! The first quotation has stack effect ( key -- key ), a no-op"
               "USING: assocs prettyprint kernel math.statistics ;"
               "\"aaabc\" [ ] [ inc-at ] H{ } sequence>assoc ."
               "H{ { 97 3 } { 98 1 } { 99 1 } }"
    }
} ;

HELP: sequence>assoc!
{ $values
    { "assoc" assoc } { "seq" sequence } { "map-quot" quotation } { "insert-quot" quotation } }
{ $description "Iterates over a sequence, allowing elements of the sequence to be added to an existing " { $snippet "assoc" } ". The " { $snippet "map-quot" } " gets passed each element from the sequence. Its outputs are passed along with the assoc being constructed to the " { $snippet "insert-quot" } ", which can modify the assoc in response." }
{ $examples
    { $example "! Iterate over a sequence and add the counts to an existing assoc"
               "USING: assocs prettyprint math.statistics kernel ;"
               "H{ { 97 2 } { 98 1 } } clone \"aaabc\" [ ] [ inc-at ] sequence>assoc! ."
               "H{ { 97 5 } { 98 2 } { 99 1 } }"
    }
} ;

HELP: sequence>hashtable
{ $values
    { "seq" sequence } { "map-quot" quotation } { "insert-quot" quotation }
    { "hashtable" hashtable }
}
{ $description "Iterates over a sequence, allowing elements of the sequence to be added to a newly created hashtable. The " { $snippet "map-quot" } " gets passed each element from the sequence. Its outputs are passed along with the assoc being constructed to the " { $snippet "insert-quot" } ", which can modify the assoc in response." }
{ $examples
    { $example "! Count the number of times an element occurs in a sequence"
               "USING: assocs kernel prettyprint math.statistics ;"
               "\"aaabc\" [ ] [ inc-at ] sequence>hashtable ."
               "H{ { 97 3 } { 98 1 } { 99 1 } }"
    }
} ;

HELP: cum-sum
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Returns the cumulative sum of " { $snippet "seq" } "." }
{ $examples
    { $example "USING: math.statistics prettyprint ;"
               "{ 1 -1 2 -1 4 } cum-sum ."
               "{ 1 0 2 1 5 }"
    }
} ;

HELP: cum-count
{ $values { "seq" sequence } { "quot" quotation } { "seq'" sequence } }
{ $description "Returns the cumulative count of how many times " { $snippet "quot" } " returns true." }
{ $examples
    { $example "USING: math math.statistics prettyprint ;"
               "{ 1 -1 2 -1 4 } [ 0 < ] cum-count ."
               "{ 0 1 1 2 2 }"
    }
} ;


HELP: cum-product
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Returns the cumulative product of " { $snippet "seq" } "." }
{ $examples
    { $example "USING: math.statistics prettyprint ;"
               "{ 1 2 3 4 } cum-product ."
               "{ 1 2 6 24 }"
    }
} ;

HELP: cum-min
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Returns the cumulative min of " { $snippet "seq" } "." }
{ $examples
    { $example "USING: math.statistics prettyprint ;"
               "{ 5 3 4 1 } cum-min ."
               "{ 5 3 3 1 }"
    }
} ;

HELP: cum-max
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Returns the cumulative max of " { $snippet "seq" } "." }
{ $examples
    { $example "USING: math.statistics prettyprint ;"
               "{ 1 -1 3 5 } cum-max ."
               "{ 1 1 3 5 }"
    }
} ;

HELP: standardize
{ $values { "u" sequence } { "v" sequence } }
{ $description "Shifts and rescales the elements of " { $snippet "u" } " to have zero mean and unit sample variance." } ;

HELP: differences
{ $values { "u" sequence } { "v" sequence } }
{ $description "Returns the successive differences of elements in " { $snippet "u" } "." } ;

HELP: rescale
{ $values { "u" sequence } { "v" sequence } }
{ $description "Returns " { $snippet "u" } " rescaled to run from 0 to 1 over the range min to max." } ;

HELP: collect-by
{ $values
    { "seq" sequence } { "quot" { $quotation "( ... obj -- ... key )" } }
    { "hashtable" hashtable }
}
{ $description "Applies a quotation to each element in the input sequence and returns a " { $snippet "hashtable" } " of like elements. The keys of this " { $snippet "hashtable" } " are the output of " { $snippet "quot" } " and the values at each key are the elements that transformed to that key." }
{ $examples
    "Collect even and odd elements:"
    { $example
               "USING: math math.statistics prettyprint ;"
               "{ 11 12 13 14 14 13 12 11 } [ odd? ] collect-by ."
               "H{ { f V{ 12 14 14 12 } } { t V{ 11 13 13 11 } } }"
    }
}
{ $notes "May be named " { $snippet "group-by" } " in other languages." } ;

HELP: collect-index-by
{ $values
    { "seq" sequence } { "quot" { $quotation "( ... obj -- ... key )" } }
    { "hashtable" hashtable }
}
{ $description "Applies a quotation to each element in the input sequence and returns a " { $snippet "hashtable" } " of like elements. The keys of this " { $snippet "hashtable" } " are the output of " { $snippet "quot" } " and the values at each key are the indices for the elements that transformed to that key." }
{ $examples
    "Collect even and odd elements:"
    { $example
               "USING: math math.statistics prettyprint ;"
               "{ 11 12 13 14 14 13 12 11 } [ odd? ] collect-index-by ."
               "H{ { f V{ 1 3 4 6 } } { t V{ 0 2 5 7 } } }"
    }
} ;

HELP: z-score
{ $values { "seq" sequence } { "n" number } }
{ $description "Calculates the Z-Score for " { $snippet "seq" } "." } ;

ARTICLE: "histogram" "Computing histograms"
"Counting elements in a sequence:"
{ $subsections
    histogram
    histogram-by
    histogram!
    sorted-histogram
}
"Combinators for implementing histogram:"
{ $subsections
    sequence>assoc
    sequence>assoc!
    sequence>hashtable
} ;

ARTICLE: "cumulative" "Computing cumulative sequences"
"Cumulative mapping combinators:"
{ $subsections
    cum-map
}
"Cumulative math:"
{ $subsections
    cum-sum
    cum-sum0
    cum-product
}
"Cumulative comparisons:"
{ $subsections
    cum-min
    cum-max
}
"Cumulative counting:"
{ $subsections
    cum-count
} ;

ARTICLE: "math.statistics" "Statistics"
"Computing the mean:"
{ $subsections mean geometric-mean harmonic-mean }
"Computing the median:"
{ $subsections median lower-median upper-median medians }
"Computing the mode:"
{ $subsections mode }
"Computing the population standard deviation, standard error, and variance:"
{ $subsections population-std population-ste population-var }
"Computing the sample standard deviation, standard error, and variance:"
{ $subsections sample-std sample-ste sample-var }
"Computing the nth delta-degrees-of-freedom statistics:"
{ $subsections std-ddof ste-ddof var-ddof }
"Computing the range and minimum and maximum elements:"
{ $subsections range minmax }
"Computing the kth smallest element:"
{ $subsections kth-smallest }
"Counting the frequency of occurrence of elements:"
{ $subsections "histogram" }
"Collecting related items:"
{ $subsections collect-by collect-index-by }
"Computing cumulative sequences:"
{ $subsections "cumulative" } ;

ABOUT: "math.statistics"

{ var-ddof population-var sample-var } related-words
{ std-ddof population-std sample-std } related-words
{ ste-ddof population-ste sample-ste } related-words
{ corr-ddof population-corr sample-corr } related-words
{ cov-ddof population-cov sample-cov } related-words
