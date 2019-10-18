USING: compiler.cfg.linear-scan
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals cpu.architecture help.markup
help.syntax math ;
IN: compiler.cfg.linear-scan.allocation.spilling

HELP: assign-spill
{ $values { "live-interval" live-interval-state } }
{ $description "Assigns a spill slot for the live interval." }
{ $see-also assign-spill-slot } ;

HELP: last-use-rep
{ $values { "live-interval" live-interval-state } { "rep" representation } }
{ $description "Gets the last usage representation for the interval. Used when determining what representation it should have when spilled." }
{ $see-also first-use-rep } ;

HELP: spill-after
{ $values
  { "after" live-interval-state }
  { "after/f" { $maybe live-interval-state } }
}
{ $description "If the interval has no more usages after the spill location, then it is the first child of an interval that was split. We spill the value and let the resolve pass insert a reload later. An interval may be split if it overlaps a " { $link sync-point } "." }
{ $see-also spill-before } ;

HELP: spill-available
{ $values { "new" live-interval-state } { "pair" "2-tuple of score and register" } }
{ $description "A register would become fully available if all active and inactive intervals using it were split and spilled." } ;

HELP: spill-before
{ $values
  { "before" live-interval-state }
  { "before/f" { $link live-interval-state } " or " { $link f } }
}
{ $description "If the interval does not have any usages before the spill location, then it is the second child of an interval that was split. We reload the value and let the resolve pass insert a spill later." }
{ $see-also spill-after } ;

HELP: split-for-spill
{ $values
  { "live-interval" live-interval-state }
  { "n" integer }
  { "before/f" { $maybe live-interval-state } }
  { "after/f" { $maybe live-interval-state } }
} { $description "During register allocation an interval needs to be split so that the 'after' part of it can be placed in a spill slot." } ;

HELP: spill-intersecting
{ $values { "new" live-interval-state } { "reg" "register" } }
{ $description "Split and spill all active and inactive intervals which intersect 'new' and use 'reg'." } ;

HELP: spill-intersecting-active
{ $values { "new" live-interval-state } { "reg" "register" } }
{ $description "If there is an active interval using 'reg' (there should be at most one) are split and spilled and removed from the inactive set." } ;

HELP: spill-intersecting-inactive
{ $values { "new" live-interval-state } { "reg" "register" } }
{ $description "Any inactive intervals using 'reg' are split and spilled and removed from the inactive set." }
{ $see-also inactive-intervals } ;

HELP: spill-partially-available
{ $values
  { "new" live-interval-state }
  { "pair" "register availability status" }
}
{ $description "A register would be available for part of the new interval's lifetime if all active and inactive intervals using that register were split and spilled." } ;

HELP: trim-before-ranges
{ $values { "live-interval" live-interval-state } }
{ $description "Extends the last intervals range to one after the last use point and removes all intervals beyond that." } ;

ARTICLE: "compiler.cfg.linear-scan.allocation.spilling" "Spill slot assignment"
"Words and dynamic variables for assigning spill slots to spilled registers during the " { $link linear-scan } " compiler pass."
$nl
"Splitting live intervals:"
{ $subsections split-for-spill }
"Usage representations:"
{ $subsections first-use-rep last-use-rep } ;

ABOUT: "compiler.cfg.linear-scan.allocation.spilling"
