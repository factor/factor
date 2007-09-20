USING: help.markup help.syntax io io.backend threads
strings byte-arrays ;
IN: io.sockets

ARTICLE: "network-addressing" "Address specifiers"
"The networking words are quite general and work with " { $emphasis "address specifiers" } " rather than concrete concepts such as host names. There are four types of address specifiers:"
{ $subsection local }
{ $subsection inet }
{ $subsection inet4 }
{ $subsection inet6 }
"While the " { $link inet } " addressing specifier is capable of performing name lookups when passed to " { $link <client> } ", sometimes it is necessary to look up a host name without making a connection:"
{ $subsection resolve-host } ;

ARTICLE: "network-connection" "Connection-oriented networking"
"Network connections can be established with this word:"
{ $subsection <client> }
"Connection-oriented network servers are implemented by first opening a server socket, then waiting for connections:"
{ $subsection <server> }
{ $subsection accept }
"The stream returned by " { $link accept } " holds the address specifier of the remote client:"
{ $subsection client-stream-addr }
"Server sockets are closed by calling " { $link stream-close } ", but they do not respond to the rest of the stream protocol."
$nl
"Address specifiers have the following interpretation with connection-oriented networking words:"
{ $list
    { { $link local } " - Unix domain stream sockets on Unix systems" }
    { { $link inet } " - a TCP/IP connection to a host name/port number pair which can resolve to an IPv4 or IPv6 address" }
    { { $link inet4 } " - a TCP/IP connection to an IPv4 address and port number; no name lookup is performed" }
    { { $link inet6 } " - a TCP/IP connection to an IPv6 address and port number; no name lookup is performed" }
}
"The " { $vocab-link "io.server" } " library defines a nice high-level wrapper around " { $link <server> } " which makes it easy to listen for IPv4 and IPv6 connections simultaneously, perform logging, and optionally only allow connections from the loopback interface." ;

ARTICLE: "network-packet" "Packet-oriented networking"
"A packet-oriented socket can be opened with this word:"
{ $subsection <datagram> }
"Packets can be sent and received with a pair of words:"
{ $subsection send }
{ $subsection receive }
"Packet-oriented sockets are closed by calling " { $link stream-close } ", but they do not respond to the rest of the stream protocol."
$nl
"Address specifiers have the following interpretation with connection-oriented networking words:"
{ $list
    { { $link local } " - Unix domain datagram sockets on Unix systems" }
    { { $link inet4 } " - a TCP/IP connection to an IPv4 address and port number; no name lookup is performed" }
    { { $link inet6 } " - a TCP/IP connection to an IPv6 address and port number; no name lookup is performed" }
}
"The " { $link inet } " address specifier is not supported by the " { $link send } " word because a single host name can resolve to any number of IPv4 or IPv6 addresses, therefore there is no way to know which address should be used. Applications should call " { $link resolve-host } " then use some kind of strategy to pick the correct address (for example, by sending a packet to each one and waiting for a response, or always assuming IPv4)." ;

ARTICLE: "network-streams" "Networking"
"Factor supports connection-oriented and packet-oriented communication over a variety of protocols:"
{ $list
    "TCP/IP and UDP/IP, over IPv4 and IPv6"
    "Unix domain sockets"
}
{ $subsection "network-addressing" }
{ $subsection "network-connection" }
{ $subsection "network-packet" } ;

ABOUT: "network-streams"

HELP: local
{ $class-description "Local address specifier for Unix domain sockets on Unix systems. The " { $link local-path } " slot holds the path name of the socket. New instances are created by calling " { $link <local> } "." }
{ $examples
    { $code "\"/tmp/.X11-unix/0\" <local>" }
} ;

HELP: inet
{ $class-description "Host name/port number specifier for TCP/IP and UDP/IP connections. The " { $link inet-host } " and " { $link inet-port } " slots hold the host name and port name or number, respectively. New instances are created by calling " { $link <inet> } "." }
{ $notes
    "This address specifier is only supported by " { $link <client> } ", which calls " { $link resolve-host }  " to obtain a list of IP addresses associated with the host name, and attempts a connection to each one in turn until one succeeds. Other network words do not accept this address specifier, and " { $link resolve-host } " must be called directly; it is then up to the application to pick the correct address from the (possibly several) addresses associated to the host name."
}
{ $examples
    { $code "\"www.apple.com\" \"http\" <inet>" }
    { $code "\"localhost\" 8080 <inet>" }
} ;

HELP: inet4
{ $class-description "IPv4 address/port number specifier for TCP/IP and UDP/IP connections. The " { $link inet4-host } " and " { $link inet4-port } " slots hold the IPv4 address and port number, respectively. New instances are created by calling " { $link <inet4> } "." }
{ $notes
"New instances should not be created directly; instead, use " { $link resolve-host } " to look up the address associated to a host name. Also, try to support IPv6 where possible."
}
{ $examples
    { $code "\"127.0.0.1\" 8080 <inet4>" }
} ;

HELP: inet6
{ $class-description "IPv6 address/port number specifier for TCP/IP and UDP/IP connections. The " { $link inet6-host } " and " { $link inet6-port } " slots hold the IPv6 address and port number, respectively. New instances are created by calling " { $link <inet6> } "." }
{ $notes
"New instances should not be created directly; instead, use " { $link resolve-host } " to look up the address associated to a host name." }
{ $examples
    { $code "\"::1\" 8080 <inet6>" }
} ;

HELP: <client>
{ $values { "addrspec" "an address specifier" } { "stream" "a bidirectional stream" } }
{ $description "Opens a network connection and outputs a bidirectional stream." }
{ $errors "Throws an error if the connection cannot be established." }
{ $examples
    { $code "\"www.apple.com\" \"http\" <inet> <client>" }
} ;

HELP: <server>
{ $values  { "addrspec" "an address specifier" } { "server" "a handle" } }
{ $description
    "Begins listening for network connections to a local address. Server objects responds to two words:"
    { $list
        { { $link stream-close } " - stops listening on the port and frees all associated resources" }
        { { $link accept } " - blocks until there is a connection" }
    }
}
{ $notes
    "To start a TCP/IP server which listens for connections from any host, use an address specifier returned by the following code, where 1234 is the desired port number:"
    { $code "f 1234 t resolve-host" }
    "To start a server which listens for connections from the loopback interface only, use an address specifier returned by the following code, where 1234 is the desired port number:"
    { $code "\"localhost\" 1234 t resolve-host" }
    "Since " { $link resolve-host } " can return multiple address specifiers, your server code must listen on them all to work properly. The " { $vocab-link "io.server" } " vocabulary can be used to help with this."
}
{ $errors "Throws an error if the address is already in use, or if it if the system forbids access." } ;

HELP: accept
{ $values { "server" "a handle" } { "client" "a bidirectional stream" } }
{ $description "Waits for a connection to a server socket created by " { $link <server> } ", and outputs a bidirectional stream when the connection has been established."
$nl
"The returned client stream responds to the " { $link client-stream-addr } " word with the address of the incoming connection." }
{ $errors "Throws an error if the server socket is closed or otherwise is unavailable." } ;

HELP: <datagram>
{ $values { "addrspec" "an address specifier" } { "datagram" "a handle" } }
{ $description "Creates a datagram socket bound to a local address. Datagram socket objects responds to three words:"
    { $list
        { { $link stream-close } " - stops listening on the port and frees all associated resources" }
        { { $link receive } " - waits for a packet" }
        { { $link send } " - sends a packet" }
    }
}
{ $notes
    "To accept UDP/IP packets from any host, use an address specifier returned by the following code, where 1234 is the desired port number:"
    { $code "f 1234 t resolve-host" }
    "To accept UDP/IP packets from the loopback interface only, use an address specifier returned by the following code, where 1234 is the desired port number:"
    { $code "\"localhost\" 1234 t resolve-host" }
    "Since " { $link resolve-host } " can return multiple address specifiers, your code must create a datagram socket for each one and co-ordinate packet sending accordingly."
}
{ $errors "Throws an error if the port is already in use, or if the OS forbids access." } ;

HELP: receive
{ $values { "datagram" "a datagram socket" } { "packet" byte-array } { "addrspec" "an address specifier" } }
{ $description "Waits for an incoming packet on the given datagram socket. Outputs the packet data, as well as the sender's address." }
{ $errors "Throws an error if the packet could not be received." } ;

HELP: send
{ $values { "packet" byte-array } { "addrspec" "an address specifier" } { "datagram" "a datagram socket" } }
{ $description "Sends a packet to the given address." }
{ $errors "Throws an error if the packet could not be sent." } ;
