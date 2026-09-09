USING: parser vocabs.loader ;
<< "compiler.cfg.register-allocation.verifier" require
   "compiler.cfg.register-allocation.verifier.rematerialization" require >>
"reference/allocator-tuning-backtracking-20260909/checked-tests.factor" run-file
