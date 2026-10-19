/* Control: CPUs without the m88k trait retain frame-top root coordinates. */
#include <assert.h>
#include <stdio.h>
#include "callback-generated.h"
extern unsigned production_visit_default(unsigned *,unsigned,const unsigned char *,unsigned,unsigned *);
int main(void) {
 unsigned frame[48]={0};
 frame[15]=0x10000; frame[16]=0x1000c;
 frame[39]=0xdeadbeef; frame[40]=0xdeadbeef;
 assert(production_visit_default(frame,96,callback_map,sizeof(callback_map),frame+15));
 assert(frame[15]==0x11000 && frame[16]==0x1100c);
 assert(frame[39]==0xdeadbeef && frame[40]==0xdeadbeef);
 puts("default collector coordinate control PASS: frame-top roots preserved without m88k trait");
 return 0;
}
