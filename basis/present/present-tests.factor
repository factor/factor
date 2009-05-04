IN: present.tests
USING: tools.test vocabs.hierarchy present math vocabs sequences kernel ;

[ "3" ] [ 3 present ] unit-test
[ "Hi" ] [ "Hi" present ] unit-test
[ "+" ] [ \ + present ] unit-test
[ "kernel" ] [ "kernel" vocab present ] unit-test
[ ] [ all-vocabs-seq [ present ] map drop ] unit-test