USING: bson.reader bson.writer byte-arrays io.encodings.binary
io.streams.byte-array tools.test literals calendar kernel math ;

IN: bson.tests

: turnaround ( value -- value )
    assoc>bv >byte-array binary [ H{ } stream>assoc ] with-byte-reader ;

[ H{ { "a" "a string" } } ] [ H{ { "a" "a string" } } turnaround ] unit-test

[ H{ { "a" "a string" } { "b" H{ { "a" "a string" } } } } ]
[ H{ { "a" "a string" } { "b" H{ { "a" "a string" } } } } turnaround ] unit-test

[ H{ { "a list" { 1 2.234 "hello world" } } } ]
[ H{ { "a list" { 1 2.234 "hello world" } } } turnaround ] unit-test

[ H{ { "a quotation" [ 1 2 + ] } } ]
[ H{ { "a quotation" [ 1 2 + ] } } turnaround ] unit-test

[ H{ { "a date" T{ timestamp { year 2009 }
                   { month 7 }
                   { day 11 }
                   { hour 9 }
                   { minute 8 }
                   { second 40+77/1000 } } } }
]
[ H{ { "a date" T{ timestamp { year 2009 }
                   { month 7 }
                   { day 11 }
                   { hour 11 }
                   { minute 8 }
                   { second 40+15437/200000 }
                   { gmt-offset T{ duration { hour 2 } } } } } } turnaround
] unit-test
                   
[ H{ { "nested" H{ { "a" "a string" } { "b" H{ { "a" "a string" } } } } }
     { "array" H{ { "a list" { 1 2.234 "hello world" } } } }
     { "quot" [ 1 2 + ] } }
]     
[ H{ { "nested" H{ { "a" "a string" } { "b" H{ { "a" "a string" } } } } }
     { "array" H{ { "a list" { 1 2.234 "hello world" } } } }
     { "quot" [ 1 2 + ] } } turnaround ] unit-test
     
     
