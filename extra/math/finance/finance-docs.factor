! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax ;

IN: math.finance

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

