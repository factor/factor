USING: kernel strings unicode.syntax.backend ; 

VALUE: n>e-table
VALUE: e>n-table

: name>encoding ( string -- encoding )
    n>e-table at ;

: encoding>name ( encoding -- string )
    e>n-table at ;


