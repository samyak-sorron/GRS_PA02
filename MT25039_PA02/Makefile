# Roll No.- MT25039

CC = gcc
CFLAGS = -pthread -std=c99 -D_POSIX_C_SOURCE=200112L

# Target Binaries
SER = server
A1 = client_A1
A2 = client_A2
A3 = client_A3

# Source Files
SERVER_SRC = MT25039_Part_A1_Server.c
A1_SRC = MT25039_Part_A1_Client.c
A2_SRC = MT25039_Part_A2_Client.c
A3_SRC = MT25039_Part_A3_Client.c

all: $(SER) $(A1) $(A2) $(A3)

$(SER): $(SERVER_SRC)
	$(CC) $(SERVER_SRC) -o $(SER) $(CFLAGS)

$(A1): $(A1_SRC)
	$(CC) $(A1_SRC) -o $(A1) $(CFLAGS)

$(A2): $(A2_SRC)
	$(CC) $(A2_SRC) -o $(A2) $(CFLAGS)

$(A3): $(A3_SRC)
	$(CC) $(A3_SRC) -o $(A3) $(CFLAGS)

clean:
	rm -f $(SER) $(A1) $(A2) $(A3)
