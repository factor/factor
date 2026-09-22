! See https://factorcode.org/license.txt for BSD license.
USING: kernel math ;
IN: tools.coverage.generic-testvocab

GENERIC: coverage-generic ( x -- x )

M: object coverage-generic ;
M: fixnum coverage-generic 1 + ;
