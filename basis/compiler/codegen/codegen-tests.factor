USING: compiler.codegen.fixup tools.test cpu.architecture math kernel make
compiler.constants words ;
IN: compiler.codegen.tests

[ ] [ gensym [ ] with-fixup drop ] unit-test
[ ] [ gensym [ \ + %call ] with-fixup drop ] unit-test

[ ] [ gensym [ <label> dup define-label dup resolve-label %jump-label ] with-fixup drop ] unit-test
[ ] [ gensym [ <label> dup define-label dup resolve-label B{ 0 0 0 0 } % rc-absolute-cell label-fixup ] with-fixup drop ] unit-test

! Error checking
[ gensym [ <label> dup define-label %jump-label ] with-fixup ] must-fail
[ gensym [ <label> dup define-label B{ 0 0 0 0 } % rc-relative label-fixup ] with-fixup ] must-fail
[ gensym [ <label> dup define-label B{ 0 0 0 0 } % rc-absolute-cell label-fixup ] with-fixup ] must-fail
