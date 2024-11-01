ns1 = home
ns2 = office
VETH1 = veth1
VETH2 = veth2

ip1 = 192.168.0.2
ip2 = 192.168.0.3
subnet = 24

LOG = logs/packet_capture.log

all: setup caputer

setup: create_namespace conf_interfaces ping_namespace
	@echo "Network namespace and interface configure"

create_namespaces:
	id netns add $(ns1)
	ip netns add $(ns2)


conf_interfaces:
	ip link add $(VETH1) type veth peer name $(VETH2)
	ip link set $(VETH1) netns $(ns1)
	ip link set $(VETH2) netns $(ns2)

	ip netns exec $(ns1) ip addr add $(ip1)/$(subnet) dev $(VETH1)
	ip netns exec $(ns2) ip addr add $(ip2)/$(subnet) dev $(VETH2)
	ip netns exec $(ns1) ip link set $(VETH1) up
	ip netns exec $(ns2) ip link set $(VETH2) up

ping_namespaces:
	ip netns exec $(ns1) ping -c 2 $(ip2)


capture:
	ip netns exec $(ns1) tcpdump -i $(VETH1) -w $(LOG) & ip netns exec $(ns2) ping -c 4 $(ip1)

clean:
	ip netns del $(ns1)
	ip netns del $(ns2)
	rm -rf  logs/*.log
