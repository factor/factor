USING: help.markup help.syntax ;
IN: compiler.cfg.linear-scan.live-intervals

HELP: <live-interval>
{ $values
  { "vreg" "virtual register" }
  { "reg-class" "register class" }
  { "live-interval" live-interval-state }
}
{ $description "Creates a new live interval for a virtual register. Initially the range is empty." } ;
