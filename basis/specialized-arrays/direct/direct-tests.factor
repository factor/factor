IN: specialized-arrays.direct.tests
USING: specialized-arrays.direct.ushort tools.test
specialized-arrays.ushort alien.syntax sequences ;

[ ushort-array{ 0 0 0 } ] [
    3 ALIEN: 123 100 <direct-ushort-array> new-sequence
] unit-test
