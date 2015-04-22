USING: compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals help.markup help.syntax ;
IN: compiler.cfg.linear-scan.allocation.spilling

HELP: assign-spill
{ $values { "live-interval" live-interval } }
{ $description "Assigns a spill slot for the live interval." }
{ $see-also assign-spill-slot } ;

HELP: spill-before
{ $values
  { "before" live-interval-state }
  { "before/f" { $link live-interval-state } " or " { $link f } }
}
{ $description "If the interval does not have any usages before the spill location, then it is the second child of an interval that was split. We reload the value and let the resolve pass insert a spill later." } ;

HELP: spill-intersecting-active
{ $values { "new" live-interval-state } { "reg" "register" } }
{ $description "If there is an active interval using 'reg' (there should be at most one) are split and spilled and removed from the inactive set." } ;

HELP: spill-partially-available
{ $values
  { "new" live-interval-state }
  { "pair" "register availability status" }
}
{ $description "A register would be available for part of the new interval's lifetime if all active and inactive intervals using that register were split and spilled." } ;
