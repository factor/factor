IN: scratchpad
USE: combinators
USE: compiler
USE: kernel
USE: lists
USE: logic
USE: math
USE: stack
USE: stdio
USE: test
USE: words

"Checking compiler type coercions." print

: >boolean [ "boolean" ] "java.lang.Boolean" jnew ; word must-compile
: >byte [ "byte" ] "java.lang.Byte" jnew ; word must-compile
: >char [ "char" ] "java.lang.Character" jnew ; word must-compile
: >short [ "short" ] "java.lang.Short" jnew ; word must-compile
: >int [ "int" ] "java.lang.Integer" jnew ; word must-compile
: >float [ "float" ] "java.lang.Float" jnew ; word must-compile
: >long [ "long" ] "java.lang.Long" jnew ; word must-compile
: >double [ "double" ] "java.lang.Double" jnew ; word must-compile

"Type coercion checks done." print
