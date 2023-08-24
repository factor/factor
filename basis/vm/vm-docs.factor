USING: help.markup help.syntax math strings ;
IN: vm

HELP: zone
{ $class-description "A struct that defines the memory layout for an allocation zone in the virtual machine. Factor code cannot directly access allocation zones, but the struct is used by the compiler to calculate memory addresses. Its slots are:"
  { $slots
    { "here" { "Memory address to the last allocated byte in the zone. Initially, this slot is equal to " { $snippet "start" } " but each allocation in the zone will increment this pointer." } }
    { "start" { "Memory address to the start of the zone." } }
    { "end" { "Memory address to the end of the zone." } }
  }
} ;

HELP: vm
{ $class-description "A struct that defines the memory layout of the running virtual machine. It is used by the optimizing compiler to calculate field offsets. Its slots are:"
  { $slots
    { "nursery" { "A " { $link zone } " in which all new objects are allocated." } }
  }
} ;

HELP: gc-info
{ $class-description "A struct that defines the sizes of the garbage collection maps for a word. It has the following slots:"
  { $slots
    { "gc-root-count" "Number of gc root bits per callsite." }
    { "derived-root-count" "Number of derived roots per callsite." }
    { "return-address-count" "Number of gc callsites." }
  }
} ;
