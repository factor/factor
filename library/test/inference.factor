IN: scratchpad
USE: arithmetic
USE: compiler
USE: lists
USE: math
USE: stack
USE: stdio
USE: test

"Checking type inference." print

![ [ [ "java.lang.Number" "java.lang.Number" ] [ "java.lang.Number" ] f f ] ]
![ [ + ] ]
![ balance>typelist ]
!test-word
!
![ [ [ "factor.Cons" ] [ "java.lang.Object" ] f f ] ]
![ [ car ] ]
![ balance>typelist ]
!test-word
!
![ [ [ "factor.Cons" "java.lang.Object" ] f f f ] ]
![ [ rplaca ] ]
![ balance>typelist ]
!test-word
!
![ [ [ "java.lang.Number" "java.lang.Number" ] [ "java.lang.Number" ] f f ] ]
![ [ swap + ] ]
![ balance>typelist ]
!test-word
!
![ [ [ "java.lang.Integer" ] [ "java.lang.Integer" ] f f ] ]
![ [ >fixnum ] ]
![ balance>typelist ]
!test-word
!
![ [ [ "java.lang.Number" ] [ "java.lang.Number" "java.lang.Number" ] f f ] ]
![ [ >rect ] ]
![ balance>typelist ]
!test-word

"Type inference checks done." print
