! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax ;

IN: math.finance

HELP: enumerate
{ $values { "seq" "a sequence" } { "newseq" "a sequence" } }
{ $description "Returns a new sequence where each element is an array of { value, index }" } ;

HELP: distribute
{ $values { "amount" "a number of amount" } { "n" "a number of buckets" } { "seq" "a sequence" } } 
{ $description
    "Distribute 'amount' in 'n' buckets, as equally as possible.  Returns a list of 'n' elements that sum to 'amount'.\n"
} 
{ $examples
    { $example
        "USING: math.finance"
        "3 1 distribute"
        "{ 3 }" }
    { $example
        "USING: math.finance"
        "3 3 distribute"
        "{ 1 1 1 }" }
    { $example
        "USING: math.finance"
        "5 3 distribute"
        "{ 2 1 2 }" }
    { $example
        "USING: math.finance"
        "3 5 distribute"
        "{ 1 0 1 0 1 }" }
    { $example
        "USING: math.finance"
        "1000 7 distribute"
        "{ 143 143 143 142 143 143 143 }" }
} ;

HELP: sma
{ $values { "seq" "a sequence" } { "n" "number of periods" } { "newseq" "a sequence" } }
{ $description "Returns the Simple Moving Average with the specified periodicity." } ;

HELP: ema
{ $values { "seq" "a sequence" } { "n" "number of periods" } { "newseq" "a sequence" } }
{ $description 
    "Returns the Exponential Moving Average with the specified periodicity, calculated by:\n" 
    { $list 
        "A = 2.0 / (N + 1)"
        "EMA[t] = (A * SEQ[t]) + ((1-A) * EMA[t-1])" }
} ;

HELP: macd
{ $values { "seq" "a sequence" } { "n1" "short number of periods" } { "n2" "long number of periods" } { "newseq" "a sequence" } }
{ $description 
    "Returns the Moving Average Converge of the sequence, calculated by:\n"
    { $list "MACD[t] = EMA2[t] - EMA1[t]" }
} ;

HELP: momentum
{ $values { "seq" "a sequence" } { "n" "number of periods" } { "newseq" "a sequence" } }
{ $description
    "Returns the Momentum of the sequence, calculated by:\n"
    { $list "MOM[t] = SEQ[t] - SEQ[t-n]" }
} ;

