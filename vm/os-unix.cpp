#include "master.hpp"

namespace factor
{

THREADHANDLE start_thread(void *(*start_routine)(void *),void *args)
{
	pthread_attr_t attr;
	pthread_t thread;
	if (pthread_attr_init (&attr) != 0)
		fatal_error("pthread_attr_init() failed",0);
	if (pthread_attr_setdetachstate (&attr, PTHREAD_CREATE_JOINABLE) != 0)
		fatal_error("pthread_attr_setdetachstate() failed",0);
	if (pthread_create (&thread, &attr, start_routine, args) != 0)
		fatal_error("pthread_create() failed",0);
	pthread_attr_destroy(&attr);
	return thread;
}

static void *null_dll;

void sleep_nanos(u64 nsec)
{
	timespec ts;
	timespec ts_rem;
	int ret;
	ts.tv_sec = nsec / 1000000000;
	ts.tv_nsec = nsec % 1000000000;
	ret = nanosleep(&ts,&ts_rem);
	while(ret == -1 && errno == EINTR)
	{
		memcpy(&ts, &ts_rem, sizeof(ts));
		ret = nanosleep(&ts, &ts_rem);
	}

	if(ret == -1)
		fatal_error("nanosleep failed", 0);
}

void factor_vm::init_ffi()
{
	null_dll = dlopen(NULL,RTLD_LAZY);
}

void factor_vm::ffi_dlopen(dll *dll)
{
	dll->handle = dlopen(alien_offset(dll->path), RTLD_LAZY);
}

void *factor_vm::ffi_dlsym_raw(dll *dll, symbol_char *symbol)
{
	return dlsym(dll ? dll->handle : null_dll, symbol);
}

void *factor_vm::ffi_dlsym(dll *dll, symbol_char *symbol)
{
	return FUNCTION_CODE_POINTER(ffi_dlsym_raw(dll, symbol));
}

#ifdef FACTOR_PPC
void *factor_vm::ffi_dlsym_toc(dll *dll, symbol_char *symbol)
{
	return FUNCTION_TOC_POINTER(ffi_dlsym_raw(dll, symbol));
}
#endif

void factor_vm::ffi_dlclose(dll *dll)
{
	if(dlclose(dll->handle))
		general_error(ERROR_FFI,false_object,false_object);
	dll->handle = NULL;
}

void factor_vm::primitive_existsp()
{
	struct stat sb;
	char *path = (char *)(untag_check<byte_array>(ctx->pop()) + 1);
	ctx->push(tag_boolean(stat(path,&sb) >= 0));
}

void factor_vm::move_file(const vm_char *path1, const vm_char *path2)
{
	int ret = 0;
	do
	{
		ret = rename((path1),(path2));
	}
	while(ret < 0 && errno == EINTR);

	if(ret < 0)
		general_error(ERROR_IO,tag_fixnum(errno),false_object);
}

segment::segment(cell size_, bool executable_p)
{
	size = size_;

	int pagesize = getpagesize();

	int prot;
	if(executable_p)
		prot = (PROT_READ | PROT_WRITE | PROT_EXEC);
	else
		prot = (PROT_READ | PROT_WRITE);

	char *array = (char *)mmap(NULL,pagesize + size + pagesize,prot,MAP_ANON | MAP_PRIVATE,-1,0);
	if(array == (char*)-1) out_of_memory();

	if(mprotect(array,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot protect low guard page",(cell)array);

	if(mprotect(array + pagesize + size,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot protect high guard page",(cell)array);

	start = (cell)(array + pagesize);
	end = start + size;
}

segment::~segment()
{
	int pagesize = getpagesize();
	int retval = munmap((void*)(start - pagesize),pagesize + size + pagesize);
	if(retval)
		fatal_error("Segment deallocation failed",0);
}

void code_heap::guard_safepoint()
{
	if(mprotect(safepoint_page,getpagesize(),PROT_NONE) == -1)
		fatal_error("Cannot protect safepoint guard page",(cell)safepoint_page);
}

void code_heap::unguard_safepoint()
{
	if(mprotect(safepoint_page,getpagesize(),PROT_WRITE) == -1)
		fatal_error("Cannot unprotect safepoint guard page",(cell)safepoint_page);
}

void factor_vm::dispatch_signal(void *uap, void (handler)())
{
	cell sp = (cell)UAP_STACK_POINTER(uap);
	cell offset = sp % 16;
	if (offset != 0)
		fatal_error("fault in unaligned frame with offset", offset);
	UAP_STACK_POINTER(uap) = (UAP_STACK_POINTER_TYPE)(sp - sizeof(cell));
	*(cell*)(UAP_STACK_POINTER(uap)) = (cell)UAP_PROGRAM_COUNTER(uap);
	UAP_PROGRAM_COUNTER(uap) = (cell)FUNCTION_CODE_POINTER(handler);
	UAP_SET_TOC_POINTER(uap, (cell)FUNCTION_TOC_POINTER(handler));
	ctx->callstack_top = (stack_frame *)UAP_STACK_POINTER(uap);
}

void memory_signal_handler(int signal, siginfo_t *siginfo, void *uap)
{
	factor_vm *vm = current_vm();
	vm->signal_fault_addr = (cell)siginfo->si_addr;
	vm->dispatch_signal(uap,factor::memory_signal_handler_impl);
}

void synchronous_signal_handler(int signal, siginfo_t *siginfo, void *uap)
{
	factor_vm *vm = current_vm_p();
	if (vm)
	{
		vm->signal_number = signal;
		vm->dispatch_signal(uap,factor::synchronous_signal_handler_impl);
	} else
		fatal_error("Foreign thread received signal ", signal);
}

void next_safepoint_signal_handler(int signal, siginfo_t *siginfo, void *uap)
{
	factor_vm *vm = current_vm_p();
	if (vm)
		vm->enqueue_safepoint_signal(signal);
	else
		fatal_error("Foreign thread received signal ", signal);
}

void ignore_signal_handler(int signal, siginfo_t *siginfo, void *uap)
{
}

void fpe_signal_handler(int signal, siginfo_t *siginfo, void *uap)
{
	factor_vm *vm = current_vm();
	vm->signal_number = signal;
	vm->signal_fpu_status = fpu_status(uap_fpu_status(uap));
	uap_clear_fpu_status(uap);

	vm->dispatch_signal(uap,
		(siginfo->si_code == FPE_INTDIV || siginfo->si_code == FPE_INTOVF)
		? factor::synchronous_signal_handler_impl
		: factor::fp_signal_handler_impl);
}

static void sigaction_safe(int signum, const struct sigaction *act, struct sigaction *oldact)
{
	int ret;
	do
	{
		ret = sigaction(signum, act, oldact);
	}
	while(ret == -1 && errno == EINTR);

	if(ret == -1)
		fatal_error("sigaction failed", 0);
}

void factor_vm::unix_init_signals()
{
	/* OpenBSD doesn't support sigaltstack() if we link against
	libpthread. See http://redmine.ruby-lang.org/issues/show/1239 */

#ifndef __OpenBSD__
	signal_callstack_seg = new segment(callstack_size,false);

	stack_t signal_callstack;
	signal_callstack.ss_sp = (char *)signal_callstack_seg->start;
	signal_callstack.ss_size = signal_callstack_seg->size;
	signal_callstack.ss_flags = 0;

	if(sigaltstack(&signal_callstack,(stack_t *)NULL) < 0)
		fatal_error("sigaltstack() failed",0);
#endif

	struct sigaction memory_sigaction;
	struct sigaction synchronous_sigaction;
	struct sigaction next_safepoint_sigaction;
	struct sigaction fpe_sigaction;
	struct sigaction ignore_sigaction;

	memset(&memory_sigaction,0,sizeof(struct sigaction));
	sigemptyset(&memory_sigaction.sa_mask);
	memory_sigaction.sa_sigaction = memory_signal_handler;
	memory_sigaction.sa_flags = SA_SIGINFO | SA_ONSTACK;

	sigaction_safe(SIGBUS,&memory_sigaction,NULL);
	sigaction_safe(SIGSEGV,&memory_sigaction,NULL);
	sigaction_safe(SIGTRAP,&memory_sigaction,NULL);

	memset(&fpe_sigaction,0,sizeof(struct sigaction));
	sigemptyset(&fpe_sigaction.sa_mask);
	fpe_sigaction.sa_sigaction = fpe_signal_handler;
	fpe_sigaction.sa_flags = SA_SIGINFO | SA_ONSTACK;

	sigaction_safe(SIGFPE,&fpe_sigaction,NULL);

	memset(&synchronous_sigaction,0,sizeof(struct sigaction));
	sigemptyset(&synchronous_sigaction.sa_mask);
	synchronous_sigaction.sa_sigaction = synchronous_signal_handler;
	synchronous_sigaction.sa_flags = SA_SIGINFO | SA_ONSTACK;

	sigaction_safe(SIGILL,&synchronous_sigaction,NULL);
	sigaction_safe(SIGABRT,&synchronous_sigaction,NULL);

	memset(&next_safepoint_sigaction,0,sizeof(struct sigaction));
	sigemptyset(&next_safepoint_sigaction.sa_mask);
	next_safepoint_sigaction.sa_sigaction = next_safepoint_signal_handler;
	next_safepoint_sigaction.sa_flags = SA_SIGINFO | SA_ONSTACK;
	sigaction_safe(SIGALRM,&next_safepoint_sigaction,NULL);
	sigaction_safe(SIGVTALRM,&next_safepoint_sigaction,NULL);
	sigaction_safe(SIGPROF,&next_safepoint_sigaction,NULL);
	sigaction_safe(SIGQUIT,&next_safepoint_sigaction,NULL);
	sigaction_safe(SIGINT,&next_safepoint_sigaction,NULL);
	sigaction_safe(SIGUSR1,&next_safepoint_sigaction,NULL);
	sigaction_safe(SIGUSR2,&next_safepoint_sigaction,NULL);

	/* We don't use SA_IGN here because then the ignore action is inherited
	by subprocesses, which we don't want. There is a unit test in
	io.launcher.unix for this. */
	memset(&ignore_sigaction,0,sizeof(struct sigaction));
	sigemptyset(&ignore_sigaction.sa_mask);
	ignore_sigaction.sa_sigaction = ignore_signal_handler;
	ignore_sigaction.sa_flags = SA_SIGINFO | SA_ONSTACK;
	sigaction_safe(SIGPIPE,&ignore_sigaction,NULL);
}

/* On Unix, shared fds such as stdin cannot be set to non-blocking mode
(http://homepages.tesco.net/J.deBoynePollard/FGA/dont-set-shared-file-descriptors-to-non-blocking-mode.html)
so we kludge around this by spawning a thread, which waits on a control pipe
for a signal, upon receiving this signal it reads one block of data from stdin
and writes it to a data pipe. Upon completion, it writes a 4-byte integer to
the size pipe, indicating how much data was written to the data pipe.

The read end of the size pipe can be set to non-blocking. */
extern "C" {
	int stdin_read;
	int stdin_write;

	int control_read;
	int control_write;

	int size_read;
	int size_write;
}

void safe_close(int fd)
{
	if(close(fd) < 0)
		fatal_error("error closing fd",errno);
}

bool check_write(int fd, void *data, ssize_t size)
{
	if(write(fd,data,size) == size)
		return true;
	else
	{
		if(errno == EINTR)
			return check_write(fd,data,size);
		else
			return false;
	}
}

void safe_write(int fd, void *data, ssize_t size)
{
	if(!check_write(fd,data,size))
		fatal_error("error writing fd",errno);
}

bool safe_read(int fd, void *data, ssize_t size)
{
	ssize_t bytes = read(fd,data,size);
	if(bytes < 0)
	{
		if(errno == EINTR)
			return safe_read(fd,data,size);
		else
		{
			fatal_error("error reading fd",errno);
			return false;
		}
	}
	else
		return (bytes == size);
}

void *stdin_loop(void *arg)
{
	unsigned char buf[4096];
	bool loop_running = true;

	sigset_t mask;
	sigfillset(&mask);
	pthread_sigmask(SIG_BLOCK, &mask, NULL);

	while(loop_running)
	{
		if(!safe_read(control_read,buf,1))
			break;

		if(buf[0] != 'X')
			fatal_error("stdin_loop: bad data on control fd",buf[0]);

		for(;;)
		{
			ssize_t bytes = read(0,buf,sizeof(buf));
			if(bytes < 0)
			{
				if(errno == EINTR)
					continue;
				else
				{
					loop_running = false;
					break;
				}
			}
			else if(bytes >= 0)
			{
				safe_write(size_write,&bytes,sizeof(bytes));

				if(!check_write(stdin_write,buf,bytes))
					loop_running = false;
				break;
			}
		}
	}

	safe_close(stdin_write);
	safe_close(control_read);

	return NULL;
}

void safe_pipe(int *in, int *out)
{
	int filedes[2];

	if(pipe(filedes) < 0)
		fatal_error("Error opening pipe",errno);

	*in = filedes[0];
	*out = filedes[1];

	if(fcntl(*in,F_SETFD,FD_CLOEXEC) < 0)
		fatal_error("Error with fcntl",errno);

	if(fcntl(*out,F_SETFD,FD_CLOEXEC) < 0)
		fatal_error("Error with fcntl",errno);
}

void open_console()
{
	safe_pipe(&control_read,&control_write);
	safe_pipe(&size_read,&size_write);
	safe_pipe(&stdin_read,&stdin_write);
	start_thread(stdin_loop,NULL);
}

}
