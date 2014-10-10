! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: fuel.eval io.streams.string math namespaces random.data sequences
tools.test ;
IN: fuel.eval.tests

! Make sure prettyprint doesn't limit output.

{ t } [
    1000 random-string fuel-eval-result set-global
    [ fuel-send-retort ] with-string-writer length 1000 >
] unit-test
