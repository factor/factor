! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: literals tools.test yaml ;
IN: yaml.tests

! TODO real conformance tests here

CONSTANT: test-string """--- # Favorite movies
 - Casablanca
 - North by Northwest
 - The Man Who Wasn't There
 - last:
   - foo
   - bar
   - baz
"""
CONSTANT: test-obj {
    "Casablanca"
    "North by Northwest"
    "The Man Who Wasn't There"
    H{ { "last" { "foo" "bar" "baz" } } }
}
CONSTANT: test-represented-string """--- !!seq
- !!str Casablanca
- !!str North by Northwest
- !!str The Man Who Wasn't There
- !!map
  !!str last: !!seq
  - !!str foo
  - !!str bar
  - !!str baz
...
"""

${ test-obj } [ $ test-string yaml> ] unit-test
${ test-represented-string } [ $ test-obj >yaml ] unit-test
${ test-represented-string } [ $ test-represented-string yaml> >yaml ] unit-test

CONSTANT: complex-key H{ { { "4" } "3" } }
CONSTANT: complex-key-represented """--- !!map
? !!seq
- !!str 4
: !!str 3
...
"""

${ complex-key } [ $ complex-key-represented yaml> ] unit-test
