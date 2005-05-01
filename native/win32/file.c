#include "../factor.h"

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
			(s64)st.nFileSizeLow | (s64)st.nFileSizeHigh << 32));
		CELL mtime = tag_integer((int)
			((*(s64*)&st.ftLastWriteTime - EPOCH_OFFSET) / 10000000));
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