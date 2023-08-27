! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: classes help.markup help.syntax kernel math ;
IN: memory.pools

HELP: <pool>
{ $values
    { "size" integer } { "class" class }
    { "pool" pool }
}
{ $description "Creates a " { $link pool } " of " { $snippet "size" } " objects of " { $snippet "class" } "." } ;

HELP: POOL:
{ $syntax "POOL: class size" }
{ $description "Creates a " { $link pool } " of " { $snippet "size" } " objects of " { $snippet "class" } ", and associates it with the class using " { $link set-class-pool } "." } ;

HELP: class-pool
{ $values
    { "class" class }
    { "pool" pool }
}
{ $description "Returns the " { $link pool } " associated with " { $snippet "class" } ", or " { $link f } " if no pool is associated." } ;

HELP: free-to-pool
{ $values
    { "object" object }
}
{ $description "Frees an object from the " { $link pool } " it was allocated from. The object must have been allocated by " { $link new-from-pool } "." } ;

HELP: new-from-pool
{ $values
    { "class" class }
    { "object" object }
}
{ $description "Allocates an object from the " { $link pool } " associated with " { $snippet "class" } ". If the pool is exhausted, " { $link f } " is returned." } ;

{ POSTPONE: POOL: class-pool set-class-pool new-from-pool free-to-pool } related-words

HELP: pool
{ $class-description "A " { $snippet "pool" } " contains a fixed-size set of preallocated tuple objects. Once the pool has been allocated, its objects can be allocated with " { $link pool-new } " and freed with " { $link pool-free } " in constant time. A pool can also be associated with its class with the " { $link POSTPONE: POOL: } " syntax or the " { $link set-class-pool } " word, after which the words " { $link new-from-pool } " and " { $link free-to-pool } " can be used with the class name to allocate and free objects." } ;

HELP: pool-free
{ $values
    { "object" object } { "pool" pool }
}
{ $description "Frees an object back into " { $link pool } "." } ;

HELP: pool-size
{ $values
    { "pool" pool }
    { "size" integer }
}
{ $description "Returns the number of unallocated objects inside a " { $link pool } "." } ;

HELP: pool-new
{ $values
    { "pool" pool }
    { "object" object }
}
{ $description "Returns an unallocated object out of a " { $link pool } ". If the pool is exhausted, " { $link f } " is returned." } ;

{ pool <pool> pool-new pool-free pool-size } related-words

HELP: set-class-pool
{ $values
    { "class" class } { "pool" pool }
}
{ $description "Associates a " { $link pool } " with " { $snippet "class" } "." } ;

ARTICLE: "memory.pools" "Pools"
"The " { $vocab-link "memory.pools" } " vocabulary provides " { $link pool } " objects which manage preallocated collections of objects."
{ $subsections
    pool
    POSTPONE: POOL:
    new-from-pool
    free-to-pool
} ;

ABOUT: "memory.pools"
