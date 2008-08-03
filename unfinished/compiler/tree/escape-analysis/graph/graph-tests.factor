IN: compiler.tree.escape-analysis.graph.tests
USING: compiler.tree.escape-analysis.graph tools.test namespaces
accessors ;

<graph> "graph" set

[ ] [ { 2 3 4 } 1 "graph" get add-edges ] unit-test
[ ] [ { 5 6 } 2 "graph" get add-edges ] unit-test
[ ] [ { 7 8 } 9 "graph" get add-edges ] unit-test
[ ] [ { 6 10 } 4 "graph" get add-edges ] unit-test

[ ] [ 3 "graph" get mark-vertex ] unit-test

[ H{ { 1 1 } { 2 2 } { 3 3 } { 4 4 } { 5 5 } { 6 6 } { 10 10 } } ]
[ "graph" get marked>> ] unit-test

[ ] [ { 1 11 } 12 "graph" get add-edges ] unit-test

[ t ] [ 11 "graph" get marked-vertex? ] unit-test
