#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <time.h>
#include <errno.h>
#include <linux/errqueue.h>

long get_nanos(struct timespec *ts) {
    return ts->tv_sec * 1000000000 + ts->tv_nsec;
}

typedef struct {
    char *fields[8]; 
} Message;

typedef struct {
    char *server_ip;
    int port;
    int duration;
    int msg_size;
    double result_throughput;
    double result_latency;
} ThreadArgs;

void generate_random_string(char *str, int length) {
    for (int i = 0; i < length; i++) {
        str[i] = 'A' + (rand() % 26);
    }
    str[length] = '\0';
}

void recv_completions(int sock) {
    struct msghdr msg = {0};
    char control[100];
    struct cmsghdr *cmsg;
    int ret;

    msg.msg_control = control;
    msg.msg_controllen = sizeof(control);

    while (1) {
        ret = recvmsg(sock, &msg, MSG_ERRQUEUE | MSG_DONTWAIT);
        if (ret == -1) {
            if (errno == EAGAIN || errno == EWOULDBLOCK) return; 
            return;
        }
    }
}

void *client_thread_func(void *arg) {
    ThreadArgs *args = (ThreadArgs *)arg;
    int sock= socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in server_addr;

    if (sock  < 0) {
        perror("Socket failed");
        return NULL;
    }

    // Enable Zero Copy
    int one = 1;
    if (setsockopt(sock, SOL_SOCKET, SO_ZEROCOPY, &one, sizeof(one))) {
        perror("SO_ZEROCOPY failed");
        return NULL;
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(args->port);
    inet_pton(AF_INET, args->server_ip, &server_addr.sin_addr);

    if (connect(sock, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("Connection Failed");
        close(sock);
        return NULL;
    }

    int chunk_size = args->msg_size/8;
    int remainder = args->msg_size%8;
    Message msg;
    
    for(int i=0;i<8;i++) {
        int current_chunk;
        if(i==7)
            current_chunk=chunk_size + remainder;
        
        else current_chunk=chunk_size;

        msg.fields[i] = malloc(current_chunk);
        generate_random_string(msg.fields[i], current_chunk - 1);
    }

    struct iovec iov[8];
    struct msghdr msg_header = {0};

    for(int i=0;i<8;i++) {
        int current_chunk;
        if(i==7)
            current_chunk=chunk_size + remainder;
        
        else current_chunk=chunk_size;

        iov[i].iov_base = msg.fields[i];
        iov[i].iov_len = current_chunk;
    }
    msg_header.msg_iov = iov;
    msg_header.msg_iovlen = 8;

    long total_bytes_sent= 0;
    long total_latency_ns= 0;
    long total_calls= 0;
    struct timespec start, end, exp_start, now;

    clock_gettime(CLOCK_MONOTONIC, &exp_start);

    while (1) {
        clock_gettime(CLOCK_MONOTONIC, &now);
        if (now.tv_sec - exp_start.tv_sec >= args->duration) break;

        clock_gettime(CLOCK_MONOTONIC, &start);

        // Send with MSG_ZEROCOPY
        ssize_t sent = sendmsg(sock, &msg_header, MSG_ZEROCOPY);

        clock_gettime(CLOCK_MONOTONIC, &end);

        if (sent < 0) {
            if (errno == ENOBUFS) {
                recv_completions(sock);
                continue; 
            }
            break;
        }

        total_bytes_sent+= sent;
        total_calls++;
        int k=get_nanos(&end) - get_nanos(&start);
        total_latency_ns+= k;

        // Must drain error queue
        recv_completions(sock);
    }

    if (total_calls > 0) {
        args->result_throughput = (total_bytes_sent * 8.0)/(args->duration * 1e9);
        args->result_latency = (double) total_latency_ns/total_calls/1000.0;
    } else {
        args->result_throughput= 0;
        args->result_latency= 0;
    }

    for(int i=0;i<8;i++)    free(msg.fields[i]);
    close(sock);
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 6) {
        printf("Usage: %s <IP> <Port> <Time> <Threads> <MsgSize>\n", argv[0]);
        return -1;
    }

    int num_threads = atoi(argv[4]);
    pthread_t threads[num_threads];
    ThreadArgs thread_args[num_threads];

    for (int i = 0; i < num_threads; i++) {
        thread_args[i].server_ip = argv[1];
        thread_args[i].port = atoi(argv[2]);
        thread_args[i].duration = atoi(argv[3]);
        thread_args[i].msg_size = atoi(argv[5]);
        pthread_create(&threads[i], NULL, client_thread_func, (void *)&thread_args[i]);
    }

    double total_throughput = 0;
    double total_latency_sum = 0;

    for (int i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
        total_throughput += thread_args[i].result_throughput;
        total_latency_sum += thread_args[i].result_latency;
    }

    printf("%.6f,%.6f\n", total_throughput, total_latency_sum/num_threads);
    return 0;
}