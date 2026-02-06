#!/bin/bash

# 1. Clean up previous namespaces if they exist (to allow re-running)
ip netns del server_ns 2>/dev/null
ip netns del client_ns 2>/dev/null

# 2. Create the namespaces
echo "Creating namespaces..."
ip netns add server_ns
ip netns add client_ns

# 3. Create the virtual ethernet (veth) cable
# Think of this as plugging a cable between two computers
ip link add veth-server type veth peer name veth-client

# 4. Plug the ends into the namespaces
ip link set veth-server netns server_ns
ip link set veth-client netns client_ns

# 5. Configure the Server side (IP: 10.0.0.1)
echo "Configuring Server..."
ip netns exec server_ns ip addr add 10.0.0.1/24 dev veth-server
ip netns exec server_ns ip link set veth-server up
ip netns exec server_ns ip link set lo up  # Loopback must be up

# 6. Configure the Client side (IP: 10.0.0.2)
echo "Configuring Client..."
ip netns exec client_ns ip addr add 10.0.0.2/24 dev veth-client
ip netns exec client_ns ip link set veth-client up
ip netns exec client_ns ip link set lo up

# 7. Verification
echo "Testing connectivity (Ping)..."
ip netns exec client_ns ping -c 2 10.0.0.1

if [ $? -eq 0 ]; then
    echo "✅ Setup Successful! Use 'ip netns exec' to run your programs."
else
    echo "❌ Connectivity failed."
fi