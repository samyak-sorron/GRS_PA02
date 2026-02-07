#!/bin/bash

# 1. Clean up previous namespaces if they exist (to allow re-running)
sudo ip netns del server_ns 2>/dev/null
sudo ip netns del client_ns 2>/dev/null

# 2. Create the namespaces
echo "Creating namespaces..."
sudo ip netns add server_ns
sudo ip netns add client_ns

# 3. Create the virtual ethernet (veth) cable
# Think of this as plugging a cable between two computers
sudo ip link add veth-server type veth peer name veth-client

# 4. Plug the ends into the namespaces
sudo ip link set veth-server netns server_ns
sudo ip link set veth-client netns client_ns

# 5. Configure the Server side (IP: 10.8.5.10)
echo "Configuring Server..."
sudo ip netns exec server_ns ip addr add 10.8.5.10/24 dev veth-server
sudo ip netns exec server_ns ip link set veth-server up
sudo ip netns exec server_ns ip link set lo up  # Loopback must be up

# 6. Configure the Client side (IP: 10.8.5.12)
echo "Configuring Client..."
sudo ip netns exec client_ns ip addr add 10.8.5.12/24 dev veth-client
sudo ip netns exec client_ns ip link set veth-client up
sudo ip netns exec client_ns ip link set lo up

# 7. Verification
echo "Testing connectivity (Ping)..."
sudo ip netns exec client_ns ping -c 2 10.8.5.10

if [ $? -eq 0 ]; then
    echo "✅ Setup Successful! Use 'ip netns exec' to run your programs."
else
    echo "❌ Connectivity failed."
fi