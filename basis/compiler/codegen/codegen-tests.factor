USING: compiler.cfg.utilities compiler.codegen compiler.codegen.labels
compiler.constants cpu.architecture kernel make math tools.test ;
IN: compiler.codegen.tests

! useless-branch?
{ t f } [
    { } 0 insns>block { } 1 insns>block useless-branch?
    { } 0 insns>block { } 20 insns>block useless-branch?
] unit-test


[ [ ] with-fixup ] must-not-fail
[ [ \ + %call ] with-fixup ] must-not-fail

[ [ <label> dup define-label dup resolve-label %jump-label ] with-fixup ] must-not-fail
[ [ <label> dup define-label dup resolve-label B{ 0 0 0 0 } % rc-absolute-cell label-fixup ] with-fixup ] must-not-fail

! Error checking
[ [ <label> dup define-label %jump-label ] with-fixup ] must-fail
[ [ <label> dup define-label B{ 0 0 0 0 } % rc-relative label-fixup ] with-fixup ] must-fail
[ [ <label> dup define-label B{ 0 0 0 0 } % rc-absolute-cell label-fixup ] with-fixup ] must-fail
