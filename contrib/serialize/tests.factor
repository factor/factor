! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
! 
USING: test kernel serialize io math ;
IN: temporary

[ f  ] [
  [ [ f serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ t  ] [
  [ [ t serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ 0  ] [
  [ [ 0 serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ -50  ] [
  [ [ -50 serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ 20  ] [
  [ [ 20 serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ t  ] [
  [ [ 5 5 5 ^ ^ serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in 5 5 5 ^ ^ =
] unit-test

[ t  ] [
  [ [ 5 5 5 ^ ^ neg serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in 5 5 5 ^ ^ neg =
] unit-test

[ 5.25  ] [
  [ [ 5.25 serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ -5.25  ] [
  [ [ -5.25 serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ C{ 1 2 }  ] [
  [ [ C{ 1 2 } serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ t ] [
  [ [ C{ 1 2 } dup serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ f ] [
  [ [ C{ 1 2 } C{ 1 2 } serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ 1/2  ] [
  [ [ 1/2 serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ "test"  ] [
  [ [ "test" serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ t  ] [
  [ [ "test" dup serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ f  ] [
  [ [ "test" "test" serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ t ] [
  [ [ "test" dup serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ { 1 2 "three" }  ] [
  [ [ { 1 2 "three" }  serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ t ] [
  [ [ { 1 2 "three" }  dup serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ f ] [
  [ [ { 1 2 "three" }  { 1 2 "three" } serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ V{ 1 2 "three" }  ] [
  [ [ V{ 1 2 "three" }  serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ t ] [
  [ [ V{ 1 2 "three" }  dup serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ f ] [
  [ [ V{ 1 2 "three" }  V{ 1 2 "three" } serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ [ \ dup dup ]  ] [
  [ [ [ \ dup dup ]  serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in
] unit-test

[ t ] [
  [ [ [ \ dup dup ]  dup serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ f ] [
  [ [ [ \ dup dup ] [ \ dup dup ] serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

TUPLE: serialize-test a b ;

[ T{ serialize-test f "a" 2 } ] [
  [ [ "a" 2 <serialize-test> serialize ] with-serialized ] string-out
  [ [ deserialize ] with-serialized ] string-in 
] unit-test

[ t ] [
  [ [ "a" 2 <serialize-test> dup serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test

[ f ] [
  [ [ "a" 2 <serialize-test> "a" 2 <serialize-test> serialize serialize ] with-serialized ] string-out
  [ [ deserialize deserialize ] with-serialized ] string-in eq?
] unit-test


