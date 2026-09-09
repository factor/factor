USING: vocabs.loader vocabs.refresh ;
<< refresh-all >>
<< "compiler.cfg.register-allocation.chordal" require >>
<< "/tmp/independent-preference-chordal.factor" run-file >>
USING: io kernel namespaces sequences system tools.test ;
f restartable-tests? set-global
"CHORDAL SOURCE SHA256 07ad63902e97af2aa99e8796832206e735e7d4c78ad31baa9a644c3f1141eb45" print
"/Users/erg/factor.worktrees/compiler-next-verification/basis/compiler/cfg/register-allocation/validation/color-preferences/color-preferences-tests.factor" run-file
test-failures get empty? t assert=
"INDEPENDENT PREFERENCE ORACLE PASS: 240 selectors, 3072 complete maps/exhaustions" print
0 exit
