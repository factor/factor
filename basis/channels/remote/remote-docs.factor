! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: channels help.markup help.syntax io.servers strings ;
IN: channels.remote

HELP: <remote-channel>
{ $values { "node" "a node object" }
          { "id" "the id of the published channel on the node" }
          { "remote-channel" remote-channel }
}
{ $description "Create a remote channel that acts as a proxy for a "
"channel on another node. The remote node's channel must have been "
"published using " { $link publish } " and the id should be the id "
"returned by " { $link publish }
}
{ $examples
  { $code "\"localhost\" 9000 <node> \"ID123456\" <remote-channel> \"foo\" over to" }
}
{ $see-also publish unpublish } ;

HELP: unpublish
{ $values { "id" string }
}
{ $description "Stop a previously published channel from being "
"accessible by remote nodes."
}
{ $examples
  { $code "<channel> publish unpublish" }
}
{ $see-also <remote-channel> publish } ;

HELP: publish
{ $values { "channel" "a channel object" }
          { "id" string }
}
{ $description "Make a channel accessible via remote Factor nodes. "
"An id is returned that can be used by another node to use "
{ $link to } " and " { $link from } " to access the channel."
}
{ $examples
  { $code "<channel> publish" }
}
{ $see-also <remote-channel> unpublish } ;

ARTICLE: "channels.remote" "Remote Channels"
"Remote channels are channels that can be accessed by other Factor instances. It uses distributed concurrency to serialize and send data between channels."
$nl
"To start a remote node, distributed concurrency must have been started. This can be done using " { $link start-server } "."
$nl
{ $snippet "\"myhost.com\" 9001 start-server" }
$nl
"Once the node is started, channels can be published using " { $link publish }
" to be accessed remotely. " { $link publish } " returns an id which a remote node "
"needs to know to access the channel."
$nl
{ $snippet "<channel> dup [ from . flush ] curry \"test\" spawn drop publish" }
$nl
"Given the id from the snippet above, a remote node can put items in the channel (where 123456 is the id):"
$nl
{ $snippet "\"myhost.com\" 9001 <node> 123456 <remote-channel>\n\"hello\" over to" }
;

ABOUT: "channels.remote"
