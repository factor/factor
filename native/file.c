#include "factor.h"

void primitive_open_file(void)
{
	bool write = untag_boolean(dpop());
	bool read = untag_boolean(dpop());
	char* path = to_c_string(untag_string(dpop()));
	int mode;
	int fd;

	if(read && write)
		mode = O_RDWR | O_CREAT;
	else if(read)
		mode = O_RDONLY;
	else if(write)
		mode = O_WRONLY | O_CREAT | O_TRUNC;
	else
		mode = 0;

	fd = open(path,mode,FILE_MODE);
	if(fd < 0)
		io_error(__FUNCTION__);

	dpush(read ? tag_object(port(PORT_READ,fd)) : F);
	dpush(write ? tag_object(port(PORT_WRITE,fd)) : F);
}

void primitive_stat(void)
{
	struct stat sb;
	STRING* path = untag_string(dpop());
	if(stat(to_c_string(path),&sb) < 0)
		dpush(F);
	else
	{
		CELL dirp = tag_boolean(S_ISDIR(sb.st_mode));
		CELL mode = tag_fixnum(sb.st_mode & ~S_IFMT);
		CELL size = tag_object(s48_long_long_to_bignum(sb.st_size));
		CELL mtime = tag_integer(sb.st_mtime);
		dpush(tag_cons(cons(
			dirp,
			tag_cons(cons(
				mode,
				tag_cons(cons(
					size,
					tag_cons(cons(
						mtime,F)))))))));
	}
}

void primitive_read_dir(void)
{
	STRING* path = untag_string(dpop());
	DIR* dir = opendir(to_c_string(path));
	CELL result = F;
	if(dir != NULL)
	{
		struct dirent* file;

		while(file = readdir(dir))
		{
			CELL name = tag_object(from_c_string(
				file->d_name));
			CELL dirp = tag_boolean(
				file->d_type == DT_DIR);
			CELL entry = tag_cons(cons(name,dirp));
			result = tag_cons(cons(entry,result));
		}

		closedir(dir);
	}

	dpush(result);
}
