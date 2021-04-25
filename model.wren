import "math" for Vec
import "./log" for Log

class Tool {
  construct new(name, size, power) {
    _name = name
    _size = size
    _power = power
    _template = getTemplate()
  }

  name { _name }
  size { _size }
  power { _power }
  template { _template }

  getTemplate() {
    var center = Vec.new()
    var targets = [center]
    for (y in -_size .. _size) {
      for (x in -_size .. _size) {
        var loc = (Vec.new(x, y))
        if (!(x == 0 && y == 0) && (loc - center).manhattan <= _size) {
          targets.add(loc)
        }
      }
    }
    return targets
  }
}

class Item {
  construct new(id, pos, size, type, value) {
    _pos = pos
    _health = 3
    _size = size
    _itemType = type
    _value = value
    _id = id
  }

  id { _id }
  pos { _pos }
  size { _size }
  itemType { _itemType }
  health { _health }
  value { _value }
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
      Item.new(0, Vec.new(0, 0, 1), Vec.new(1, 1), "coin", 4),
      Item.new(1, Vec.new(1, 0, 3), Vec.new(1, 2), "bone", 8),
      Item.new(2, Vec.new(1, 4, 4), Vec.new(2, 1), "ironbar", 8),
      Item.new(3, Vec.new(3, 3, 4), Vec.new(2, 2), "pot", 16)
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

  digWith(x, y, tool) {
    var result = []
    var pos = Vec.new(x, y)
    var locations = tool.template.map{|spot| spot + pos }
    var foundItems = {}
    var damagedItems = {}
    for (layer in 0...tool.power) {
      for (location in locations) {
        var x = location.x
        var y = location.y
        if (x < 0 || x >= _width || y < 0 || y >= _height) {
          continue
        }
        var currentItem = itemAt(x, y)
        if (!currentItem) {
          this[x, y] = this[x, y] + 1
          var item = itemAt(x, y)
          if (item) {
            foundItems[item.id] = item
          }
        } else {
          damagedItems[currentItem.id] = currentItem
        }
      }
    }

    for (item in damagedItems.values) {
      result.add(["damage", item])
      item.damage()
      Log.debug("Damaged %(item.itemType) at %(x), %(y)")
    }
    for (item in foundItems.values) {
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
    if (isComplete) {
      result.add(["complete"])
    }
    _movesTaken = (_movesTaken + 1)
    return result
  }

  digAt(x, y, layers) {
    var result = []
    var currentItem = itemAt(x, y)
    if (currentItem) {
      result.add(["damage", currentItem])
      if (currentItem.health > 0) {
        _movesTaken = (_movesTaken + 1)
      }
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
        if (isComplete) {
          result.add(["complete"])
        }
      }
      _movesTaken = (_movesTaken + 1)
    }
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

  calculateScore() {
    var total = 0
    var totalDepth = 0
    for (item in _foundItems) {
      var value = (item.value / 2.pow(3 - item.health)).floor
      Log.debug("%(item.itemType) with %(item.health) health = %(value)")
      total = total + value
      totalDepth = totalDepth + item.pos.z
    }
    Log.debug("Spend %(_movesTaken) to complete")
    total = total - (_movesTaken - totalDepth)

    return total
  }
}
