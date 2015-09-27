USING: math hashtables accessors kernel words hints
compiler.tree.debugger tools.test ;
IN: hints.tests

! Regression
GENERIC: blahblah ( a b c -- )

M: hashtable blahblah 2nip [ 1 + ] change-count drop ;

HINTS: M\ hashtable blahblah { object fixnum object } { object word object } ;

{ t } [ M\ hashtable blahblah { count>> count<< } inlined? ] unit-test
