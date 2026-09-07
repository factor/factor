USING: accessors kernel regexp sequences strings tools.test ;
IN: regexp.tests.lookaround

! #2684: assertions inside lookbehind test a boundary, not the index
! of the next character being read backwards.
{ "t" } [ "test" R/ (?<=^)./ first-match >string ] unit-test
{ "ello" } [ "hello" R/ (?<=^h)ello/ first-match >string ] unit-test
{ f } [ "hhello" R/ (?<=^h)ello/ re-contains? ] unit-test
{ t } [ "" R/ (?<=^$)/ matches? ] unit-test
{ 3 3 } [ "foo" R/ (?<=$)/ first-match [ from>> ] [ to>> ] bi ] unit-test
{ t } [ "foo" R/ foo(?<=$)/ matches? ] unit-test
{ "ello" } [ "hello" R/ (?<!^)ello/ first-match >string ] unit-test
{ "a" } [ "x\na" R/ (?<=^)a/m first-match >string ] unit-test
{ "a" } [ "x\na" R/ (?<=^)a/md first-match >string ] unit-test

{ "h" } [ "hello" R/ (?<=\b)./ first-match >string ] unit-test
{ "ello" } [ "hello" R/ (?<=(?<=^)h)ello/ first-match >string ] unit-test
{ "ello" } [ "hello" R/ (?<=(?=hello)h)ello/ first-match >string ] unit-test
{ "t" } [ "test" R/ (?<=(?=test)^)./ first-match >string ] unit-test
{ f } [ "hello" R/ (?<!^h)ello/ re-contains? ] unit-test

! Reversed searches use the same boundary convention, but lookahead
! always scans forward, even when compiled within a reversed matcher.
{ t } [ "hello" R/ ^hello$/r matches? ] unit-test
{ t } [ "" R/ ^$/r matches? ] unit-test
{ t } [ "hello" R/ h(?=ello)ello/r matches? ] unit-test
{ t } [ "hello" R/ (?<=^)hello/r matches? ] unit-test
{ 0 0 } [ "" R/ ^$/r first-match [ from>> ] [ to>> ] bi ] unit-test
{ 3 3 } [ "foo" R/ $/r first-match [ from>> ] [ to>> ] bi ] unit-test
{ 0 0 } [ "foo" R/ ^/r first-match [ from>> ] [ to>> ] bi ] unit-test
{ 0 3 } [ "foo" R/ (?<=^)foo/r first-match [ from>> ] [ to>> ] bi ] unit-test

! Options belong to the lookaround's lexical context, including terms
! nested beneath repetition and explicit local option overrides.
{ "x" } [ "AAx" R/ (?<=a+)x/i first-match >string ] unit-test
{ "x" } [ "\nx" R/ (?<=.)x/s first-match >string ] unit-test
{ "x" } [ "\nx" R/ (?<=.+)x/s first-match >string ] unit-test
{ f } [ "\nx" R/ (?<=(?-s:.))x/s re-contains? ] unit-test
{ f } [ "Ax" R/ (?<=(?-i:a))x/i re-contains? ] unit-test
{ t } [ "test" R/ (?=^test$)test/ matches? ] unit-test
