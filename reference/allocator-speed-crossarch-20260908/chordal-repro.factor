USING: compiler.cfg.gc-checks.private compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.chordal compiler.cfg.linear-scan.allocation.state
compiler.cfg.checker compiler.cfg.value-numbering kernel namespaces prettyprint ;
chordal-allocator register-allocator set-global
f global-value-numbering? set-global
t check-allocation? set-global
t check-ssa? set-global
\ update-predecessor-phis measure-compilation .
