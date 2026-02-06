CC = gcc
CFLAGS = -pthread
ROLL_NUM = MT25039

# Target Binaries
SERVER = server
CLIENT_A1 = client_A1
CLIENT_A2 = client_A2
CLIENT_A3 = client_A3

# Source Files
SERVER_SRC = $(ROLL_NUM)_Part_A1_Server.c
CLIENT_A1_SRC = $(ROLL_NUM)_Part_A1_Client.c
CLIENT_A2_SRC = $(ROLL_NUM)_Part_A2_Client.c
CLIENT_A3_SRC = $(ROLL_NUM)_Part_A3_Client.c

all: $(SERVER) $(CLIENT_A1) $(CLIENT_A2) $(CLIENT_A3)

$(SERVER): $(SERVER_SRC)
    $(CC) $(SERVER_SRC) -o $(SERVER) $(CFLAGS)

$(CLIENT_A1): $(CLIENT_A1_SRC)
    $(CC) $(CLIENT_A1_SRC) -o $(CLIENT_A1) $(CFLAGS)

$(CLIENT_A2): $(CLIENT_A2_SRC)
    $(CC) $(CLIENT_A2_SRC) -o $(CLIENT_A2) $(CFLAGS)

$(CLIENT_A3): $(CLIENT_A3_SRC)
    $(CC) $(CLIENT_A3_SRC) -o $(CLIENT_A3) $(CFLAGS)

clean:
    rm -f $(SERVER) $(CLIENT_A1) $(CLIENT_A2) $(CLIENT_A3)