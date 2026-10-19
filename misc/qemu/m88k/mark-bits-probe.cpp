#include "../../../vm/master.hpp"
int main() {
 factor::mark_bits b(4096,0x10000000);
 for(unsigned i=0;i<256;i++) { b.clear_mark_bits(); b.set_marked_p(0x10000000+i*16,16); for(unsigned j=0;j<256;j++) if(b.marked_p(0x10000000+j*16)!=(i==j)) { printf("mark error %u %u\n",i,j);return 1;} }
 for(unsigned start=0;start<256;start++)for(unsigned length=1;length<=32&&start+length<=256;length++) {
  b.clear_mark_bits();b.set_marked_p(0x10000000+start*16,length*16);
  for(unsigned j=0;j<256;j++) {
   unsigned wanted=j;while(wanted<256&&(wanted>=start&&wanted<start+length))wanted++;
   auto got=b.next_unmarked_block_after(0x10000000+j*16);
   if(got!=0x10000000+wanted*16){printf("next-unmarked start=%u len=%u j=%u got=%lx wanted=%x\n",start,length,j,got,0x10000000+wanted*16);return 3;}
   wanted=j;while(wanted<256&&!(wanted>=start&&wanted<start+length))wanted++;
   got=b.next_marked_block_after(0x10000000+j*16);
   if(got!=0x10000000+wanted*16){printf("next-marked start=%u len=%u j=%u got=%lx wanted=%x\n",start,length,j,got,0x10000000+wanted*16);return 4;}
  }
 }
 b.clear_mark_bits(); for(unsigned i=0;i<256;i+=3)b.set_marked_p(0x10000000+i*16,16);
 b.compute_forwarding(); for(unsigned i=0;i<256;i+=3)if(b.forward_block(0x10000000+i*16)!=0x10000000+(i/3)*16)return 2;
 puts("production mark_bits256 boundary+forwarding PASS");
}
