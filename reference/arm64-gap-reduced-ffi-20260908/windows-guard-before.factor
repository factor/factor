USING: kernel tools.test namespaces sequences prettyprint system ;
IN: stack-checker.alien
! Negative control: replace the guard with the previous unchecked behavior.
: check-windows-small-float-varargs ( params -- ) drop ;
"stack-checker.alien" test
"test failures" . test-failures get length dup . 0 = 0 1 ? exit
