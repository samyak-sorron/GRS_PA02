# Network Data Movement Analysis (PA02)

**Name:** Samyak Kr Sharma

**Roll Number:** MT25039

## 📌 Objective
The goal of this assignment is to experimentally study the cost of data movement in network I/O by implementing and comparing:
- Standard two-copy socket communication
- One-copy optimized socket communication
- Zero-copy socket communication

The project includes multithreaded client–server C programs, profile them on your own machine, and analyze micro-architectural effects such as CPU cycles and cache behavior.
---

## 📂 Project Structure

```text
MT25039_PA02/
├── MT25039_Part_A1_Server.c    # Common Server implementation
├── MT25039_Part_A1_Client.c    # Client A1: Standard Two-Copy
├── MT25039_Part_A2_Client.c    # Client A2: One-Copy (Scatter-Gather)
├── MT25039_Part_A3_Client.c    # Client A3: Zero-Copy (MSG_ZEROCOPY)
├── MT25039_Part_C.sh           # Automation Script (Runs experiments & collects data)
├── MT25039_Part_D.py           # Plotting Script (Generates graphs from data (hardcodedvalues of data))
├── MT25039_PartA_Shell.sh      # Helper script for Part A demo 
├── MT25039_PartB_Shell.sh      # Helper script for Part B profiling 
├── setup_ns.sh                 # Network Namespace setup script
├── Makefile                    # Build automation
└── README.md                   # Project documentation
```
### Install Dependencies
To run this project, you need `gcc`, `make`, `perf`, and Python libraries for plotting.

```bash
# 1. Update package list
sudo apt-get update

# 2. Install Build Tools and Perf (Linux Profiler)
sudo apt-get install build-essential linux-tools-common linux-tools-generic linux-tools-$(uname -r) python3-pip

# 3. Install Python Plotting Libraries
pip3 install matplotlib numpy
```

## 🚀 How to Run

### 1. Compilation
Use the included `Makefile` to compile all server and client binaries.

```bash
make
```

### 2. Network Setup
This project uses Linux Network Namespaces to simulate a realistic multi-node network environment on a single machine.

This is required to run once before the execution of the project.

```bash
chmod +x setup_ns.sh
sudo ./setup_ns.sh
```

### 3. Run Automated Experiments
The automation script runs:

- 3 implementations (Two-Copy, One-Copy, Zero-Copy)

- 4 message sizes

- 4 thread counts

It collects:

- Throughput

- Latency

- Cache Misses

- CPU Cycles

- Context Switches

```bash
chmod +x MT25039_Part_C.sh
sudo ./MT25039_Part_C.sh
```

Output:
`MT25039_results.csv` — raw performance data


## Cleanup

To remove compiled binaries and temporary output files:

```bash
make clean
```
