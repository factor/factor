IN: compiler.tree.builder.tests
USING: compiler.tree.builder tools.test sequences kernel
compiler.tree ;

\ build-tree must-infer
\ build-tree-with must-infer
\ build-tree-from-word must-infer

: inline-recursive ( -- ) inline-recursive ; inline recursive

[ t ] [ \ inline-recursive build-tree-from-word [ #recursive? ] any? nip ] unit-test
