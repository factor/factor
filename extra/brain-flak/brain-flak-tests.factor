! Copyright (C) 2023 Aleksander Sabak.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors brain-flak combinators.short-circuit kernel
    strings tools.test ;
IN: brain-flak.tests


: >brain-flak< ( state -- active inactive total )
  [ active>> ] [ inactive>> ] [ total>> ] tri ;


{ V{ 2 1 3 7 } V{ } 0 }
[ { 2 1 3 7 } <brain-flak> >brain-flak< ] unit-test


{ V{ } V{ } 0 }
[ { } <brain-flak> "" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ } V{ } 0 }
[ { } <brain-flak> b-f""
  >brain-flak< ] unit-test

{ V{ } V{ } 0 }
[ { } <brain-flak> "X" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ } V{ } 0 }
[ { } <brain-flak> b-f"X"
  >brain-flak< ] unit-test

{ V{ } V{ } 1 }
[ { } <brain-flak> "()" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ } V{ } 1 }
[ { } <brain-flak> b-f"()"
  >brain-flak< ] unit-test

{ V{ } V{ } 0 }
[ { } <brain-flak> "[]" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ } V{ } 0 }
[ { } <brain-flak> b-f"[]"
  >brain-flak< ] unit-test

{ V{ } V{ } 0 }
[ { } <brain-flak> "{}" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ } V{ } 0 }
[ { } <brain-flak> b-f"{}"
  >brain-flak< ] unit-test

{ V{ } V{ } 0 }
[ { } <brain-flak> "<>" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ } V{ } 0 }
[ { } <brain-flak> b-f"<>"
  >brain-flak< ] unit-test

{ V{ 1 } V{ } 1 }
[ { } <brain-flak> "(())" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 1 } V{ } 1 }
[ { } <brain-flak> b-f"(())"
  >brain-flak< ] unit-test

{ V{ 1 } V{ } 1 }
[ { } <brain-flak> "((X))" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 1 } V{ } 1 }
[ { } <brain-flak> b-f"((X))"
  >brain-flak< ] unit-test

{ V{ 1 } V{ } 1 }
[ { } <brain-flak> "(X()X)" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 1 } V{ } 1 }
[ { } <brain-flak> b-f"(X()X)"
  >brain-flak< ] unit-test

{ V{ 2 } V{ } 2 }
[ { } <brain-flak> "(()())" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 2 } V{ } 2 }
[ { } <brain-flak> b-f"(()())"
  >brain-flak< ] unit-test

{ V{ 2 2 } V{ } 2 }
[ { } <brain-flak> "((()()))" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 2 2 } V{ } 2 }
[ { } <brain-flak> b-f"((()()))"
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> "([])" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> b-f"([])"
  >brain-flak< ] unit-test

{ V{ 1 2 3 3 } V{ } 3 }
[ { 1 2 3 } <brain-flak> "([])" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 1 2 3 3 } V{ } 3 }
[ { 1 2 3 } <brain-flak> b-f"([])"
  >brain-flak< ] unit-test

{ V{ 1 2 2 3 } V{ } 5 }
[ { 1 2 } <brain-flak> "([])([])" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 1 2 2 3 } V{ } 5 }
[ { 1 2 } <brain-flak> b-f"([])([])"
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> "({})" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> b-f"({})"
  >brain-flak< ] unit-test

{ V{ 1 2 } V{ } 2 }
[ { 1 2 } <brain-flak> "({})" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 1 2 } V{ } 2 }
[ { 1 2 } <brain-flak> b-f"({})"
  >brain-flak< ] unit-test

{ V{ 1 } V{ } 2 }
[ { 1 2 } <brain-flak> "{}" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 1 } V{ } 2 }
[ { 1 2 } <brain-flak> b-f"{}"
  >brain-flak< ] unit-test

{ V{ 0 } V{ 1 2 } 0 }
[ { 1 2 } <brain-flak> "(<>)" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 0 } V{ 1 2 } 0 }
[ { 1 2 } <brain-flak> b-f"(<>)"
  >brain-flak< ] unit-test

{ V{ 1 2 0 } V{ } 0 }
[ { 1 2 } <brain-flak> "(<><>)" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 1 2 0 } V{ } 0 }
[ { 1 2 } <brain-flak> b-f"(<><>)"
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> "([[]])" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> b-f"([[]])"
  >brain-flak< ] unit-test

{ V{ 1 2 -2 } V{ } -2 }
[ { 1 2 } <brain-flak> "([[]])" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 1 2 -2 } V{ } -2 }
[ { 1 2 } <brain-flak> b-f"([[]])"
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> "([()]())" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> b-f"([()]())"
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> "({<>})" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> b-f"({<>})"
  >brain-flak< ] unit-test

{ V{ 4 3 2 1 0 6 } V{ } 6 }
[ { 4 } <brain-flak> "({(({})[()])})" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 4 3 2 1 0 6 } V{ } 6 }
[ { 4 } <brain-flak> b-f"({(({})[()])})"
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> "(<()()()>)" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 0 } V{ } 0 }
[ { } <brain-flak> b-f"(<()()()>)"
  >brain-flak< ] unit-test

{ V{ 1 0 } V{ 1 2 } 0 }
[ { 1 2 } <brain-flak> "(<<>({}())>)" compile-brain-flak call
  >brain-flak< ] unit-test

{ V{ 1 0 } V{ 1 2 } 0 }
[ { 1 2 } <brain-flak> b-f"(<<>({}())>)"
  >brain-flak< ] unit-test


{ V{ 2 1 3 7 } V{ } 0 { 2 1 3 7 } }
[ { 2 1 3 7 } [ dup ] with-brain-flak [ >brain-flak< ] dip ]
unit-test

{ { 55 } }
[ { 10 }
  [ b-f"(<>)(())<>{({}[()])(<>({})<({}{}<>)><>)(<>{}<>)<>}"
    b-f"<>{}" ] with-brain-flak ] unit-test


[ "{" compile-brain-flak ]
[ { [ unclosed-brain-flak-expression? ]
    [ program>> "{" = ]
  } 1&& ] must-fail-with

[ "{>" compile-brain-flak ]
[ { [ mismatched-brain-flak-brackets? ]
    [ program>> "{>" = ]
  } 1&& ] must-fail-with

[ "{}>" compile-brain-flak ]
[ { [ leftover-program-after-compilation? ]
    [ program>> "{}>" = ]
    [ leftover>> >string ">" = ]
  } 1&& ] must-fail-with
