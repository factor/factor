! Tests the dictionary words.

"Checking dictionary words." print

! Just make sure this works.

! OUTPUT          INPUT               WORD
[             ] [ "httpd"         ] [ apropos           ] test-word
[ t           ] [ "ifte"          ] [ worddef compound? ] test-word
[ t           ] [ "dup"           ] [ worddef shuffle?  ] test-word
[ f           ] [ "ifte"          ] [ worddef shuffle?  ] test-word
[ f           ] [ "dup"           ] [ worddef compound? ] test-word

! Test word iternalization.

: gensym-test ( -- ? )
    f 10 [ gensym gensym = and ] times ;

[ f           ] [                 ] [ gensym-test       ] test-word

: intern-test ( 1 2 -- ? )
    [ intern ] 2apply = ;

[ t           ] [ "a" "a"         ] [ intern-test       ] test-word
[ f           ] [ "a" "A"         ] [ intern-test       ] test-word
[ f           ] [ "a" "B"         ] [ intern-test       ] test-word
[ f           ] [ "a" "a"      ] [ <word> swap intern = ] test-word

: worddef>list-test ( -- ? )
    [ dup * ] dup no-name worddef>list cdr cdr = ;

[ t           ] [                 ] [ worddef>list-test ] test-word

: words-test ( -- ? )
    t words [ word? and ] each ;

[ t           ] [                 ] [ words-test        ] test-word
