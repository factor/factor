! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Compatibility vocabulary: base provenance is shared by every allocator.
QUALIFIED: compiler.cfg.register-allocation.ssa.bases
IN: compiler.cfg.register-allocation.chordal.bases

ALIAS: derived-definition? compiler.cfg.register-allocation.ssa.bases:derived-definition?
ALIAS: inconsistent-ssa-derived-pointers compiler.cfg.register-allocation.ssa.bases:inconsistent-ssa-derived-pointers
ALIAS: inconsistent-ssa-derived-pointers? compiler.cfg.register-allocation.ssa.bases:inconsistent-ssa-derived-pointers?
ALIAS: derived-definitions compiler.cfg.register-allocation.ssa.bases:derived-definitions
ALIAS: phi-bases compiler.cfg.register-allocation.ssa.bases:phi-bases
ALIAS: false-base compiler.cfg.register-allocation.ssa.bases:false-base
ALIAS: construct-phi-base compiler.cfg.register-allocation.ssa.bases:construct-phi-base
ALIAS: construct-ssa-bases compiler.cfg.register-allocation.ssa.bases:construct-ssa-bases
ALIAS: compute-ssa-live-sets compiler.cfg.register-allocation.ssa.bases:compute-ssa-live-sets
