USING: compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation cpu.architecture help.markup help.syntax
math sequences ;
IN: compiler.cfg.linear-scan.live-intervals

HELP: <live-interval>
{ $values
  { "vreg" "virtual register" }
  { "reg-class" "register class" }
  { "live-interval" live-interval-state }
}
{ $description "Creates a new live interval for a virtual register. Initially the range is empty." } ;

HELP: block-from
{ $values { "bb" basic-block } { "n" integer } }
{ $description "The instruction number immediately preceeding this block." } ;

HELP: finish-live-intervals
{ $values { "live-intervals" sequence } }
{ $description "Since live intervals are computed in a backward order, we have to reverse some sequences, and compute the start and end." } ;

HELP: from
{ $var-description "An integer representing a sequence number one lower than all numbers in the currently processed block." } ;

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
    { { $slot "start" } { "Earliest insn# where the interval is live." } }
    { { $slot "end" } { "Latest insn# where the interval is live." } }
    {
        { $slot "ranges" }
        { "Inclusive ranges where the live interval is live. This is because the [start,end] interval can have gaps." }
    }
    {
        { $slot "uses" } { "sequence of references to instructions that use the register in the live interval." }
    }
    {
        { $slot "reg-class" }
        { "Register class of the interval, either "
          { $link int-regs } " or " { $link float-regs } "." }

    }
  }
}
{ $notes "The " { $slot "uses" } " and " { $slot "ranges" } " will never be empty because then the interval would be unused." } ;


HELP: live-intervals
{ $var-description "Mapping from vreg to " { $link live-interval-state } "." } ;

HELP: live-range
{ $class-description "Represents a range in the " { $link cfg } " in which a vreg is live." } ;

HELP: sync-point
{ $class-description "A location where all registers have to be spilled. For example when garbage collection is run or an alien ffi call is invoked. Figuring out where in the " { $link cfg } " the sync points are is done in the " { $link compute-live-intervals } " step. The tuple has the following slots:"
  { $table
    { { $slot "n" } { "Set from an instructions sequence number." } }
  }
}
{ $see-also insn } ;

HELP: sync-points
{ $var-description "Sequence of sync points." } ;

HELP: to
{ $var-description "An integer representing a sequence number equal to the highest number in the currently processed block." } ;

ARTICLE: "compiler.cfg.linear-scan.live-intervals" "Live interval utilities"
"This vocab contains words for managing live intervals."
$nl
"Liveness classes and constructors:"
{ $subsections
  <live-interval>
  <live-range>
  live-interval
  live-range
} ;


ABOUT: "compiler.cfg.linear-scan.live-intervals"
