#!/bin/bash

SHOW_CPU=true
SHOW_MEM=true
SHOW_EPHEMERAL=false
SHOW_GPU=false

# Parse flags
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -c|--cpu)
      SHOW_CPU=true
      ;;
    -m|--mem)
      SHOW_MEM=true
      ;;
    -e|--ephemeral)
      SHOW_EPHEMERAL=true
      ;;
    -g|--gpu)
      SHOW_GPU=true
      ;;
    -ne|--no-ephemeral)
      SHOW_EPHEMERAL=false
      ;;
    -ng|--no-gpu)
      SHOW_GPU=false
      ;;
    -nc|--no-cpu)
      SHOW_CPU=false
      ;;
    -nm|--no-mem)
      SHOW_MEM=false
      ;;
    -h|--help)
      echo -n "Usage: $0 "
      echo -n "[-c|--cpu] [-m|--mem] "
      echo -n "[-e|--ephemeral] [-g|--gpu] "
      echo -n "[-nc|--no-cpu] [-nm|--no-mem] "
      echo -n "[-ne|--no-ephemeral] [-ng|--no-gpu]"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# 1. Determine binary
if command -v oc &> /dev/null; then
  CMD="oc"
elif command -v kubectl &> /dev/null; then
  CMD="kubectl"
else
  echo "Neither 'oc' nor 'kubectl' command is available. Please install one of them."
  exit 1
fi

# Unit normalization logic for jq
JQ_NORMALIZE='
def parse_bytes:
  if . == null or . == "0" or . == "" then 0
  elif endswith("Ki") or endswith("ki") then (.[0:-2] | tonumber * 1024)
  elif endswith("Mi") or endswith("mi") then (.[0:-2] | tonumber * 1024 * 1024)
  elif endswith("Gi") or endswith("gi") then (.[0:-2] | tonumber * 1024 * 1024 * 1024)
  elif endswith("Ti") or endswith("ti") then (.[0:-2] | tonumber * 1024 * 1024 * 1024 * 1024)
  elif endswith("k") or endswith("K") then (.[0:-1] | tonumber * 1000)
  elif endswith("M") or endswith("MB") then (if endswith("MB") then .[0:-2] else .[0:-1] end | tonumber * 1000000)
  elif endswith("G") or endswith("GB") then (if endswith("GB") then .[0:-2] else .[0:-1] end | tonumber * 1000000000)
  elif endswith("m") then (.[0:-1] | tonumber / 1000)
  else (tonumber)
  end;

def parse_cpu:
  if . == null or . == "0" or . == "" then 0
  elif endswith("m") then (.[0:-1] | tonumber)
  elif endswith("k") or endswith("K") then (.[0:-1] | tonumber * 1000000)
  elif endswith("M") then (.[0:-1] | tonumber * 1000)
  elif endswith("G") then (.[0:-1] | tonumber * 1000000)
  else (tonumber * 1000)
  end;
'

generate_data() {
  # Build dynamic table header with STATUS
  HEADER="NODE|"
  if [ "$SHOW_CPU" = true ]; then
    HEADER+="|CPU CAP|CPU ALLOC"
    HEADER+="|CPU REQ|CPU AVAIL"
  fi

  if [ "$SHOW_MEM" = true ]; then
    HEADER+="|MEM CAP (GiB)|MEM ALLOC (GiB)"
    HEADER+="|MEM REQ (GiB)|MEM AVAIL (GiB)"
  fi

  if [ "$SHOW_EPHEMERAL" = true ]; then
    HEADER+="|EPH CAP (GiB)|EPH ALLOC (GiB)"
    HEADER+="|EPH REQ (GiB)|EPH AVAIL (GiB)"
  fi

  if [ "$SHOW_GPU" = true ]; then
    HEADER+="|GPU CAP|GPU ALLOC"
    HEADER+="|GPU REQ|GPU AVAIL"
  fi

  HEADER+="|STATUS"
  echo "${HEADER}"

  # Process node specs & status
  ${CMD} get nodes -o json | jq -r "${JQ_NORMALIZE} "'
    .items[] | 
    .metadata.name as $node |
    
    # Extract Node Status (Ready / NotReady / SchedulingDisabled)
    (
      if .spec.unschedulable == true then "SchedulingDisabled"
      else (
        .status.conditions[] | select(.type=="Ready") | 
        if .status == "True" then "Ready" else "NotReady" end
      )
      end
    ) as $status |

    # CPU
    ((.status.capacity.cpu | parse_cpu) / 1000) as $cpu_cap |
    ((.status.allocatable.cpu | parse_cpu) / 1000) as $cpu_alloc |
    
    # Memory (GiB)
    ((.status.capacity.memory | parse_bytes) / 1073741824) as $mem_cap |
    ((.status.allocatable.memory | parse_bytes) / 1073741824) as $mem_alloc |
    
    # Ephemeral (GiB)
    ((.status.capacity["ephemeral-storage"] | parse_bytes) / 1073741824) as $eph_cap |
    ((.status.allocatable["ephemeral-storage"] | parse_bytes) / 1073741824) as $eph_alloc |
    
    # GPU
    ((.status.capacity["nvidia.com/gpu"] // .status.capacity["amd.com/gpu"] // "0") | tonumber) as $gpu_cap |
    ((.status.allocatable["nvidia.com/gpu"] // .status.allocatable["amd.com/gpu"] // "0") | tonumber) as $gpu_alloc |

    "\( $node )\t\( $status )\t\( $cpu_cap )\t\( $cpu_alloc )\t\( $mem_cap )\t\( $mem_alloc )\t\( $eph_cap )\t\( $eph_alloc )\t\( $gpu_cap )\t\( $gpu_alloc )"
  ' 2>/dev/null | while read -r NODE STATUS CPU_CAP CPU_ALLOC MEM_CAP MEM_ALLOC EPH_CAP EPH_ALLOC GPU_CAP GPU_ALLOC; do

    # Query Pod Requests on Node
    POD_REQS=$(${CMD} get pods --all-namespaces --field-selector spec.nodeName="${NODE}" -o json | jq -r "${JQ_NORMALIZE} "'
      [
        .items[].spec.containers[].resources.requests // {} | 
        {
          cpu: (.cpu // "0"),
          mem: (.memory // "0"),
          eph: (."ephemeral-storage" // "0"),
          gpu: (."nvidia.com/gpu" // ."amd.com/gpu" // "0")
        }
      ] | 
      reduce .[] as $item ({cpu: 0, mem: 0, eph: 0, gpu: 0}; 
        .cpu += ($item.cpu | parse_cpu) |
        .mem += ($item.mem | parse_bytes) |
        .eph += ($item.eph | parse_bytes) |
        .gpu += ($item.gpu | tonumber)
      ) |
      "\( .cpu / 1000 )\t\( .mem / 1073741824 )\t\( .eph / 1073741824 )\t\( .gpu )"
    ')

    read -r CPU_REQ MEM_REQ EPH_REQ GPU_REQ <<< "$POD_REQS"

    # Fallback to zero if unassigned
    : ${CPU_REQ:=0}
    : ${MEM_REQ:=0}
    : ${EPH_REQ:=0}
    : ${GPU_REQ:=0}

    # Calculations (Available = Allocatable - Requested)
    CPU_AVAIL=$(printf "%.2f" "$(echo "${CPU_ALLOC} - ${CPU_REQ}" | bc)")
    MEM_AVAIL=$(printf "%.2f" "$(echo "${MEM_ALLOC} - ${MEM_REQ}" | bc)")
    EPH_AVAIL=$(printf "%.2f" "$(echo "${EPH_ALLOC} - ${EPH_REQ}" | bc)")
    GPU_AVAIL=$(( GPU_ALLOC - GPU_REQ ))

    # Output row joined by pipes
    ROW="${NODE}"

    if [ "$SHOW_CPU" = true ]; then
      ROW+="|$(printf "%.2f" "${CPU_CAP}")|$(printf "%.2f" "${CPU_ALLOC}")"
      ROW+="|$(printf "%.2f" "${CPU_REQ}")|${CPU_AVAIL}"
    fi

    if [ "$SHOW_MEM" = true ]; then
      ROW+="|$(printf "%.2f" "${MEM_CAP}")|$(printf "%.2f" "${MEM_ALLOC}")"
      ROW+="|$(printf "%.2f" "${MEM_REQ}")|${MEM_AVAIL}"
    fi

    if [ "$SHOW_EPHEMERAL" = true ]; then
      ROW+="|$(printf "%.2f" "${EPH_CAP}")|$(printf "%.2f" "${EPH_ALLOC}")"
      ROW+="|$(printf "%.2f" "${EPH_REQ}")|${EPH_AVAIL}"
    fi

    if [ "$SHOW_GPU" = true ]; then
      ROW+="|${GPU_CAP}|${GPU_ALLOC}"
      ROW+="|${GPU_REQ}|${GPU_AVAIL}"
    fi

    ROW+="|${STATUS}"
    echo "${ROW}"
  done
}

# Pipe output into column -t with pipe delimiter for a clean table layout
generate_data | column -t -s '|'