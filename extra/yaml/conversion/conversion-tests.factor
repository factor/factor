! Copyright (C) 2014 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel literals sequences tools.test yaml.conversion
yaml.ffi ;
IN: yaml.conversion.tests

: resolve-test ( res str -- ) [ f resolve-plain-scalar ] curry unit-test ;
: resolve-tests ( res seq -- ) [
  [ f resolve-plain-scalar ] curry unit-test
] with each ;

${ YAML_NULL_TAG } "null" resolve-test
${ YAML_NULL_TAG } ""     resolve-test
${ YAML_STR_TAG } "\"\""  resolve-test
${ YAML_BOOL_TAG } { "true" "True" "false" "FALSE" } resolve-tests
${ YAML_INT_TAG } { "0" "0o7" "0x3A" "-19" } resolve-tests
${ YAML_FLOAT_TAG } { "0." "-0.0" ".5" "+12e03" "-2E+05" } resolve-tests
${ YAML_FLOAT_TAG } { ".inf" "-.Inf" "+.INF" ".NAN" } resolve-tests
${ YAML_TIMESTAMP_TAG } {
  "2001-12-15T02:59:43.1Z"
  "2001-12-14t21:59:43.10-05:00"
  "2001-12-14 21:59:43.10 -5"
  "2001-12-15 2:59:43.10"
  "2002-12-14"
  "2001-2-4   \t\t  1:59:43.10  \t\t   -5:00"
} resolve-tests
${ YAML_STR_TAG } "<<" resolve-test
${ YAML_MERGE_TAG } [ "<<" t resolve-plain-scalar ] unit-test
