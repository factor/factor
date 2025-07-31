USING: bson bson.constants calendar linked-assocs math
tools.test ;

{ LH{ { "a" "a string" } } } [ LH{ { "a" "a string" } } >bson bson> ] unit-test

{ LH{ { "a" "a string" } { "b" LH{ { "a" "アップルからの最新のニュースや情報を読む" } } } } }
[ LH{ { "a" "a string" } { "b" LH{ { "a" "アップルからの最新のニュースや情報を読む" } } } } >bson bson> ] unit-test

{ LH{ { "a list" { 1 2.234 "hello world" } } } }
[ LH{ { "a list" { 1 2.234 "hello world" } } } >bson bson> ] unit-test

{ LH{ { "a quotation" [ 1 2 + ] } } }
[ LH{ { "a quotation" [ 1 2 + ] } } >bson bson> ] unit-test

{ LH{ { "ref" T{ dbref f "a" "b" "c" } } } }
[ LH{ { "ref" T{ dbref f "a" "b" "c" } } } >bson bson> ] unit-test

{ LH{ { "a date" T{ timestamp { year 2009 }
                   { month 7 }
                   { day 11 }
                   { hour 9 }
                   { minute 8 }
                   { second 40+77/1000 } } } }
} [ LH{ { "a date" T{ timestamp { year 2009 }
                   { month 7 }
                   { day 11 }
                   { hour 11 }
                   { minute 8 }
                   { second 40+15437/200000 }
                   { gmt-offset T{ duration { hour 2 } } } } } } >bson bson>
] unit-test

{
     LH{
          { "nested" LH{ { "a" "a string" } { "b" LH{ { "a" "a string" } } } } }
          { "ref" T{ dbref f "a" "b" "c" } }
          { "array" LH{ { "a list" { 1 2.234 "hello world" } } } }
          { "quot" [ 1 2 + ] }
     }
} [
     LH{
          { "nested" LH{ { "a" "a string" } { "b" H{ { "a" "a string" } } } } }
          { "ref" T{ dbref f "a" "b" "c" } }
          { "array" LH{ { "a list" { 1 2.234 "hello world" } } } }
          { "quot" [ 1 2 + ] }
     } >bson bson>
] unit-test
