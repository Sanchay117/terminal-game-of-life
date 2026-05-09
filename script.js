const hanoiBoard = document.getElementById("hanoi-board");
const hanoiStatus = document.getElementById("hanoi-status");
const diskCountInput = document.getElementById("disk-count");
const diskCountValue = document.getElementById("disk-count-value");
const restartHanoiButton = document.getElementById("restart-hanoi");

const lifeCanvas = document.getElementById("life-canvas");
const lifeGenerationLabel = document.getElementById("life-generation");
const toggleLifeButton = document.getElementById("toggle-life");
const resetLifeButton = document.getElementById("reset-life");

let hanoiPegs = [];
let hanoiMoves = [];
let hanoiMoveIndex = 0;
let hanoiTimer = null;

function buildHanoiMoves(count, from, to, aux, moves) {
  // Recursion demo:
  // This function mirrors the recursive Bash solver by breaking the problem into n - 1 moves.
  if (count === 1) {
    moves.push([from, to]);
    return;
  }

  buildHanoiMoves(count - 1, from, aux, to, moves);
  moves.push([from, to]);
  buildHanoiMoves(count - 1, aux, to, from, moves);
}

function renderHanoi() {
  hanoiBoard.innerHTML = "";
  const diskCount = Number(diskCountInput.value);

  hanoiPegs.forEach((peg, pegIndex) => {
    const pegElement = document.createElement("div");
    pegElement.className = "peg";

    const stack = document.createElement("div");
    stack.className = "peg-stack";

    peg.forEach((disk) => {
      const diskElement = document.createElement("div");
      diskElement.className = "disk";
      diskElement.style.width = `${28 + disk * 20}px`;
      diskElement.style.background = `linear-gradient(90deg,
        hsl(${24 + disk * 8} 78% 46%),
        hsl(${38 + disk * 6} 90% 74%))`;
      stack.appendChild(diskElement);
    });

    const label = document.createElement("div");
    label.className = "peg-label";
    label.textContent = String.fromCharCode(65 + pegIndex);

    pegElement.appendChild(stack);
    pegElement.appendChild(label);
    hanoiBoard.appendChild(pegElement);
  });

  hanoiStatus.textContent =
    hanoiMoveIndex >= hanoiMoves.length
      ? `Solved with ${diskCount} disks in ${hanoiMoves.length} moves.`
      : `Move ${hanoiMoveIndex} of ${hanoiMoves.length}`;
}

function stepHanoi() {
  if (hanoiMoveIndex >= hanoiMoves.length) {
    window.clearInterval(hanoiTimer);
    hanoiTimer = null;
    renderHanoi();
    return;
  }

  const [from, to] = hanoiMoves[hanoiMoveIndex];
  const disk = hanoiPegs[from].pop();
  hanoiPegs[to].push(disk);
  hanoiMoveIndex += 1;
  renderHanoi();
}

function startHanoi() {
  const diskCount = Number(diskCountInput.value);
  diskCountValue.textContent = String(diskCount);

  hanoiPegs = [
    Array.from({ length: diskCount }, (_, index) => diskCount - index),
    [],
    [],
  ];
  hanoiMoves = [];
  hanoiMoveIndex = 0;
  buildHanoiMoves(diskCount, 0, 2, 1, hanoiMoves);
  renderHanoi();

  if (hanoiTimer) {
    window.clearInterval(hanoiTimer);
  }

  hanoiTimer = window.setInterval(stepHanoi, 600);
}

diskCountInput.addEventListener("input", () => {
  diskCountValue.textContent = diskCountInput.value;
});

diskCountInput.addEventListener("change", startHanoi);
restartHanoiButton.addEventListener("click", startHanoi);

const lifeContext = lifeCanvas.getContext("2d");
const gridSize = 28;
const cellSize = lifeCanvas.width / gridSize;
let lifeBoard = [];
let lifeGeneration = 0;
let lifeRunning = true;
let lifeAnimationId = null;
let lastLifeTick = 0;

function createLifeBoard() {
  return Array.from({ length: gridSize }, () => Array(gridSize).fill(0));
}

function seedLifeBoard() {
  lifeBoard = createLifeBoard();
  const center = Math.floor(gridSize / 2);
  const glider = [
    [center - 2, center - 1],
    [center - 1, center],
    [center, center - 2],
    [center, center - 1],
    [center, center],
  ];

  glider.forEach(([row, col]) => {
    lifeBoard[row][col] = 1;
  });

  lifeGeneration = 0;
  lifeGenerationLabel.textContent = `Generation ${lifeGeneration}`;
}

function countNeighbors(board, row, col) {
  let count = 0;

  // Iteration demo:
  // Two nested loops examine the eight surrounding cells before applying the rules.
  for (let dr = -1; dr <= 1; dr += 1) {
    for (let dc = -1; dc <= 1; dc += 1) {
      if (dr === 0 && dc === 0) {
        continue;
      }

      const nextRow = row + dr;
      const nextCol = col + dc;
      if (
        nextRow >= 0 &&
        nextRow < gridSize &&
        nextCol >= 0 &&
        nextCol < gridSize
      ) {
        count += board[nextRow][nextCol];
      }
    }
  }

  return count;
}

function stepLife() {
  const next = createLifeBoard();

  // Iteration demo:
  // This walks the full grid and computes the next generation cell by cell.
  for (let row = 0; row < gridSize; row += 1) {
    for (let col = 0; col < gridSize; col += 1) {
      const alive = lifeBoard[row][col] === 1;
      const neighbors = countNeighbors(lifeBoard, row, col);

      if ((alive && (neighbors === 2 || neighbors === 3)) || (!alive && neighbors === 3)) {
        next[row][col] = 1;
      }
    }
  }

  lifeBoard = next;
  lifeGeneration += 1;
  lifeGenerationLabel.textContent = `Generation ${lifeGeneration}`;
}

function renderLife() {
  lifeContext.clearRect(0, 0, lifeCanvas.width, lifeCanvas.height);
  lifeContext.fillStyle = "#0c2b31";
  lifeContext.fillRect(0, 0, lifeCanvas.width, lifeCanvas.height);

  for (let row = 0; row < gridSize; row += 1) {
    for (let col = 0; col < gridSize; col += 1) {
      lifeContext.strokeStyle = "rgba(255,255,255,0.05)";
      lifeContext.strokeRect(col * cellSize, row * cellSize, cellSize, cellSize);

      if (lifeBoard[row][col] === 1) {
        lifeContext.fillStyle = "#ffbf70";
        lifeContext.fillRect(
          col * cellSize + 1,
          row * cellSize + 1,
          cellSize - 2,
          cellSize - 2,
        );
      }
    }
  }
}

function animateLife(timestamp) {
  if (!lastLifeTick) {
    lastLifeTick = timestamp;
  }

  if (lifeRunning && timestamp - lastLifeTick >= 180) {
    stepLife();
    lastLifeTick = timestamp;
  }

  renderLife();
  lifeAnimationId = window.requestAnimationFrame(animateLife);
}

toggleLifeButton.addEventListener("click", () => {
  lifeRunning = !lifeRunning;
  toggleLifeButton.textContent = lifeRunning ? "Pause" : "Resume";
});

resetLifeButton.addEventListener("click", () => {
  seedLifeBoard();
  renderLife();
});

startHanoi();
seedLifeBoard();
renderLife();

if (lifeAnimationId) {
  window.cancelAnimationFrame(lifeAnimationId);
}
lifeAnimationId = window.requestAnimationFrame(animateLife);
