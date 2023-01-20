! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel tools.dns ;
IN: tools.dns.public

! Example usage:
! yandex-dns-servers "downloads.factorcode.org" dns-host
! "downloads.factorcode.org" cloudflare-host
! "downloads.factorcode.org" google-host

CONSTANT: google-dns-servers { "8.8.8.8" "8.8.4.4" }
: google-host ( domain -- ) [ google-dns-servers ] dip dns-host ;

CONSTANT: dnsvantage-dns-servers {
    "156.154.70.1"
    "156.154.71.1"
}
: dnsvantage-host ( domain -- ) [ dnsvantage-dns-servers ] dip dns-host ;

CONSTANT: opendns-dns-servers { "208.67.222.222" "208.67.220.220" }
: opendns-host ( domain -- ) [ opendns-dns-servers ] dip dns-host ;

CONSTANT: norton-dns-servers { "198.153.192.1" "198.153.194.1" }
: norton-host ( domain -- ) [ norton-dns-servers ] dip dns-host ;

CONSTANT: verizon-dns-servers {
    "4.2.2.1"
    "4.2.2.2"
    "4.2.2.3"
    "4.2.2.4"
    "4.2.2.5"
    "4.2.2.6"
}
: verizon-host ( domain -- ) [ verizon-dns-servers ] dip dns-host ;

CONSTANT: cloudflare-dns-servers { "1.1.1.1" "1.0.0.1" }
: cloudflare-host ( domain -- ) [ cloudflare-dns-servers ] dip dns-host ;

CONSTANT: quad9-dns-servers { "9.9.9.9" "149.112.112.112" }
CONSTANT: clean-browsing-servers { "185.228.168.9" "185.228.169.9" }
CONSTANT: alternate-dns-servers { "76.76.19.19" "76.223.122.150" }
CONSTANT: adguard-dns-servers { "94.140.14.14" "94.140.15.15" }
CONSTANT: cyberghost-dns-servers { "38.132.106.139" "194.187.251.67" }
CONSTANT: opennic-dns-servers { "192.71.245.208" "94.247.43.254" }
CONSTANT: dns-watch-servers { "84.200.69.80" "84.200.70.40" }
CONSTANT: yandex-dns-servers { "77.88.8.88" "77.88.8.2" }
CONSTANT: neustar-dns-servers { "156.154.70.5" "156.154.71.5" }
CONSTANT: comodo-secure-dns-servers { "8.26.56.26" "8.20.247.20" }
CONSTANT: uncensored-dns-servers { "91.239.100.100" "89.233.43.71" }
CONSTANT: free-dns-servers { "45.33.97.5" "37.235.1.177" }
CONSTANT: verisign-dns-servers { "64.6.64.6" "64.6.65.6" }
CONSTANT: safeserve-dns-servers { "198.54.117.10" "198.54.117.11" }
CONSTANT: safe-dns-servers { "195.46.39.39" "195.46.39.40" }
