! Untimed checked closure plus actual generation capture. Same arguments as
! timing.factor: allocator check 3 on on source-commit.
USING: parser vocabs.loader ;
<< "compiler.cfg.register-allocation.verifier" require
   "compiler.cfg.register-allocation.verifier.rematerialization" require
   "reference/compiler-next-20260909/capture-workload-code.factor" run-file >>
USE: compiler-next.code-capture
begin-code-capture
"reference/allocator-speed-crossarch-20260908/timing.factor" run-file
finish-code-capture
