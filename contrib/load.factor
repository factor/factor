! Load all contrib libs, compile them, and save a new image.
IN: scratchpad
USING: alien kernel words sequences parser compiler memory ;

! digraph dependencies {
!   // run-file libs in the correct order to avoid repeated run-filing
!   aim -> crypto
!   concurrency -> dlists
!   concurrency -> math
!   cont-responder -> httpd
!   crypto -> math
!   factor -> x11
!   space-invaders -> parser-combinators
!   cont-responder -> parser-combinators
! }

: add-simple-library ( name file -- ) 
    win32? ".dll" ".so" ? append
    win32? "stdcall" "cdecl" ? add-library ;

{ "coroutines" "dlists" "splay-trees" }
[ dup
  "contrib/" swap ".factor" append3 run-file
   words [ try-compile ] each ] each

{ "cairo" "math" "concurrency" "crypto" "aim" "httpd" "units" "sqlite" "win32"
  "x11" ! "factory" has a C component, ick.
  "postgresql" "parser-combinators" "cont-responder" "space-invaders"
} [ "contrib/" swap "/load.factor" append3 run-file ] each

compile-all
