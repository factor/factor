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
		CELL mode = tag_integer(sb.st_mode);
		CELL size = tag_object(s48_long_long_to_bignum(sb.st_size));
		CELL mtime = tag_integer(sb.st_mtime);
		dpush(tag_cons(cons(
			mode,
			tag_cons(cons(
				size,
				tag_cons(cons(
					mtime,F)))))));
	}
}
