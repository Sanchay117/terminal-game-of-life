#!/usr/bin/env bash

set -euo pipefail

# Tower of Hanoi demo with simple ASCII graphics.
# Usage:
#   ./hanoi.sh            # defaults to 4 disks
#   ./hanoi.sh 5          # run with 5 disks

disk_count="${1:-4}"

if ! [[ "$disk_count" =~ ^[1-9][0-9]*$ ]]; then
  echo "Please provide a positive integer disk count."
  exit 1
fi

declare -a peg_A=()
declare -a peg_B=()
declare -a peg_C=()
move_count=0
popped_disk=""

for ((disk = disk_count; disk >= 1; disk--)); do
  peg_A+=("$disk")
done

repeat_char() {
  local char="$1"
  local count="$2"
  local out=""
  for ((i = 0; i < count; i++)); do
    out+="$char"
  done
  printf '%s' "$out"
}

draw_disk() {
  local disk="${1:-0}"
  local width=$((disk_count * 2 + 1))

  if ((disk == 0)); then
    local padding=$((disk_count))
    printf "%*s|%*s" "$padding" "" "$padding" ""
    return
  fi

  local disk_width=$((disk * 2 + 1))
  local side_padding=$(((width - disk_width) / 2))
  local fill
  fill="$(repeat_char "=" "$disk_width")"
  printf "%*s%s%*s" "$side_padding" "" "$fill" "$side_padding" ""
}

render_peg_line() {
  local peg_label="$1"
  shift

  printf '%s: ' "$peg_label"
  if (($# == 0)); then
    printf '(empty)'
  else
    local disk
    # Iteration demo:
    # This loop walks across one peg's current disks and draws each as ASCII.
    for disk in "$@"; do
      draw_disk "$disk"
      printf ' '
    done
  fi
  printf '\n'
}

render_state() {
  clear 2>/dev/null || true
  printf 'Tower of Hanoi with %s disk(s)\n' "$disk_count"
  printf 'Moves so far: %s\n\n' "$move_count"
  render_peg_line "A" "${peg_A[@]-}"
  render_peg_line "B" "${peg_B[@]-}"
  render_peg_line "C" "${peg_C[@]-}"
}

pop_disk() {
  local peg_name="$1"
  local last_index

  case "$peg_name" in
    peg_A)
      last_index=$((${#peg_A[@]} - 1))
      popped_disk="${peg_A[last_index]}"
      unset "peg_A[last_index]"
      peg_A=("${peg_A[@]-}")
      ;;
    peg_B)
      last_index=$((${#peg_B[@]} - 1))
      popped_disk="${peg_B[last_index]}"
      unset "peg_B[last_index]"
      peg_B=("${peg_B[@]-}")
      ;;
    peg_C)
      last_index=$((${#peg_C[@]} - 1))
      popped_disk="${peg_C[last_index]}"
      unset "peg_C[last_index]"
      peg_C=("${peg_C[@]-}")
      ;;
    *)
      echo "Unknown peg: $peg_name" >&2
      exit 1
      ;;
  esac

}

push_disk() {
  local peg_name="$1"
  local disk="$2"

  case "$peg_name" in
    peg_A) peg_A+=("$disk") ;;
    peg_B) peg_B+=("$disk") ;;
    peg_C) peg_C+=("$disk") ;;
    *)
      echo "Unknown peg: $peg_name" >&2
      exit 1
      ;;
  esac
}

move_disk() {
  local from_peg="$1"
  local to_peg="$2"
  pop_disk "$from_peg"
  push_disk "$to_peg" "$popped_disk"
  ((move_count += 1))
  render_state
  printf '\nMove %s: disk %s from %s to %s\n' "$move_count" "$popped_disk" "${from_peg#peg_}" "${to_peg#peg_}"
  sleep 0.2
}

solve_hanoi() {
  local n="$1"
  local from_peg="$2"
  local to_peg="$3"
  local aux_peg="$4"

  # Recursion demo:
  # Move the top n-1 disks away, move the largest disk, then move the n-1 back.
  if ((n == 1)); then
    move_disk "$from_peg" "$to_peg"
    return
  fi

  solve_hanoi $((n - 1)) "$from_peg" "$aux_peg" "$to_peg"
  move_disk "$from_peg" "$to_peg"
  solve_hanoi $((n - 1)) "$aux_peg" "$to_peg" "$from_peg"
}

render_state
printf '\nStarting solution...\n'
sleep 0.8
solve_hanoi "$disk_count" peg_A peg_C peg_B

printf '\nSolved in %s moves.\n' "$move_count"
