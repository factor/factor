USING: help.markup help.syntax quotations kernel ;
IN: irc.client

HELP: irc-client "IRC Client object"
"blah" ;

HELP: irc-server-listener "Listener for server messages unmanaged by other listeners"
"blah" ;

HELP: irc-channel-listener "Listener for irc channels"
"blah" ;

HELP: irc-nick-listener "Listener for irc users"
"blah" ;

HELP: irc-profile "IRC Client profile object"
"blah" ;

HELP: connect-irc "Connecting to an irc server"
{ $values { "irc-client" "an irc client object" } }
{ $description "Connects and logins " { $link irc-client } " using the settings specified on its " { $link irc-profile } "." } ;

HELP: add-listener "Listening to irc channels/users/etc"
{ $values { "irc-client" "an irc client object" } { "irc-listener" "an irc listener object" } }
{ $description "Registers " { $snippet "irc-listener" } " with " { $snippet "irc-client" } " and starts listening." } ;

HELP: terminate-irc "Terminates an irc client"
{ $values { "irc-client" "an irc client object" } }
{ $description "Terminates all activity by " { $link irc-client } " cleaning up resources and notifying listeners." } ;

ARTICLE: "irc.client" "IRC Client"
"An IRC Client library"
{ $heading "IRC objects:" }
{ $subsection irc-client }
{ $heading "Listener objects:" }
{ $subsection irc-server-listener }
{ $subsection irc-channel-listener }
{ $subsection irc-nick-listener }
{ $heading "Setup objects:" }
{ $subsection irc-profile }
{ $heading "Words:" }
{ $subsection connect-irc }
{ $subsection terminate-irc }
{ $subsection add-listener }
{ $heading "IRC messages" }
"Some of the RFC defined irc messages as objects:"
{ $table
  { { $link irc-message } "base of all irc messages" }
  { { $link logged-in } "logged in to server" }
  { { $link ping } "ping message" }
  { { $link join } "channel join" }
  { { $link part } "channel part" }
  { { $link quit } "quit from irc" }
  { { $link privmsg } "private message (to client or channel)" }
  { { $link kick } "kick from channel" }
  { { $link roomlist } "list of participants in channel" }
  { { $link nick-in-use } "chosen nick is in use by another client" }
  { { $link notice } "notice message" }
  { { $link mode } "mode change" }
  { { $link unhandled } "uninmplemented/unhandled message" }
  }
{ $heading "Special messages" }
"Some special messages that are created by the library and not by the irc server."
{ $table
  { { $link irc-end } " sent when the client isn't running anymore, listeners should stop after this." }
  { { $link irc-disconnected } " sent to notify listeners that connection was lost." }
  { { $link irc-connected } " sent to notify listeners that a connection with the irc server was established." } }

{ $heading "Example:" }
{ $code
  "USING: irc.client concurrency.mailboxes ;"
  "SYMBOL: bot"
  "SYMBOL: mychannel"
  "! Create the profile and client objects"
  "\"irc.freenode.org\" irc-port \"mybot123\" f <irc-profile> <irc-client> bot set"
  "! Connect to the server"
  "bot get connect-irc"
  "! Create a channel listener"
  "\"#mychannel123\" <irc-channel-listener> mychannel set"
  "! Register and start listener (this joins the channel)"
  "bot get mychannel get add-listener"
  "! Send a message to the channel"
  "\"what's up?\" mychannel get out-messages>> mailbox-put"
  "! Read a message from the channel"
  "mychannel get in-messages>> mailbox-get"
}
  ;

ABOUT: "irc.client"