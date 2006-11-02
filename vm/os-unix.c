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

void ffi_dlopen(F_DLL *dll, bool error)
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

void *ffi_dlsym(F_DLL *dll, F_STRING *symbol, bool error)
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

void ffi_dlclose(F_DLL *dll)
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

void primitive_read_dir(void)
{
	DIR* dir = opendir(unbox_char_string());
	CELL result_count = 0;
	F_ARRAY *result = allot_array(ARRAY_TYPE,100,F);

	if(dir != NULL)
	{
		struct dirent* file;

		while((file = readdir(dir)) != NULL)
		{
			if(result_count == array_capacity(result))
			{
				result = reallot_array(result,
					result_count * 2,F);
			}

			REGISTER_ARRAY(result);
			CELL name = tag_object(from_char_string(file->d_name));
			UNREGISTER_ARRAY(result);

			set_array_nth(result,result_count,name);
			result_count++;
		}

		closedir(dir);
	}

	result = reallot_array(result,result_count,F);

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

F_BOUNDED_BLOCK *alloc_bounded_block(CELL size)
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

	F_BOUNDED_BLOCK *retval = safe_malloc(sizeof(F_BOUNDED_BLOCK));
	
	retval->start = (CELL)(array + pagesize);
	retval->size = size;

	return retval;
}

void dealloc_bounded_block(F_BOUNDED_BLOCK *block)
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
	memory_protection_error((CELL)siginfo->si_addr, signal);
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
