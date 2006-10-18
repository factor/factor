#include "factor.h"

static void *null_dll;

s64 current_millis(void)
{
	struct timeval t;
	gettimeofday(&t,NULL);
	return (s64)t.tv_sec * 1000 + t.tv_usec/1000;
}

void init_ffi(void)
{
	null_dll = dlopen(NULL,RTLD_LAZY);
}

void ffi_dlopen(DLL *dll, bool error)
{
	void *dllptr = dlopen(to_char_string(untag_string(dll->path),true), RTLD_LAZY);

	if(dllptr == NULL)
	{
		if(error)
		{
			general_error(ERROR_FFI,F,
				tag_object(from_char_string(dlerror())),true);
		}
		else
			dll->dll = NULL;

		return;
	}

	dll->dll = dllptr;
}

void *ffi_dlsym(DLL *dll, F_STRING *symbol, bool error)
{
	void *handle = (dll == NULL ? null_dll : dll->dll);
	void *sym = dlsym(handle,to_char_string(symbol,true));
	if(sym == NULL)
	{
		if(error)
		{
			general_error(ERROR_FFI,tag_object(symbol),
				tag_object(from_char_string(dlerror())),true);
		}

		return NULL;
	}
	return sym;
}

void ffi_dlclose(DLL *dll)
{
	if(dlclose(dll->dll))
	{
		general_error(ERROR_FFI,tag_object(
			from_char_string(dlerror())),F,true);
	}
	dll->dll = NULL;
}

void primitive_stat(void)
{
	struct stat sb;
	F_STRING* path;

	maybe_gc(0);

	path = untag_string(dpop());
	if(stat(to_char_string(path,true),&sb) < 0)
		dpush(F);
	else
	{
		CELL dirp = tag_boolean(S_ISDIR(sb.st_mode));
		CELL mode = tag_fixnum(sb.st_mode & ~S_IFMT);
		CELL size = tag_bignum(s48_long_long_to_bignum(sb.st_size));
		CELL mtime = tag_integer(sb.st_mtime);
		dpush(make_array_4(dirp,mode,size,mtime));
	}
}

void primitive_read_dir(void)
{
	F_STRING *path;
	DIR* dir;
	F_ARRAY *result;
	CELL result_count = 0;

	maybe_gc(0);

	result = array(ARRAY_TYPE,100,F);

	path = untag_string(dpop());
	dir = opendir(to_char_string(path,true));
	if(dir != NULL)
	{
		struct dirent* file;

		while((file = readdir(dir)) != NULL)
		{
			CELL name = tag_object(from_char_string(file->d_name));
			if(result_count == array_capacity(result))
			{
				result = resize_array(result,
					result_count * 2,F);
			}
			
			put(AREF(result,result_count),name);
			result_count++;
		}

		closedir(dir);
	}

	result = resize_array(result,result_count,F);

	dpush(tag_object(result));
}

void primitive_cwd(void)
{
	char wd[MAXPATHLEN];
	maybe_gc(0);
	if(getcwd(wd,MAXPATHLEN) == NULL)
		io_error();
	box_char_string(wd);
}

void primitive_cd(void)
{
	maybe_gc(0);
	chdir(unbox_char_string());
}

BOUNDED_BLOCK *alloc_bounded_block(CELL size)
{
	int pagesize = getpagesize();

	char *array = mmap((void*)0,pagesize + size + pagesize,
		PROT_READ | PROT_WRITE | PROT_EXEC,
		MAP_ANON | MAP_PRIVATE,-1,0);

	if(array == NULL)
		fatal_error("Cannot allocate memory region",0);

	if(mprotect(array,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot protect low guard page",(CELL)array);

	if(mprotect(array + pagesize + size,pagesize,PROT_NONE) == -1)
		fatal_error("Cannot protect high guard page",(CELL)array);

	BOUNDED_BLOCK *retval = safe_malloc(sizeof(BOUNDED_BLOCK));
	
	retval->start = (CELL)(array + pagesize);
	retval->size = size;

	return retval;
}

void dealloc_bounded_block(BOUNDED_BLOCK *block)
{
	int pagesize = getpagesize();

	int retval = munmap((void*)(block->start - pagesize),
		pagesize + block->size + pagesize);
	
	if(retval)
		fatal_error("Failed to unmap region",0);

	free(block);
}

void signal_handler(int signal, siginfo_t* siginfo, void* uap)
{
	memory_protection_error(siginfo->si_addr, signal);
}

static void sigaction_safe(int signum, const struct sigaction *act, struct sigaction *oldact)
{
	int ret;
	do
	{
		ret = sigaction(signum, act, oldact);
	} while(ret == -1 && errno == EINTR);
}

void unix_init_signals(void)
{
	struct sigaction custom_sigaction;
	struct sigaction ign_sigaction;
	
	sigemptyset(&custom_sigaction.sa_mask);
	custom_sigaction.sa_sigaction = signal_handler;
	custom_sigaction.sa_flags = SA_SIGINFO;
	sigaction_safe(SIGABRT,&custom_sigaction,NULL);
	sigaction_safe(SIGFPE,&custom_sigaction,NULL);
	sigaction_safe(SIGBUS,&custom_sigaction,NULL);
	sigaction_safe(SIGQUIT,&custom_sigaction,NULL);
	sigaction_safe(SIGSEGV,&custom_sigaction,NULL);
	sigaction_safe(SIGILL,&custom_sigaction,NULL);
	
	sigemptyset(&ign_sigaction.sa_mask);
	ign_sigaction.sa_handler = SIG_IGN;
	sigaction_safe(SIGPIPE,&ign_sigaction,NULL);
}

void reset_stdio(void)
{
	fcntl(0,F_SETFL,0);
	fcntl(1,F_SETFL,0);
}
