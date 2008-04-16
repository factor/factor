
USING: kernel namespaces accessors smtp builder.util builder.common ;

IN: builder.email

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: builder-from
SYMBOL: builder-recipients

: subject-status ( -- str ) status get [ "report" ] [ "error" ] if ;

: subject ( -- str ) { "builder@" host-name* ": " subject-status } to-string ;

: email-report ( -- )
  <email>
    builder-from get       >>from
    builder-recipients get >>to
    subject                >>subject
    "report" file>string   >>body
  send-email ;

