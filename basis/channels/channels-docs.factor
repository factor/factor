! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup kernel ;
IN: channels

HELP: <channel>
{ $values { "channel" channel }
}
{ $description "Create a channel that can be used for communicating between "
"concurrent processes and threads. " { $link to } " and " { $link from }
" can be used to send and receive data to/from the channel respectively. "
"There can be multiple readers and writers on a channel. If there are "
"multiple readers or writers, only one is selected at random to resume."
}
{ $see-also from to } ;

HELP: to
{ $values { "value" object }
          { "channel" channel }
}
{ $description "Sends an object to a channel. The send operation is synchronous."
" It will block the calling thread until there is a receiver waiting "
"for data on the channel. It will return when the receiver has received "
"the data successfully."
}
{ $see-also <channel> from } ;

HELP: from
{ $values { "channel" channel }
          { "value" object }
}
{ $description "Receives an object from a channel. The operation is synchronous."
" It will block the calling thread until there is data in the channel."
}
{ $see-also <channel> to } ;

ARTICLE: "channels" "Channels"
"The " { $vocab-link "channels" } " vocabulary provides a simple abstraction to send and receive objects." $nl
"Opening a channel:"
{ $subsections <channel> }
"Sending a message:"
{ $subsections to }
"Receiving a message:"
{ $subsections from } ;

ABOUT: "channels"
