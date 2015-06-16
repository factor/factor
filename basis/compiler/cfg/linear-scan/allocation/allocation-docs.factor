USING: assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals hashtables help.markup help.syntax
kernel sequences ;
IN: compiler.cfg.linear-scan.allocation

HELP: (allocate-registers)
{ $values { "unhandled-min-heap" "stuff" } }
{ $description "Register allocation works by emptying the unhandled intervals and sync points." } ;

HELP: active-positions
{ $values { "new" live-interval-state } { "assoc" assoc } }
{ $description "Looks at the " { $link active-intervals } " and sets to 0 those registers in 'assoc' that can't be used for allocation." } ;

HELP: allocate-registers
{ $values
  { "intervals/sync-points" sequence }
  { "registers" assoc }
  { "live-intervals'" sequence }
}
{ $description "Performs register allocation of a " { $link sequence } " of live intervals. Each live interval is assigned a physical register and also a spill slot if it needs to be spilled." } ;

HELP: assign-register
{ $values { "new" live-interval-state } { "registers" assoc } }
{ $description "Assigns a processor register to the live interval." } ;

HELP: free-positions
{ $values { "registers" assoc } { "reg-class" } { "avail-registers" assoc } }
{ $description "Creates an alist mapping registers to their desirability for allocation. 'avail-registers' is an alist and not a " { $link hashtable } " because the register allocation order is significant." }
{ $see-also register-status } ;

HELP: handle-sync-point
{ $values
  { "sync-point" sync-point }
  { "active-intervals" assoc }
}
{ $description "Removes from 'active-intervals' all intervals that were spilled at the sync point. Most of the time, all intervals are spilled. But it depends on if the sync point was constructed from a " { $link clobber-insn } " or " { $link hairy-clobber-insn } "." } ;

HELP: spill-at-sync-point
{ $values
  { "sync-point" sync-point }
  { "live-interval" live-interval-state }
  { "?" boolean }
}
{ $description "Maybe spills the live-interval at the given sync point. If the interval was spilled, then " { $link f } " is put on the stack to indicate that the interval isn't live anymore, " { $link t } " otherwise." }
{ $see-also spill-at-sync-point? } ;

HELP: spill-at-sync-point?
{ $values
  { "sync-point" sync-point }
  { "live-interval" live-interval-state }
  { "?" boolean }
}
{ $description "If the live interval has a definition at a keep-dst? sync-point, don't spill." } ;
