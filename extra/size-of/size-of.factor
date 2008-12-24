
USING: io io.encodings.ascii io.files io.files.temp io.launcher
       locals math.parser sequences sequences.deep
       help.syntax
       easy-help ;

IN: size-of

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Word: size-of

Values:

    HEADERS sequence : List of header files
    TYPE    string : A C type
    n       integer : Size in number of bytes ..

Description:

    Use 'size-of' to find out the size in bytes of a C type. 

    The 'headers' argument is a list of header files to use. You may 
    pass 'f' to only use 'stdio.h'. ..

Example:

    ! Find the size of 'int'

    f "int" size-of .    ..

Example:

    ! Find the size of the 'XAnyEvent' struct from Xlib.h

    { "X11/Xlib.h" } "XAnyEvent" size-of .    ..

;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: size-of ( HEADERS TYPE -- n )

  [let | C-FILE   [ "size-of.c" temp-file ]
         EXE-FILE [ "size-of"   temp-file ]
         INCLUDES [ HEADERS [| FILE | { "#include <" FILE ">" } concat ] map ] |

    {
      "#include <stdio.h>"
      INCLUDES
      "main() { printf( \"%i\" , sizeof( " TYPE " ) ) ; }"
    }

    flatten C-FILE  ascii  set-file-lines

    { "gcc" C-FILE "-o" EXE-FILE } try-process

    EXE-FILE ascii <process-reader> contents string>number ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

