class Cell {
  constructor(x, y) {
    this.x = x
    this.y = y
    this.walls = [true, true, true, true]
    this.visited = false

    this.node = document.createElement('td')
    this.node.classList = 'top right bottom left'
  }

  activate() {
    this.visit()
    this.node.classList.add("active")
  }

  deactivate() {
    this.node.classList.remove("active")
  }

  visit() {
    this.visited = true
    this.node.classList = this.node.classList + ' visited'
  }

  removeWall(n) {
    this.walls[n] = false
    this.node.classList = this.drawWalls()
  }

  drawWalls() {
    let outputBuffer = ''
    if (this.walls[0]) outputBuffer = outputBuffer + 'top '
    if (this.walls[1]) outputBuffer = outputBuffer + 'right '
    if (this.walls[2]) outputBuffer = outputBuffer + 'bottom '
    if (this.walls[3]) outputBuffer = outputBuffer + 'left '
    if (this.visited) outputBuffer = outputBuffer + "visited "
    return outputBuffer
  }

  availableNeighbors() {
    let neighborIndexes = [[0, -1], [1, 0], [0, 1], [-1, 0]]
    let outputBuffer = []

    neighborIndexes.forEach(coords => {
      let potentialNeighborRow = this.y + coords[1]
      let potentialNeighborCol = this.x + coords[0]
      let potentialNeighbor

      if (
        grid[potentialNeighborRow] &&
        grid[potentialNeighborRow][potentialNeighborCol]
      ) {
        potentialNeighbor = grid[potentialNeighborRow][potentialNeighborCol]
      } else {
        return
      }

      if (potentialNeighbor && potentialNeighbor.visited === false) {
        outputBuffer.push(potentialNeighbor)
      }
    })

    return outputBuffer
  }
}

const grid = []
const stack = []

function setup(height, width) {
  if (!width) {
    width = height
  }

  for (let i = 0; i < height; i++) {
    let row = []
    let domRow = document.createElement('tr')

    for (let j = 0; j < width; j++) {
      let cell = new Cell(j, i)
      row.push(cell)
      domRow.appendChild(cell.node)
    }

    grid.push(row)
    document.getElementById('maze').appendChild(domRow)
  }
}

setup(60)
stack.push(grid[0][0])
grid[0][0].visit

window.setInterval(step, 10)

function step() {
  deactivateActive()
  let current = stack[stack.length - 1]

  let availableCells = current.availableNeighbors()

  if (availableCells.length > 0) {
    let next = availableCells[Math.floor(Math.random() * availableCells.length)]

    removeWall(current, next)
    stack.push(next)
  } else {

    stack.pop()
  }
  current.activate()
}

function deactivateActive() {
  let active = document.querySelector(".active")
  if (!active) return
  active.classList.remove("active")
}

function removeWall(one, two) {
  let oneWall, twoWall
  if (one.x - two.x === 1) {
    // one removes left
    oneWall = 3
    twoWall = 1
  } else if (one.x - two.x === -1) {
    // one removes right
    oneWall = 1
    twoWall = 3
  } else if (one.y - two.y === 1) {
    // one removes top
    oneWall = 0
    twoWall = 2
  } else if (one.y - two.y === -1) {
    // one removes bottom
    oneWall = 2
    twoWall = 0
  }
  one.removeWall(oneWall)
  two.removeWall(twoWall)
}

