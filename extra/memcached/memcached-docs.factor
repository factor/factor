! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: help.syntax help.markup io.sockets math memcached
quotations sequences strings ;

IN: memcached

HELP: memcached-server
{ $var-description
    "Holds an " { $link inet } " object with the address of "
    "an Memcached server."
} ;

HELP: with-memcached
{ $values { "quot" quotation } }
{ $description
    "Opens a network connection to the " { $link memcached-server }
    " and runs the specified quotation."
} ;

HELP: m/get
{ $values { "key" string } { "val" string } }
{ $description
    "Gets a single key."
} ;

HELP: m/set
{ $values { "val" string } { "key" string } }
{ $description
    "Sets a single key to a particular value, whether the item "
    "exists or not."
} ;

HELP: m/add
{ $values { "val" string } { "key" string } }
{ $description
    "Adds an item only if the item does not already exist. "
    "If the item already exists, throws an error."
} ;

HELP: m/replace
{ $values { "val" string } { "key" string } }
{ $description
    "Replaces an item only if it already eixsts. "
    "If the item does not exist, throws an error."
} ;

HELP: m/delete
{ $values { "key" string } }
{ $description
    "Deletes an item."
} ;

HELP: m/append
{ $values { "val" string } { "key" string } }
{ $description
    "Appends the value to the specified item."
} ;

HELP: m/prepend
{ $values { "val" string } { "key" string } }
{ $description
    "Prepends the value to the specified item."
} ;

HELP: m/incr
{ $values { "key" string } { "val" string } }
{ $description
    "Increments the value of the specified item by 1."
} ;

HELP: m/incr-val
{ $values { "amt" string } { "key" string } { "val" string } }
{ $description
    "Increments the value of the specified item by the specified amount."
} ;

HELP: m/decr
{ $values { "key" string } { "val" string } }
{ $description
    "Decrements the value of the specified item by 1."
} ;

HELP: m/decr-val
{ $values { "amt" string } { "key" string } { "val" string } }
{ $description
    "Decrements the value of the specified item by the specified amount."
} ;

HELP: m/version
{ $values { "version" string } }
{ $description
    "Retrieves the version of the " { $link memcached-server } "."
} ;

HELP: m/noop
{ $description
    "Used as a keep-alive. Also flushes any outstanding quiet gets."
} ;

HELP: m/stats
{ $values { "stats" sequence } }
{ $description
    "Get various statistics about the " { $link memcached-server } "."
} ;

HELP: m/flush
{ $description
    "Deletes all the items in the cache now."
} ;

HELP: m/flush-later
{ $values { "seconds" integer } }
{ $description
    "Deletes all the items in the cache sometime in the future."
} ;

HELP: m/quit
{ $description
    "Close the connection to the " { $link memcached-server } "."
} ;
