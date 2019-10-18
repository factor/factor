USING: kernel math test namespaces crypto crypto-internals ;

[ 6 ] [ 5 T{ bbs f 590695557939 811977232793 } random-bbs-bits* ] unit-test
[ 792723710536787233474130382522 ] [ 100 T{ bbs f 200352954495 846054538649 } [ random-bbs-bits* drop ] 2keep random-bbs-bits* ] unit-test

