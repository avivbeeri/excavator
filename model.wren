import "math" for Vec
import "./log" for Log

class ActionResult {
  construct new(success, effects) {
    _success = success
    _effects = effects
  }
  success { _success }
  effects { _effects }
}

class Item {
  construct new(pos, size, type) {
    _pos = pos
    _size = size
    _itemType = type
  }
  pos { _pos }
  size { _size }
  itemType { _itemType }
}


class Model {
  construct new(width, height, depth) {
    _width = width
    _height = height
    _grid = List.filled(width * height, 0)
    _foundItems = []
    _items = [
      Item.new(Vec.new(0, 0, 1), Vec.new(1, 1), "coin"),
      Item.new(Vec.new(1, 0, 3), Vec.new(1, 2), "bone"),
      Item.new(Vec.new(1, 0, 5), Vec.new(2, 2), "pot")
    ]
  }

  isComplete { _items.count == 0 }
  grid { _grid }
  foundItems { _foundItems }
  items { _items }
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
    result = []
    this[x, y] = this[x, y] + layers
    var item = itemAt(x, y)
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
        result.add([item, "found"])
        Log.debug("Item %(item.itemType) was found!")
      }
    }
    return result
  }

  itemAt(x, y) {
    var depth = this[x, y]
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
