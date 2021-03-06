#!/bin/bash

nft add table ip filter
nft add chain filter $CHAIN \{ type filter hook forward priority 0\; policy drop\; \}
nft add rule ip filter $CHAIN ct state established counter accept
nft add rule ip filter $CHAIN ip saddr 192.168.10.2 ct state new counter accept
nft add rule ip filter $CHAIN ip saddr 192.168.10.3 ct state new counter accept
nft add rule ip filter $CHAIN ip saddr 192.168.10.4 ct state new counter accept
nft add rule ip filter $CHAIN ip saddr 192.168.10.5 ct state new counter accept
nft add rule ip filter $CHAIN ip saddr 192.168.10.6 ct state new counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.2 udp dport 8080 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.2 udp dport 8081 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.2 udp dport 8082 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.2 udp dport 8083 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.2 udp dport 8084 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.2 udp dport 8085 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.2 udp dport 8086 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.2 udp dport 8087 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.2 udp dport 8088 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.3 udp dport 8080 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.3 udp dport 8081 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.3 udp dport 8082 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.3 udp dport 8083 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.3 udp dport 8084 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.3 udp dport 8085 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.3 udp dport 8086 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.3 udp dport 8087 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.3 udp dport 8088 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.4 udp dport 8080 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.4 udp dport 8081 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.4 udp dport 8082 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.4 udp dport 8083 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.4 udp dport 8084 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.4 udp dport 8085 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.4 udp dport 8086 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.4 udp dport 8087 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.4 udp dport 8088 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.5 udp dport 8080 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.5 udp dport 8081 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.5 udp dport 8082 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.5 udp dport 8083 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.5 udp dport 8084 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.5 udp dport 8085 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.5 udp dport 8086 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.5 udp dport 8087 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.5 udp dport 8088 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.6 udp dport 8080 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.6 udp dport 8081 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.6 udp dport 8082 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.6 udp dport 8083 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.6 udp dport 8084 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.6 udp dport 8085 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.6 udp dport 8086 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.6 udp dport 8087 counter accept
nft add rule ip filter $CHAIN ip daddr 192.168.10.6 udp dport 8088 counter accept
nft add rule ip filter $CHAIN counter drop
