USING: help.markup help.syntax kernel math math.order ;
IN: math.intervals

ARTICLE: "math-intervals-new" "Creating intervals"
"Standard constructors:"
{ $subsections
    [a,b]
    (a,b)
    [a,b)
    (a,b]
}
"One-point interval constructor:"
{ $subsections [a,a] }
"Open-ended interval constructors:"
{ $subsections
    [-inf,b]
    [-inf,b)
    [a,inf]
    (a,inf]
}
"The set of all real numbers with infinities:"
{ $subsections [-inf,inf] }
"The empty set:"
{ $subsections empty-interval }
"Another constructor:"
{ $subsections points>interval } ;

ARTICLE: "math-intervals-arithmetic" "Interval arithmetic"
"In general, a binary operation " { $snippet "X Y op" } " where " { $snippet "X" } " and " { $snippet "Y" } " are intervals is the set " { $snippet "{x op y forall x in X, y in Y}" } "."
$nl
"Binary operations on intervals:"
{ $subsections
    interval+
    interval-
    interval*
    interval/
    interval/i
    interval-mod
    interval-rem
    interval-min
    interval-max
}
"Bitwise operations on intervals:"
{ $subsections
    interval-shift
    interval-bitand
    interval-bitor
    interval-bitxor
}
"Unary operations on intervals:"
{ $subsections
    interval-1+
    interval-1-
    interval-neg
    interval-bitnot
    interval-recip
    interval-2/
    interval-abs
    interval-log2
} ;

ARTICLE: "math-intervals-sets" "Set-theoretic operations on intervals"
{ $subsections
    interval-contains?
    interval-subset?
    interval-intersect
    interval-union
    interval-closure
    integral-closure
} ;

ARTICLE: "math-intervals-compare" "Comparing intervals"
{ $subsections
    interval<
    interval<=
    interval>
    interval>=
    assume<
    assume<=
    assume>
    assume>=
} ;

ARTICLE: "math-interval-properties" "Properties of interval arithmetic"
"For some operations, interval arithmetic yields inaccurate results, either because the result of lifting some operations to intervals does not result in intervals (bitwise operations, for example) or for the sake of simplicity of implementation."
$nl
"However, one important property holds for all operations. Suppose " { $emphasis "I, J" } " are intervals and " { $emphasis "op" } " is an operation. If " { $emphasis "x" } " is an element of " { $emphasis "I" } " and " { $emphasis "y" } " is an element of " { $emphasis "J" } ", then " { $emphasis "x op y" } " is an element of " { $emphasis "I op J" } "."
$nl
"In other words, the resulting interval might be an overestimate, but it is never an underestimate." ;

ARTICLE: "math.intervals" "Intervals"
"Interval arithmetic is performed on ranges of real numbers, rather than exact values. It is used by the Factor compiler to convert arbitrary-precision arithmetic to machine arithmetic, by inferring bounds for integer calculations."
{ $subsections "math-interval-properties" }
"The class of intervals:"
{ $subsections
    interval
    interval?
}
"Interval operations:"
{ $subsections
    "math-intervals-new"
    "math-intervals-arithmetic"
    "math-intervals-sets"
    "math-intervals-compare"
} ;

ABOUT: "math.intervals"

HELP: interval
{ $class-description "An interval represents a set of real numbers between two endpoints; the endpoints can either be included or excluded from the interval."
$nl
"The " { $snippet "from" } " and " { $snippet "to" } " slots store endpoints, represented as arrays of the shape " { $snippet "{ number included? }" } "."
$nl
"Intervals are created by calling " { $link [a,b] } ", " { $link (a,b) } ", " { $link [a,b) } ", " { $link (a,b] } " or " { $link [a,a] } "." } ;

HELP: <interval>
{ $values { "from" "a " { $snippet "{ point included? }" } " pair" } { "to" "a " { $snippet "{ point included? }" } " pair" } { "interval" interval } }
{ $description "Creates a new interval. Usually it is more convenient to create intervals using one of the following words instead:"
    { $list
        { $link [a,b] }
        { $link (a,b) }
        { $link [a,b) }
        { $link (a,b] }
        { $link [a,inf] }
        { $link (a,inf] }
        { $link [-inf,b) }
        { $link [-inf,b] }
    }
} ;

HELP: [a,b]
{ $values { "a" real } { "b" real } { "interval" interval } }
{ $description "Creates a new interval that includes both endpoints." } ;

HELP: (a,b)
{ $values { "a" real } { "b" real } { "interval" interval } }
{ $description "Creates a new interval that excludes both endpoints." } ;

HELP: [a,b)
{ $values { "a" real } { "b" real } { "interval" interval } }
{ $description "Creates a new interval that includes the lower endpoint and excludes the upper endpoint." } ;

HELP: (a,b]
{ $values { "a" real } { "b" real } { "interval" interval } }
{ $description "Creates a new interval that excludes the lower endpoint and includes the upper endpoint." } ;

HELP: [a,a]
{ $values { "a" real } { "interval" interval } }
{ $description "Creates a new interval consisting of a single point." } ;

HELP: [0,b]
{ $values { "b" real } { "interval" interval } }
{ $description "Creates a new interval that includes lower endpoint 0 and includes the upper endpoint." } ;

HELP: [0,b)
{ $values { "b" real } { "interval" interval } }
{ $description "Creates a new interval that includes lower endpoint 0 and excludes the upper endpoint." } ;


HELP: [-inf,b]
{ $values { "b" real } { "interval" interval } }
{ $description "Creates a new interval containing all real numbers less than or equal to " { $snippet "b" } ", together with negative infinity." } ;

HELP: [-inf,b)
{ $values { "b" real } { "interval" interval } }
{ $description "Creates a new interval containing all real numbers less than " { $snippet "b" } ", together with negative infinity." } ;

HELP: [a,inf]
{ $values { "a" real } { "interval" interval } }
{ $description "Creates a new interval containing all real numbers greater than or equal to " { $snippet "a" } ", together with positive infinity." } ;

HELP: (a,inf]
{ $values { "a" real } { "interval" interval } }
{ $description "Creates a new interval containing all real numbers greater than " { $snippet "a" } ", together with positive infinity." } ;

HELP: interval+
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Adds two intervals."
$nl
"The output interval contains all possible values from adding any number in " { $snippet "i1" } " to any number in " { $snippet "i2" } "." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "10 11 [a,b] 5 7 [a,b] interval+ ."
        "T{ interval { from { 15 t } } { to { 18 t } } }"
    }
} ;

HELP: interval-
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Subtracts " { $snippet "i2" } " from " { $snippet "i1" } "."
$nl
"The output interval contains all possible values from subtracting any number in " { $snippet "i2" } " from any number in " { $snippet "i1" } "." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "10 11 [a,b] 5 7 [a,b] interval- ."
        "T{ interval { from { 3 t } } { to { 6 t } } }"
    }
} ;

HELP: interval*
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Multiplies two intervals."
$nl
"The output interval contains all possible values from multiplying any number in " { $snippet "i1" } " with any number in " { $snippet "i2" } "." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "10 11 [a,b] 5 7 [a,b] interval* ."
        "T{ interval { from { 50 t } } { to { 77 t } } }"
    }
    { $example "USING: math.intervals prettyprint ;"
        "-10 11 [a,b] 5 7 [a,b] interval* ."
        "T{ interval { from { -70 t } } { to { 77 t } } }"
    }
} ;

HELP: interval-shift
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Shifts " { $snippet "i1" } " to the left by " { $snippet "i2" } " bits. Outputs " { $link full-interval } " if the endpoints of either " { $snippet "i1" } " or " { $snippet "i2" } " are not integers." } ;

HELP: interval-mod
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs an interval containing all possible values obtained by applying " { $link mod } " to elements of " { $snippet "i1" } " and " { $snippet "i2" } "." } ;

HELP: interval-rem
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs an interval containing all possible values obtained by applying " { $link rem } " to elements of " { $snippet "i1" } " and " { $snippet "i2" } "." } ;

HELP: interval-bitand
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs an interval containing all possible values obtained by applying " { $link bitand } " to elements of " { $snippet "i1" } " and " { $snippet "i2" } "." } ;

HELP: interval-bitor
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs an interval containing all possible values obtained by applying " { $link bitor } " to elements of " { $snippet "i1" } " and " { $snippet "i2" } "." } ;

HELP: interval-bitxor
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs an interval containing all possible values obtained by applying " { $link bitxor } " to elements of " { $snippet "i1" } " and " { $snippet "i2" } "." } ;

HELP: interval-max
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs the interval values obtained by lifting the " { $link max } " word to " { $snippet "i1" } " and " { $snippet "i2" } "." } ;

HELP: interval-min
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs the interval values obtained by lifting the " { $link min } " word to " { $snippet "i1" } " and " { $snippet "i2" } "." } ;

HELP: interval-1+
{ $values { "i1" interval } { "i2" interval } }
{ $description "Adds 1 to an interval." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "10 11 [a,b] interval-1+ ."
        "T{ interval { from { 11 t } } { to { 12 t } } }"
    }
} ;

HELP: interval-1-
{ $values { "i1" interval } { "i2" interval } }
{ $description "Subtracts 1 from an interval." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "10 11 [a,b] interval-1- ."
        "T{ interval { from { 9 t } } { to { 10 t } } }"
    }
} ;

HELP: interval-neg
{ $values { "i1" interval } { "i2" interval } }
{ $description "Negates an interval." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "10 11 [a,b] interval-neg ."
        "T{ interval { from { -11 t } } { to { -10 t } } }"
    }
} ;

HELP: interval-abs
{ $values { "i1" interval } { "i2" interval } }
{ $description "Absolute value of an interval." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "-11 -10 [a,b] interval-abs ."
        "T{ interval { from { 10 t } } { to { 11 t } } }"
    }
} ;

HELP: interval-log2
{ $values { "i1" interval } { "i2" interval } }
{ $description "Integer-valued Base-2 logarithm of an interval." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "20 32 [a,b] interval-log2 ."
        "T{ interval { from { 0 t } } { to { 5 t } } }"
    }
} ;

HELP: interval-intersect
{ $values { "i1" interval } { "i2" interval } { "i3" { $maybe interval } } }
{ $description "Outputs the set-theoretic intersection of " { $snippet "i1" } " and " { $snippet "i2" } ". If " { $snippet "i1" } " and " { $snippet "i2" } " do not intersect, outputs " { $link f } "." } ;

HELP: interval-union
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs the smallest interval containing the set-theoretic union of " { $snippet "i1" } " and " { $snippet "i2" } " (the union itself may not be an interval)." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "1 5 [a,b] 10 15 [a,b] interval-union ."
        "T{ interval { from { 1 t } } { to { 15 t } } }"
    }
    { $example "USING: math.intervals prettyprint ;"
        "empty-interval empty-interval interval-union ."
        "empty-interval"
    }
} ;

{ interval-intersect interval-union } related-words

HELP: interval-subset?
{ $values { "i1" interval } { "i2" interval } { "?" boolean } }
{ $description "Tests if every point of " { $snippet "i1" } " is contained in " { $snippet "i2" } "." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "2 4 [a,b] 1 9 [a,b] interval-subset? ."
        "t"
    }
} ;

HELP: interval-contains?
{ $values { "x" real } { "interval" interval } { "?" boolean } }
{ $description "Tests if " { $snippet "x" } " is contained in " { $snippet "interval" } "." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "1.5 1 2 [a,b] interval-contains? ."
        "t"
    }
    "Half-open endpoints are not contained:"
    { $example "USING: math.intervals prettyprint ;"
        "1 1 2 (a,b] interval-contains? ."
        "f"
    }
    "The empty interval obviously does not contain an interval:"
    { $example "USING: math.intervals prettyprint ;"
        "1 2 (a,b] empty-interval interval-contains? ."
        "f"
    }
} ;

{ interval-contains? interval-subset? } related-words

HELP: interval-closure
{ $values { "i1" interval } { "i2" interval } }
{ $description "Outputs the smallest closed interval containing the endpoints of " { $snippet "i1" } "." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "1 3 [a,b) interval-closure ."
        "T{ interval { from { 1 t } } { to { 3 t } } }"
    }
} ;

HELP: interval/
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Ouputs an interval " { $snippet "i3" } " containing all possible values from dividing any element in " { $snippet "i1" } " by any element from " { $snippet "i2" } ", using " { $link / } " to perform the division." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "7 9 [a,b] 10 11 [a,b] interval/ ."
        "T{ interval { from { 7/11 t } } { to { 9/10 t } } }"
    }
} ;

HELP: interval/i
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Ouputs an interval " { $snippet "i3" } " containing all possible values from dividing any element in " { $snippet "i1" } " by any element from " { $snippet "i2" } ", using " { $link /i } " to perform the division." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "9 25 [a,b] 10 11 [a,b] interval/i ."
        "T{ interval { from { 0 t } } { to { 2 t } } }"
    }
    { $example "USING: math.intervals prettyprint ;"
        "10 11 [a,b] 5 7 [a,b] interval/i ."
        "T{ interval { from { 1 t } } { to { 2 t } } }"
    }
} ;

{ interval/ interval/i interval/f } related-words

HELP: interval/f
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Ouputs an interval " { $snippet "i3" } " containing all possible values from dividing any element in " { $snippet "i1" } " by any element from " { $snippet "i2" } ", using " { $link /f } " to perform the division." }
{ $examples
    { $example "USING: math.intervals prettyprint ;"
        "10 12 [a,b] 2 4 [a,b] interval/f ."
        "T{ interval { from { 2.5 t } } { to { 6.0 t } } }"
    }
} ;

HELP: interval-recip
{ $values { "i1" interval } { "i2" interval } }
{ $description "Outputs the reciprocal of an interval. Outputs " { $link f } " if " { $snippet "i1" } " contains points arbitrarily close to zero." } ;

HELP: interval-2/
{ $values { "i1" interval } { "i2" interval } }
{ $description "Shifts an interval to the right by one bit." } ;

HELP: interval-bitnot
{ $values { "i1" interval } { "i2" interval } }
{ $description "Computes the bitwise complement of the interval." } ;

HELP: points>interval
{ $values { "seq" "a sequence of " { $snippet "{ point included? }" } " pairs" } { "interval" interval } { "nan?" "true if the computation produced NaNs" } }
{ $description "Outputs the smallest interval containing all of the endpoints." }
;

HELP: interval-shift-safe
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Shifts " { $snippet "i1" } " to the left by " { $snippet "i2" } " bits. Outputs " { $link full-interval } " if the endpoints of either " { $snippet "i1" } " or " { $snippet "i2" } " are not integers, or if the endpoints of " { $snippet "i2" } " are so large that the resulting interval will consume too much memory." } ;

HELP: incomparable
{ $description "Output value from " { $link interval<= } ", " { $link interval< } ", " { $link interval>= } " and " { $link interval> } " in the case where the result of the comparison is ambiguous." } ;

HELP: interval<=
{ $values { "i1" interval } { "i2" interval } { "?" "a boolean or " { $link incomparable } } }
{ $description "Compares " { $snippet "i1" } " with " { $snippet "i2" } ", and outputs one of the following:"
    { $list
        { { $link t } " if every point in " { $snippet "i1" } " is less than or equal to every point in " { $snippet "i2" } }
        { { $link f } " if every point in " { $snippet "i1" } " is greater than every point in " { $snippet "i2" } }
        { { $link incomparable } " if neither of the above conditions hold" }
    }
} ;

HELP: interval<
{ $values { "i1" interval } { "i2" interval } { "?" "a boolean or " { $link incomparable } } }
{ $description "Compares " { $snippet "i1" } " with " { $snippet "i2" } ", and outputs one of the following:"
    { $list
        { { $link t } " if every point in " { $snippet "i1" } " is less than every point in " { $snippet "i2" } }
        { { $link f } " if every point in " { $snippet "i1" } " is greater than or equal to every point in " { $snippet "i2" } }
        { { $link incomparable } " if neither of the above conditions hold" }
    }
} ;

HELP: interval>=
{ $values { "i1" interval } { "i2" interval } { "?" "a boolean or " { $link incomparable } } }
{ $description "Compares " { $snippet "i1" } " with " { $snippet "i2" } ", and outputs one of the following:"
    { $list
        { { $link t } " if every point in " { $snippet "i1" } " is greater than or equal to every point in " { $snippet "i2" } }
        { { $link f } " if every point in " { $snippet "i1" } " is less than every point in " { $snippet "i2" } }
        { { $link incomparable } " if neither of the above conditions hold" }
    }
} ;

HELP: interval>
{ $values { "i1" interval } { "i2" interval } { "?" "a boolean or " { $link incomparable } } }
{ $description "Compares " { $snippet "i1" } " with " { $snippet "i2" } ", and outputs one of the following:"
    { $list
        { { $link t } " if every point in " { $snippet "i1" } " is greater than every point in " { $snippet "i2" } }
        { { $link f } " if every point in " { $snippet "i1" } " is less than or equal to every point in " { $snippet "i2" } }
        { { $link incomparable } " if neither of the above conditions hold" }
    }
} ;

HELP: interval>points
{ $values { "interval" interval } { "from" "a " { $snippet "{ point included? }" } " pair" } { "to" "a " { $snippet "{ point included? }" } " pair" } }
{ $description "Outputs both endpoints of the interval." } ;

HELP: assume<
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs the interval consisting of points from " { $snippet "i1" } " which are less than all points in " { $snippet "i2" } "." } ;

HELP: assume<=
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs the interval consisting of points from " { $snippet "i1" } " which are less or equal to all points in " { $snippet "i2" } "." } ;

HELP: assume>
{ $values { "i1" interval } { "i2" interval } { "i3" { $maybe interval } } }
{ $description "Outputs the interval consisting of points from " { $snippet "i1" } " which are greater than all points in " { $snippet "i2" } ". If the resulting interval is empty, outputs " { $link f } "." } ;

HELP: assume>=
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs the interval consisting of points from " { $snippet "i1" } " which are greater than or equal to all points in " { $snippet "i2" } "." } ;

HELP: integral-closure
{ $values { "i1" "an " { $link interval } " with integer end-points" } { "i2" "a closed " { $link interval } " with integer end-points" } }
{ $description "Outputs a closed interval which is equal as a set to " { $snippet "i1" } ", when " { $snippet "i1" } " is viewed as an interval over in integers (that is, a discrete set)." } ;
