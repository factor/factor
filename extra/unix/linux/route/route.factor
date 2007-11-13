
USING: alien.syntax ;

IN: unix.linux.route

C-STRUCT: struct-rtentry
  { "ulong"           "rt_pad1" }
  { "struct-sockaddr" "rt_dst" }
  { "struct-sockaddr" "rt_gateway" }
  { "struct-sockaddr" "rt_genmask" }
  { "ushort"          "rt_flags" }
  { "short"           "rt_pad2" }
  { "ulong"           "rt_pad3" }
  { "uchar"	      "rt_tos" }
  { "uchar"	      "rt_class" }
  { "short"	      "rt_pad4" }
  { "short"	      "rt_metric" }
  { "char*"	      "rt_dev" }
  { "ulong"	      "rt_mtu" }
  { "ulong"	      "rt_window" }
  { "ushort"	      "rt_irtt" } ;

: RTF_UP	 HEX: 0001 ;		! Route usable.
: RTF_GATEWAY	 HEX: 0002 ;		! Destination is a gateway.

: RTF_HOST	 HEX: 0004 ;		! Host entry (net otherwise).
: RTF_REINSTATE	 HEX: 0008 ;		! Reinstate route after timeout.
: RTF_DYNAMIC	 HEX: 0010 ;		! Created dyn. (by redirect).
: RTF_MODIFIED	 HEX: 0020 ;		! Modified dyn. (by redirect).
: RTF_MTU	 HEX: 0040 ;		! Specific MTU for this route.
: RTF_MSS	 RTF_MTU ;		! Compatibility.
: RTF_WINDOW	 HEX: 0080 ;		! Per route window clamping.
: RTF_IRTT	 HEX: 0100 ;		! Initial round trip time.
: RTF_REJECT	 HEX: 0200 ;		! Reject route.
: RTF_STATIC	 HEX: 0400 ;		! Manually injected route.
: RTF_XRESOLVE	 HEX: 0800 ;		! External resolver.
: RTF_NOFORWARD  HEX: 1000 ;		! Forwarding inhibited.
: RTF_THROW	 HEX: 2000 ;		! Go to next class.
: RTF_NOPMTUDISC HEX: 4000 ;		! Do not send packets with DF.
