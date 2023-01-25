! Copyright (C) 2016 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.streams.string json json.prettyprint tools.test ;

{
"{
  \"a\": 3
}"
} [
    "{\"a\":3}" json> pprint-json>string
] unit-test

{ "{ }" } [ "{ }" json> pprint-json>string ] unit-test
{ "[ ]" } [ "[ ]" json> pprint-json>string ] unit-test
{ "null" } [ "null" json> pprint-json>string ] unit-test
{ "false" } [ "false" json> pprint-json>string ] unit-test
{ "3" } [ "3" json> pprint-json>string ] unit-test
{ "[
  3,
  4,
  5
]" } [ "[3,4,5]" json> pprint-json>string ] unit-test

{ "{
  3: 30,
  4: 40,
  5: 50
}" } [ "{3:30,4:40,5:50}" json> pprint-json>string ] unit-test
