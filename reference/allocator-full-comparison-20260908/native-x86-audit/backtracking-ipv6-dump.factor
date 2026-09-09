USING: parser vocabs.loader ;
<< "compiler.cfg.register-allocation.verifier" require
"compiler.cfg.register-allocation.verifier.rematerialization" require >>
USING: arrays compiler compiler.units compiler.cfg.linearization compiler.cfg.utilities compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.spill-sites
compiler.cfg.value-numbering continuations generic io io.sockets io.sockets.private
kernel namespaces prettyprint prettyprint.config quotations sequences tools.annotations ;
IN: allocator-backtracking-ipv6-probe
backtracking-allocator register-allocator set
t check-allocation? set
f global-value-numbering? set
f length-limit set f nesting-limit set
\ backtracking-allocation-with-registers
[ [ "ORIGINAL IR" print over cfg>insns . ] prepose
  [ "ALLOCATED IR" print cfg get cfg>insns . ] append ] annotate
{ { f f } } [
 dup "flags loop/remat=" write .
 first2 rematerialize-constants? set backtracking-loop-spills? set
 [ ipv6 \ make-sockaddr ?lookup-method 1array compile "PASS" print ]
 [ "FAIL " write . ] recover
] each
