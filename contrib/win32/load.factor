IN: scratchpad
USING: alien compiler kernel parser sequences words ;

{ { "user" "user32" }
  { "kernel" "kernel32" } }
[ first2 add-simple-library ] each

{ "utils" "types" "kernel32" "user32" }
[ "contrib/win32/" swap ".factor" append3 run-file ] each

"win32" words [ try-compile ] each
