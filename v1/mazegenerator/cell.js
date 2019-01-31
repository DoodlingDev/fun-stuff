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
