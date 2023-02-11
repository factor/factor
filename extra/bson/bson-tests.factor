USING: bson bson.constants byte-arrays io.encodings.binary
io.streams.byte-array tools.test literals calendar kernel math ;

IN: bson.tests

: turnaround ( value -- value )
    assoc>bv binary [ H{ } clone stream>assoc ] with-byte-reader ;

{ H{ { "a" "a string" } } } [ H{ { "a" "a string" } } turnaround ] unit-test

{ H{ { "a" "a string" } { "b" H{ { "a" "アップルからの最新のニュースや情報を読む" } } } } }
[ H{ { "a" "a string" } { "b" H{ { "a" "アップルからの最新のニュースや情報を読む" } } } } turnaround ] unit-test

{ H{ { "a list" { 1 2.234 "hello world" } } } }
[ H{ { "a list" { 1 2.234 "hello world" } } } turnaround ] unit-test

{ H{ { "a quotation" [ 1 2 + ] } } }
[ H{ { "a quotation" [ 1 2 + ] } } turnaround ] unit-test

{ H{ { "ref" T{ dbref f "a" "b" "c" } } } }
[ H{ { "ref" T{ dbref f "a" "b" "c" } } } turnaround ] unit-test

{ H{ { "a date" T{ timestamp { year 2009 }
                   { month 7 }
                   { day 11 }
                   { hour 9 }
                   { minute 8 }
                   { second 40+77/1000 } } } }
}
[ H{ { "a date" T{ timestamp { year 2009 }
                   { month 7 }
                   { day 11 }
                   { hour 11 }
                   { minute 8 }
                   { second 40+15437/200000 }
                   { gmt-offset T{ duration { hour 2 } } } } } } turnaround
] unit-test

{
     H{
          { "nested" H{ { "a" "a string" } { "b" H{ { "a" "a string" } } } } }
          { "ref" T{ dbref f "a" "b" "c" } }
          { "array" H{ { "a list" { 1 2.234 "hello world" } } } }
          { "quot" [ 1 2 + ] }
     }
} [
     H{
          { "nested" H{ { "a" "a string" } { "b" H{ { "a" "a string" } } } } }
          { "ref" T{ dbref f "a" "b" "c" } }
          { "array" H{ { "a list" { 1 2.234 "hello world" } } } }
          { "quot" [ 1 2 + ] }
     } turnaround
] unit-test
