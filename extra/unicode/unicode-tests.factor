USING: unicode kernel tools.test words sequences namespaces ;

[ "Hello How Are You? I'M Good" ] [ "hEllo how ARE yOU? I'm good" >title ] unit-test
[ "FUSS" ] [ "Fu\u00DF" >upper ] unit-test
[ "\u03C3\u03C2" ] [ "\u03A3\u03A3" >lower ] unit-test
[ t ] [ "hello how are you?" lower? ] unit-test
[
    "tr" locale set
    [ "i\u0131i \u0131jj" ] [ "i\u0131I\u0307 IJj" >lower ] unit-test
!    [ "I\u307\u0131i Ijj" ] [ "i\u0131I\u0307 IJj" >title ] unit-test
    [ "I\u0307II\u0307 IJJ" ] [ "i\u0131I\u0307 IJj" >upper ] unit-test
    "lt" locale set
    ! Lithuanian casing tests
] with-scope

[ { f f t t f t t f f t } ] [ CHAR: A { 
    blank? letter? LETTER? Letter? digit? 
    printable? alpha? control? uncased? character? 
} [ execute ] curry* map ] unit-test
[ "Nd" ] [ CHAR: 3 category ] unit-test
[ CHAR: ! ] [ UNICHAR: exclamation-mark ] unit-test
[ "ab\u0323\u0302cd" ] [ "ab\u0302" "\u0323cd" string-append ] unit-test

[ "ab\u064b\u034d\u034e\u0347\u0346" ] [ "ab\u0346\u0347\u064b\u034e\u034d" dup reorder ] unit-test
[ "hello" "hello" ] [ "hello" [ nfd ] keep nfkd ] unit-test
[ "\uFB012\u2075\u017F\u0323\u0307" "fi25s\u0323\u0307" ]
[ "\uFB012\u2075\u1E9B\u0323" [ nfd ] keep nfkd ] unit-test

[ "\u1E69" "s\u0323\u0307" ] [ "\u1E69" [ nfc ] keep nfd ] unit-test
[ "\u1E0D\u0307" ] [ "\u1E0B\u0323" nfc ] unit-test

[ 54620 ] [ 4370 4449 4523 jamo>hangul ] unit-test
[ 4370 4449 4523 ] [ 54620 hangul>jamo first3 ] unit-test
[ t ] [ 54620 hangul? ] unit-test
[ f ] [ 0 hangul? ] unit-test
[ "\u1112\u1161\u11ab" ] [ "\ud55c" nfd ] unit-test
[ "\ud55c" ] [ "\u1112\u1161\u11ab" nfc ] unit-test
