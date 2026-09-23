USING: alien.c-types classes.struct kernel system tools.test windows.iphlpapi ;
IN: windows.iphlpapi.tests

! Equal total sizes previously concealed shifted members on x64.
{ t t t } [
    IP_ADAPTER_INFO heap-size cpu x86.32? 648 704 ? =
    "LeaseObtained" IP_ADAPTER_INFO offset-of cpu x86.32? 632 688 ? =
    "LeaseExpires" IP_ADAPTER_INFO offset-of cpu x86.32? 640 696 ? =
] unit-test
