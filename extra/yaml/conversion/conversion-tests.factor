! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.smart.syntax kernel literals sequences
tools.test yaml.conversion yaml.ffi ;
IN: yaml.conversion.tests

: resolve-test ( res str -- ) [ f resolve-plain-scalar ] curry unit-test ;
: resolve-tests ( res seq -- ) [
  [ f resolve-plain-scalar ] curry unit-test
] with each ;

array[ YAML_NULL_TAG ] "null" resolve-test
array[ YAML_NULL_TAG ] ""     resolve-test
array[ YAML_STR_TAG ] "\"\""  resolve-test
array[ YAML_BOOL_TAG ] { "true" "True" "false" "FALSE" } resolve-tests
array[ YAML_INT_TAG ] { "0" "0o7" "0x3A" "-19" } resolve-tests
array[ YAML_FLOAT_TAG ] { "0." "-0.0" ".5" "+12e03" "-2E+05" } resolve-tests
array[ YAML_FLOAT_TAG ] { ".inf" "-.Inf" "+.INF" ".NAN" } resolve-tests
array[ YAML_TIMESTAMP_TAG ] {
  "2001-12-15T02:59:43.1Z"
  "2001-12-14t21:59:43.10-05:00"
  "2001-12-14 21:59:43.10 -5"
  "2001-12-15 2:59:43.10"
  "2002-12-14"
  "2001-2-4   \t\t  1:59:43.10  \t\t   -5:00"
} resolve-tests
array[ YAML_STR_TAG ] "<<" resolve-test
array[ YAML_MERGE_TAG ] [ "<<" t resolve-plain-scalar ] unit-test
