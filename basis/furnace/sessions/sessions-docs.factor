! Copyright (C) 2008 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string quotations strings ;
IN: furnace.sessions

HELP: <session-cookie>
{ $values
    
     { "cookie" null }
}
{ $description "" } ;

HELP: <session>
{ $values
     { "id" null }
     { "session" null }
}
{ $description "" } ;

HELP: <sessions>
{ $values
     { "responder" null }
     { "responder'" null }
}
{ $description "" } ;

HELP: begin-session
{ $values
    
     { "session" null }
}
{ $description "" } ;

HELP: check-session
{ $values
     { "state/f" null }
     { "state/f" null }
}
{ $description "" } ;

HELP: empty-session
{ $values
    
     { "session" null }
}
{ $description "" } ;

HELP: existing-session
{ $values
     { "path" "a pathname string" } { "session" null }
     { "response" null }
}
{ $description "" } ;

HELP: get-session
{ $values
     { "id" null }
     { "session" null }
}
{ $description "" } ;

HELP: init-session
{ $values
     { "session" null }
}
{ $description "" } ;

HELP: init-session*
{ $values
     { "responder" null }
}
{ $description "" } ;

HELP: put-session-cookie
{ $values
     { "response" null }
     { "response'" null }
}
{ $description "" } ;

HELP: remote-host
{ $values
    
     { "string" string }
}
{ $description "" } ;

HELP: request-session
{ $values
    
     { "session/f" null }
}
{ $description "" } ;

HELP: save-session-after
{ $values
     { "session" null }
}
{ $description "" } ;

HELP: schange
{ $values
     { "key" null } { "quot" quotation }
}
{ $description "" } ;

HELP: session
{ $description "" } ;

HELP: session-changed
{ $description "" } ;

HELP: session-id-key
{ $description "" } ;

HELP: sessions
{ $description "" } ;

HELP: sget
{ $values
     { "key" null }
     { "value" null }
}
{ $description "" } ;

HELP: sset
{ $values
     { "value" null } { "key" null }
}
{ $description "" } ;

HELP: touch-session
{ $values
     { "session" null }
}
{ $description "" } ;

HELP: verify-session
{ $values
     { "session" null }
     { "session" null }
}
{ $description "" } ;

ARTICLE: "furnace.sessions" "Furnace sessions"
{ $vocab-link "furnace.sessions" }
;

ABOUT: "furnace.sessions"
