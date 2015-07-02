
USING: help.markup help.syntax io.sockets ;

IN: io.sockets.icmp

HELP: icmp
{ $class-description
    "Host name specifier for ICMP. "
    "The " { $snippet "host" } " slot holds the host name. "
    "New instances are created by calling " { $link <icmp> } "." }
{ $notes
    "This address specifier can be used with " { $link resolve-host }
    " to obtain a list of IP addresses associated with the host name, "
    "and attempts a connection to each one in turn until one succeeds. "
    "Other network words do not accept this address specifier, and "
    { $link resolve-host } " must be called directly; it is "
    "then up to the application to pick the correct address from the "
    "(possibly several) addresses associated to the host name."
}
{ $examples
    { $code "\"www.apple.com\" <icmp>" }
} ;

HELP: <icmp>
{ $values { "host" "a host name" } { "icmp" icmp } }
{ $description "Creates a new " { $link icmp } " address specifier." } ;

HELP: icmp4
{ $class-description
    "IPv4 address specifier for ICMP. "
    "The " { $snippet "host" } " slot holds the IPv4 address. "
    "New instances are created by calling " { $link <icmp4> } "."
}
{ $notes
    "Most applications do not operate on IPv4 addresses directly, "
    "and instead should use the " { $link icmp }
    " address specifier, or call " { $link resolve-host } "."
}
{ $examples
    { $code "\"127.0.0.1\" <icmp4>" }
} ;

HELP: <icmp4>
{ $values { "host" "an IPv4 address" } { "icmp4" icmp4 } }
{ $description "Creates a new " { $link icmp4 } " address specifier." } ;

HELP: icmp6
{ $class-description
    "IPv6 address specifier for ICMP. "
    "The " { $snippet "host" } " slot holds the IPv6 address. "
    "New instances are created by calling " { $link <icmp6> } "."
}
{ $notes
    "Most applications do not operate on IPv6 addresses directly, "
    "and instead should use the " { $link icmp }
    " address specifier, or call " { $link resolve-host } "."
}
{ $examples
    { $code "\"::1\" <icmp6>" }
} ;

HELP: <icmp6>
{ $values { "host" "an IPv6 address" } { "icmp6" icmp4 } }
{ $description "Creates a new " { $link icmp6 } " address specifier." } ;

ARTICLE: "network-icmp" "ICMP"
"ICMP support is implemented for both IPv4 and IPv6 addresses, using the "
"operating system's host name resolution (via " { $link resolve-host } "):"
{ $subsections
    icmp
    <icmp>
}
"IPv4 addresses, with no host name resolution:"
{ $subsections
    icmp4
    <icmp4>
}
"IPv6 addresses, with no host name resolution:"
{ $subsections
    icmp6
    <icmp6>
} ;

ABOUT: "network-icmp"
