IN: compiler.graphviz.tests
USING: compiler.graphviz io.files ;

[ t ] [ [ [ 1 ] [ 2 ] if ] render-cfg exists? ] unit-test
[ t ] [ [ [ 1 ] [ 2 ] if ] render-dom exists? ] unit-test
[ t ] [ [ [ 1 ] [ 2 ] if ] render-call-graph exists? ] unit-test
