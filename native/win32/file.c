#include "../factor.h"

void primitive_open_file(void) 
{
	bool write = unbox_boolean();
	bool read = unbox_boolean();
	char *path;
	DWORD mode = 0, create = 0;
	HANDLE fp;
	SECURITY_ATTRIBUTES sa;

	path = unbox_c_string();

	mode |= write ? GENERIC_WRITE : 0;
	mode |= read ? GENERIC_READ : 0;

	if (read && write)
		create = OPEN_ALWAYS;
	else if (read)
		create = OPEN_EXISTING;
	else if (write)
		create = CREATE_ALWAYS;

	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	sa.lpSecurityDescriptor = NULL;
	sa.bInheritHandle = true;

	fp = CreateFile(
		path, 
		mode, 
		FILE_SHARE_DELETE|FILE_SHARE_READ|FILE_SHARE_WRITE,
		&sa,
		create,
		/* FILE_FLAG_OVERLAPPED TODO */0, 
		NULL);

	if (fp == INVALID_HANDLE_VALUE) 
	{
		io_error(__FUNCTION__);
	} 
	else 
	{
		dpush(read ? tag_object(port(PORT_READ, (CELL)fp)) : F);
		dpush(write ? tag_object(port(PORT_WRITE, (CELL)fp)) : F);
	}
}

void primitive_stat(void)
{
	F_STRING *path;
	WIN32_FILE_ATTRIBUTE_DATA st;

	maybe_garbage_collection();
	path = untag_string(dpop());

	if(!GetFileAttributesEx(to_c_string(path), GetFileExInfoStandard, &st)) 
	{
		dpush(F);
	} 
	else 
	{
		CELL dirp = tag_boolean(st.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY);
		CELL size = tag_bignum(s48_long_long_to_bignum(
			(int64_t)st.nFileSizeLow | (int64_t)st.nFileSizeHigh << 32));
		CELL mtime = tag_integer((int)
			((*(int64_t*)&st.ftLastWriteTime - EPOCH_OFFSET) / 10000000));
		dpush(
			cons(dirp,
			cons(tag_fixnum(0),
			cons(size,
			cons(mtime, F)))));
	}
}

void primitive_read_dir(void)
{
	F_STRING *path;
	HANDLE dir;
	WIN32_FIND_DATA find_data;
	CELL result = F;

	maybe_garbage_collection();

	path = untag_string(dpop());
	if (INVALID_HANDLE_VALUE != (dir = FindFirstFile(".\\*", &find_data)))
	{
		do 
		{
			CELL name = tag_object(from_c_string(find_data.cFileName));
			result = cons(name, result);
		} 
		while (FindNextFile(dir, &find_data));
		CloseHandle(dir);
	}

	dpush(result);
}

void primitive_cwd(void)
{
	char buf[MAX_PATH];

	maybe_garbage_collection();
	if(!GetCurrentDirectory(MAX_PATH, buf))
		io_error(__FUNCTION__);

	box_c_string(buf);
}

void primitive_cd(void)
{
	maybe_garbage_collection();
	SetCurrentDirectory(unbox_c_string());
}