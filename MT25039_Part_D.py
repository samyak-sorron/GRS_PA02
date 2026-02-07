import matplotlib.pyplot as plt
import numpy as np

# THROUGHPUT vs MESSAGE SIZE (Thread Count = 1)
sizes_kb = ['1KB', '32KB', '128KB', '1MB']

thru_A1 = [3.76, 47.52, 74.84, 69.22]  
thru_A2 = [4.04, 50.76, 91.13, 101.89] 
thru_A3 = [2.31, 34.92, 61.73, 76.60] 

# LATENCY vs THREAD COUNT (Message Size = 32KB)
threads = ['1', '2', '4', '8']

lat_A1 = [5.41, 5.57, 5.90, 7.38]
lat_A2 = [5.07, 5.19, 5.42, 7.34]
lat_A3 = [6.76, 6.97, 7.28, 9.62]

# CACHE MISSES vs MESSAGE SIZE (Threads = 1)
cache_A1 = [4342, 7103, 15183, 22265]
cache_A2 = [5275, 5442, 9729, 27012]
cache_A3 = [3428, 5554, 65405, 84021]

# CPU CYCLES PER BYTE (Threads = 1)
cycles_A1 = [8.07, 0.77, 0.49, 0.53]
cycles_A2 = [9.15, 0.73, 0.41, 0.36]
cycles_A3 = [16.02, 1.05, 0.59, 0.47]

def plot_throughput():
    x = np.arange(len(sizes_kb))
    width = 0.2
    
    plt.figure(figsize=(10, 6))
    plt.bar(x - width, thru_A1, width, label='A1 (Two-Copy)', color='#1f77b4')
    plt.bar(x, thru_A2, width, label='A2 (One-Copy)', color='#ff7f0e')
    plt.bar(x + width, thru_A3, width, label='A3 (Zero-Copy)', color='#2ca02c')
    
    plt.xlabel('Message Size')
    plt.ylabel('Throughput (Gbps)')
    plt.title('Throughput vs Message Size (Threads=1)')
    plt.xticks(x, sizes_kb)
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.savefig('MT25039_Plot_Throughput.png')
    print("Generated: MT25039_Plot_Throughput.png")

def plot_latency():
    x = np.arange(len(threads))
    
    plt.figure(figsize=(10, 6))
    plt.plot(x, lat_A1, marker='o', label='A1 (Two-Copy)', linewidth=2)
    plt.plot(x, lat_A2, marker='s', label='A2 (One-Copy)', linewidth=2)
    plt.plot(x, lat_A3, marker='^', label='A3 (Zero-Copy)', linewidth=2)
    
    plt.xlabel('Thread Count')
    plt.ylabel('Latency (microseconds)')
    plt.title('Latency vs Thread Count (Size=32KB)')
    plt.xticks(x, threads)
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.savefig('MT25039_Plot_Latency.png')
    print("Generated: MT25039_Plot_Latency.png")

def plot_cache():
    x = np.arange(len(sizes_kb))
    width = 0.2
    
    plt.figure(figsize=(10, 6))
    plt.bar(x - width, cache_A1, width, label='A1 (Two-Copy)')
    plt.bar(x, cache_A2, width, label='A2 (One-Copy)')
    plt.bar(x + width, cache_A3, width, label='A3 (Zero-Copy)')
    
    plt.xlabel('Message Size')
    plt.ylabel('LLC Load Misses (Log Scale)')
    plt.title('Cache Misses vs Message Size')
    plt.xticks(x, sizes_kb)
    plt.legend()
    plt.yscale('log') # Log scale is crucial here
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.savefig('MT25039_Plot_Cache.png')
    print("Generated: MT25039_Plot_Cache.png")

def plot_cycles():
    x = np.arange(len(sizes_kb))
    width = 0.2
    
    plt.figure(figsize=(10, 6))
    plt.bar(x - width, cycles_A1, width, label='A1 (Two-Copy)')
    plt.bar(x, cycles_A2, width, label='A2 (One-Copy)')
    plt.bar(x + width, cycles_A3, width, label='A3 (Zero-Copy)')
    
    plt.xlabel('Message Size')
    plt.ylabel('CPU Cycles per Byte')
    plt.title('CPU Efficiency (Cycles per Byte)')
    plt.xticks(x, sizes_kb)
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.savefig('MT25039_Plot_Cycles.png')
    print("Generated: MT25039_Plot_Cycles.png")

if __name__ == "__main__":
    plot_throughput()
    plot_latency()
    plot_cache()
    plot_cycles()