USING: calendar help.markup help.syntax sequences strings
quotations ;
IN: imap

ARTICLE: "imap" "IMAP library"
"The " { $vocab-link "imap" } " vocab implements a large part of the IMAP4rev1 client protocol."
$nl
"IMAP is primarily used for retrieving and managing email and folders on an IMAP server. Note that some IMAP servers, such as " { $snippet "imap.gmail.com" } ", require application-specific passwords."
$nl
"Configuration:"
{ $subsections
    imap-settings
}
"Combinators:"
{ $subsections
    with-imap
    with-imap-settings
}
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
    "\"imap.gmail.com\" \"email_address@gmail.com\" \"password\" [ list-folders ] with-imap"
  }
  { $unchecked-example
    "USING: imap namespaces ;
    \\ imap-settings get-global [
        \"factor\" select-folder drop
        \"ALL\" \"\" search-mails
        \"(BODY[HEADER.FIELDS (SUBJECT)])\" fetch-mails
    ] with-imap-settings 3 head ."
    "{
    \"Subject: [Factor-talk] Wiki Tutorial\"
    \"Subject: Re: [Factor-talk] font-size in listener\"
    \"Subject: Re: [Factor-talk] Indentation width and other style guidelines\"
}"
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
{ $values { "directory" string } { "folders" sequence } }
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
  { $unchecked-example
    "USING: imap ;
    \\ imap-settings get-global [
        \"INBOX\" { \"MESSAGES\" \"UNSEEN\" } status-folder
    ] with-imap-settings"
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

HELP: imap-settings
{ $var-description "A tuple for holding the host, email, and password for an IMAP account. Setting this information as a global variable in your .factor-rc or .factor-boot-rc is recommended." }
{ $examples
    "Run the next example and click the link to edit your boot rc:"
    { $unchecked-example

        "USING: imap tools.scaffold ; "
        "scaffold-factor-boot-rc"
        ""
     }
    "Add the following settings to your bootstrap rc file:"
    { $unchecked-example
        "USING: imap namespaces ;"
        "\"imap.gmail.com\" \"foo@gmail.com\" \"password\" <imap-settings> \\ imap-settings set-global"
        ""
    }
    "Run your boot rc again:"
    { $unchecked-example
        "USING: command-line ;"
        "run-bootstrap-init"
        ""
    }
}
{ $see-also with-imap-settings } ;

HELP: with-imap
{ $values
    { "host" string } { "email" string } { "password" string } { "quot" quotation }
}
{ $description "Logs into the IMAP server with the provided settings. The quotation should contain code to execute once authentication has aloready occurred." } ;

HELP: with-imap-settings
{ $values
    { "imap-settings" imap-settings } { "quot" quotation }
}
{ $description "Logs into the IMAP server with the provided settings. The quotation should contain code to execute once authentication has aloready occurred." } ;

{ with-imap with-imap-settings } related-words
