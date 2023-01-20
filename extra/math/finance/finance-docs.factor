! Copyright (C) 2008 John Benediktsson, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license
USING: help.markup help.syntax math sequences ;
IN: math.finance

HELP: sma
{ $values { "seq" sequence } { "n" "number of periods" } { "newseq" sequence } }
{ $description "Returns the Simple Moving Average with the specified periodicity." } ;

HELP: ema
{ $values { "seq" sequence } { "n" "number of periods" } { "newseq" sequence } }
{ $description
    "Returns the Exponential Moving Average with the specified periodicity, calculated by:\n"
    { $list
        "A = 2.0 / (N + 1)"
        "EMA[t] = (A * SEQ[t]) + ((1-A) * EMA[t-1])" }
} ;

HELP: macd
{ $values { "seq" sequence } { "n1" "short number of periods" } { "n2" "long number of periods" } { "newseq" sequence } }
{ $description
    "Returns the Moving Average Converge of the sequence, calculated by:\n"
    { $list "MACD[t] = EMA2[t] - EMA1[t]" }
} ;

HELP: momentum
{ $values { "seq" sequence } { "n" "number of periods" } { "newseq" sequence } }
{ $description
    "Returns the Momentum of the sequence, calculated by:\n"
    { $list "MOM[t] = SEQ[t] - SEQ[t-n]" }
} ;

HELP: biweekly
{ $values
    { "x" number }
    { "y" number }
}
{ $description "Divides a number by the number of two week periods in a year." } ;

HELP: daily-360
{ $values
    { "x" number }
    { "y" number }
}
{ $description "Divides a number by the number of days in a 360-day year." } ;

HELP: daily-365
{ $values
    { "x" number }
    { "y" number }
}
{ $description "Divides a number by the number of days in a 365-day year." } ;

HELP: monthly
{ $values
    { "x" number }
    { "y" number }
}
{ $description "Divides a number by the number of months in a year." } ;

HELP: semimonthly
{ $values
    { "x" number }
    { "y" number }
}
{ $description "Divides a number by the number of half-months in a year. Note that biweekly has two more periods than semimonthly." } ;

HELP: weekly
{ $values
    { "x" number }
    { "y" number }
}
{ $description "Divides a number by the number of weeks in a year." } ;

ARTICLE: "time-period-calculations" "Calculations over periods of time"
{ $subsections
    monthly
    semimonthly
    biweekly
    weekly
    daily-360
    daily-365
} ;

ARTICLE: "math.finance" "Financial math"
"The " { $vocab-link "math.finance" } " vocabulary contains financial calculation words." $nl
"Calculating payroll over periods of time:"
{ $subsections "time-period-calculations" } ;

ABOUT: "math.finance"
