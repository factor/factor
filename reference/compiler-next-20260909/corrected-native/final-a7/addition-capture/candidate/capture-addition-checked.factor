! Additional untimed diagnostic; original WORK-only captures are retained.
USING: parser vocabs vocabs.loader ;
<< "compiler.cfg.register-allocation.verifier" require
   "compiler.cfg.register-allocation.verifier.rematerialization" require
   "reference/compiler-next-20260909/capture-workload-code.factor" run-file >>
USING: allocator-runtime-comparison compiler-next.code-capture namespaces sequences ;
begin-code-capture
benchmark-words get-global [ word-id { "math:+" ":fixnum=>+" } member? ] filter captured-targets set
"reference/allocator-speed-crossarch-20260908/timing.factor" run-file
finish-code-capture
