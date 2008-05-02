USING: io.streams.string csv tools.test shuffle ;
IN: csv.tests

! I like to name my unit tests
: named-unit-test ( name output input -- ) 
  nipd unit-test ; inline

! tests nicked from the wikipedia csv article
! http://en.wikipedia.org/wiki/Comma-separated_values

"Fields are separated by commas"
[ { { "1997" "Ford" "E350" } } ] 
[ "1997,Ford,E350" <string-reader> csv ] named-unit-test

"ignores whitespace before and after elements. n.b.specifically prohibited by RFC 4180, which states, 'Spaces are considered part of a field and should not be ignored.'"
[ { { "1997" "Ford" "E350" } } ]
[ "1997,   Ford   , E350" <string-reader> csv ] named-unit-test

"keeps spaces in quotes"
[ { { "1997" "Ford" "E350" "Super, luxurious truck" } } ]
[ "1997,Ford,E350,\"Super, luxurious truck\"" <string-reader> csv ] named-unit-test

"double quotes mean escaped in quotes"
[ { { "1997" "Ford" "E350" "Super \"luxurious\" truck" } } ]
[ "1997,Ford,E350,\"Super \"\"luxurious\"\" truck\"" 
  <string-reader> csv ] named-unit-test

"Fields with embedded line breaks must be delimited by double-quote characters."
[ { { "1997" "Ford" "E350" "Go get one now\nthey are going fast" } } ]
[ "1997,Ford,E350,\"Go get one now\nthey are going fast\""
  <string-reader> csv ] named-unit-test

"Fields with leading or trailing spaces must be delimited by double-quote characters. (See comment about leading and trailing spaces above)"
[ { { "1997" "Ford" "E350" "  Super luxurious truck    " } } ]
[ "1997,Ford,E350,\"  Super luxurious truck    \""
  <string-reader> csv ] named-unit-test

"Fields may always be delimited by double-quote characters, whether necessary or not."
[ { { "1997" "Ford" "E350" } } ]
[ "\"1997\",\"Ford\",\"E350\"" <string-reader> csv ] named-unit-test

"The first record in a csv file may contain column names in each of the fields."
[ { { "Year" "Make" "Model" } 
    { "1997" "Ford" "E350" }
    { "2000" "Mercury" "Cougar" } } ]
[ "Year,Make,Model\n1997,Ford,E350\n2000,Mercury,Cougar" 
   <string-reader> csv ] named-unit-test


! !!!!!!!!  other tests
   
[ { { "Phil Dawes" } } ] 
[ "\"Phil Dawes\"" <string-reader> csv ] unit-test

[ { { "1" "2" "3" } { "4" "5" "6" } } ] 
[ "1,2,3\n4,5,6\n" <string-reader> csv ] unit-test

"trims leading and trailing whitespace - n.b. this isn't really conformant, but lots of csv seems to assume this"
[ { { "foo yeah" "bah" "baz" } } ] 
[ "  foo yeah  , bah ,baz\n" <string-reader> csv ] named-unit-test


"allows setting of delimiting character"
[ { { "foo" "bah" "baz" } } ] 
[ "foo\tbah\tbaz\n" <string-reader> CHAR: \t [ csv ] with-delimiter ] named-unit-test

"Quoted field followed immediately by newline"
[ { { "foo" "bar" }
    { "1"   "2" } } ]
[ "foo,\"bar\"\n1,2" <string-reader> csv ] named-unit-test
