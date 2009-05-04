#include "master.hpp"

namespace factor
{

void start_thread(void *(*start_routine)(void *))
{
	pthread_attr_t attr;
	pthread_t thread;

	if (pthread_attr_init (&attr) != 0)
		fatal_error("pthread_attr_init() failed",0);
	if (pthread_attr_setdetachstate (&attr, PTHREAD_CREATE_DETACHED) != 0)
		fatal_error("pthread_attr_setdetachstate() failed",0);
	if (pthread_create (&thread, &attr, start_routine, NULL) != 0)
		fatal_error("pthread_create() failed",0);
	pthread_attr_destroy (&attr);
}

static void *null_dll;

s64 current_micros(void)
{
	struct timeval t;
	gettimeofday(&t,NULL);
	return (s64)t.tv_sec * 1000000 + t.tv_usec;
}

void sleep_micros(cell usec)
{
	usleep(usec);
}

void init_ffi(void)
{
	/* NULL_DLL is "libfactor.dylib" for OS X and NULL for generic unix */
	null_dll = dlopen(NULL_DLL,RTLD_LAZY);
}

void ffi_dlopen(dll *dll)
{
	dll->dll = dlopen(alien_offset(dll->path), RTLD_LAZY);
}

void *ffi_dlsym(dll *dll, symbol_char *symbol)
{
	void *handle = (dll == NULL ? null_dll : dll->dll);
	return dlsym(handle,symbol);
}

void ffi_dlclose(dll *dll)
{
	if(dlclose(dll->dll))
		general_error(ERROR_FFI,F,F,NULL);
	dll->dll = NULL;
}

PRIMITIVE(existsp)
{
	struct stat sb;
	char *path = (char *)(untag_check<byte_array>(dpop()) + 1);
	box_boolean(stat(path,&sb) >= 0);
}

segment *alloc_segment(cell size)
{
	int pagesize = getpagesize();

	char *array = (char *)mmap(NULL,pagesize + size + pagesize,
		PROT_READ | PROT_WRITE | PROT_EXEC,
		MAP_ANON | MAP_PRIVATE,-1,0);

	if(array == (char*)-1)
		out_of_memory();

	if(mprotect(array,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot protect low guard page",(cell)array);

	if(mprotect(array + pagesize + size,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot protect high guard page",(cell)array);

	segment *retval = (segment *)safe_malloc(sizeof(segment));

	retval->start = (cell)(array + pagesize);
	retval->size = size;
	retval->end = retval->start + size;

	return retval;
}

void dealloc_segment(segment *block)
{
	int pagesize = getpagesize();

	int retval = munmap((void*)(block->start - pagesize),
		pagesize + block->size + pagesize);
	
	if(retval)
		fatal_error("dealloc_segment failed",0);

	free(block);
}
  
static stack_frame *uap_stack_pointer(void *uap)
{
	/* There is a race condition here, but in practice a signal
	delivered during stack frame setup/teardown or while transitioning
	from Factor to C is a sign of things seriously gone wrong, not just
	a divide by zero or stack underflow in the listener */
	if(in_code_heap_p(UAP_PROGRAM_COUNTER(uap)))
	{
		stack_frame *ptr = (stack_frame *)ucontext_stack_pointer(uap);
		if(!ptr)
			critical_error("Invalid uap",(cell)uap);
		return ptr;
	}
	else
		return NULL;
}

void memory_signal_handler(int signal, siginfo_t *siginfo, void *uap)
{
	signal_fault_addr = (cell)siginfo->si_addr;
	signal_callstack_top = uap_stack_pointer(uap);
	UAP_PROGRAM_COUNTER(uap) = (cell)memory_signal_handler_impl;
}

void misc_signal_handler(int signal, siginfo_t *siginfo, void *uap)
{
	signal_number = signal;
	signal_callstack_top = uap_stack_pointer(uap);
	UAP_PROGRAM_COUNTER(uap) = (cell)misc_signal_handler_impl;
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

void unix_init_signals(void)
{
	struct sigaction memory_sigaction;
	struct sigaction misc_sigaction;
	struct sigaction ignore_sigaction;

	memset(&memory_sigaction,0,sizeof(struct sigaction));
	sigemptyset(&memory_sigaction.sa_mask);
	memory_sigaction.sa_sigaction = memory_signal_handler;
	memory_sigaction.sa_flags = SA_SIGINFO;

	sigaction_safe(SIGBUS,&memory_sigaction,NULL);
	sigaction_safe(SIGSEGV,&memory_sigaction,NULL);

	memset(&misc_sigaction,0,sizeof(struct sigaction));
	sigemptyset(&misc_sigaction.sa_mask);
	misc_sigaction.sa_sigaction = misc_signal_handler;
	misc_sigaction.sa_flags = SA_SIGINFO;

	sigaction_safe(SIGABRT,&misc_sigaction,NULL);
	sigaction_safe(SIGFPE,&misc_sigaction,NULL);
	sigaction_safe(SIGQUIT,&misc_sigaction,NULL);
	sigaction_safe(SIGILL,&misc_sigaction,NULL);

	memset(&ignore_sigaction,0,sizeof(struct sigaction));
	sigemptyset(&ignore_sigaction.sa_mask);
	ignore_sigaction.sa_handler = SIG_IGN;
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

void open_console(void)
{
	int filedes[2];

	if(pipe(filedes) < 0)
		fatal_error("Error opening control pipe",errno);

	control_read = filedes[0];
	control_write = filedes[1];

	if(pipe(filedes) < 0)
		fatal_error("Error opening size pipe",errno);

	size_read = filedes[0];
	size_write = filedes[1];

	if(pipe(filedes) < 0)
		fatal_error("Error opening stdin pipe",errno);

	stdin_read = filedes[0];
	stdin_write = filedes[1];

	start_thread(stdin_loop);
}

VM_C_API void wait_for_stdin(void)
{
	if(write(control_write,"X",1) != 1)
	{
		if(errno == EINTR)
			wait_for_stdin();
		else
			fatal_error("Error writing control fd",errno);
	}
}

}
