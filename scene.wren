import "graphics" for Canvas, Color
import "input" for Mouse
import "math" for Vec

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
    _items = [
      Item.new(Vec.new(0, 0, 1), Vec.new(1, 1), "coin"),
      Item.new(Vec.new(1, 0, 3), Vec.new(1, 2), "bone")
    ]
  }

  grid { _grid }
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
    this[x, y] = this[x, y] + layers
    return itemAt(x, y)
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

var BROWNS = [
  Color.hex("#7c3f00"),
  Color.hex("#633200"),
  Color.hex("#562b00"),
  Color.hex("#492201"),
  Color.hex("#3e1c00")
]
var HOVER_COLOR = Color.rgb(255, 255, 255, 128)

class Scene {
  construct init() {
    _maxDepth = 12
    BROWNS = (_maxDepth..0).map {|v| Color.hsv(34, 1, (0.65-0.18) * (v / _maxDepth) + 0.18) }.toList
    Canvas.resize(320, 180)
    _model = Model.new(5, 5, _maxDepth)
    _tileSize = Canvas.height / _model.height
    _hoverPos = null
  }

  update() {
    var pos = Mouse.pos
    _hoverPos = null
    if (pos.x >= 0 && pos.x < (_tileSize * _model.width) && pos.y >= 0 && pos.y < (_tileSize * _model.height)) {
      pos.x = (pos.x / _tileSize).floor
      pos.y = (pos.y / _tileSize).floor
      _hoverPos = pos
      if (Mouse["left"].justPressed) {
        _model.digAt(pos.x, pos.y, 1)
      }
    }
  }

  getDepthColor(depth) {
    return BROWNS[depth] || Color.lightgray
  }

  draw(alpha) {
    Canvas.cls(Color.darkgray)
    for (y in 0..._model.height) {
      for (x in 0..._model.width) {
        var color = getDepthColor(_model[x, y].min(_maxDepth))
        Canvas.rectfill(_tileSize * x, _tileSize * y, _tileSize, _tileSize, color)
        if (_model.itemAt(x, y)) {
          Canvas.rectfill(_tileSize * x, _tileSize * y, _tileSize, _tileSize, Color.yellow)
        }
        Canvas.rect(_tileSize * x, _tileSize * y, _tileSize, _tileSize, Color.darkpurple)
      }
    }
    if (_hoverPos) {
      var border = 1
      var x = _hoverPos.x
      var y = _hoverPos.y
      Canvas.rect(_tileSize * x - border, _tileSize * y - border, _tileSize + border * 2, _tileSize + border * 2, HOVER_COLOR)
    }
  }
}
