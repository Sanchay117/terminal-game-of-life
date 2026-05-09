#!/usr/bin/env bash

set -euo pipefail

# Conway's Game of Life demo with simple terminal graphics.
# Usage:
#   bash ./life.sh         # defaults to 20x20 grid, 25 generations
#   bash ./life.sh 30 15   # 30 generations on a 15x15 grid

generations="${1:-20}"
grid_size="${2:-20}"

if ! [[ "$generations" =~ ^[1-9][0-9]*$ ]]; then
  echo "Please provide a positive integer for generations."
  exit 1
fi

if ! [[ "$grid_size" =~ ^[1-9][0-9]*$ ]]; then
  echo "Please provide a positive integer for grid size."
  exit 1
fi

declare -a board=()
declare -a next_board=()

cell_index() {
  local row="$1"
  local col="$2"
  printf '%s' $((row * grid_size + col))
}

seed_glider() {
  local center=$((grid_size / 2 - 1))
  local row
  local col

  for ((row = 0; row < grid_size; row++)); do
    for ((col = 0; col < grid_size; col++)); do
      board[$(cell_index "$row" "$col")]=0
    done
  done

  board[$(cell_index "$center" $((center + 1)))]=1
  board[$(cell_index $((center + 1)) $((center + 2)))]=1
  board[$(cell_index $((center + 2)) "$center")]=1
  board[$(cell_index $((center + 2)) $((center + 1)))]=1
  board[$(cell_index $((center + 2)) $((center + 2)))]=1
}

count_neighbors() {
  local row="$1"
  local col="$2"
  local neighbors=0
  local dr
  local dc
  local nr
  local nc

  # Iteration demo:
  # These nested loops scan the 8 surrounding cells around one position.
  for dr in -1 0 1; do
    for dc in -1 0 1; do
      if ((dr == 0 && dc == 0)); then
        continue
      fi

      nr=$((row + dr))
      nc=$((col + dc))

      if ((nr >= 0 && nr < grid_size && nc >= 0 && nc < grid_size)); then
        neighbors=$((neighbors + board[$(cell_index "$nr" "$nc")]))
      fi
    done
  done

  printf '%s' "$neighbors"
}

render_board() {
  local generation="$1"
  local row
  local col
  local alive_char="[]"
  local dead_char="  "

  clear 2>/dev/null || true
  printf "Conway's Game of Life\n"
  printf "Generation: %s of %s\n\n" "$generation" "$generations"

  # Iteration demo:
  # These loops walk the full board row by row to draw the current state.
  for ((row = 0; row < grid_size; row++)); do
    for ((col = 0; col < grid_size; col++)); do
      if ((${board[$(cell_index "$row" "$col")]} == 1)); then
        printf '%s' "$alive_char"
      else
        printf '%s' "$dead_char"
      fi
    done
    printf '\n'
  done
}

step_generation() {
  local row
  local col
  local index
  local alive
  local neighbors

  # Iteration demo:
  # This double loop applies Conway's rules to every cell in the grid.
  for ((row = 0; row < grid_size; row++)); do
    for ((col = 0; col < grid_size; col++)); do
      index="$(cell_index "$row" "$col")"
      alive="${board[index]}"
      neighbors="$(count_neighbors "$row" "$col")"

      if ((alive == 1 && (neighbors == 2 || neighbors == 3))); then
        next_board[index]=1
      elif ((alive == 0 && neighbors == 3)); then
        next_board[index]=1
      else
        next_board[index]=0
      fi
    done
  done

  board=("${next_board[@]}")
}

seed_glider

for ((generation = 0; generation <= generations; generation++)); do
  render_board "$generation"
  sleep 0.15

  if ((generation < generations)); then
    step_generation
  fi
done

printf '\nSimulation complete.\n'
