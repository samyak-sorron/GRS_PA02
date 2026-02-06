#!/bin/bash

# --- CONFIGURATION ---
ROLL_NUM="MT25039" 
RESULTS_FILE="${ROLL_NUM}_results.csv"
DURATION=5         
SERVER_IP="10.0.0.1"
PORT=8080

# Experiment Parameters
SIZES=(1024 32768 131072 1048576)
THREADS=(1 2 4 8)
VERSIONS=("A1" "A2" "A3")

# --- COMPILATION ---
echo "Compiling programs..."
# Ensure we compile correctly
make clean > /dev/null 2>&1
make > /dev/null 2>&1

# If make fails or isn't used, fallback to manual gcc
if [ ! -f "client_A1" ]; then
    gcc ${ROLL_NUM}_Part_A1_Server.c -o server -pthread
    gcc ${ROLL_NUM}_Part_A1_Client.c -o client_A1 -pthread
    gcc ${ROLL_NUM}_Part_A2_Client.c -o client_A2 -pthread
    gcc ${ROLL_NUM}_Part_A3_Client.c -o client_A3 -pthread
fi

# --- CSV HEADER ---
echo "Version,MsgSize,Threads,Throughput_Gbps,Latency_us,Cycles,L1_Misses,LLC_Misses,Context_Switches" > $RESULTS_FILE

# --- EXPERIMENT LOOP ---
echo "Starting Experiments..."

for VER in "${VERSIONS[@]}"; do
    CLIENT_BIN="./client_${VER}"
    
    for SIZE in "${SIZES[@]}"; do
        for THREAD in "${THREADS[@]}"; do
            echo "Running: Ver=$VER | Size=$SIZE | Threads=$THREAD"
            
            # 1. Start Server
            sudo ip netns exec server_ns ./server $PORT > /dev/null 2>&1 &
            SERVER_PID=$!
            sleep 1

            # 2. Run Client wrapped in PERF
            # We use -e events specific to cpu_core to avoid the 'atom' confusion if possible,
            # but standard names work if we grep intelligently.
            sudo ip netns exec client_ns perf stat \
                -e cycles,L1-dcache-load-misses,LLC-load-misses,cs \
                -x, -o perf_out.txt \
                $CLIENT_BIN $SERVER_IP $PORT $DURATION $THREAD $SIZE > app_out.txt

            # 3. Kill Server
            sudo kill $SERVER_PID 2>/dev/null
            wait $SERVER_PID 2>/dev/null

            # --- ROBUST PARSING (THE FIX) ---
            
            # Get App Data (Throughput, Latency)
            APP_DATA=$(cat app_out.txt)
            if [ -z "$APP_DATA" ]; then APP_DATA="0,0"; fi
            
            # Function to extract the first valid number for a metric
            # It looks for the metric name, filters out '<not supported>', and takes the largest number (usually cpu_core)
            get_perf_val() {
                grep "$1" perf_out.txt | grep -v "<not supported>" | cut -d',' -f1 | sort -rn | head -n1
            }

            CYCLES=$(get_perf_val "cycles")
            L1_MISS=$(get_perf_val "L1-dcache-load-misses")
            LLC_MISS=$(get_perf_val "LLC-load-misses")
            CS=$(get_perf_val "cs")

            # Fallbacks to 0 if empty
            CYCLES=${CYCLES:-0}
            L1_MISS=${L1_MISS:-0}
            LLC_MISS=${LLC_MISS:-0}
            CS=${CS:-0}

            # Append to CSV
            echo "$VER,$SIZE,$THREAD,$APP_DATA,$CYCLES,$L1_MISS,$LLC_MISS,$CS" >> $RESULTS_FILE
        done
    done
done

echo "---------------------------------------"
echo "Experiment Complete!"
echo "Data saved to: $RESULTS_FILE"