/* Private guest console for stock images without SSH. See README.md. */
#include <arpa/inet.h>
#include <errno.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <unistd.h>

int main(int argc, char **argv) {
    char *end;
    long port = argc == 3 ? strtol(argv[2], &end, 10) : 0;
    struct sockaddr_in address = {0};
    address.sin_family = AF_INET;
    if (argc != 3 || !port || port > 65535 || port < 0 || *end ||
        inet_pton(AF_INET, argv[1], &address.sin_addr) != 1) {
        fprintf(stderr, "Usage: %s GUEST_IPV4 PORT\n", argv[0]);
        return 2;
    }
    address.sin_port = htons((unsigned short)port);
    int listener = socket(AF_INET, SOCK_STREAM, 0);
    int reuse = 1;
    if (listener < 0 ||
        setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0 ||
        bind(listener, (struct sockaddr *)&address, sizeof(address)) < 0 ||
        listen(listener, 8) < 0 || signal(SIGCHLD, SIG_IGN) == SIG_ERR) {
        perror("guest console");
        return 1;
    }
    for (;;) {
        int client = accept(listener, NULL, NULL);
        if (client < 0) {
            if (errno == EINTR) continue;
            perror("accept");
            return 1;
        }
        pid_t child = fork();
        if (child == 0) {
            close(listener);
            if (signal(SIGCHLD, SIG_DFL) == SIG_ERR) _exit(126);
            for (int fd = 0; fd < 3; ++fd)
                if (dup2(client, fd) < 0) _exit(126);
            if (client > 2) close(client);
            execl("/bin/sh", "sh", (char *)NULL);
            _exit(127);
        }
        close(client);
        if (child < 0) perror("fork");
    }
}
