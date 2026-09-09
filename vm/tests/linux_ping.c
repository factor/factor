#include <arpa/inet.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>

int main(void) {
    int fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
    if (fd < 0) { perror("ICMP datagram socket"); return 1; }
    struct timeval timeout = { 1, 0 };
    if (setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout))) return 1;
    struct sockaddr_in peer = { .sin_family = AF_INET };
    inet_pton(AF_INET, "127.0.0.1", &peer.sin_addr);
    unsigned char packet[8] = { 8, 0, 0xf7, 0xff, 0, 0, 0, 0 };
    if (sendto(fd, packet, sizeof(packet), 0, (struct sockaddr *)&peer, sizeof(peer)) != sizeof(packet)) return 1;
    ssize_t length = recv(fd, packet, sizeof(packet), 0);
    close(fd);
    if (length != sizeof(packet) || packet[0] != 0 || packet[1] != 0) return 1;
    puts("C-CONTROL Linux ICMP datagram reply excludes the IP header");
    return 0;
}
