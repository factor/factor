USING: help.markup help.syntax debugger ;
IN: math.statistics

HELP: geometric-mean
{ $values { "seq" "a sequence of numbers" } { "x" "a non-negative real number"} }
{ $description "Computes the geometric mean of all elements in " { $snippet "seq" } ". The geometric mean measures the central tendency of a data set that minimizes the effects of extreme values." }
{ $examples { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } geometric-mean ." "1.81712059283214" } }
{ $errors "Throws a " { $link signal-error. } " (square-root of 0) if the sequence is empty." } ;

HELP: harmonic-mean
{ $values { "seq" "a sequence of numbers" } { "x" "a non-negative real number"} }
{ $description "Computes the harmonic mean of the elements in " { $snippet "seq" } ". The harmonic mean is appropriate when the average of rates is desired." }
{ $notes "Positive reals only." }
{ $examples { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } harmonic-mean ." "6/11" } }
{ $errors "Throws a " { $link signal-error. } " (divide by zero) if the sequence is empty." } ;

HELP: mean
{ $values { "seq" "a sequence of numbers" } { "x" "a non-negative real number"} }
{ $description "Computes the arithmetic mean of all elements in " { $snippet "seq" } "." }
{ $examples { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } mean ." "2" } }
{ $errors "Throws a " { $link signal-error. } " (divide by zero) if the sequence is empty." } ;

HELP: median
{ $values { "seq" "a sequence of numbers" } { "x" "a non-negative real number"} }
{ $description "Computes the median of " { $snippet "seq" } " by sorting the sequence from lowest value to highest and outputting the middle one. If there is an even number of elements in the sequence, the median is not unique, so the mean of the two middle values is outputted." }
{ $examples
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } median ." "2" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 4 } median ." "2+1/2" } }
{ $errors "Throws a " { $link signal-error. } " (divide by zero) if the sequence is empty." } ;

HELP: range
{ $values { "seq" "a sequence of numbers" } { "x" "a non-negative real number"} }
{ $description "Computes the distance of the maximum and minimum values in " { $snippet "seq" } "." }
{ $examples
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } range ." "2" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 4 } range ." "3" } }  ;

HELP: std
{ $values { "seq" "a sequence of numbers" } { "x" "a non-negative real number"} }
{ $description "Computes the standard deviation of " { $snippet "seq" } ", which is the square root of the variance. It measures how widely spread the values in a sequence are about the mean." }
{ $examples
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } std ." "1.0" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 4 } std ." "1.290994448735806" } } ;

HELP: ste
  { $values { "seq" "a sequence of numbers" } { "x" "a non-negative real number"} }
  { $description "Computes the standard error of the mean for " { $snippet "seq" } ". It's defined as the standard deviation divided by the square root of the length of the sequence, and measures uncertainty associated with the estimate of the mean." }
  { $examples
    { $example "USING: math.statistics prettyprint ;" "{ -2 2 } ste ." "2.0" }
    { $example "USING: math.statistics prettyprint ;" "{ -2 2 2 } ste ." "1.333333333333333" } } ;

HELP: var
{ $values { "seq" "a sequence of numbers" } { "x" "a non-negative real number"} }
{ $description "Computes the variance of " { $snippet "seq" } ". It's a measurement of the spread of values in a sequence. The larger the variance, the larger the distance of values from the mean." }
{ $notes "If the number of elements in " { $snippet "seq" } " is 1 or less, it outputs 0." }
{ $examples
  { $example "USING: math.statistics prettyprint ;" "{ 1 } var ." "0" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 } var ." "1" }
  { $example "USING: math.statistics prettyprint ;" "{ 1 2 3 4 } var ." "1+2/3" } } ;

