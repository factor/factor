! Copyright (C) 2010 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax kernel math sequences strings ;
IN: bitcoin.client

HELP: bitcoin-server
{ $values
  { "string" string }
}
{ $description
    "Returns the hostname of the json-rpc server for the bitcoin client. "
    "This defaults to 'localhost' or the value of the 'bitcoin-server' "
    "variable."
}
{ $see-also bitcoin-port bitcoin-user bitcoin-password } ;

HELP: bitcoin-port
{ $values
  { "n" number }
}
{ $description
    "Returns the port of the json-rpc server for the bitcoin client. "
    "This defaults to '8332' or the value of the 'bitcoin-port' "
    "variable."
}
{ $see-also bitcoin-server bitcoin-user bitcoin-password } ;

HELP: bitcoin-user
{ $values
  { "string" string }
}
{ $description
    "Returns the username required to authenticate with the json-rpc "
    "server for the bitcoin client. This defaults to empty or the "
    "value of the 'bitcoin-user' variable."
}
{ $see-also bitcoin-port bitcoin-server bitcoin-password } ;

HELP: bitcoin-password
{ $values
  { "string" string }
}
{ $description
    "Returns the password required to authenticate with the json-rpc "
    "server for the bitcoin client. This returns the "
    "value of the 'bitcoin-password' variable."
}
{ $see-also bitcoin-port bitcoin-server bitcoin-user } ;

HELP: get-addresses-by-label
{ $values
  { "label" string }
  { "seq" sequence }
}
{ $description
    "Returns the list of addresses with the given label."
} ;

HELP: get-balance
{ $values
  { "n" number }
}
{ $description
    "Returns the server's available balance."
} ;

HELP: get-block-count
{ $values
  { "n" number }
}
{ $description
    "Returns the number of blocks in the longest block chain."
} ;

HELP: get-block-number
{ $values
  { "n" number }
}
{ $description
    "Returns the block number of the latest block in the longest block chain."
} ;

HELP: get-connection-count
{ $values
  { "n" number }
}
{ $description
    "Returns the number of connections to other nodes."
} ;

HELP: get-difficulty
{ $values
  { "n" number }
}
{ $description
    "Returns the proof-of-work difficulty as a multiple of the minimum "
    "difficulty."
} ;

HELP: get-generate
{ $values
  { "?" boolean }
}
{ $description
    "Returns true if the server is trying to generate bitcoins, false "
    "otherwise."
} ;

HELP: set-generate
{ $values
  { "gen" boolean }
  { "n" number }
}
{ $description
    "If 'gen' is true, the server starts generating bitcoins. If 'gen' is "
    "'false' then the server stops generating bitcoins. 'n' is the number "
    "of CPU's to use while generating. A value of '-1' means use all the "
    "CPU's available."
} ;

HELP: get-info
{ $values
  { "result" assoc }
}
{ $description
    "Returns an assoc containing server information."
} ;

HELP: get-label
{ $values
  { "address" string }
  { "label" string }
}
{ $description
    "Returns the label associated with the given address."
} ;

HELP: set-label
{ $values
  { "address" string }
  { "label" string }
}
{ $description
    "Sets the label associateed with the given address."
} ;

HELP: remove-label
{ $values
  { "address" string }
}
{ $description
    "Removes the label associated with the given address."
} ;

HELP: get-new-address
{ $values
  { "address" string }
}
{ $description
    "Returns a new bitcoin address for receiving payments."
} ;

HELP: get-new-labelled-address
{ $values
  { "label" string }
  { "address" string }
}
{ $description
    "Returns a new bitcoin address for receiving payments. The given "
    "label is associated with the new address."
} ;

HELP: get-received-by-address
{ $values
  { "address" string }
  { "amount" number }
}
{ $description
    "Returns the total amount received by the address in transactions "
    "with at least one confirmation."
} ;

HELP: get-confirmed-received-by-address
{ $values
  { "address" string }
  { "minconf" number }
  { "amount" number }
}
{ $description
    "Returns the total amount received by the address in transactions "
    "with at least 'minconf' confirmations."
} ;

HELP: get-received-by-label
{ $values
  { "label" string }
  { "amount" number }
}
{ $description
    "Returns the total amount received by addresses with 'label' in transactions "
    "with at least one confirmation."
} ;

HELP: get-confirmed-received-by-label
{ $values
  { "label" string }
  { "minconf" number }
  { "amount" number }
}
{ $description
    "Returns the total amount received by the addresses with 'label' in transactions "
    "with at least 'minconf' confirmations."
} ;

HELP: list-received-by-address
{ $values
  { "minconf" number }
  { "include-empty" boolean }
  { "seq" sequence }
}
{ $description
    "Return a sequence containing an assoc of data about the payments an "
    "address has received. 'include-empty' indicates whether addresses that "
    "haven't received any payments should be included. 'minconf' is the "
    "minimum number of confirmations before payments are included."
} ;

HELP: list-received-by-label
{ $values
  { "minconf" number }
  { "include-empty" boolean }
  { "seq" sequence }
}
{ $description
    "Return a sequence containing an assoc of data about the payments that "
    "addresses with the given label have received. 'include-empty' "
    " indicates whether addresses that "
    "haven't received any payments should be included. 'minconf' is the "
    "minimum number of confirmations before payments are included."
} ;

HELP: send-to-address
{ $values
  { "address" string }
  { "amount" number }
  { "?" boolean }
}
{ $description
    "Sends 'amount' from the server's available balance to 'address'. "
    "'amount' is rounded to the nearest 0.01. Returns a boolean indicating "
    "if the call succeeded."
} ;

HELP: stop
{ $description
    "Stops the bitcoin server."
} ;

HELP: list-transactions
{ $values
  { "count" number }
  { "include-generated" boolean }
  { "seq" sequence }
}
{ $description
    "Return's a sequence containing up to 'count' most recent transactions."
    "This requires a patched bitcoin server so may not work with old or unpatched "
    "servers."
} ;
