#include <stdio.h>
#include <stddef.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <time.h>
int main(void) { printf("time_t=%zu timeval=%zu timeval_usec_offset=%zu timespec=%zu timespec_nsec_offset=%zu stat=%zu stat_size_offset=%zu stat_size_width=%zu\n",sizeof(time_t),sizeof(struct timeval),offsetof(struct timeval,tv_usec),sizeof(struct timespec),offsetof(struct timespec,tv_nsec),sizeof(struct stat),offsetof(struct stat,st_size),sizeof(((struct stat*)0)->st_size));return 0; }
