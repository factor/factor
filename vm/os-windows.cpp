#include "master.hpp"

namespace factor
{

HMODULE hFactorDll;

void factor_vm::init_ffi()
{
	hFactorDll = GetModuleHandle(FACTOR_DLL);
	if(!hFactorDll)
		fatal_error("GetModuleHandle() failed", 0);
}

void factor_vm::ffi_dlopen(dll *dll)
{
	dll->handle = LoadLibraryEx((WCHAR *)alien_offset(dll->path), NULL, 0);
}

void *factor_vm::ffi_dlsym(dll *dll, symbol_char *symbol)
{
	return (void *)GetProcAddress(dll ? (HMODULE)dll->handle : hFactorDll, symbol);
}

void factor_vm::ffi_dlclose(dll *dll)
{
	FreeLibrary((HMODULE)dll->handle);
	dll->handle = NULL;
}

BOOL factor_vm::windows_stat(vm_char *path)
{
	BY_HANDLE_FILE_INFORMATION bhfi;
	HANDLE h = CreateFileW(path,
			GENERIC_READ,
			FILE_SHARE_READ,
			NULL,
			OPEN_EXISTING,
			FILE_FLAG_BACKUP_SEMANTICS,
			NULL);

	if(h == INVALID_HANDLE_VALUE)
	{
		// FindFirstFile is the only call that can stat c:\pagefile.sys
		WIN32_FIND_DATA st;
		HANDLE h;

		if(INVALID_HANDLE_VALUE == (h = FindFirstFile(path, &st)))
			return false;
		FindClose(h);
		return true;
	}
	BOOL ret = GetFileInformationByHandle(h, &bhfi);
	CloseHandle(h);
	return ret;
}

void factor_vm::windows_image_path(vm_char *full_path, vm_char *temp_path, unsigned int length)
{
	SNWPRINTF(temp_path, length-1, L"%s.image", full_path); 
	temp_path[length - 1] = 0;
}

/* You must free() this yourself. */
const vm_char *factor_vm::default_image_path()
{
	vm_char full_path[MAX_UNICODE_PATH];
	vm_char *ptr;
	vm_char temp_path[MAX_UNICODE_PATH];

	if(!GetModuleFileName(NULL, full_path, MAX_UNICODE_PATH))
		fatal_error("GetModuleFileName() failed", 0);

	if((ptr = wcsrchr(full_path, '.')))
		*ptr = 0;

	SNWPRINTF(temp_path, MAX_UNICODE_PATH-1, L"%s.image", full_path); 
	temp_path[MAX_UNICODE_PATH - 1] = 0;

	return safe_strdup(temp_path);
}

/* You must free() this yourself. */
const vm_char *factor_vm::vm_executable_path()
{
	vm_char full_path[MAX_UNICODE_PATH];
	if(!GetModuleFileName(NULL, full_path, MAX_UNICODE_PATH))
		fatal_error("GetModuleFileName() failed", 0);
	return safe_strdup(full_path);
}

void factor_vm::primitive_existsp()
{
	vm_char *path = untag_check<byte_array>(ctx->pop())->data<vm_char>();
	ctx->push(tag_boolean(windows_stat(path)));
}

segment::segment(cell size_, bool executable_p)
{
	size = size_;

	char *mem;
	DWORD ignore;

	if((mem = (char *)VirtualAlloc(NULL, getpagesize() * 2 + size,
		MEM_COMMIT, executable_p ? PAGE_EXECUTE_READWRITE : PAGE_READWRITE)) == 0)
		out_of_memory();

	if (!VirtualProtect(mem, getpagesize(), PAGE_NOACCESS, &ignore))
		fatal_error("Cannot allocate low guard page", (cell)mem);

	if (!VirtualProtect(mem + size + getpagesize(),
		getpagesize(), PAGE_NOACCESS, &ignore))
		fatal_error("Cannot allocate high guard page", (cell)mem);

	start = (cell)mem + getpagesize();
	end = start + size;
}

segment::~segment()
{
	SYSTEM_INFO si;
	GetSystemInfo(&si);
	if(!VirtualFree((void*)(start - si.dwPageSize), 0, MEM_RELEASE))
		fatal_error("Segment deallocation failed",0);
}

long getpagesize()
{
	static long g_pagesize = 0;
	if (! g_pagesize)
	{
		SYSTEM_INFO system_info;
		GetSystemInfo (&system_info);
		g_pagesize = system_info.dwPageSize;
	}
	return g_pagesize;
}

/* 
	Windows argument parsing ported to work on
	int main(int argc, wchar_t **argv).

	Based on MinGW's public domain char** version.

	Used by WinMain() implementation in main-windows-ce.cpp
	and main-windows-nt.cpp.

*/

VM_C_API int parse_tokens(wchar_t *string, wchar_t ***tokens, int length)
{
	/* Extract whitespace- and quotes- delimited tokens from the given string
	   and put them into the tokens array. Returns number of tokens
	   extracted. Length specifies the current size of tokens[].
	   THIS METHOD MODIFIES string.  */

	const wchar_t *whitespace = L" \t\r\n";
	wchar_t *tokenEnd = 0;
	const wchar_t *quoteCharacters = L"\"\'";
	wchar_t *end = string + wcslen(string);

	if (string == NULL)
		return length;

	while (1)
	{
		const wchar_t *q;
		/* Skip over initial whitespace.  */
		string += wcsspn(string, whitespace);
		if (*string == '\0')
			break;

		for (q = quoteCharacters; *q; ++q)
		{
			if (*string == *q)
				break;
		}
		if (*q)
		{
			/* Token is quoted.  */
			wchar_t quote = *string++;
			tokenEnd = wcschr(string, quote);
			/* If there is no endquote, the token is the rest of the string.  */
			if (!tokenEnd)
				tokenEnd = end;
		}
		else
		{
			tokenEnd = string + wcscspn(string, whitespace);
		}

		*tokenEnd = '\0';

		{
			wchar_t **new_tokens;
			int newlen = length + 1;
			new_tokens = (wchar_t **)realloc (*tokens, sizeof (wchar_t**) * newlen);
			if (!new_tokens)
			{
				/* Out of memory.  */
				return -1;
			}

			*tokens = new_tokens;
			(*tokens)[length] = string;
			length = newlen;
		}
		if (tokenEnd == end)
			break;
		string = tokenEnd + 1;
	}
	return length;
}

VM_C_API void parse_args(int *argc, wchar_t ***argv, wchar_t *cmdlinePtrW)
{
	int cmdlineLen = 0;

	if (!cmdlinePtrW)
		cmdlineLen = 0;
	else
		cmdlineLen = wcslen(cmdlinePtrW);

	/* gets realloc()'d later */
	*argc = 0;
	*argv = (wchar_t **)malloc (sizeof (wchar_t**));

	if (!*argv)
		ExitProcess(1);

#ifdef WINCE
	wchar_t cmdnameBufW[MAX_UNICODE_PATH];

	/* argv[0] is the path of invoked program - get this from CE.  */
	cmdnameBufW[0] = 0;
	GetModuleFileNameW(NULL, cmdnameBufW, sizeof (cmdnameBufW)/sizeof (cmdnameBufW[0]));

	(*argv)[0] = wcsdup(cmdnameBufW);
	if(!(*argv[0]))
		ExitProcess(1);
	/* Add one to account for argv[0] */
	(*argc)++;
#endif

	if (cmdlineLen > 0)
	{
		wchar_t *argv1 = wcsdup(cmdlinePtrW);
		if(!argv1)
			ExitProcess(1);
		*argc = parse_tokens(argv1, argv, *argc);
		if (*argc < 0)
			ExitProcess(1);
	}
	(*argv)[*argc] = 0;
	return;
}

}
