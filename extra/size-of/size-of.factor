
USING: kernel namespaces sequences
       io io.files io.launcher bake builder.util
       accessors vars ;

IN: size-of

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: headers

: include-headers ( -- seq )
  headers> [ { "#include <" , ">" } bake to-string ] map ;

: size-of-c-program ( type -- lines )
  {
    "#include <stdio.h>"
    include-headers
    { "main() { printf( \"%i\\n\" , sizeof( " , " ) ) ; }" }
  }
  bake to-strings ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: c-file ( -- path ) "size-of.c" temp-file ;

: exe ( -- path ) "size-of" temp-file ;

: answer ( -- path ) "size-of-answer" temp-file ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: size-of ( type -- n )
  c-file
    [ size-of-c-program [ print ] each ]
  with-file-writer

  { "gcc" c-file "-o" exe } to-strings
  [ "Error compiling generated C program" print ] run-or-bail
  
  <process*>
    { exe } to-strings >>arguments
    answer             >>stdout
  >desc run-process drop

  answer eval-file ;