USING: calendar help.markup help.syntax ;
IN: rdap

ARTICLE: "rdap" "Registration Data Access Protocol (RDAP)"

The { $vocab-link "rdap" } vocabulary provides an implementation of the
Registration Data Access Protocol used to retrieve information about domain
names, autonomous system numbers, and IP addresses.

Some words for performing RDAP lookups:
{ $subsections
    lookup-asn
    lookup-domain
    lookup-ipv4
    lookup-ipv6
    lookup-entity
}

Some words for performing RDAP searches:
{ $subsections
    search-domains-by-name
    search-domains-by-nameserver
    search-domains-by-nameserver-ip
    search-nameservers-by-name
    search-nameservers-by-ip
    search-entities-by-name
    search-entities-by-handle
}

By default, RDAP lookups are directed to RDAP servers specified by the RDAP
bootstrap files while RDAP searches are directed to { $url
"https://root.rdap.org/" } . To override this behavior and direct to a
particular server you can set the \ rdap-url symbol or using the \
with-rdap word.

The results generated from these lookups and searches are hierarchical RDAP
documents. You can use the \ print-rdap word to render them in a simple
hierarchy of key/value strings.

The RDAP bootstrap files will be cached for the \ duration specified in the \
bootstrap-cache symbol. The RDAP bootstrap files can be removed by using the \
reset-bootstrap word.

;

ABOUT: "rdap"
