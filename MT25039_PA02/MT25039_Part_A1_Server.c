#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define BACKLOG 10

// Arguments passed to the thread handling a client
typedef struct {
    int client_sock;
} ThreadArgs;

// This function handles one specific client connection
void *handle_client(void *arg) {
    ThreadArgs *args = (ThreadArgs *)arg;
    int sock = args->client_sock;
    free(args); // Free the memory allocated in main loop

    // We use a large buffer to receive data.
    // The size doesn't strictly matter for correctness, 
    // but 64KB is a standard large chunk.
    char buffer[65536]; 
    ssize_t bytes_read;

    // Keep receiving until the client closes the connection (returns 0)
    // or an error occurs (returns < 0)
    while ((bytes_read = recv(sock, buffer, sizeof(buffer), 0)) > 0) {
        // We don't need to do anything with the data for this experiment.
        // Just receiving it consumes the bandwidth.
    }

    close(sock);
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <Port>\n", argv[0]);
        return -1;
    }

    int port = atoi(argv[1]);
    int server_fd;
    struct sockaddr_in address;

    // 1. Create Socket
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("Socket failed");
        exit(EXIT_FAILURE);
    }

    // Optional: Allow immediate reuse of the port after stopping server
    int opt = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY; // Listen on all interfaces (including the veth)
    address.sin_port = htons(port);

    // 2. Bind
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    // 3. Listen
    if (listen(server_fd, BACKLOG) < 0) {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }

    printf("Server listening on port %d...\n", port);

    while (1) {
        struct sockaddr_in client_addr;
        socklen_t addr_len = sizeof(client_addr);
        
        // 4. Accept new connection
        int new_sock = accept(server_fd, (struct sockaddr *)&client_addr, &addr_len);
        if (new_sock < 0) {
            perror("Accept failed");
            continue;
        }

        // 5. Create a thread for this client
        pthread_t thread_id;
        ThreadArgs *args = malloc(sizeof(ThreadArgs));
        args->client_sock = new_sock;

        if (pthread_create(&thread_id, NULL, handle_client, (void *)args) != 0) {
            perror("Thread create failed");
            free(args);
            close(new_sock);
        } else {
            // Detach thread so resources are freed automatically when it finishes
            pthread_detach(thread_id);
        }
    }

    return 0;
}