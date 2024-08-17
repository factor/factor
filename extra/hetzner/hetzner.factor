! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: assocs assocs.extras formatting http http.client io
io.encodings.string io.encodings.utf8 json kernel namespaces
sequences sequences.generalizations ;

IN: hetzner

SYMBOL: hetzner-access-token

CONSTANT: hetzner-api-v1 "https://api.hetzner.cloud/v1/"

ERROR: hetzner-access-token-required symbol ;

: get-hetzner-token ( -- token/* )
    hetzner-access-token get [
        hetzner-access-token hetzner-access-token-required
    ] unless* ;

: set-hetzner-auth-header ( request -- request )
    get-hetzner-token set-bearer-auth ;

: hetzner-get ( route -- json )
    hetzner-api-v1 prepend <get-request>
    set-hetzner-auth-header http-request nip utf8 decode json> ;

! Actions
: get-hetzner-actions ( -- servers ) "actions" hetzner-get ;
: get-hetzner-action ( action-id -- servers ) "actions/%d" sprintf hetzner-get ;

! Certificates
: get-hetzner-certificates ( -- servers ) "certificates" hetzner-get ;

! Datacenters
: get-hetzner-datacenters ( -- servers ) "datacenters" hetzner-get ;
: get-hetzner-datacenter ( datacenter-id -- servers ) "datacenters/%s" sprintf hetzner-get ;

! Firewalls
: get-hetzner-firewalls ( -- servers ) "firewalls" hetzner-get ;

! Floating IPs
: get-hetzner-floating-ips ( -- servers ) "floating_ips" hetzner-get ;

! Images
: get-hetzner-images ( -- servers ) "images" hetzner-get ;

! ISOs
: get-hetzner-isos ( -- servers ) "isos" hetzner-get ;
: get-hetzner-iso ( iso-id -- servers ) "isos/%d" sprintf hetzner-get ;

! Locations
: get-hetzner-locations ( -- servers ) "locations" hetzner-get ;

! Networks
: get-hetzner-networks ( -- servers ) "networks" hetzner-get ;

! Pricing
: get-hetzner-pricing ( -- servers ) "pricing" hetzner-get ;

! Servers
: get-hetzner-servers ( -- servers ) "servers" hetzner-get ;
: get-hetzner-server-by-id ( id -- servers ) "servers/%d" sprintf hetzner-get ;

: server-type. ( hash -- )
    { "description" "cores" "cpu_type" "memory" "disk" } values-of 5 firstn
    "%s: %d cores %s,  %dGB RAM, %d GB disk" sprintf print ;

: hetzner-servers. ( -- )
    get-hetzner-servers "servers" of [ "server_type" of server-type. ] each ;

! Server Types
: get-hetzner-server-types ( -- servers ) "server_types" hetzner-get ;

! SSH Keys
: get-hetzner-ssh-keys ( -- servers ) "ssh_keys" hetzner-get ;

! Volumes
: get-hetzner-volumes ( -- servers ) "volumes" hetzner-get ;

! Volume Actions
: get-hetzner-volume-actions ( volume-id -- servers ) "volumes/%d/actions" sprintf hetzner-get ;
: get-hetzner-volume-action ( volume-id action-id -- servers ) "volumes/%d/actions/%d" sprintf hetzner-get ;
