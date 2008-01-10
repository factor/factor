USING: unicode.normalize kernel tools.test sequences ;

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
