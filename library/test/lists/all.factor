USE: combinators
USE: kernel
USE: test

"lists/cons" test
"lists/lists" test
"lists/assoc" test
"lists/destructive" test
"lists/namespaces" test
java? [ "lists/java" test ] when
