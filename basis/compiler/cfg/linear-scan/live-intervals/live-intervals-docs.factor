USING: compiler.cfg compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.linear-scan.allocation cpu.architecture help.markup
help.syntax kernel math sequences ;
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

HELP: clobber-insn
{ $class-description "Instructions that clobber registers but are allowed to produce outputs in registers. Inputs are in spill slots, except for inputs coalesced with the output, in which case that input will be in a register. Each instruction that is a member of the clobber-insn class requires a " { $link sync-point } "." } ;

HELP: compute-live-intervals
{ $values { "cfg" cfg } { "intervals/sync-points" sequence } }
{ $description "Computes the live intervals and sync points of a cfg." }
{ $notes "The instructions must be numbered." } ;

HELP: (find-use)
{ $values
  { "insn#" integer }
  { "live-interval" live-interval-state }
  { "vreg-use" vreg-use }
} { $description "Finds the last use of the live interval before the instruction point." } ;

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

HELP: hairy-clobber-insn
{ $class-description "Instructions that clobber registers. They receive inputs and produce outputs in spill slots." }
{ $notes "The " { $link ##call-gc } " instruction is not included in the class even though it clobbers registers because it is handled specially." } ;

HELP: insn>sync-point
{ $values { "insn" insn } { "sync-point/f" { $maybe sync-point } } }
{ $description "If the instruction clobbers arbitrary registers, then a sync point for it is emitted. Most instructions don't so then " { $link f } " is returned instead." } ;

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
  { $slots
    { "vreg" { "The vreg this live interval state is bound to." } }
    {
        "reg"
        { "The allocated register, set in the " { $link allocate-registers } " step." }
    }
    {
        "spill-rep"
        { { $link representation } " the vreg will have when it is spilled." }
    }
    {
        "spill-to"
        { { $link spill-slot } " to use for spilling, if it needs to be spilled." }
    }
    {
        "ranges"
        { "Inclusive ranges where the live interval is live. This is because the [start,end] interval can have gaps." }
    }
    {
        "uses"
        { "sequence of insn# numbers which reference insructions that use the register in the live interval." }
    }
  }
}
{ $notes "The " { $slot "uses" } " and " { $slot "ranges" } " will never be empty because then the interval would be unused." } ;

HELP: live-intervals
{ $var-description "Mapping from vreg to " { $link live-interval-state } ". The data is computed in the " { $link cfg>live-intervals } " word." } ;

HELP: record-def
{ $values { "vreg" integer } { "n" integer } { "spill-slot?" boolean } }
{ $description "Records that the 'vreg' is defined at the instruction numbered 'n'." } ;

HELP: record-use
{ $values { "vreg" integer } { "n" integer } { "spill-slot?" boolean } }
{ $description "Records that the virtual register was used at the given instruction point." } ;

HELP: record-temp
{ $values { "vreg" number } { "n" number } }
{ $description "Assigns the interval [n,n] to vreg:s live interval." } ;

HELP: sync-point
{ $class-description "A location where all live registers have to be spilled. For example when garbage collection is run or an alien ffi call is invoked. Figuring out where in the " { $link cfg } " the sync points are is done in the " { $link compute-live-intervals } " step. The tuple has the following slots:"
  { $slots
    { "n" { "Set from an instructions sequence number." } }
    { "keep-dst?" { "Boolean that determines whether registers are spilled around this sync point." } }
  }
}
{ $see-also cfg>sync-points clobber-insn hairy-clobber-insn insn } ;

HELP: to
{ $var-description "An integer representing a sequence number equal to the highest number in the currently processed block." } ;

HELP: uses-vregs*
{ $values { "insn" insn } { "seq" sequence } }
{ $description "Like " { $link uses-vregs } " except it also includes gc-maps base pointers. The point is to make their values available even if the base pointers themselves are never used again." } ;

HELP: vreg-use
{ $class-description "Models a usage at an instruction point in the CFG of a virtual register." } ;

ARTICLE: "compiler.cfg.linear-scan.live-intervals" "Live interval utilities"
"This vocab contains words for managing live intervals. The main word is " { $link compute-live-intervals } " which goes through the " { $link cfg } " and returns a sequence of " { $link live-interval-state } " instances which encodes all liveness information for it."
$nl
"Liveness classes and constructors:"
{ $subsections
  <live-interval>
  live-interval-state
  vreg-use
}
"Recording liveness info:"
{ $subsections
  compute-live-intervals*
  record-def
  record-use
  record-temp
}
"Sync point handling:"
{ $subsections
  cfg>sync-points
  clobber-insn
  hairy-clobber-insn
  insn>sync-point
}
"Dynamic variables:"
{ $subsections
  from
  live-intervals
  to
} ;


ABOUT: "compiler.cfg.linear-scan.live-intervals"
