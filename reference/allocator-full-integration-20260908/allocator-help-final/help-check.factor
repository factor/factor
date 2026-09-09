USING: vocabs.loader vocabs.refresh ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh >>
USING: assocs compiler.errors help.lint help.lint.private io kernel namespaces parser sequences system ;
"basis/compiler/cfg/register-allocation/register-allocation-docs.factor" run-file
"basis/compiler/cfg/register-allocation/greedy/greedy-docs.factor" run-file
{ "compiler.cfg.register-allocation" "compiler.cfg.register-allocation.greedy" } help-lint-vocabs
lint-failures get assoc-empty? t assert=
compiler-errors get assoc-empty? t assert=
"ALLOCATOR HELP PASS" print
0 exit
