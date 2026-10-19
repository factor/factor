/* Scoped checkpoint repair: replace only the complete context restoration
 * 36-byte sequence, including both following stack reloads, in templates/code blocks. */
#include <stddef.h>
#include <stdint.h>
#include <string.h>
static const unsigned char old_sequence[]={
 0xe3,0xf0,0x80,0,0,4, 0xe3,0xc0,0xf0,0,0,4,
 0xe3,0xe0,0xf0,8,0,4, 0xe3,0xf0,0xf0,16,0,0x71,
 0xe3,0x60,0x80,16,0,4, 0xe3,0x70,0x80,24,0,4
};
size_t patch_context_code(void *address,size_t length) {
 unsigned char *p=address;size_t count=0;
 for(size_t i=0;i+sizeof(old_sequence)<=length;i++)if(!memcmp(p+i,old_sequence,sizeof(old_sequence))){
  const unsigned char nops[]={7,0,7,0,7,0};memcpy(p+i+12,nops,6);count++;
 }
 if(count){
  __builtin___clear_cache((char*)p,(char*)p+length);
#ifdef __s390x__
  __asm__ volatile("bcr 15,0":::"memory");
#endif
 }
 return count;
}
