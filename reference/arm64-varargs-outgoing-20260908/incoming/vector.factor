USING: windows-varargs.incoming alien alien.c-types alien.syntax alien.varargs classes.struct compiler.test kernel locals math math.vectors.simd sequences tools.test accessors ;
IN: windows-varargs.incoming
LIBRARY: windows-incoming
STRUCT: inc-hva { a float-4 } { b float-4 } ;
CALLBACK: double incoming-vector-reader ( int n, ... )
{ 224.0 } [ [| n args |
    args float-4 va-arg :> a
    args inc-hva va-arg :> h
    n a { 1 2 3 4 } [ * ] 2map sum +
    h a>> { 1 2 3 4 } [ * ] 2map sum + h b>> { 1 2 3 4 } [ * ] 2map sum +
    args double va-arg +
] incoming-vector-reader [ 1 incoming_vector ] with-callback ] compiled-unit-test
