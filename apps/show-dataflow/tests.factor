IN: temporary
USING: show-dataflow math kernel words test kernel-internals ;

[ ] [ [ 2 ] t print-dataflow ] unit-test
[ ] [ [ 3 + ] t print-dataflow ] unit-test
[ ] [ [ drop ] t print-dataflow ] unit-test
[ ] [ [ [ sq ] [ abs ] if ] t print-dataflow ] unit-test
[ ] [ [ { [ sq ] [ abs ] } dispatch ] t print-dataflow ] unit-test
[ ] [ [ 0 0 / ] t print-dataflow ] unit-test
