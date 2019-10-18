USING: inference kernel kernel-internals math test words ;

[ ] [ [ 2 ] t dataflow. ] unit-test
[ ] [ [ 3 + ] t dataflow. ] unit-test
[ ] [ [ drop ] t dataflow. ] unit-test
[ ] [ [ [ sq ] [ abs ] if ] t dataflow. ] unit-test
[ ] [ [ { [ sq ] [ abs ] } dispatch ] t dataflow. ] unit-test
[ ] [ \ unify-values word-def t dataflow. ] unit-test
[ ] [ [ 0 0 / ] t dataflow. ] unit-test
