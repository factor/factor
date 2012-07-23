source ~/.gdbinit-1
exec-file /usr/bin/mdimport
set args test.factor
br * 0x0000000100001bb0
fb GetMetadataForFile
