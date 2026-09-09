#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#define CHECK(x) do { if (!(x)) { perror(#x); return 1; } } while (0)
int main(void) {
    char directory[] = "/tmp/factor-file-flags-XXXXXX";
    CHECK(mkdtemp(directory));
    CHECK(chdir(directory) == 0);
    int first = open("append", O_WRONLY | O_CREAT | O_APPEND, 0600);
    CHECK(first >= 0);
    CHECK(fcntl(first, F_SETFL, fcntl(first, F_GETFL) | O_NONBLOCK) == 0);
    int second = open("append", O_WRONLY | O_APPEND);
    CHECK(second >= 0);
    CHECK(write(second, "b", 1) == 1);
    CHECK(write(first, "a", 1) == 1);
    CHECK(close(first) == 0 && close(second) == 0);
    first = open("append", O_RDONLY);
    char bytes[2];
    CHECK(read(first, bytes, 2) == 2 && memcmp(bytes, "ba", 2) == 0);
    CHECK(close(first) == 0 && unlink("append") == 0);
    CHECK(mkfifo("pipe", 0600) == 0);
    CHECK(open("pipe", O_WRONLY | O_NONBLOCK) == -1 && errno == ENXIO);
    first = open("pipe", O_RDONLY | O_NONBLOCK);
    CHECK(first >= 0 && read(first, bytes, 1) == 0);
    second = open("pipe", O_WRONLY | O_APPEND | O_NONBLOCK);
    CHECK(second >= 0);
    CHECK(lseek(second, 0, SEEK_END) == -1 && errno == ESPIPE);
    CHECK(write(second, "x", 1) == 1 && read(first, bytes, 1) == 1 && bytes[0] == 'x');
    CHECK(close(first) == 0 && close(second) == 0 && unlink("pipe") == 0);
    CHECK(chdir("/") == 0 && rmdir(directory) == 0);
    puts("C-CONTROL append, nonblocking FIFO, FIFO appender passed");
    return 0;
}
