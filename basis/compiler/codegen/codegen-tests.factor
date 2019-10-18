USING: compiler.codegen compiler.codegen.labels
compiler.codegen.relocation tools.test cpu.architecture math
kernel make compiler.constants words ;
IN: compiler.codegen.tests

[ ] [ [ ] with-fixup drop ] unit-test
[ ] [ [ \ + %call ] with-fixup drop ] unit-test

[ ] [ [ <label> dup define-label dup resolve-label %jump-label ] with-fixup drop ] unit-test
[ ] [ [ <label> dup define-label dup resolve-label B{ 0 0 0 0 } % rc-absolute-cell label-fixup ] with-fixup drop ] unit-test

! Error checking
[ [ <label> dup define-label %jump-label ] with-fixup ] must-fail
[ [ <label> dup define-label B{ 0 0 0 0 } % rc-relative label-fixup ] with-fixup ] must-fail
[ [ <label> dup define-label B{ 0 0 0 0 } % rc-absolute-cell label-fixup ] with-fixup ] must-fail
