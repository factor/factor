#ifndef __FACTOR_H__
#define __FACTOR_H__

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <setjmp.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#define INLINE inline static

/* CELL must be 32 bits and your system must have 32-bit pointers */
typedef unsigned long int CELL;
#define CELLS sizeof(CELL)

/* must always be 16 bits */
typedef unsigned short CHAR;
#define CHARS sizeof(CHAR)

/* must always be 8 bits */
typedef unsigned char BYTE;
#define BYTES 1

/* Memory heap size */
#define DEFAULT_ARENA (128 * 1024 * 1024)
#define STACK_SIZE 1024

#include "error.h"
#include "memory.h"
#include "gc.h"
#include "types.h"
#include "array.h"
#include "handle.h"
#include "fixnum.h"
#include "bignum.h"
#include "arithmetic.h"
#include "string.h"
#include "fd.h"
#include "file.h"
#include "cons.h"
#include "word.h"
#include "run.h"
#include "image.h"
#include "primitives.h"
#include "vector.h"
#include "socket.h"
#include "stack.h"
#include "sbuf.h"
#include "relocate.h"

#endif /* __FACTOR_H__ */
