#!/bin/bash
#Name - "Samyak Kr Sharma"
#ROLL_NUM - "MT25039" 

# --- CONFIGURATION ---
SERVER_BIN="./server"
CLIENT_A1="./client_A1"
CLIENT_A2="./client_A2"
CLIENT_A3="./client_A3"
IP="10.0.0.1"
PORT=8080

# 1. Compile
echo "--- Compiling ---"
gcc MT25039_Part_A1_Server.c -o server -pthread
gcc MT25039_Part_A1_Client.c -o client_A1 -pthread
gcc MT25039_Part_A2_Client.c -o client_A2 -pthread
gcc MT25039_Part_A3_Client.c -o client_A3 -pthread

if [ ! -f $SERVER_BIN ]; then echo "Compilation Failed!"; exit 1; fi

# Function to run a test
run_test() {
    VERSION=$1
    CLIENT_EXEC=$2
    echo "------------------------------------------------"
    echo "Testing Part $VERSION (Connectivity Check)..."
    
    # Start Server in Namespace
    sudo ip netns exec server_ns $SERVER_BIN $PORT > /dev/null 2>&1 &
    SERVER_PID=$!
    sleep 1

    # Run Client (Short duration: 2s, 1 Thread, 1KB size)
    sudo ip netns exec client_ns $CLIENT_EXEC $IP $PORT 2 1 1024 > temp_output.txt
    
    # Check if client exited successfully
    if [ $? -eq 0 ]; then
        echo "✅ Part $VERSION: Client ran successfully."
        cat temp_output.txt | grep "throughput" # Show the data line
    else
        echo "❌ Part $VERSION: Client Failed!"
    fi

    # Cleanup
    sudo kill $SERVER_PID 2>/dev/null
    wait $SERVER_PID 2>/dev/null
    rm temp_output.txt
}

# Run the 3 Tests
run_test "A1 (Baseline)" $CLIENT_A1
run_test "A2 (One-Copy)" $CLIENT_A2
run_test "A3 (Zero-Copy)" $CLIENT_A3

echo "------------------------------------------------"
echo "Demo Complete."