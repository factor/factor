IN: temporary
USING: tools.browser tools.test help.markup ;

[ t ] [ "resource:core" "kernel" vocab-dir? ] unit-test

[ ] [ { $describe-vocab "scratchpad" } print-content ] unit-test
