IN: scratchpad
USE: combinators
USE: kernel
USE: test

java? [
    "jvm-compiler/auxiliary" test
    "jvm-compiler/compiler" test
    "jvm-compiler/compiler-types" test
    "jvm-compiler/inference" test
    "jvm-compiler/primitives" test
    "jvm-compiler/tail" test
    "jvm-compiler/types" test
    "jvm-compiler/miscellaneous" test
] when
