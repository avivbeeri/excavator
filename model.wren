import "math" for Vec
import "./log" for Log

class Item {
  construct new(pos, size, type) {
    _pos = pos
    _health = 3
    _size = size
    _itemType = type
  }
  pos { _pos }
  size { _size }
  itemType { _itemType }
  health { _health }
  damage() {
    _health = (_health - 1).max(0)
  }
}


class Model {
  construct new(width, height, depth) {
    _movesTaken = 0
    _width = width
    _height = height
    _grid = List.filled(width * height, 0)
    _foundItems = []
    _items = [
      Item.new(Vec.new(0, 0, 1), Vec.new(1, 1), "coin"),
      Item.new(Vec.new(1, 0, 3), Vec.new(1, 2), "bone"),
      Item.new(Vec.new(1, 4, 4), Vec.new(2, 1), "ironbar"),
      Item.new(Vec.new(3, 3, 4), Vec.new(2, 2), "pot")
    ]
  }

  isComplete { _items.count == 0 }
  grid { _grid }
  foundItems { _foundItems }
  items { _items }
  movesTaken { _movesTaken }
  width { _width }
  height { _height }
  [x, y] {
    if (x < 0 || x >= _width || y < 0 || y >= _height) {
      return Fiber.abort("Out of grid bounds")
    }

    return _grid[y * _width + x]
  }
  [x, y]=(v) {
    if (x < 0 || x >= _width || y < 0 || y >= _height) {
      return Fiber.abort("Out of grid bounds")
    }

    _grid[y * _width + x] = v
  }

  digAt(x, y, layers) {
    var result = []
    var currentItem = itemAt(x, y)
    if (currentItem) {
      result.add(["damage", currentItem])
      currentItem.damage()
      Log.debug("Damaged %(currentItem.itemType) at %(x), %(y)")
      /*


      if (currentItem.health == 0) {
        _items.remove(currentItem)
        result.add(["destroyed", currentItem])
        Log.debug("Destroyed %(currentItem.itemType) at %(x), %(y)")
      }
      */
    } else {
      this[x, y] = this[x, y] + layers
      var item = itemAt(x, y)
      Log.debug("Digging at %(x), %(y)")
      if (item) {
        var top = item.pos
        var bottom = item.pos + item.size
        var covered = false
        for (y in top.y...bottom.y) {
          for (x in top.x...bottom.x) {
            if (!itemAt(x, y)) {
              covered = true
              break
            }
          }
        }
        if (!covered) {
          _items.remove(item)
          _foundItems.add(item)
          result.add(["found", item])
          Log.debug("Item %(item.itemType) was found!")
        }
      }
    }
    _movesTaken = (_movesTaken + 1)
    return result
  }

  itemAt(x, y) { itemAt(x, y, this[x, y]) }
  itemAt(x, y, depth) {
    for (item in _items) {
      var corner = item.pos + item.size
      if (x >= item.pos.x && y >= item.pos.y && x < corner.x && y < corner.y) {
        if (item.pos.z == depth) {
          return item
        }
      }
    }
    return null
  }
}
