USING: digraphs kernel sequences tools.test ;
IN: digraphs.tests

: test-digraph ( -- digraph )
    <digraph>
    { { "one" 1 } { "two" 2 } { "three" 3 } { "four" 4 } { "five" 5 } }
    [ first2 pick add-vertex ] each
    { { "one" "three" } { "one" "four" } { "two" "three" } { "two" "one" } { "three" "four" } }
    [ first2 pick add-edge ] each ;

{ 5 } [ test-digraph topological-sort length ] unit-test
