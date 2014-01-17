USING: calendar help.markup help.syntax sequences strings ;
IN: imap

ARTICLE: "imap" "IMAP library"
"The " { $vocab-link "imap" } " vocab implements a large part of the IMAP4rev1 client protocol."
$nl
"Constructing an IMAP session:"
{ $subsections <imap4ssl> }
"IMAP folder management:"
{ $subsections
    list-folders
    select-folder
    create-folder
    delete-folder
    rename-folder
    status-folder
    close-folder
}
"Retrieving mails:"
{ $subsections search-mails fetch-mails }
"Updating and storing mails:"
{ $subsections copy-mails append-mail store-mail }
{ $examples
  { $code
    "USING: imap ; "
    "\"imap-server\" <imap4ssl> [ \"mail@example.com\" \"password\" login drop ] with-stream"
  }
  { $code
    "USING: imap ; "
    "\"imap-server\" <imap4ssl> ["
    "    \"mail@example.com\" \"password\" login drop"
    "    \"factor\" select-folder drop "
    "    \"ALL\" \"\" search-mails"
    "    \"(BODY[HEADER.FIELDS (SUBJECT)])\" fetch-mails"
    "] with-stream 3 head ."
    "{"
    "    \"Subject: [Factor-talk] Wiki Tutorial\\r\\n\\r\\n\""
    "    \"Subject: Re: [Factor-talk] font-size in listener\\r\\n\\r\\n\""
    "    \"Subject: Re: [Factor-talk] Indentation width and other style guidelines\\r\\n\\r\\n\""
    "}"
  }
} ;

HELP: <imap4ssl>
{ $values { "host" string } { "imap4" "a duplex stream" } }
{ $description "Connects to an IMAP server using SSL on port 993." } ;

HELP: login
{ $values { "username" string } { "password" string } { "caps" string } }
{ $description "Authenticates with the IMAP server." } ;

HELP: capabilities
{ $values { "caps" string } }
{ $description "Fetches the advertised extensions of the IMAP server." } ;

HELP: list-folders
{ $values { "directory" string } { "folders" "a sequence" } }
{ $description "Lists all folders in " { $snippet "directory" } ". Folders is a sequence of 3-tuples with the attributes, root and name of each folder matched." } ;

HELP: select-folder
{ $values { "mailbox" string } { "count" "number of mails in the folder" } }
{ $description "Selects which folder to operate on." } ;

HELP: create-folder
{ $values { "mailbox" string } }
{ $description "Creates a new folder." } ;

HELP: delete-folder
{ $values { "mailbox" string } }
{ $description "Deletes a folder." } ;

HELP: rename-folder
{ $values { "old-name" string } { "new-name" string } }
{ $description "Renames a folder." } ;

HELP: status-folder
{ $values
  { "mailbox" string }
  { "keys" "a sequence of attributes" }
  { "assoc" "attribute values" }
}
{ $description "Requests a collection of attributes for the specified folder." }
{ $examples
  { $code
    "USE: imap"
    "\"imap-host\" <imap4ssl> [ "
    "    \"email\" \"pwd\" login drop "
    "    \"INBOX\" { \"MESSAGES\" \"UNSEEN\" } status-folder "
    "] with-stream ."
    "{ { \"MESSAGES\" 67 } { \"UNSEEN\" 18 } }"
  }
} ;

HELP: close-folder
{ $description "Closes the currently selected folder." } ;

HELP: search-mails
{ $values
  { "data-spec" "An IMAP search query" }
  { "str" "Text to search for" }
  { "uids" "UID:s of the matching mails" }
}
{ $description "Searches the currently selected folder for matching mails. See rfc3501 for the syntax to use for " { $snippet "data-spec" } "." } ;

HELP: fetch-mails
{ $values
  { "uids" "A sequence of UID:s" }
  { "data-spec" "IMAP Message part specifier" }
  { "texts" "A sequence of FETCH responses" }
}
{ $description "Fetches message parts for the specified mails. See rfc3501 for the format of " { $snippet "data-spec" } "." } ;

HELP: copy-mails
{ $values
  { "uids" "A sequence of UID:s" }
  { "mailbox" string }
}
{ $description "Copies a set of mails to the specified folder." } ;

HELP: append-mail
{ $values
  { "mailbox" string }
  { "flags" string }
  { "date-time" timestamp }
  { "mail" string }
  { "uid/f" "UID of the mail if the server supports UIDPLUS, f otherwise" }
}
{ $description "Appends a mail to the specified folder." } ;

HELP: store-mail
{ $values
  { "uids" "A sequence of UID:s" }
  { "command" "An IMAP store command" }
  { "flags" "Flags to set or remove" }
  { "mail-flags" "Flags of mails after update" }
}
{ $description "Updates the attributes of a set of mails." } ;
