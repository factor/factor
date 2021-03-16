USING: arrays assocs checksums checksums.wyhash kernel sequences
tools.test ;

{
    { 0x42bc986dc5eec4d3  "" 0 }
    { 0x84508dc903c31551  "a" 1 }
    { 0xbc54887cfc9ecb1   "abc" 2 }
    { 0xadc146444841c430  "message digest" 3 }
    { 0x9a64e42e897195b9  "abcdefghijklmnopqrstuvwxyz" 4 }
    { 0x9199383239c32554  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" 5 }
    { 0x7c1ccf6bba30f5a5  "12345678901234567890123456789012345678901234567890123456789012345678901234567890" 6 }
} [
    first3 [ 1array ] 2dip '[ _ _ <wyhash> checksum-bytes ] unit-test
] each

