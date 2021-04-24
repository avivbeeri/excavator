import "graphics" for Canvas, Color
import "input" for Mouse
import "math" for Vec
import "./model" for Model
import "./resource" for Resource

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
    _sprites = []
    _animations = []

    updateView()
  }

  update() {
    var events = []
    _animations = _animations.where{|anim|
      anim.update()
      return !anim.done
    }.toList
    var pos = Mouse.pos
    _hoverPos = null
    if (pos.x >= 0 && pos.x < (_tileSize * _model.width) &&
        pos.y >= 0 && pos.y < (_tileSize * _model.height)) {
      pos.x = (pos.x / _tileSize).floor
      pos.y = (pos.y / _tileSize).floor
      _hoverPos = pos
      if (Mouse["left"].justPressed) {
        events.addAll(_model.digAt(pos.x, pos.y, 1))
        updateView()
      }
    }
    for (event in events) {
      if (event[0] == "found") {
        _animations.add(ItemFoundAnimation.new(event[1], _tileSize))
      }
    }
  }

  updateView() {
    var sprites = _sprites = []
    for (item in _model.items) {
      sprites.add(ItemSprite.new(item, _tileSize))
    }
    for (y in 0..._model.height) {
      for (x in 0..._model.width) {
        var depth = _model[x, y]
        if (_model.itemAt(x, y)) {
        } else {
          sprites.add(GroundTile.new(Vec.new(x, y, depth), _tileSize))
        }
      }
    }
    sprites.sort {|a, b| a.pos.z > b.pos.z }
  }

  getDepthColor(depth) {
    return BROWNS[depth] || Color.lightgray
  }

  draw(alpha) {
    Canvas.cls(Color.darkgray)
    _sprites.each {|sprite| sprite.draw() }
    if (_hoverPos) {
      var border = 2
      var x = _hoverPos.x
      var y = _hoverPos.y
      Canvas.rect(_tileSize * x - border, _tileSize * y - border, _tileSize + border * 2, _tileSize + border * 2, HOVER_COLOR)
    }
    _animations.each {|anim| anim.draw() }
    Canvas.print(_model.movesAllowed, Canvas.width - 8 * 2, 0, Color.white)
  }
}

class Animation {
  construct new(pos) {
    _pos = pos
  }

  pos { _pos }
  done { true }
  update() {}
  draw() {}
}

class ItemFoundAnimation is Animation {
  construct new(item, tileSize) {
    super(item.pos)
    _t = 0
    _tileSize = tileSize
    _sprite = ItemSprite.new(item, tileSize)
  }

  update() {
    _t = _t + 1
  }
  done { _t > 60 }
  draw() {
    _sprite.draw()
  }
}

class Sprite {
  construct new(pos) {
    _pos = pos
  }

  pos { _pos }
  draw() {}
}

class ItemSprite is Sprite {
  construct new(item, size) {
    super(item.pos)
    _itemType = item.itemType
    _tileSize = size
    _ground = []

    var top = item.pos
    var bottom = item.pos + item.size
    for (y in top.y...bottom.y) {
      for (x in top.x...bottom.x) {
        _ground.add(GroundTile.new(Vec.new(x, y, top.z), size))
      }
    }
  }

  draw() {
    _ground.each {|ground| ground.draw() }
    Resource.image(_itemType).draw(_tileSize * pos.x, _tileSize * pos.y)
  }
}

class GroundTile is Sprite {
  construct new(pos, size) {
    super(pos)
    _tileSize = size
  }

  draw() {
    var color = getDepthColor(pos.z)
    Canvas.rectfill(_tileSize * pos.x, _tileSize * pos.y, _tileSize, _tileSize, color)
    Canvas.rect(_tileSize * pos.x, _tileSize * pos.y, _tileSize, _tileSize, Color.darkpurple)
  }

  getDepthColor(depth) {
    return BROWNS[depth.min(BROWNS.count - 1)] || Color.lightgray
  }
}
