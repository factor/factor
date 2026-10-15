// Real fault in Factor-emitted callee entry; real caller spill; production
// factor_vm::iterate_callstack and call_frame_slot_visitor. The fixture owns
// only the VM fields these iterators read, and does not construct a full VM.
#include "../master.hpp"
#include "../sparc-linux-signal.h"
#include <cassert>
#include <fstream>
#include <iterator>
namespace factor {
void critical_error(const char* message, cell value) {
  fprintf(stderr, "%s: %zx\n", message, value); ::abort();
}
struct entry_fixup {
  static constexpr bool translated_code_block_map = false;
  unsigned* visits;
  code_block* translate_code(code_block* p) { return p; }
  object* fixup_data(object* p) { ++*visits; return (object*)((cell)p + 16); }
};
}
using namespace factor;
static factor_sparc_signal_storage saved_signal;
static cell fake_sp, interrupted_sp, interrupted_o7, fault_pc;
static code_block *caller, *callee;
static factor_vm* model;
static context* stack_context;
static unsigned visits, signals;
static bool zig_bridge;
extern "C" uintptr_t factor_sparc_prepare_signal_bridge(void*,void*,uintptr_t);
static unsigned char altstack[65536];
extern "C" void sparc_entry_gc_signal();
static uint32_t read32(const unsigned char* p) {
  return uint32_t(p[0])<<24 | uint32_t(p[1])<<16 | uint32_t(p[2])<<8 | p[3];
}
static void write32(unsigned char* p, uint32_t n) {
  p[0]=n>>24; p[1]=n>>16; p[2]=n>>8; p[3]=n;
}
static void patch32(unsigned char* p, uint32_t n) {
  write32(p,(read32(p)&~0x3fffffu)|(n>>10));
  write32(p+4,(read32(p+4)&~0x3ffu)|(n&0x3ffu));
}
static void patch(code_block* block, const std::string& path, cell target) {
  std::ifstream file(path, std::ios::binary);
  std::vector<unsigned char> bytes((std::istreambuf_iterator<char>(file)),{});
  assert(bytes.size()==4);
  cell end=read32(bytes.data())&0xffffff;
  unsigned char* literal=(unsigned char*)block->entry_point()+end-(sizeof(cell)==8?24:8);
#if __SIZEOF_POINTER__ == 8
  patch32(literal,target>>32); patch32(literal+12,uint32_t(target));
#else
  patch32(literal,target);
#endif
  __builtin___clear_cache((char*)block->entry_point(),(char*)block+4096);
}
static code_block* load(unsigned char* memory, const std::string& file) {
  auto* block=(code_block*)memory;
  block->header=4096;
  std::ifstream input(file,std::ios::binary);
  std::vector<char> bytes((std::istreambuf_iterator<char>(input)),{});
  assert(!bytes.empty() && bytes.size()<512);
  memcpy((void*)block->entry_point(),bytes.data(),bytes.size());
  gc_info* info=block->block_gc_info();
  info->gc_root_count=info->derived_root_count=info->return_address_count=0;
  return block;
}
extern "C" cell sparc_entry_gc_collect() {
  // Stop before the native outer caller frame; it is a pinned callback boundary.
  cell caller_sp=sparc_frame_predecessor(interrupted_sp);
  if (sparc_frame_return_address(interrupted_sp)!=caller->entry_point()+
      caller->block_gc_info()->return_addresses()[0]) caller_sp=interrupted_sp;
  stack_context->callstack_top=fake_sp;
  stack_context->callstack_bottom=sparc_frame_predecessor(caller_sp);
  slot_visitor<entry_fixup> slots(model,entry_fixup{&visits});
  call_frame_slot_visitor<entry_fixup> frames(&slots);
  entry_fixup no_move{&visits};
  auto trace = [&](cell top, cell size, code_block* owner, cell addr) {
    fprintf(stderr,"frame top=%zx parent=%zx owner=%s offset=%zu\n",top,top+size,owner==caller?"caller":"callee",addr-owner->entry_point());
    frames(top,size,owner,addr);
  };
  model->iterate_callstack(stack_context,trace,no_move);
  // Skip this test's protected poll after restoring the exact interrupted window.
#if __SIZEOF_POINTER__ == 8
  cell* pc=(cell*)(saved_signal.bytes+456);
#else
  cell* pc=(cell*)(saved_signal.bytes+228);
#endif
  assert(pc[0]==fault_pc && pc[1]==fault_pc+4);
  pc[0]+=4; pc[1]+=4;
  return (cell)saved_signal.bytes;
}
static void handler(int, siginfo_t*, void* raw) {
  ++signals;
#if __SIZEOF_POINTER__ == 8
  cell* regs=(cell*)((unsigned char*)raw+128);
  fault_pc=*(cell*)((unsigned char*)raw+264);
#else
  cell* regs=(cell*)((unsigned char*)raw+16);
  fault_pc=*(cell*)((unsigned char*)raw+4);
#endif
  interrupted_sp=regs[14]+SPARC_STACK_BIAS;
  interrupted_o7=regs[15];
  fake_sp=zig_bridge
    ? factor_sparc_prepare_signal_bridge(raw,&saved_signal,(cell)sparc_entry_gc_signal)
    : factor_sparc_prepare_signal(raw,&saved_signal,(cell)sparc_entry_gc_signal);
}
int main(int argc,char** argv) {
  assert(argc==3 || argc==4);
  zig_bridge=argc==4;
  std::string dir=argv[1], order=argv[2];
  unsigned char* memory=(unsigned char*)mmap(nullptr,8192,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  assert(memory!=MAP_FAILED);
  caller=load(memory,dir+"/caller.bin");
  callee=load(memory+4096,dir+"/"+order+".bin");
  assert((read32((unsigned char*)caller->entry_point()) & 0x1fff) ==
         (unsigned(-(JIT_FRAME_SIZE+16)) & 0x1fff));
  assert((read32((unsigned char*)caller->entry_point()+4) & 0x1fff) ==
         JIT_FRAME_SIZE+SPARC_STACK_BIAS);
  std::ifstream offset(dir+"/caller.offset"); cell return_offset; offset>>return_offset;
  gc_info* info=caller->block_gc_info();
  cell root=JIT_FRAME_SIZE/sizeof(cell);
  info->gc_root_count=root+1; info->return_address_count=1;
  info->return_addresses()[0]=return_offset;
  info->gc_info_bitmap()[root/8]=1u<<(root%8);
  patch(caller,dir+"/caller.reloc",callee->entry_point());
  void* guard=mmap(nullptr,4096,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  assert(guard!=MAP_FAILED); patch(callee,dir+"/"+order+".reloc",(cell)guard);
  // Minimal metadata owners, with real production code-heap address lookup.
  model=(factor_vm*)calloc(1,sizeof(factor_vm));
  model->code=(code_heap*)calloc(1,sizeof(code_heap));
  new (&model->code->all_blocks) std::set<cell>();
  model->code->all_blocks.insert((cell)caller); model->code->all_blocks.insert((cell)callee);
  model->code->seg=(segment*)calloc(1,sizeof(segment));
  model->code->seg->start=(cell)memory; model->code->seg->end=(cell)memory+8192;
  model->callbacks=(callback_heap*)calloc(1,sizeof(callback_heap));
  model->callbacks->seg=(segment*)calloc(1,sizeof(segment));
  model->callbacks->seg->end=~cell(0);
  stack_context=(context*)calloc(1,sizeof(context));
  stack_t alternate={}; alternate.ss_sp=altstack; alternate.ss_size=sizeof(altstack);
  assert(sigaltstack(&alternate,nullptr)==0);
  struct sigaction action={}; action.sa_sigaction=handler; action.sa_flags=SA_SIGINFO|SA_ONSTACK;
  sigemptyset(&action.sa_mask); assert(sigaction(SIGSEGV,&action,nullptr)==0);
  cell result=((cell(*)(cell))caller->entry_point())(0x1002);
  assert(signals==1);
  bool after=order.compare(0,6,"before")!=0;
  fprintf(stderr,"visits=%u result=%zx callerSP=%zx interruptedSP=%zx\n",visits,result,fake_sp,interrupted_sp);
  assert(visits==(after?1u:0u)); assert(result==(after?0x1012u:0x1002u));
  printf("SPARC%zu %s-SAVE poll: live caller root %s; fault=%zx o7=%zx window.i7=%zx\n",sizeof(cell)*8,order.c_str(),visits?"forwarded":"MISSED",fault_pc,interrupted_o7,((cell*)saved_signal.bytes)[15]);
}
