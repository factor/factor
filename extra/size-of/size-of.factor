
USING: kernel namespaces sequences
       io io.files io.launcher io.encodings.ascii
       bake builder.util
       accessors vars
       math.parser ;

IN: size-of

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: headers

: include-headers ( -- seq )
  headers> [ { "#include <" , ">" } bake to-string ] map ;

: size-of-c-program ( type -- lines )
  {
    "#include <stdio.h>"
    include-headers
    { "main() { printf( \"%i\" , sizeof( " , " ) ) ; }" }
  }
  bake to-strings ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: c-file ( -- path ) "size-of.c" temp-file ;

: exe ( -- path ) "size-of" temp-file ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: size-of ( type -- n )
  size-of-c-program c-file ascii set-file-lines

  { "gcc" c-file "-o" exe } to-strings
  [ "Error compiling generated C program" print ] run-or-bail

  exe ascii <process-reader> contents string>number ;