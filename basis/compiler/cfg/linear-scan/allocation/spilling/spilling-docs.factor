USING: compiler.cfg.linear-scan.live-intervals help.markup help.syntax ;
IN: compiler.cfg.linear-scan.allocation.spilling

HELP: spill-intersecting-active
{ $values { "new" live-interval-state } { "reg" "register" } }
{ $description "If there is an active interval using 'reg' (there should be at most one) are split and spilled and removed from the inactive set." } ;

HELP: spill-partially-available
{ $values { "new" live-interval-state } { "pair" "register availability status" } }
{ $description "A register would be available for part of the new interval's lifetime if all active and inactive intervals using that register were split and spilled." } ;
