USING: compiler compiler.units parser system namespaces vocabs.loader ;
<< disable-optimizer "resource:core/system/system.factor" run-file
"resource:basis/compiler/constants/constants.factor" run-file
"cpu.architecture" reload "compiler.cfg.builder.alien.params" reload >>
USE: cpu.ppc
<< ppc.32 \ cpu set-global "cpu.ppc" reload >>
USING: cpu.architecture io.files io.encodings.binary make ;
[ t { { 0 double-rep 1 } } ppc-varargs-indicator ] B{ } make
"/tmp/ppc32-varargs-fp-marker.bin" binary set-file-contents
[ t { { 0 int-rep 3 } } ppc-varargs-indicator ] B{ } make
"/tmp/ppc32-varargs-no-fp-marker.bin" binary set-file-contents
