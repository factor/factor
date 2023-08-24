USING: help.markup help.syntax io io.backend threads
strings byte-arrays continuations destructors quotations math ;
IN: io.sockets

ARTICLE: "network-addressing" "Address specifiers"
"The networking words are quite general and work with " { $emphasis "address specifiers" } " rather than concrete concepts such as host names. There are four types of address specifiers."
$nl
"Unix domain sockets:"
{ $subsections
    local
    <local>
}
"Internet host name/port number pairs; the host name is resolved to an IPv4 or IPv6 address using the operating system's resolver:"
{ $subsections
    inet
    <inet>
}
"IPv4 addresses, with no host name resolution:"
{ $subsections
    inet4
    <inet4>
}
"IPv6 addresses, with no host name resolution:"
{ $subsections
    inet6
    <inet6>
}
"While the " { $link inet } " addressing specifier is capable of performing name lookups when passed to " { $link <client> } ", sometimes it is necessary to look up a host name without making a connection:"
{ $subsections resolve-host } ;

ARTICLE: "network-connection" "Connection-oriented networking"
"Network connections can be established with this word:"
{ $subsections
    <client>
    with-client
}
"The local address of a client socket can be controlled with this word:"
{ $subsections
    with-local-address
}
"Connection-oriented network servers are implemented by first opening a server socket, then waiting for connections:"
{ $subsections
    <server>
    accept
}
"Server sockets are closed by calling " { $link dispose } "."
$nl
"Address specifiers have the following interpretation with connection-oriented networking words:"
{ $list
    { { $link local } " - Unix domain stream sockets on Unix systems" }
    { { $link inet } " - a TCP/IP connection to a host name/port number pair which can resolve to an IPv4 or IPv6 address" }
    { { $link inet4 } " - a TCP/IP connection to an IPv4 address and port number; no name lookup is performed" }
    { { $link inet6 } " - a TCP/IP connection to an IPv6 address and port number; no name lookup is performed" }
}
"The " { $vocab-link "io.servers" } " library defines high-level wrappers around " { $link <server> } " which makes it easy to listen for IPv4, IPv6 and secure socket connections simultaneously, perform logging, and optionally only allow connections from the loopback interface."
$nl
"The " { $vocab-link "io.sockets.secure" } " vocabulary implements secure, encrypted sockets via SSL and TLS." ;

ARTICLE: "network-packet" "Packet-oriented networking"
"A packet-oriented socket can be opened with this word:"
{ $subsections <datagram> }
"Packets can be sent and received with a pair of words:"
{ $subsections
    send
    receive
}
"Packet-oriented sockets are closed by calling " { $link dispose } "."
$nl
"Address specifiers have the following interpretation with packet-oriented networking words:"
{ $list
    { { $link local } " - Unix domain datagram sockets on Unix systems" }
    { { $link inet4 } " - a TCP/IP connection to an IPv4 address and port number; no name lookup is performed" }
    { { $link inet6 } " - a TCP/IP connection to an IPv6 address and port number; no name lookup is performed" }
}
"The " { $link inet } " address specifier is not supported by the " { $link send } " word because a single host name can resolve to any number of IPv4 or IPv6 addresses, therefore there is no way to know which address should be used. Applications should call " { $link resolve-host } " then use some kind of strategy to pick the correct address (for example, by sending a packet to each one and waiting for a response, or always assuming IPv4)." ;

ARTICLE: "network-examples" "Networking examples"
"Send some bytes to a remote host:"
{ $code
    "USING: io io.encodings.ascii io.sockets strings ;"
    "\"myhost\" 1033 <inet> ascii"
    "[ B{ 12 17 102 } write ] with-client"
}
"Look up the IP addresses associated with a host name:"
{ $code "USING: io.sockets ;" "\"www.apple.com\" 80 <inet> resolve-host ." } ;

ARTICLE: "network-streams" "Networking"
"Factor supports connection-oriented and packet-oriented communication over a variety of protocols:"
{ $list
    "TCP/IP and UDP/IP, over IPv4 and IPv6"
    "Unix domain sockets (Unix only)"
}
{ $subsections
    "network-examples"
    "network-addressing"
    "network-connection"
    "network-packet"
}
{ $vocab-subsection "Secure sockets (SSL, TLS)" "io.sockets.secure" }
{ $see-also "io.pipes" } ;

ABOUT: "network-streams"

HELP: local
{ $class-description "Local address specifier for Unix domain sockets on Unix systems. The " { $snippet "path" } " slot holds the path name of the socket. New instances are created by calling " { $link <local> } "." }
{ $examples
    { $code "\"/tmp/.X11-unix/0\" <local>" }
} ;

HELP: inet
{ $class-description "Host name/port number specifier for TCP/IP and UDP/IP connections. The " { $snippet "host" } " and " { $snippet "port" } " slots hold the host name and port name or number, respectively. New instances are created by calling " { $link <inet> } "." }
{ $notes
    "This address specifier is only supported by " { $link <client> } ", which calls " { $link resolve-host } " to obtain a list of IP addresses associated with the host name, and attempts a connection to each one in turn until one succeeds. Other network words do not accept this address specifier, and " { $link resolve-host } " must be called directly; it is then up to the application to pick the correct address from the (possibly several) addresses associated to the host name."
}
{ $examples
    { $code "\"www.apple.com\" 80 <inet>" }
} ;

HELP: <inet>
{ $values { "host" "a host name" } { "port" "a port number" } { "inet" inet } }
{ $description "Creates a new " { $link inet } " address specifier. If the host is an IPv4 address, an " { $link inet4 } " tuple will be returned; likewise for " { $link inet6 } "." } ;

HELP: inet4
{ $class-description "IPv4 address/port number specifier for TCP/IP and UDP/IP connections. The " { $snippet "host" } " and " { $snippet "port" } " slots hold the IPv4 address and port number, respectively. New instances are created by calling " { $link <inet4> } ". A host of " { $link f } " refers to localhost, and a port of " { $link f } " defers the port choice until later." }
{ $notes "Most applications do not operate on IPv4 addresses directly, and instead should use the " { $link inet } " address specifier, or call " { $link resolve-host } "." }
{ $examples
    { $code "\"127.0.0.1\" 8080 <inet4>" }
} ;

HELP: <inet4>
{ $values { "host" "an IPv4 address" } { "port" "a port number" } { "inet4" inet4 } }
{ $description "Creates a new " { $link inet4 } " address specifier. A value of " { $link f } " as the host refers to localhost, while " { $link f } " as the port defers the port choice until a later time." } ;

HELP: inet6
{ $class-description "IPv6 address/port number specifier for TCP/IP and UDP/IP connections. The " { $snippet "host" } " and " { $snippet "port" } " slots hold the IPv6 address and port number, respectively. New instances are created by calling " { $link <inet6> } ". A host of " { $link f } " refers to localhost, and a port of " { $link f } " defers the port choice until later." }
{ $notes "Most applications do not operate on IPv6 addresses directly, and instead should use the " { $link inet } " address specifier, or call " { $link resolve-host } "." }
{ $examples
    { $code "\"::1\" 8080 <inet6>" }
} ;

HELP: <inet6>
{ $values { "host" "an IPv6 address" } { "port" "a port number" } { "inet6" inet6 } }
{ $description "Creates a new " { $link inet6 } " address specifier. A value of " { $link f } " as the host refers to localhost, while " { $link f } " as the port defers the port choice until a later time." } ;

HELP: <client>
{ $values { "remote" "an address specifier" } { "encoding" "an encoding descriptor" } { "stream" "a bidirectional stream" } { "local" "an address specifier" } }
{ $description "Opens a network connection and outputs a bidirectional stream using the given encoding, together with the local address the socket was bound to." }
{ $errors "Throws an error if the connection cannot be established." }
{ $notes "The " { $link with-client } " word is easier to use in most situations." }
{ $examples
    { $code "\"www.apple.com\" 80 <inet> utf8 <client>" }
} ;

HELP: with-client
{ $values { "remote" "an address specifier" } { "encoding" "an encoding descriptor" } { "quot" quotation } }
{ $description "Opens a network connection and calls the quotation in a new dynamic scope with " { $link input-stream } " and " { $link output-stream } " rebound to the network streams. The local address the socket is connected to is stored in the " { $link local-address } " variable, and the remote address is stored in the " { $link remote-address } " variable." }
{ $errors "Throws an error if the connection cannot be established." }
{ $examples
    { $code
        "T{ inet f \"www.factorcode.org\" 80 } ascii"
        "["
        "    \"GET / HTTP/1.1\\r\\nhost: www.factorcode.org\\r\\n\\r\\n\" write flush"
        "    read-?crlf"
        "] with-client"
    }
} ;

HELP: <server>
{ $values { "addrspec" "an address specifier" } { "encoding" "an encoding descriptor" } { "server" "a handle" } }
{ $description
    "Begins listening for network connections to a local address. Server objects respond to two words:"
    { $list
        { { $link dispose } " - stops listening on the port and frees all associated resources" }
        { { $link accept } " - blocks until there is a connection, and returns a stream of the encoding passed to the constructor" }
    }
}
{ $notes
    "To start a TCP/IP server which listens for connections from any host, use an address specifier returned by the following code, where 1234 is the desired port number:"
    { $code "f 1234 <inet> resolve-host" }
    "To start a server which listens for connections from the loopback interface only, use an address specifier returned by the following code, where 1234 is the desired port number:"
    { $code "\"localhost\" 1234 <inet> resolve-host" }
    "Since " { $link resolve-host } " can return multiple address specifiers, your server code must listen on them all to work properly. The " { $vocab-link "io.servers" } " vocabulary can be used to help with this."
    $nl
    "To start a TCP/IP server which listens for connections on a randomly-assigned port, set the port number in the address specifier to 0, and then read the " { $snippet "addr" } " slot of the server instance to obtain the actual port number it is listening on:"
    { $unchecked-example
        "f 0 <inet4> ascii <server>"
        "[ addr>> . ] [ dispose ] bi"
        "T{ inet4 f \"0.0.0.0\" 58901 }"
    }
}
{ $errors "Throws an error if the address is already in use, or if it if the system forbids access." } ;

HELP: accept
{ $values { "server" "a handle" } { "client" "a bidirectional stream" } { "remote" "an address specifier" } }
{ $description "Waits for a connection to a server socket created by " { $link <server> } ", and outputs a bidirectional stream when the connection has been established. The encoding of this stream is the one that was passed to the server constructor." }
{ $errors "Throws an error if the server socket is closed or otherwise is unavailable." } ;

HELP: <datagram>
{ $values { "addrspec" "an address specifier" } { "datagram" "a handle" } }
{ $description "Creates a datagram socket bound to a local address. Datagram socket objects responds to three words:"
    { $list
        { { $link dispose } " - stops listening on the port and frees all associated resources" }
        { { $link receive } " - waits for a packet" }
        { { $link send } " - sends a packet" }
    }
}
{ $notes
    "To accept UDP/IP packets from any host, use an address specifier where the host name is set to " { $link f } ":"
    { $code "f 1234 <inet4> <datagram>" }
    "To create a datagram socket bound to a randomly-assigned port, set the port number in the address specifier to 0, and then read the " { $snippet "addr" } " slot of the datagram instance to obtain the actual port number it is bound to:"
    { $code "f 0 <inet4> <datagram>" }
    "To accept UDP/IP packets from the loopback interface only, use an address specifier like the following:"
    { $code "\"127.0.0.1\" 1234 <inet4> <datagram>" }
    "Since " { $link resolve-host } " can return multiple address specifiers, your code must create a datagram socket for each one and coordinate packet sending accordingly."
}
{ $errors "Throws an error if the port is already in use, or if the OS forbids access." } ;

HELP: receive
{ $values { "datagram" "a datagram socket" } { "bytes" byte-array } { "addrspec" "an address specifier" } }
{ $description "Waits for an incoming packet on the given datagram socket. Outputs the packet data, as well as the sender's address." }
{ $errors "Throws an error if the packet could not be received." } ;

HELP: send
{ $values { "bytes" byte-array } { "addrspec" "an address specifier" } { "datagram" "a datagram socket" } }
{ $description "Sends a packet to the given address." }
{ $errors "Throws an error if the packet could not be sent." } ;

HELP: send-once
{ $values
    { "bytes" byte-array } { "addrspec" "an address specifier" }
}
{ $examples
    "Send a datagram to localhost, port 7777:"
    { $example "USING: io.sockets prettyprint ;"
        "B{ 1 2 3 } f 7777 <inet4> send-once"
        ""
    }
}
{ $description "Sends a packet one time to the address and closes the sending datagram port." } ;

HELP: broadcast-once
{ $values
    { "bytes" byte-array } { "addrspec" "an address specifier" }
}
{ $examples
    "Send a datagram to localhost, port 7777:"
    { $example "USING: io.sockets prettyprint ;"
        "B{ 1 2 3 } f 7777 <inet4> broadcast-once"
        ""
    }
    "Send a datagram to the broadcast address, port 7777:"
    { $example "USING: io.sockets prettyprint ;"
        "B{ 1 2 3 } \"192.168.88.255\" 7777 <inet4> broadcast-once"
        ""
    }
    "Receive a datagram on port 7777:"
    { $unchecked-example "USING: destructors kernel io.sockets ;"
        "f 7777 <inet4> <datagram> [ receive ] [ dispose ] bi"
        ""
    }
}
{ $description "Broadcasts a packet one time to the address and closes the sending broadcast port." } ;

HELP: with-any-port-local-broadcast
{ $values
    { "quot" quotation }
}
{ $description "Creates a broadcast datagram socket and calls the quotation with this datagram on top of the stack, cleaning up afterwards." } ;

HELP: with-any-port-local-datagram
{ $values
    { "quot" quotation }
}
{ $description "Creates a datagram socket and calls the quotation with this datagram on top of the stack, cleaning up afterwards." } ;


HELP: resolve-host
{ $values { "addrspec" "an address specifier" } { "seq" "a sequence of address specifiers" } }
{ $description "Resolves host names to IP addresses." }
{ $errors "Throws an " { $link addrinfo-error } " if the host name cannot be resolved." }
{ $examples
    { $code
      "\"www.facebook.com\" resolve-host . "
      "{ T{ ipv4 { host \"31.13.64.32\" } } }"
    }
} ;

HELP: with-local-address
{ $values { "addr" "an " { $link inet4 } " or " { $link inet6 } " address specifier" } { "quot" quotation } }
{ $description "Client sockets opened within the scope of the quotation passed to this combinator will have their local address bound to the given address." }
{ $examples
  { "Binds the local address of a newly created client socket within the quotation to 127.0.0.1."
    "This ensures that all traffic originates from the given address (the port is chosen by the TCP stack)." }
  { $code "\"127.0.0.1\" 0 <inet4> [ ] with-local-address" }
  $nl
  { "Binds the local address of a newly created client socket within the quotation to the local address 192.168.0.1 and the local port 23000. "
    "Be aware that you can only have one client socket with the same local address at a time or else an I/O error (\"address already in use\") will be thrown."
  }
  { $code "\"192.168.0.1\" 23000 <inet4> [ ] with-local-address" }
} ;

HELP: protocol-port
{ $values { "protocol" "a protocol string" } { "port" { $maybe integer } } }
{ $description "Outputs the port number associated with a protocol, or " { $link f } " if the protocol is unknown." } ;

HELP: port-protocol
{ $values { "port" integer } { "protocol" { $maybe "a protocol string" } } }
{ $description "Outputs the protocol associated with a port number, or " { $link f } " if the port number is unknown." } ;

{ protocol-port port-protocol } related-words
