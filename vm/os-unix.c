#include "master.h"

static void *null_dll;

s64 current_millis(void)
{
	struct timeval t;
	gettimeofday(&t,NULL);
	return (s64)t.tv_sec * 1000 + t.tv_usec/1000;
}

void sleep_millis(CELL msec)
{
	usleep(msec * 1000);
}

void init_ffi(void)
{
    // NULL_DLL is "libfactor.dylib" for OS X and NULL for generic unix
	null_dll = dlopen(NULL_DLL,RTLD_LAZY);
}

void ffi_dlopen(F_DLL *dll, bool error)
{
	void *dllptr = dlopen(alien_offset(dll->path), RTLD_LAZY);

	if(dllptr == NULL)
	{
		if(error)
		{
			simple_error(ERROR_FFI,F,
				tag_object(from_char_string(dlerror())));
		}
		else
			dll->dll = NULL;

		return;
	}

	dll->dll = dllptr;
}

void *ffi_dlsym(F_DLL *dll, F_SYMBOL *symbol)
{
	void *handle = (dll == NULL ? null_dll : dll->dll);
	return dlsym(handle,symbol);
}

void ffi_dlclose(F_DLL *dll)
{
	if(dlclose(dll->dll))
	{
		simple_error(ERROR_FFI,tag_object(
			from_char_string(dlerror())),F);
	}
	dll->dll = NULL;
}

void primitive_stat(void)
{
	struct stat sb;

	if(stat(unbox_char_string(),&sb) < 0)
	{
		dpush(F);
		dpush(F);
		dpush(F);
		dpush(F);
	}
	else
	{
		box_boolean(S_ISDIR(sb.st_mode));
		box_signed_4(sb.st_mode & ~S_IFMT);
		box_unsigned_8(sb.st_size);
		box_unsigned_8(sb.st_mtime);
	}
}

/* Allocates memory */
CELL parse_dir_entry(struct dirent *file)
{
	CELL name = tag_object(from_char_string(file->d_name));
	if(UNKNOWN_TYPE_P(file))
		return name;
	else
	{
		CELL dirp = tag_boolean(DIRECTORY_P(file));
		return allot_array_2(name,dirp);
	}
}

void primitive_read_dir(void)
{
	DIR* dir = opendir(unbox_char_string());
	GROWABLE_ARRAY(result);

	if(dir != NULL)
	{
		struct dirent* file;

		while((file = readdir(dir)) != NULL)
		{
			REGISTER_ARRAY(result);
			CELL pair = parse_dir_entry(file);
			UNREGISTER_ARRAY(result);
			GROWABLE_ADD(result,pair);
		}

		closedir(dir);
	}

	GROWABLE_TRIM(result);

	dpush(tag_object(result));
}

void primitive_cwd(void)
{
	char wd[MAXPATHLEN];
	if(getcwd(wd,MAXPATHLEN) == NULL)
		io_error();
	box_char_string(wd);
}

void primitive_cd(void)
{
	chdir(unbox_char_string());
}

F_SEGMENT *alloc_segment(CELL size)
{
	int pagesize = getpagesize();

	char *array = mmap(NULL,pagesize + size + pagesize,
		PROT_READ | PROT_WRITE | PROT_EXEC,
		MAP_ANON | MAP_PRIVATE,-1,0);

	if(array == (char*)-1)
		fatal_error("Out of memory in alloc_segment",0);

	if(mprotect(array,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot protect low guard page",(CELL)array);

	if(mprotect(array + pagesize + size,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot protect high guard page",(CELL)array);

	F_SEGMENT *retval = safe_malloc(sizeof(F_SEGMENT));

	retval->start = (CELL)(array + pagesize);
	retval->size = size;
	retval->end = retval->start + size;

	return retval;
}

void dealloc_segment(F_SEGMENT *block)
{
	int pagesize = getpagesize();

	int retval = munmap((void*)(block->start - pagesize),
		pagesize + block->size + pagesize);
	
	if(retval)
		fatal_error("dealloc_segment failed",0);

	free(block);
}
  
INLINE F_COMPILED_FRAME *uap_stack_pointer(void *uap)
{
	F_COMPILED_FRAME *ptr = ucontext_stack_pointer(uap);
	if(ptr)
		return ptr;
	else
		return native_stack_pointer();
}

void memory_signal_handler(int signal, siginfo_t *siginfo, void *uap)
{
	memory_protection_error((CELL)siginfo->si_addr,
		uap_stack_pointer(uap));
}

void misc_signal_handler(int signal, siginfo_t *siginfo, void *uap)
{
	signal_error(signal,uap_stack_pointer(uap));
}

static void sigaction_safe(int signum, const struct sigaction *act, struct sigaction *oldact)
{
	int ret;
	do
	{
		ret = sigaction(signum, act, oldact);
	}
	while(ret == -1 && errno == EINTR);
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

void reset_stdio(void)
{
	fcntl(0,F_SETFL,0);
	fcntl(1,F_SETFL,0);
}
