USING: compiler.cfg.instructions help.markup help.syntax ;
IN: compiler.cfg.linear-scan.live-intervals

HELP: live-intervals
{ $var-description "Mapping from vreg to " { $link live-interval-state } "." } ;

HELP: sync-point
{ $class-description "A location where all registers have to be spilled. It has the following slots:"
  { $table
    { { $slot "n" } { "Set from an instructions sequence number." } }
  }
}
{ $see-also insn } ;

HELP: live-interval-state
{ $class-description "A class encoding the \"liveness\" of a virtual register." } ;

HELP: <live-interval>
{ $values
  { "vreg" "virtual register" }
  { "reg-class" "register class" }
  { "live-interval" live-interval-state }
}
{ $description "Creates a new live interval for a virtual register. Initially the range is empty." } ;
