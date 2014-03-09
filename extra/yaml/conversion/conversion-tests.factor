! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel literals sequences tools.test yaml.conversion
yaml.ffi ;
IN: yaml.conversion.tests

: resolve-test ( res str -- ) [ resolve-plain-scalar ] curry unit-test ;
: resolve-tests ( res seq -- ) [
  [ resolve-plain-scalar ] curry unit-test
] with each ;

${ YAML_NULL_TAG } "null" resolve-test
${ YAML_NULL_TAG } ""     resolve-test
${ YAML_STR_TAG } "\"\""  resolve-test
${ YAML_BOOL_TAG } { "true" "True" "false" "FALSE" } resolve-tests
${ YAML_INT_TAG } { "0" "0o7" "0x3A" "-19" } resolve-tests
${ YAML_FLOAT_TAG } { "0." "-0.0" ".5" "+12e03" "-2E+05" } resolve-tests
${ YAML_FLOAT_TAG } { ".inf" "-.Inf" "+.INF" ".NAN" } resolve-tests
