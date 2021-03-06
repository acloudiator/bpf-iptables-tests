#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NOW=$(date +"%m-%d-%Y-%T")

###############################
# Remote configurations (DUT) #
###############################
REMOTE_DUT=IPADDRESS
REMOTE_FOLDER="~/bpf-iptables-tests/system-benchmarking/rule-complexity"
DST_MAC_IF0="3cfd:feaf:ec30"
DST_MAC_IF1="3cfd:feaf:ec31"
INGRESS_IFACE_NAME="enp101s0f0"
SET_IRQ_SCRIPT="~/bpf-iptables-tests/common-scripts/set_irq_affinity"

polycubed="sudo polycubed"
polycubectl="$GOPATH/bin/polycubectl"
POLYCUBECTL_CONFIG_FILE="$HOME/.config/polycube/polycubectl_config.yaml"

########################################
# Local configurations (Pkt generator) #
########################################
PKTGEN_FOLDER="$HOME/dev/pktgen-dpdk"
POLYCUBE_VERSION="none"
IPTABLES="pcn-iptables"
LOCAL_NAME=cube1
LOCAL_DUT=IPADDRESS
START_RATE=50.0

CONTAINER_ID=0000

declare -a ruleset_values=("ipsrc" "ipsrc_ipdst" "ipsrc_ipdst_proto" "ipsrc_ipdst_proto_portsrc" "all")

#######################################
# Specific Test (srcip) Configuration #
#######################################
function generate_test_configuration() {
local test_name=$1
if [ $test_name == "ipsrc" ]; then
	START_SRC_IP=192.168.0.2
	END_SRC_IP=192.168.3.233
	NUM_IP_SRC=1000
	START_DST_IP=192.168.10.2
	END_DST_IP=192.168.10.20
	NUM_IP_DST=20
	START_SPORT=10100
	END_SPORT=10110
	START_DPORT=8090
	END_DPORT=8100
elif [ $test_name == "ipsrc_ipdst" ]; then
	START_SRC_IP=192.168.0.2
	END_SRC_IP=192.168.0.41
	NUM_IP_SRC=40
	START_DST_IP=192.168.10.2
	END_DST_IP=192.168.10.26
	NUM_IP_DST=25
	START_SPORT=10100
	END_SPORT=10110
	START_DPORT=8090
	END_DPORT=8100
elif [ $test_name == "ipsrc_ipdst_proto" ]; then
	START_SRC_IP=192.168.0.2
	END_SRC_IP=192.168.0.41
	NUM_IP_SRC=40
	START_DST_IP=192.168.10.2
	END_DST_IP=192.168.10.26
	NUM_IP_DST=25
	START_SPORT=10100
	END_SPORT=10110
	START_DPORT=8090
	END_DPORT=8100
elif [ $test_name == "ipsrc_ipdst_proto_portsrc" ]; then
	START_SRC_IP=192.168.0.2
	END_SRC_IP=192.168.0.11
	NUM_IP_SRC=10
	START_DST_IP=192.168.10.2
	END_DST_IP=192.168.10.11
	NUM_IP_DST=10
	START_SPORT=10100
	END_SPORT=10109
	START_DPORT=8090
	END_DPORT=8100
elif [ $test_name == "all" ]; then
	START_SRC_IP=192.168.0.2
	END_SRC_IP=192.168.0.11
	NUM_IP_SRC=10
	START_DST_IP=192.168.10.2
	END_DST_IP=192.168.10.6
	NUM_IP_DST=5
	START_SPORT=10100
	END_SPORT=10103
	START_DPORT=8090
	END_DPORT=8094
else
	echo "Test case not supported"
	exit 1
fi
}

function show_help() {
usage="$(basename "$0") [-h] [-r #runs] [-o output_file] [-i|-n]
Run tests of pcn-iptables for the FORWARD chain with a different number of rules

where:
    -h  show this help text
    -r  number of runs for the test
    -o  path to file where the results are placed
    -i  use iptables
    -n  use nftables"

echo "$usage"
}

# Kill polycubed, and wait all services to be unloaded and process to be completely killed
function polycubed_kill_and_wait {
  echo "killing polycubed ..."
  sudo pkill polycubed > /dev/null 2>&1
  done=0
  i=0
  while : ; do
    sleep 1
    alive=$(ps -el | grep polycubed)
    if [ -z "$alive" ]; then
      done=1
    fi

    i=$((i+1))

    if [ "$done" -eq 1 ]; then
        echo "killing polycubed in $i seconds"
        break
    fi
  done
}

function setup_environment {
local test_type=$1
ssh polycube@$REMOTE_DUT "sudo service docker restart"
CONTAINER_ID=$(ssh polycube@$REMOTE_DUT "sudo docker run -id --name bpf-iptables --rm --privileged --network host -v /lib/modules:/lib/modules:ro -v /usr/src:/usr/src:ro -v /etc/localtime:/etc/localtime:ro netgrouppolito/bpf-iptables:latest bash")
ssh polycube@$REMOTE_DUT << EOF
  set -x
  sudo docker exec -d bpf-iptables bash -c "exec -a config_dut $REMOTE_FOLDER/config_dut_routing.sh -s $NUM_IP_SRC -d $NUM_IP_DST &> ~/log &"
  sudo docker exec bpf-iptables bash -c "$REMOTE_FOLDER/rulesets/rules_${test_type}.sh $IPTABLES FORWARD"
EOF
if [ ${IPTABLES} == "pcn-iptables"  ]; then
  generate_polycube_config_file
fi
}

function generate_polycube_config_file {
#Create configuration file for polycubectl
ssh polycube@$REMOTE_DUT << EOF
sudo docker exec bpf-iptables bash -c "cat > ${POLYCUBECTL_CONFIG_FILE} << EOF
  debug: false
  expert: true
  url: http://${REMOTE_DUT}:9000/polycube/v1/
  version: "2"
  hardcodedversionenabled: true
  singleparameterworkaround: true
EOF"
EOF
}

function cleanup_environment {
ssh polycube@$REMOTE_DUT << EOF
  $(typeset -f polycubed_kill_and_wait)
  polycubed_kill_and_wait
  sudo iptables -F FORWARD
  sudo docker exec bpf-iptables bash -c "sudo pkill config_dut"
  sudo docker exec bpf-iptables bash -c "$REMOTE_FOLDER/config_dut_routing.sh -s $NUM_IP_SRC -d $NUM_IP_DST -r &> /dev/null" &> /dev/null
  sudo docker stop ${CONTAINER_ID} &> /dev/null
  sudo docker rm -f bpf-iptables
  sudo nft flush table ip filter &> /dev/null
  sudo nft delete table ip filter &> /dev/null
EOF
}

function wait_for_remote_machine {
ssh -q polycube@$REMOTE_DUT exit
result=$?
sleep 5
while [ $result -ne 0 ]; do
  ssh -q polycube@$REMOTE_DUT exit #Loop until the host becomes ready
  result=$?
  sleep 5
done
}

function reboot_remote_dut {
ssh polycube@$REMOTE_DUT << EOF
  set -x
  sudo reboot
EOF
}

function check_conntrack {
local enabled=$(ssh polycube@$REMOTE_DUT "lsmod | grep conntrack")
local result='disabled'
if [ -z "$enabled"]; then
	# Conntrack is disabled
	result='disabled'
else 
	result='enabled'
fi
echo "$result"
}

function disable_conntrack {
ssh polycube@$REMOTE_DUT << EOF
  sudo rmmod iptable_nat
  sudo rmmod ipt_MASQUERADE
  sudo rmmod nf_nat_ipv4
  sudo rmmod nf_nat
  sudo rmmod xt_conntrack
  sudo rmmod nf_conntrack_netlink
  sudo rmmod nf_conntrack
  sudo rmmod iptable_filter
  sudo rmmod ip_tables
  sudo rmmod nf_defrag_ipv6
  sudo rmmod nf_defrag_ipv4
  sudo rmmod x_tables
  sudo rmmod ip_set_hash_ipport
  sudo rmmod ip_set
EOF
}

function disable_nft {
ssh polycube@$REMOTE_DUT << EOF
  sudo rmmod nft_counter
  sudo rmmod nft_ct
  sudo rmmod nf_tables
EOF
}

function cleanup {
  set +e
  cleanup_environment
}

# The argument of this function is the range of cores to be used
# or 'all' in case all cores are used
function set_irq_affinity {
ssh polycube@$REMOTE_DUT << EOF
  set -x
  sudo docker exec bpf-iptables bash -c "$SET_IRQ_SCRIPT $1 $INGRESS_IFACE_NAME"
EOF
}

function generate_pktgen_config_file {
#Create configuration file for swagger-codegen
cat > ${PKTGEN_FOLDER}/config.lua << EOF
-- config.lua
-- Automatically generated at ${NOW}

local _M = {}

_M.test = {
    dstMac0 = "${DST_MAC_IF0}",
    dstMac1 = "${DST_MAC_IF1}",
    num_runs = ${NUMBER_RUNS},
    simple_test = $1,
    startSrcIP = "${START_SRC_IP}",
    endSrcIP = "${END_SRC_IP}",
    startDstIP = "${START_DST_IP}",
    endDstIP = "${END_DST_IP}",
    startSport = ${START_SPORT},
    endSport = ${END_SPORT},
    startDport = ${START_DPORT},
    endDport = ${END_DPORT},
    startRate = ${START_RATE},
}

return _M
EOF
}

#set -e

while getopts :r:o:inh option; do
 case "${option}" in
 h|\?)
  show_help
  exit 0
  ;;
 r) NUMBER_RUNS=${OPTARG}
  ;;
 o) OUT_FILE=${OPTARG}
  ;;
 i) IPTABLES="iptables"
  ;;
 n) IPTABLES="nftables"
  ;;
 :)
    echo "Option -$OPTARG requires an argument." >&2
    show_help
    exit 0
    ;;
 esac
done

if [ -z ${NUMBER_RUNS+x} ]; then
	echo "You should specify the number of runs with the -r option" >&2;
	show_help
	exit 0
fi

if [ -z ${OUT_FILE+x} ]; then
	echo "You should specify the output file with the -o option" >&2;
	show_help
	exit 0
fi

set -x

#reboot_remote_dut

for test_type in "${ruleset_values[@]}"; do
  set +e

  generate_test_configuration $test_type

  set -e
  cleanup

  if [ ${IPTABLES} == "pcn-iptables"  ]; then
    ssh polycube@$REMOTE_DUT "$polycubed --version" > $DIR/"$OUT_FILE-${test_type}.txt"
  elif [ ${IPTABLES} == "iptables"  ]; then
    ssh polycube@$REMOTE_DUT "sudo iptables --version" > $DIR/"$OUT_FILE-${test_type}.txt"
  else 
    ssh polycube@$REMOTE_DUT "sudo nft --version" > $DIR/"$OUT_FILE-${test_type}.txt"
  fi

  echo "Processing type: ${test_type}" >> $DIR/"$OUT_FILE-${test_type}.txt"
  ssh polycube@$REMOTE_DUT "uname -r" >> $DIR/"$OUT_FILE-${test_type}.txt"
  echo "" >> $DIR/"$OUT_FILE-${test_type}.txt"
  #####################################################
  # Execute the first test with interrupts set to all #
  #####################################################
  START_RATE=50.0
  setup_environment $test_type
  set_irq_affinity "all"

  sleep 5
  generate_pktgen_config_file 0

  cd $PKTGEN_FOLDER
  sudo ./app/x86_64-native-linuxapp-gcc/pktgen -c ff -n 4 --proc-type auto --file-prefix pg -- -T -P -m "[1:2/3/4/5].0, [6/7].1" -f $DIR/rule-complexity.lua
  sleep 5
  cat "pcn-iptables-forward.csv" >> $DIR/"$OUT_FILE-${test_type}.txt"

  cleanup_environment
  sleep 5
  cd $DIR
done

ssh polycube@$REMOTE_DUT "sudo service docker restart"

exit 0
