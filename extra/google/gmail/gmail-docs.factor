! Copyright (C) 2018 Björn Lindqvist.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: google.gmail

ARTICLE: "google.gmail" "GMail Client"
"This vocab implements an api to GMail based on " { $vocab-link "oauth2" } "."
$nl
"To use the vocab, it first needs to be supplied the 'Client ID' and 'Client secret settings' using the " { $link configure-oauth2 } " vord:"
{ $unchecked-example
  "\"client-id\" \"client-secret\" configure-oauth2"
}
"The settings can be found on Google's developer console at " { $url "https://console.developers.google.com" } ". Then the authenticated users labels can be listed using:"
{ $unchecked-example
  "list-labels"
}
"Or to list the first message in the users inbox:"
{ $unchecked-example
  "\"INBOX\" list-messages-by-label \"messages\" of"
  "first \"id\" of { } get-messages"
} ;

ABOUT: "google.gmail"
