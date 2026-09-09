! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.verifier namespaces ;
IN: compiler.cfg.register-allocation.verifier.rematerialization

! Both vocabularies are optional. A callback outside checked allocation is
! inert; inside it, original identity and literal semantics are verified.
[ record-value-flow-rematerialization ] rematerialization-observer set-global
