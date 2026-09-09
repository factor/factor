USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors arrays assocs compiler.cfg compiler.cfg.value-numbering.global
compiler.cfg.value-numbering.global.validation compiler.cfg.register-allocation.verifier
io kernel locals namespaces parser prettyprint sequences system tools.test words ;
IN: compiler.cfg.value-numbering.global
SYMBOL: audit-original-global
SYMBOL: audit-global-calls
<< \ global-value-numbering def>> \ audit-original-global set-global >>
:: global-value-numbering ( graph -- changed? )
    graph audit-original-global get call( cfg -- changed? ) :> changed?
    audit-global-calls get [ graph label>> changed? 2array swap push ] when*
    changed? ;
IN: compiler.cfg.value-numbering.global.validation
V{ } clone audit-global-calls set-global
f restartable-tests? set-global
f silent-tests? set-global
"/Users/erg/factor.worktrees/compiler-gvn-verification/basis/compiler/cfg/value-numbering/global/global-tests.factor" run-file
"/Users/erg/factor.worktrees/compiler-gvn-verification/basis/compiler/cfg/value-numbering/global/validation/validation-tests.factor" run-file
test-failures get empty? t assert=
"GVN AUDIT CALLS " write audit-global-calls get length .
"GVN AUDIT CHANGED " write audit-global-calls get [ second ] count .
audit-global-calls get [ second ] any? t assert=
"GVN INDEPENDENT VALIDATION PASS" print
0 exit
