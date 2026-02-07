#!/bin/bash

#ROLL_NUM - "MT25039" 



if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <Version: A1|A2|A3> <Threads> <MsgSize>"
    echo "Example: $0 A3 4 32768"
    exit 1
fi

VER=$1
THREADS=$2
SIZE=$3

CLIENT_BIN="./client_${VER}"
SERVER_IP="10.8.5.10"
PORT=8080
DURATION=5


if [ ! -f $CLIENT_BIN ]; then
    echo "Error: Binary $CLIENT_BIN not found. Compile first."
    exit 1
fi

echo "=========================================="
echo " PROFILING: Version=$VER | Threads=$THREADS | Size=$SIZE"
echo "=========================================="


sudo ip netns exec server_ns ./server $PORT > /dev/null 2>&1 &
SERVER_PID=$!
sleep 1

# Run Perf
echo "Running Perf..."
sudo ip netns exec client_ns perf stat \
    -e cycles,instructions,cache-misses,L1-dcache-load-misses,LLC-load-misses,cs \
    $CLIENT_BIN $SERVER_IP $PORT $DURATION $THREADS $SIZE

# Cleanup
sudo kill $SERVER_PID
wait $SERVER_PID 2>/dev/null

echo "=========================================="
echo "Done."