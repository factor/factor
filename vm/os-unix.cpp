#include "master.hpp"

namespace factor {

THREADHANDLE start_thread(void* (*start_routine)(void*), void* args) {
  pthread_attr_t attr;
  pthread_t thread;
  if (pthread_attr_init(&attr) != 0)
    fatal_error("pthread_attr_init() failed", 0);
  if (pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE) != 0)
    fatal_error("pthread_attr_setdetachstate() failed", 0);
  if (pthread_create(&thread, &attr, start_routine, args) != 0)
    fatal_error("pthread_create() failed", 0);
  pthread_attr_destroy(&attr);
  return thread;
}

static void* null_dll;

void sleep_nanos(uint64_t nsec) {
  timespec ts;
  timespec ts_rem;
  int ret;
  ts.tv_sec = nsec / 1000000000;
  ts.tv_nsec = nsec % 1000000000;
  ret = nanosleep(&ts, &ts_rem);
  while (ret == -1 && errno == EINTR) {
    memcpy(&ts, &ts_rem, sizeof(ts));
    ret = nanosleep(&ts, &ts_rem);
  }

  if (ret == -1)
    fatal_error("nanosleep failed", 0);
}

void factor_vm::init_ffi() { null_dll = dlopen(NULL, RTLD_LAZY); }

void factor_vm::ffi_dlopen(dll* dll) {
  dll->handle = dlopen(alien_offset(dll->path), RTLD_LAZY | RTLD_GLOBAL);
}

void* factor_vm::ffi_dlsym_raw(dll* dll, symbol_char* symbol) {
  return dlsym(dll ? dll->handle : null_dll, symbol);
}

void* factor_vm::ffi_dlsym(dll* dll, symbol_char* symbol) {
  return FUNCTION_CODE_POINTER(ffi_dlsym_raw(dll, symbol));
}

#ifdef FACTOR_PPC
void* factor_vm::ffi_dlsym_toc(dll* dll, symbol_char* symbol) {
  return FUNCTION_TOC_POINTER(ffi_dlsym_raw(dll, symbol));
}
#endif

void factor_vm::ffi_dlclose(dll* dll) {
  if (dlclose(dll->handle))
    general_error(ERROR_FFI, false_object, false_object);
  dll->handle = NULL;
}

void factor_vm::primitive_existsp() {
  struct stat sb;
  char* path = (char*)(untag_check<byte_array>(ctx->pop()) + 1);
  ctx->push(tag_boolean(stat(path, &sb) >= 0));
}

void factor_vm::move_file(const vm_char* path1, const vm_char* path2) {
  int ret = 0;
  do {
    ret = rename((path1), (path2));
  } while (ret < 0 && errno == EINTR);

  if (ret < 0)
    general_error(ERROR_IO, tag_fixnum(errno), false_object);
}

segment::segment(cell size_, bool executable_p) {
  size = size_;

  int pagesize = getpagesize();

  int prot;
  if (executable_p)
    prot = (PROT_READ | PROT_WRITE | PROT_EXEC);
  else
    prot = (PROT_READ | PROT_WRITE);

  char* array = (char*)mmap(NULL, pagesize + size + pagesize, prot,
                            MAP_ANON | MAP_PRIVATE, -1, 0);
  if (array == (char*)- 1)
    out_of_memory();

  if (mprotect(array, pagesize, PROT_NONE) == -1)
    fatal_error("Cannot protect low guard page", (cell)array);

  if (mprotect(array + pagesize + size, pagesize, PROT_NONE) == -1)
    fatal_error("Cannot protect high guard page", (cell)array);

  start = (cell)(array + pagesize);
  end = start + size;
}

segment::~segment() {
  int pagesize = getpagesize();
  int retval = munmap((void*)(start - pagesize), pagesize + size + pagesize);
  if (retval)
    fatal_error("Segment deallocation failed", 0);
}

void code_heap::guard_safepoint() {
  if (mprotect(safepoint_page, getpagesize(), PROT_NONE) == -1)
    fatal_error("Cannot protect safepoint guard page", (cell)safepoint_page);
}

void code_heap::unguard_safepoint() {
  if (mprotect(safepoint_page, getpagesize(), PROT_WRITE) == -1)
    fatal_error("Cannot unprotect safepoint guard page", (cell)safepoint_page);
}

void factor_vm::dispatch_signal(void* uap, void(handler)()) {
  dispatch_signal_handler((cell*)&UAP_STACK_POINTER(uap),
                          (cell*)&UAP_PROGRAM_COUNTER(uap),
                          (cell)FUNCTION_CODE_POINTER(handler));
  UAP_SET_TOC_POINTER(uap, (cell)FUNCTION_TOC_POINTER(handler));
}

void factor_vm::start_sampling_profiler_timer() {
  struct itimerval timer;
  memset((void*)&timer, 0, sizeof(struct itimerval));
  timer.it_value.tv_usec = 1000000 / samples_per_second;
  timer.it_interval.tv_usec = 1000000 / samples_per_second;
  setitimer(ITIMER_REAL, &timer, NULL);
}

void factor_vm::end_sampling_profiler_timer() {
  struct itimerval timer;
  memset((void*)&timer, 0, sizeof(struct itimerval));
  setitimer(ITIMER_REAL, &timer, NULL);
}

void memory_signal_handler(int signal, siginfo_t* siginfo, void* uap) {
  factor_vm* vm = current_vm();
  vm->verify_memory_protection_error((cell)siginfo->si_addr);
  vm->signal_fault_addr = (cell)siginfo->si_addr;
  vm->signal_fault_pc = (cell)UAP_PROGRAM_COUNTER(uap);
  vm->dispatch_signal(uap, factor::memory_signal_handler_impl);
}

void synchronous_signal_handler(int signal, siginfo_t* siginfo, void* uap) {
  if (factor_vm::fatal_erroring_p)
    return;

  factor_vm* vm = current_vm_p();
  if (vm) {
    vm->signal_number = signal;
    vm->dispatch_signal(uap, factor::synchronous_signal_handler_impl);
  } else
    fatal_error("Foreign thread received signal", signal);
}

void safe_write_nonblock(int fd, void* data, ssize_t size);

static void enqueue_signal(factor_vm* vm, int signal) {
  if (vm->signal_pipe_output != 0)
    safe_write_nonblock(vm->signal_pipe_output, &signal, sizeof(int));
}

void enqueue_signal_handler(int signal, siginfo_t* siginfo, void* uap) {
  if (factor_vm::fatal_erroring_p)
    return;

  factor_vm* vm = current_vm_p();
  if (vm)
    enqueue_signal(vm, signal);
}

void fep_signal_handler(int signal, siginfo_t* siginfo, void* uap) {
  if (factor_vm::fatal_erroring_p)
    return;

  factor_vm* vm = current_vm_p();
  if (vm) {
    vm->safepoint.enqueue_fep(vm);
    enqueue_signal(vm, signal);
  } else
    fatal_error("Foreign thread received signal", signal);
}

void sample_signal_handler(int signal, siginfo_t* siginfo, void* uap) {
  factor_vm* vm = current_vm_p();
  bool foreign_thread = false;
  if (vm == NULL) {
    foreign_thread = true;
    vm = thread_vms.begin()->second;
  }
  if (atomic::load(&vm->sampling_profiler_p))
    vm->safepoint.enqueue_samples(vm, 1, (cell)UAP_PROGRAM_COUNTER(uap),
                                  foreign_thread);
  else if (!foreign_thread)
    enqueue_signal(vm, signal);
}

void ignore_signal_handler(int signal, siginfo_t* siginfo, void* uap) {}

void fpe_signal_handler(int signal, siginfo_t* siginfo, void* uap) {
  factor_vm* vm = current_vm();
  vm->signal_number = signal;
  vm->signal_fpu_status = fpu_status(uap_fpu_status(uap));
  uap_clear_fpu_status(uap);

  vm->dispatch_signal(
      uap, (siginfo->si_code == FPE_INTDIV || siginfo->si_code == FPE_INTOVF)
               ? factor::synchronous_signal_handler_impl
               : factor::fp_signal_handler_impl);
}

static void sigaction_safe(int signum, const struct sigaction* act,
                           struct sigaction* oldact) {
  int ret;
  do {
    ret = sigaction(signum, act, oldact);
  } while (ret == -1 && errno == EINTR);

  if (ret == -1)
    fatal_error("sigaction failed", errno);
}

static void init_sigaction_with_handler(struct sigaction* act,
                                        void (*handler)(int, siginfo_t*,
                                                        void*)) {
  memset(act, 0, sizeof(struct sigaction));
  sigemptyset(&act->sa_mask);
  act->sa_sigaction = handler;
  act->sa_flags = SA_SIGINFO | SA_ONSTACK;
}

static void safe_pipe(int* in, int* out) {
  int filedes[2];

  if (pipe(filedes) < 0)
    fatal_error("Error opening pipe", errno);

  *in = filedes[0];
  *out = filedes[1];

  if (fcntl(*in, F_SETFD, FD_CLOEXEC) < 0)
    fatal_error("Error with fcntl", errno);

  if (fcntl(*out, F_SETFD, FD_CLOEXEC) < 0)
    fatal_error("Error with fcntl", errno);
}

static void init_signal_pipe(factor_vm* vm) {
  safe_pipe(&vm->signal_pipe_input, &vm->signal_pipe_output);

  if (fcntl(vm->signal_pipe_output, F_SETFL, O_NONBLOCK) < 0)
    fatal_error("Error with fcntl", errno);

  vm->special_objects[OBJ_SIGNAL_PIPE] = tag_fixnum(vm->signal_pipe_input);
}

void factor_vm::unix_init_signals() {
  init_signal_pipe(this);

  signal_callstack_seg = new segment(callstack_size, false);

  stack_t signal_callstack;
  signal_callstack.ss_sp = (char*)signal_callstack_seg->start;
  signal_callstack.ss_size = signal_callstack_seg->size;
  signal_callstack.ss_flags = 0;

  if (sigaltstack(&signal_callstack, (stack_t*)NULL) < 0)
    fatal_error("sigaltstack() failed", 0);

  struct sigaction memory_sigaction;
  struct sigaction synchronous_sigaction;
  struct sigaction enqueue_sigaction;
  struct sigaction sample_sigaction;
  struct sigaction fpe_sigaction;
  struct sigaction ignore_sigaction;

  init_sigaction_with_handler(&memory_sigaction, memory_signal_handler);
  sigaction_safe(SIGBUS, &memory_sigaction, NULL);
  sigaction_safe(SIGSEGV, &memory_sigaction, NULL);
  sigaction_safe(SIGTRAP, &memory_sigaction, NULL);

  init_sigaction_with_handler(&fpe_sigaction, fpe_signal_handler);
  sigaction_safe(SIGFPE, &fpe_sigaction, NULL);

  init_sigaction_with_handler(&synchronous_sigaction,
                              synchronous_signal_handler);
  sigaction_safe(SIGILL, &synchronous_sigaction, NULL);
  sigaction_safe(SIGABRT, &synchronous_sigaction, NULL);

  init_sigaction_with_handler(&enqueue_sigaction, enqueue_signal_handler);
  sigaction_safe(SIGWINCH, &enqueue_sigaction, NULL);
  sigaction_safe(SIGUSR1, &enqueue_sigaction, NULL);
  sigaction_safe(SIGCONT, &enqueue_sigaction, NULL);
  sigaction_safe(SIGURG, &enqueue_sigaction, NULL);
  sigaction_safe(SIGIO, &enqueue_sigaction, NULL);
  sigaction_safe(SIGPROF, &enqueue_sigaction, NULL);
  sigaction_safe(SIGVTALRM, &enqueue_sigaction, NULL);
#ifdef SIGINFO
  sigaction_safe(SIGINFO, &enqueue_sigaction, NULL);
#endif

  handle_ctrl_c();

  init_sigaction_with_handler(&sample_sigaction, sample_signal_handler);
  sigaction_safe(SIGALRM, &sample_sigaction, NULL);

  /* We don't use SA_IGN here because then the ignore action is inherited
     by subprocesses, which we don't want. There is a unit test in
     io.launcher.unix for this. */
  init_sigaction_with_handler(&ignore_sigaction, ignore_signal_handler);
  sigaction_safe(SIGPIPE, &ignore_sigaction, NULL);
  /* We send SIGUSR2 to the stdin_loop thread to interrupt it on FEP */
  sigaction_safe(SIGUSR2, &ignore_sigaction, NULL);
}

/* On Unix, shared fds such as stdin cannot be set to non-blocking mode
   (http://homepages.tesco.net/J.deBoynePollard/FGA/dont-set-shared-file-descriptors-to-non-blocking-mode.html)
   so we kludge around this by spawning a thread, which waits on a control pipe
   for a signal, upon receiving this signal it reads one block of data from
   stdin and writes it to a data pipe. Upon completion, it writes a 4-byte
   integer to the size pipe, indicating how much data was written to the data
   pipe.

   The read end of the size pipe can be set to non-blocking. */
extern "C" {
int stdin_read;
int stdin_write;

int control_read;
int control_write;

int size_read;
int size_write;

bool stdin_thread_initialized_p = false;
THREADHANDLE stdin_thread;
pthread_mutex_t stdin_mutex;
}

void safe_close(int fd) {
  if (close(fd) < 0)
    fatal_error("error closing fd", errno);
}

bool check_write(int fd, void* data, ssize_t size) {
  if (write(fd, data, size) == size)
    return true;
  else {
    if (errno == EINTR)
      return check_write(fd, data, size);
    else
      return false;
  }
}

void safe_write(int fd, void* data, ssize_t size) {
  if (!check_write(fd, data, size))
    fatal_error("error writing fd", errno);
}

void safe_write_nonblock(int fd, void* data, ssize_t size) {
  if (!check_write(fd, data, size) && errno != EAGAIN)
    fatal_error("error writing fd", errno);
}

bool safe_read(int fd, void* data, ssize_t size) {
  ssize_t bytes = read(fd, data, size);
  if (bytes < 0) {
    if (errno == EINTR)
      return safe_read(fd, data, size);
    else {
      fatal_error("error reading fd", errno);
      return false;
    }
  } else
    return (bytes == size);
}

void* stdin_loop(void* arg) {
  unsigned char buf[4096];
  bool loop_running = true;

  sigset_t mask;
  sigfillset(&mask);
  sigdelset(&mask, SIGUSR2);
  sigdelset(&mask, SIGTTIN);
  sigdelset(&mask, SIGTERM);
  sigdelset(&mask, SIGQUIT);
  pthread_sigmask(SIG_SETMASK, &mask, NULL);

  int unused;
  pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &unused);
  pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, &unused);

  while (loop_running) {
    if (!safe_read(control_read, buf, 1))
      break;

    if (buf[0] != 'X')
      fatal_error("stdin_loop: bad data on control fd", buf[0]);

    for (;;) {
      /* If we fep, the parent thread will grab stdin_mutex and send us
         SIGUSR2 to interrupt the read() call. */
      pthread_mutex_lock(&stdin_mutex);
      pthread_mutex_unlock(&stdin_mutex);
      ssize_t bytes = read(0, buf, sizeof(buf));
      if (bytes < 0) {
        if (errno == EINTR)
          continue;
        else {
          loop_running = false;
          break;
        }
      } else if (bytes >= 0) {
        safe_write(size_write, &bytes, sizeof(bytes));

        if (!check_write(stdin_write, buf, bytes))
          loop_running = false;
        break;
      }
    }
  }

  safe_close(stdin_write);
  safe_close(control_read);

  return NULL;
}

void factor_vm::open_console() {
  FACTOR_ASSERT(!stdin_thread_initialized_p);
  safe_pipe(&control_read, &control_write);
  safe_pipe(&size_read, &size_write);
  safe_pipe(&stdin_read, &stdin_write);
  stdin_thread = start_thread(stdin_loop, NULL);
  stdin_thread_initialized_p = true;
  pthread_mutex_init(&stdin_mutex, NULL);
}

/* This method is used to kill the stdin_loop before exiting from factor.
   A Nvidia driver bug on Linux is the reason this has to be done, see:
     http://www.nvnews.net/vbulletin/showthread.php?t=164619 */
void factor_vm::close_console() {
  if (stdin_thread_initialized_p) {
    pthread_cancel(stdin_thread);
    pthread_join(stdin_thread, 0);
  }
}

void factor_vm::lock_console() {
  FACTOR_ASSERT(stdin_thread_initialized_p);
  /* Lock the stdin_mutex and send the stdin_loop thread a signal to interrupt
     any read() it has in progress. When the stdin loop iterates again, it will
     try to lock the same mutex and wait until unlock_console() is called. */
  pthread_mutex_lock(&stdin_mutex);
  pthread_kill(stdin_thread, SIGUSR2);
}

void factor_vm::unlock_console() {
  FACTOR_ASSERT(stdin_thread_initialized_p);
  pthread_mutex_unlock(&stdin_mutex);
}

void factor_vm::ignore_ctrl_c() {
  sig_t ret;
  do {
    ret = signal(SIGINT, SIG_DFL);
  } while (ret == SIG_ERR && errno == EINTR);
}

void factor_vm::handle_ctrl_c() {
  struct sigaction fep_sigaction;
  init_sigaction_with_handler(&fep_sigaction, fep_signal_handler);
  sigaction_safe(SIGINT, &fep_sigaction, NULL);
}

void abort() {
  sig_t ret;
  do {
    ret = signal(SIGABRT, SIG_DFL);
  } while (ret == SIG_ERR && errno == EINTR);

  factor_vm::close_console();
  ::abort();
}

}
