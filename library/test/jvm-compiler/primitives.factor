IN: scratchpad
USE: stdio
USE: test

"Checking primitive compilation." print

! jvar-get
"car" must-compile

! jvar-get-static
"version" must-compile

! jnew
"cons" must-compile
"<namespace>" must-compile

! jinvoke with return value
">str" must-compile
"is" must-compile

! jinvoke without return value
"set" must-compile

! jinvoke-static
">rect" must-compile
"+" must-compile

"Primitive compilation checks done." print
