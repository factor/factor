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
    [-inf,a]
    [-inf,a)
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

ARTICLE: "math-intervals" "Intervals"
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

ABOUT: "math-intervals"

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
        { $link [-inf,a) }
        { $link [-inf,a] }
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

HELP: [-inf,a]
{ $values { "a" real } { "interval" interval } }
{ $description "Creates a new interval containing all real numbers less than or equal to " { $snippet "a" } ", together with negative infinity." } ;

HELP: [-inf,a)
{ $values { "a" real } { "interval" interval } }
{ $description "Creates a new interval containing all real numbers less than " { $snippet "a" } ", together with negative infinity." } ;

HELP: [a,inf]
{ $values { "a" real } { "interval" interval } }
{ $description "Creates a new interval containing all real numbers greater than or equal to " { $snippet "a" } ", together with positive infinity." } ;

HELP: (a,inf]
{ $values { "a" real } { "interval" interval } }
{ $description "Creates a new interval containing all real numbers greater than " { $snippet "a" } ", together with positive infinity." } ;

HELP: interval+
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Adds two intervals." } ;

HELP: interval-
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Subtracts " { $snippet "i2" } " from " { $snippet "i1" } "." } ;

HELP: interval*
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Multiplies two intervals." } ;

HELP: interval-shift
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Shifts " { $snippet "i1" } " to the left by " { $snippet "i2" } " bits. Outputs " { $link full-interval } " if the endpoints of either " { $snippet "i1" } " or " { $snippet "i2" } " are not integers." } ;

HELP: interval-max
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs the interval values obtained by lifting the " { $link max } " word to " { $snippet "i1" } " and " { $snippet "i2" } "." } ;

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

HELP: interval-min
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs the interval values obtained by lifting the " { $link min } " word to " { $snippet "i1" } " and " { $snippet "i2" } "." } ;

HELP: interval-1+
{ $values { "i1" interval } { "i2" interval } }
{ $description "Adds 1 to an interval." } ;

HELP: interval-1-
{ $values { "i1" interval } { "i2" interval } }
{ $description "Subtracts 1 from an interval." } ;

HELP: interval-neg
{ $values { "i1" interval } { "i2" interval } }
{ $description "Negates an interval." } ;

HELP: interval-abs
{ $values { "i1" interval } { "i2" interval } }
{ $description "Absolute value of an interval." } ;

HELP: interval-log2
{ $values { "i1" interval } { "i2" interval } }
{ $description "Integer-valued Base-2 logarithm of an interval." } ;

HELP: interval-intersect
{ $values { "i1" interval } { "i2" interval } { "i3" { $maybe interval } } }
{ $description "Outputs the set-theoretic intersection of " { $snippet "i1" } " and " { $snippet "i2" } ". If " { $snippet "i1" } " and " { $snippet "i2" } " do not intersect, outputs " { $link f } "." } ;

HELP: interval-union
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Outputs the smallest interval containing the set-theoretic union of " { $snippet "i1" } " and " { $snippet "i2" } " (the union itself may not be an interval)." } ;

HELP: interval-subset?
{ $values { "i1" interval } { "i2" interval } { "?" boolean } }
{ $description "Tests if every point of " { $snippet "i1" } " is contained in " { $snippet "i2" } "." } ;

HELP: interval-contains?
{ $values { "x" real } { "int" interval } { "?" boolean } }
{ $description "Tests if " { $snippet "x" } " is contained in " { $snippet "int" } "." } ;

HELP: interval-closure
{ $values { "i1" interval } { "i2" interval } }
{ $description "Outputs the smallest closed interval containing the endpoints of " { $snippet "i1" } "." } ;

HELP: interval/
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Divides " { $snippet "i1" } " by " { $snippet "i2" } ", using " { $link / } " to perform the division." } ;

HELP: interval/i
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Divides " { $snippet "i1" } " by " { $snippet "i2" } ", using " { $link /i } " to perform the division." } ;

HELP: interval/f
{ $values { "i1" interval } { "i2" interval } { "i3" interval } }
{ $description "Divides " { $snippet "i1" } " by " { $snippet "i2" } ", using " { $link /f } " to perform the division." } ;

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
{ $values { "int" interval } { "from" "a " { $snippet "{ point included? }" } " pair" } { "to" "a " { $snippet "{ point included? }" } " pair" } }
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
