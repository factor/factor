`ping` sends IPv4 ICMP echo requests. On Linux it uses ICMP datagram
sockets, so it does not need a raw-socket capability when the process's
group is permitted by `/proc/sys/net/ipv4/ping_group_range`. Socket creation
reports the OS error when that policy denies access.

Linux supplies the ICMP reply without an IP header. The Windows and macOS
receive paths retain their existing packet framing. IPv6 echo requests are
not implemented by this vocabulary.
