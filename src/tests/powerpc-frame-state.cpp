// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
// Standalone native signal-context regression, independent of a Factor image.
// Build with the target's C compiler for src/powerpc-context.c, then link that
// object with this file and powerpc-frame-state{,-invoke}.S using target C++17.
// PPC64 diagnostic controls additionally compile the C bridge with
// -DFACTOR_PPC_FRAME_TEST; production PPC64 retains the baseline bridge.
// Run on PowerPC32, PowerPC64BE and PowerPC64LE. Each trap restores the exact
// original instruction before decoding and resuming it; no instruction shifts.
#define _GNU_SOURCE 1
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <sys/mman.h>
#include <assert.h>
typedef uintptr_t cell;
typedef intptr_t fixnum;
#include "../../vm/powerpc.hpp"
using namespace factor;
namespace factor { void critical_error(const char*,cell) { abort(); } }
extern "C" cell *factor_powerpc_signal_registers(void*);
extern "C" cell *factor_powerpc_signal_pc(void*);
extern "C" cell *factor_powerpc_signal_lr(void*);
extern "C" void ppc_boundary_invoke(void*,cell*);
extern "C" void ppc_pic_boundary_invoke(void*,cell*,cell*);
extern "C" char ppc_pic_boundary_after_call[],pic_start[],pic_branch[],pic_hitload[],pic_hit_end[],pic_miss[],pic_missload[],pic_end[];
extern "C" char unsupported_start[],unsupported_allocated[],unsupported_restored[],unsupported_end[];
extern "C" char ppc_boundary_after_call[],ppc_boundary_return_stub[];
#define DECLARE(name) extern "C" char name##_start[], name##_body[], name##_restored[], name##_end[];
DECLARE(fixture)
DECLARE(quotation)
DECLARE(boundary)
DECLARE(large)
DECLARE(leaf)
DECLARE(getter)
DECLARE(setter)
DECLARE(caller)
DECLARE(collision)
DECLARE(quotation_poll)
DECLARE(leaf_getter)
DECLARE(leaf_setter)
DECLARE(conditional)
extern "C" char conditional_prologue[];
extern "C" char leaf_getter_temporary[],leaf_getter_temporary_restored[],leaf_setter_temporary[],leaf_setter_temporary_restored[];
DECLARE(recursive)
extern "C" char recursive_callload[],recursive_link[],recursive_counterload[];
extern "C" char caller_callload[],caller_link[],caller_lr_restored[];
extern "C" char getter_temporary[],getter_temporary_restored[],setter_temporary[],setter_temporary_restored[];
struct testcase {cell start,body,restored,end,size,temp=0,temp_end=0,prologue=0;};
static cell code_start,code_end,target,initial_sp,frame_size,known_prologue;
static uint32_t original;
static cell expected_lr;
static volatile sig_atomic_t recursive_stage;
static uint32_t recursion_counter, recursive_entry_instruction, recursive_call_instruction;
static cell recursive_call;
static ppc_interrupted_frame_state expected;
static volatile sig_atomic_t hits;
static bool pic_control;
static cell pic_lr_ready;
static bool unsupported_control;
static cell unsupported_allocated_pc,unsupported_restored_pc;
static uint32_t polling;
static void trap(int, siginfo_t*, void* context) {
 cell* pc=factor_powerpc_signal_pc(context);
 if(recursive_stage) {
  if(recursive_stage==1) {
   if(*pc!=recursive_call && *pc!=recursive_call+4) _exit(31);
   ppc_store_instruction(recursive_call,recursive_call_instruction);
   ppc_store_instruction(code_start,0x7fe00008);
   __builtin___clear_cache((char*)code_start,(char*)code_end);
   recursive_stage=2; *pc=recursive_call; return;
  }
  if(*pc!=code_start && *pc!=code_start+4) _exit(32);
  ppc_store_instruction(code_start,recursive_entry_instruction);
  __builtin___clear_cache((char*)code_start,(char*)code_end);
  cell sp=factor_powerpc_signal_registers(context)[1];
  if(sp!=initial_sp-80 || *(cell*)sp-sp!=80) _exit(33);
  if(*factor_powerpc_signal_lr(context)!=code_start+(cell)recursive_link-(cell)recursive_start) _exit(34);
  if(ppc_frame_state(code_start,code_end,code_start,80)!=ppc_pre) _exit(35);
  recursive_stage=0; ++hits; *pc=code_start; return;
 }
 if (*pc!=target && *pc!=target+4) _exit(21);
 ppc_store_instruction(target,original);
 __builtin___clear_cache((char*)target,(char*)target+4);
 ppc_interrupted_frame_state state=ppc_frame_state_from_prologue(code_start,code_end,target,frame_size,known_prologue);
 cell expected_sp=initial_sp-(expected==ppc_temporary_leaf?32:expected==ppc_temporary?frame_size+32:expected==ppc_active?frame_size:0);
 if (unsupported_control && target>=unsupported_allocated_pc && target<unsupported_restored_pc)
  expected_sp=initial_sp-16*sizeof(cell);
 if (state!=expected) _exit(22);
 if (factor_powerpc_signal_registers(context)[1]!=expected_sp) _exit(23);
 if (*factor_powerpc_signal_lr(context)!=expected_lr) _exit(24);
 if (pic_control && *(cell*)expected_sp-expected_sp!=112) _exit(25);
 if (pic_control && target>=pic_lr_ready && factor_powerpc_signal_registers(context)[6]!=expected_lr) _exit(26);
 ++hits;
 *pc=target;
}
int main() {
 // Reading R1, selecting CR1, or naming FPR1 does not change the stack.
 assert(!ppc_instruction_changes_stack(0x38610000)); // addi r3,r1,0
 assert(!ppc_instruction_changes_stack(0x7c262000)); // cmp CR1,r6,r4
 assert(!ppc_instruction_changes_stack(0x80610000)); // lwz r3,0(r1)
 assert(!ppc_instruction_changes_stack(0xc8210000)); // lfd f1,0(r1)
 assert(!ppc_instruction_changes_stack(0xf8610000)); // std r3,0(r1)
 assert(ppc_instruction_changes_stack(0x38210040)); // addi r1,r1,64
 assert(ppc_instruction_changes_stack(0x9421ffc0)); // stwu r1,-64(r1)
 assert(ppc_instruction_changes_stack(0xf821ff81)); // stdu r1,-128(r1)
 testcase cases[]={{(cell)fixture_start,(cell)fixture_body,(cell)fixture_restored,(cell)fixture_end,48},
 {(cell)quotation_start,(cell)quotation_body,(cell)quotation_restored,(cell)quotation_end,80},
 {(cell)boundary_start,(cell)boundary_body,(cell)boundary_restored,(cell)boundary_end,32768},
 {(cell)large_start,(cell)large_body,(cell)large_restored,(cell)large_end,32784},
 {(cell)leaf_start,(cell)leaf_body,(cell)leaf_restored,(cell)leaf_end,0},
 {(cell)getter_start,(cell)getter_body,(cell)getter_restored,(cell)getter_end,80,(cell)getter_temporary,(cell)getter_temporary_restored},
 {(cell)setter_start,(cell)setter_body,(cell)setter_restored,(cell)setter_end,80,(cell)setter_temporary,(cell)setter_temporary_restored},
 {(cell)caller_start,(cell)caller_body,(cell)caller_restored,(cell)caller_end,80},
 {(cell)collision_start,(cell)collision_body,(cell)collision_restored,(cell)collision_end,256},
 {(cell)quotation_poll_start,(cell)quotation_poll_body,(cell)quotation_poll_restored,(cell)quotation_poll_end,128},
 {(cell)leaf_getter_start,(cell)leaf_getter_body,(cell)leaf_getter_restored,(cell)leaf_getter_end,0,(cell)leaf_getter_temporary,(cell)leaf_getter_temporary_restored},
 {(cell)leaf_setter_start,(cell)leaf_setter_body,(cell)leaf_setter_restored,(cell)leaf_setter_end,0,(cell)leaf_setter_temporary,(cell)leaf_setter_temporary_restored},
 {(cell)conditional_start,(cell)conditional_body,(cell)conditional_restored,(cell)conditional_end,128,0,0,(cell)conditional_prologue}};
 stack_t stack{};stack.ss_sp=malloc(1024*1024);stack.ss_size=1024*1024;assert(stack.ss_sp);assert(sigaltstack(&stack,nullptr)==0);
 struct sigaction action{};action.sa_sigaction=trap;action.sa_flags=SA_SIGINFO|SA_ONSTACK;sigemptyset(&action.sa_mask);assert(sigaction(SIGTRAP,&action,nullptr)==0);
 size_t total=0;
 for(auto c:cases) {
  size_t length=c.end-c.start;
  void* mem=mmap(nullptr,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);assert(mem!=MAP_FAILED);
  code_start=(cell)mem;code_end=code_start+length;frame_size=c.size;known_prologue=code_start+(c.prologue?c.prologue-c.start:0);
  memcpy(mem,(void*)c.start,length);
  const cell load_size=(sizeof(cell)==8?5:2)*4;
  if(c.size!=80 && c.size!=0 && c.start!=(cell)collision_start && c.start!=(cell)conditional_start) ppc_store_absolute(code_start+load_size,(fixnum)&polling);
  // %jump's two absolute loads follow mtlr; transfer to a private BLR stub.
  if(c.size>=32768) ppc_store_absolute(code_end-8,(fixnum)ppc_boundary_return_stub);
  if(c.start==(cell)caller_start) ppc_store_absolute(code_start+(cell)caller_callload-c.start+load_size,(fixnum)ppc_boundary_return_stub);
  __builtin___clear_cache((char*)mem,(char*)mem+length);
  for(cell offset=0;offset<length;offset+=4) {
   if(c.start==(cell)conditional_start && offset==16) continue; // miss path skips hit return

   target=code_start+offset;
   expected=c.size==0?ppc_leaf:offset<c.body-c.start?ppc_pre:offset<c.restored-c.start?ppc_active:ppc_post;
   if(c.temp && offset>=c.temp-c.start && offset<c.temp_end-c.start) expected=c.size?ppc_temporary:ppc_temporary_leaf;
   expected_lr=(cell)ppc_boundary_after_call;
   if(c.start==(cell)caller_start && offset>=(cell)caller_link-c.start && offset<(cell)caller_lr_restored-c.start)
    expected_lr=code_start+(cell)caller_link-c.start;
   original=ppc_instruction(target);hits=0;
   ppc_store_instruction(target,0x7fe00008); // tw 31,r0,r0
   __builtin___clear_cache((char*)target,(char*)target+4);
   ppc_boundary_invoke(mem,&initial_sp);
   assert(hits==1);++total;
  }
  if(c.start==(cell)conditional_start) {
   // The hit path returns before allocating; exercise its five boundaries
   // separately from the miss path above, with the same frame descriptor.
   ppc_store_instruction(code_start,0x38a00000);
   for(cell offset=0;offset<=16;offset+=4) {
    target=code_start+offset;expected=ppc_pre;expected_lr=(cell)ppc_boundary_after_call;
    original=ppc_instruction(target);hits=0;
    ppc_store_instruction(target,0x7fe00008);
    __builtin___clear_cache((char*)code_start,(char*)code_end);
    ppc_boundary_invoke(mem,&initial_sp);
    assert(hits==1); ++total;
   }
  }
  assert(munmap(mem,4096)==0);
 }
 // Enter the same owner recursively with the same frame size. Rearm the
 // entry trap at the outer call so its kernel SP names the active caller.
 size_t recursive_length=(cell)recursive_end-(cell)recursive_start;
 void* recursive_mem=mmap(nullptr,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);assert(recursive_mem!=MAP_FAILED);
 code_start=(cell)recursive_mem;code_end=code_start+recursive_length;
 memcpy(recursive_mem,recursive_start,recursive_length);
 const cell recursive_load_size=(sizeof(cell)==8?5:2)*4;
 ppc_store_absolute(code_start+(cell)recursive_counterload-(cell)recursive_start+recursive_load_size,(fixnum)&recursion_counter);
 ppc_store_absolute(code_start+(cell)recursive_callload-(cell)recursive_start+recursive_load_size,(fixnum)code_start);
 recursive_call=code_start+(cell)recursive_link-(cell)recursive_start-4;
 recursive_call_instruction=ppc_instruction(recursive_call);
 recursive_entry_instruction=ppc_instruction(code_start);
 ppc_store_instruction(recursive_call,0x7fe00008);
 __builtin___clear_cache((char*)code_start,(char*)code_end);
 recursion_counter=1;recursive_stage=1;hits=0;
 ppc_boundary_invoke(recursive_mem,&initial_sp);
 assert(recursive_stage==0 && hits==1 && recursion_counter==0);
 assert(munmap(recursive_mem,4096)==0); ++total;
 // Actual PIC hit/miss instructions retain a 112-byte caller, despite the
 // old PIC header's 128-byte nominal frame. Both paths preserve incoming LR.
 size_t pic_length=(cell)pic_end-(cell)pic_start;
 void* pic_mem=mmap(nullptr,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);assert(pic_mem!=MAP_FAILED);
 memcpy(pic_mem,pic_start,pic_length);code_start=(cell)pic_mem;code_end=code_start+pic_length;
 frame_size=0;known_prologue=code_start;pic_control=true;
 pic_lr_ready=code_start+(cell)pic_missload-(cell)pic_start;
 ppc_store_absolute(code_start+(cell)pic_hitload-(cell)pic_start+recursive_load_size,(fixnum)ppc_boundary_return_stub);
 ppc_store_absolute(code_start+(cell)pic_missload-(cell)pic_start+recursive_load_size,(fixnum)ppc_boundary_return_stub);
 for(unsigned path=0;path<2;++path) {
  for(cell offset=0;offset<pic_length;offset+=4) {
   if(path==0 && offset>=(cell)pic_miss-(cell)pic_start) continue;
   if(path==1 && offset>(cell)pic_branch-(cell)pic_start && offset<(cell)pic_miss-(cell)pic_start) continue;
   cell data_stack[8]={path==0?11u:0u};
   target=code_start+offset;expected=ppc_leaf;expected_lr=(cell)ppc_pic_boundary_after_call;
   original=ppc_instruction(target);hits=0;
   ppc_store_instruction(target,0x7fe00008);
   __builtin___clear_cache((char*)code_start,(char*)code_end);
   ppc_pic_boundary_invoke(pic_mem,&initial_sp,data_stack);
   assert(hits==1);++total;
  }
 }
 pic_control=false;assert(munmap(pic_mem,4096)==0);
 size_t unsupported_length=(cell)unsupported_end-(cell)unsupported_start;
 void* unsupported_mem=mmap(nullptr,4096,PROT_READ|PROT_WRITE|PROT_EXEC,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);assert(unsupported_mem!=MAP_FAILED);
 memcpy(unsupported_mem,unsupported_start,unsupported_length);code_start=(cell)unsupported_mem;code_end=code_start+unsupported_length;
 frame_size=0;known_prologue=code_start;unsupported_control=true;
 unsupported_allocated_pc=code_start+(cell)unsupported_allocated-(cell)unsupported_start;
 unsupported_restored_pc=code_start+(cell)unsupported_restored-(cell)unsupported_start;
 for(cell offset=0;offset<unsupported_length;offset+=4) {
  target=code_start+offset;expected=target<unsupported_allocated_pc?ppc_leaf:ppc_unknown;
  expected_lr=(cell)ppc_boundary_after_call;original=ppc_instruction(target);hits=0;
  ppc_store_instruction(target,0x7fe00008);
  __builtin___clear_cache((char*)code_start,(char*)code_end);
  ppc_boundary_invoke(unsupported_mem,&initial_sp);
  assert(hits==1);++total;
 }
 unsupported_control=false;assert(munmap(unsupported_mem,4096)==0);
 printf("Native PPC kernel PC/SP/LR exact instruction boundaries passed: %zu\n",total);
}
