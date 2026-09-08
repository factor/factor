! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.linear-scan compiler.cfg.linear-scan.allocation.state
compiler.cfg.ssa.destruction kernel namespaces ;
IN: compiler.cfg.register-allocation

SYMBOL: register-allocator

! Loading compiler.cfg.register-allocation.verifier installs the optional
! final-machine checker. Default bootstrap does not load that vocabulary.
SYMBOL: allocation-verifier

SINGLETON: linear-scan-allocator

: current-register-allocator ( -- allocator )
    register-allocator get linear-scan-allocator or ;

! The input is still in SSA form. Each allocator owns SSA destruction,
! coalescing, assignment, spill insertion and edge-move resolution.
! The output must be ready for build-stack-frame and code generation.
GENERIC: allocate-cfg ( cfg allocator -- )

! Optional diagnostics for the most recent allocation in the current scope.
! Values are observational only and must not affect allocation decisions.
GENERIC: allocator-statistics ( allocator -- assoc )

M: object allocator-statistics drop H{ } clone ;

M: linear-scan-allocator allocate-cfg
    drop dup destruct-ssa linear-scan ;

: allocate-registers ( cfg -- )
    check-allocation? get [ allocation-verifier get ] [ f ] if
    [ call( cfg -- ) ] [ current-register-allocator allocate-cfg ] if* ;
