! Additional untimed diagnostic; original WORK-only captures are retained.
USING: parser vocabs vocabs.loader ;
<< "compiler.cfg.register-allocation.verifier" require
   "compiler.cfg.register-allocation.verifier.rematerialization" require
   "reference/compiler-next-20260909/capture-workload-code.factor" run-file >>
<< "reference/compiler-next-20260909/capture-installed.factor" run-file >>
USING: allocator-runtime-comparison compiler-next.code-capture namespaces sequences ;
begin-code-capture
benchmark-words get-global [ word-id { "math:+" ":fixnum=>+" "allocator-runtime-comparison:base32-work" "allocator-runtime-comparison:integer-pressure-work" "allocator-runtime-comparison:integer-pressure" } member? ] filter captured-targets set
"reference/compiler-next-20260909/capture-timing-flags-body.factor" run-file
"after-outputs" capture-installed
finish-code-capture
