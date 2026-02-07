import matplotlib.pyplot as plt
import numpy as np

# ==========================================
# PASTE YOUR DATA HERE FROM THE CSV
# ==========================================

# 1. THROUGHPUT vs MESSAGE SIZE (Thread Count = 1)
# Copy the 'Throughput_Gbps' column for Threads=1
sizes_kb = ['1KB', '32KB', '128KB', '1MB']
thru_A1 = [4.742413, 46.89515, 75.597506, 67.511517]  # REPLACE with your A1 values
thru_A2 = [4.268309, 51.56535, 90.566977, 100.269031]  # REPLACE with your A2 values
thru_A3 = [2.522402,36.693344,64.999339,79.05592]  # REPLACE with your A3 values

# 2. LATENCY vs THREAD COUNT (Message Size = 32KB)
# Copy the 'Latency_us' column for Size=32KB
threads = ['1', '2', '4', '8']
lat_A1 = [05.494517,5.518251,5.819878,7.636283]   # REPLACE with your A1 values
lat_A2 = [4.98684,5.148212,5.417695,7.291491]   # REPLACE with your A2 values
lat_A3 = [6.563802,6.890608,7.238484,9.656879]   # REPLACE with your A3 values

# 3. CACHE MISSES vs MESSAGE SIZE (Threads = 1)
# Copy 'LLC_Misses' (Last Level Cache) for Threads=1
cache_A1 = [3802,4666,8256,116554]         # REPLACE with your A1 values
cache_A2 = [3206,5926,11702,18735]         # REPLACE with your A2 values
cache_A3 = [20369,4295,10560,16295]         # REPLACE with your A3 values

# 4. CPU CYCLES PER BYTE (Threads = 1)
# Calculation: (Total Cycles) / (Total Bytes Transferred)
# You might need to calculate this manually from CSV columns: Cycles / (MsgSize * Count)
cycles_A1 = [0, 0, 0, 0]        
cycles_A2 = [0, 0, 0, 0]
cycles_A3 = [0, 0, 0, 0]

# ==========================================
# PLOTTING FUNCTIONS
# ==========================================

def plot_throughput():
    x = np.arange(len(sizes_kb))
    width = 0.2
    
    plt.figure(figsize=(10, 6))
    plt.bar(x - width, thru_A1, width, label='A1 (Two-Copy)')
    plt.bar(x, thru_A2, width, label='A2 (One-Copy)')
    plt.bar(x + width, thru_A3, width, label='A3 (Zero-Copy)')
    
    plt.xlabel('Message Size')
    plt.ylabel('Throughput (Gbps)')
    plt.title('Throughput vs Message Size (Threads=1)')
    plt.xticks(x, sizes_kb)
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig('Plot_Throughput.png')
    plt.show()

def plot_latency():
    x = np.arange(len(threads))
    
    plt.figure(figsize=(10, 6))
    plt.plot(x, lat_A1, marker='o', label='A1 (Two-Copy)')
    plt.plot(x, lat_A2, marker='s', label='A2 (One-Copy)')
    plt.plot(x, lat_A3, marker='^', label='A3 (Zero-Copy)')
    
    plt.xlabel('Thread Count')
    plt.ylabel('Latency (microseconds)')
    plt.title('Latency vs Thread Count (Size=32KB)')
    plt.xticks(x, threads)
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig('Plot_Latency.png')
    plt.show()

def plot_cache():
    x = np.arange(len(sizes_kb))
    width = 0.2
    
    plt.figure(figsize=(10, 6))
    plt.bar(x - width, cache_A1, width, label='A1')
    plt.bar(x, cache_A2, width, label='A2')
    plt.bar(x + width, cache_A3, width, label='A3')
    
    plt.xlabel('Message Size')
    plt.ylabel('LLC Load Misses')
    plt.title('Cache Misses vs Message Size')
    plt.xticks(x, sizes_kb)
    plt.legend()
    plt.yscale('log') # Log scale often helps with cache misses
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig('Plot_Cache.png')
    plt.show()

if __name__ == "__main__":
    plot_throughput()
    plot_latency()
    plot_cache()
    # plot_cycles() # Uncomment if you populate the cycles data