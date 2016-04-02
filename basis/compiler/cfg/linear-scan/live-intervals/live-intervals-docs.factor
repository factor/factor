USING: compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation cpu.architecture help.markup help.syntax
kernel math sequences ;
IN: compiler.cfg.linear-scan.live-intervals

HELP: <live-interval>
{ $values
  { "vreg" "virtual register" }
  { "live-interval" live-interval-state }
}
{ $description "Creates a new live interval for a virtual register. Initially the ranges are empty and it has no uses." }
{ $see-also vreg>live-interval } ;

HELP: block-from
{ $values { "bb" basic-block } { "n" integer } }
{ $description "The instruction number immediately preceeding this block." } ;

HELP: cfg>live-intervals
{ $values { "cfg" cfg } { "live-intervals" sequence } }
{ $description "The cfg is traversed in reverse linearization order." } ;

HELP: cfg>sync-points
{ $values { "cfg" cfg } { "sync-points" sequence } }
{ $description "Creates a sequence of all sync points in the cfg." }
{ $see-also sync-point } ;

HELP: compute-live-intervals
{ $values { "cfg" cfg } { "intervals/sync-points" sequence } }
{ $description "Computes the live intervals and sync points of a cfg." }
{ $notes "The instructions must be numbered." } ;

HELP: find-use
{ $values
  { "insn#" integer }
  { "live-interval" live-interval-state }
  { "vreg-use/f" vreg-use }
}
{ $description "Finds the live intervals " { $link vreg-use } " at the given instruction number, if it has one." } ;

HELP: finish-live-interval
{ $values { "live-interval" live-interval-state } }
{ $description "Reverses the 'ranges' and 'uses' of the live-interval since those are computed in the reverse order." } ;

HELP: from
{ $var-description "An integer representing a sequence number one lower than all numbers in the currently processed block." } ;

HELP: intervals-intersect?
{ $values
  { "interval1" live-interval-state }
  { "interval2" live-interval-state }
  { "?" boolean }
}
{ $description "Checks if two live intervals intersect each other." } ;

HELP: last-use?
{ $values { "insn#" integer } { "uses" sequence } { "use/f" $maybe vreg-use } }
{ $description "Maybe gets the last " { $link vreg-use } " of a " { $link live-interval-state } "." } ;

HELP: live-interval-state
{ $class-description "A class encoding the \"liveness\" of a virtual register. It has the following slots:"
  { $table
    { { $slot "vreg" } { "The vreg this live interval state is bound to." } }
    {
        { $slot "reg" }
        { "The allocated register, set in the " { $link allocate-registers } " step." }
    }
    {
        { $slot "spill-rep" }
        { "Representation the vreg will have when it is spilled." }
    }
    {
        { $slot "spill-to" }
        { { $link spill-slot } " to use for spilling, if it needs to be spilled." }
    }
    {
        { $slot "ranges" }
        { "Inclusive ranges where the live interval is live. This is because the [start,end] interval can have gaps." }
    }
    {
        { $slot "uses" } { "sequence of insn# numbers which reference insructions that use the register in the live interval." }
    }
  }
}
{ $notes "The " { $slot "uses" } " and " { $slot "ranges" } " will never be empty because then the interval would be unused." } ;

HELP: live-intervals
{ $var-description "Mapping from vreg to " { $link live-interval-state } "." } ;

HELP: record-def
{ $values { "vreg" integer } { "n" integer } { "spill-slot?" boolean } }
{ $description "Records that the 'vreg' is defined at the instruction numbered 'n'." } ;

HELP: record-temp
{ $values { "vreg" number } { "n" number } }
{ $description "Assigns the interval [n,n] to vreg:s live interval." } ;

HELP: sync-point
{ $class-description "A location where all live registers have to be spilled. For example when garbage collection is run or an alien ffi call is invoked. Figuring out where in the " { $link cfg } " the sync points are is done in the " { $link compute-live-intervals } " step. The tuple has the following slots:"
  { $table
    { { $slot "n" } { "Set from an instructions sequence number." } }
    { { $slot "keep-dst?" } { "Boolean that determines whether registers are spilled around this sync point." } }
  }
}
{ $see-also cfg>sync-points insn } ;

HELP: to
{ $var-description "An integer representing a sequence number equal to the highest number in the currently processed block." } ;

ARTICLE: "compiler.cfg.linear-scan.live-intervals" "Live interval utilities"
"This vocab contains words for managing live intervals. The main word is " { $link compute-live-intervals } " which goes through the " { $link cfg } " and returns a sequence of " { $link live-interval-state } " instances which encodes all liveness information for it."
$nl
"Liveness classes and constructors:"
{ $subsections <live-interval> live-interval-state }
"Recording liveness info:"
{ $subsections record-def record-use record-temp } ;


ABOUT: "compiler.cfg.linear-scan.live-intervals"
