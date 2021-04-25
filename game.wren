import "graphics" for Canvas, Color
import "input" for Mouse, Keyboard
import "math" for Vec
import "./scene" for Scene
import "./model" for Model, Tool
import "./resource" for Resource
import "./profile" for Profile
import "./widgets" for Button

var BROWNS = [
  Color.hex("#7c3f00"),
  Color.hex("#633200"),
  Color.hex("#562b00"),
  Color.hex("#492201"),
  Color.hex("#3e1c00")
]
var HOVER_COLOR = Color.rgb(255, 255, 255, 64)


class GameScene is Scene {
  construct init(args) {
    super(args)
    _maxDepth = 12
    BROWNS = (_maxDepth..0).map {|v| Color.hsv(34, 1, (0.65-0.18) * (v / _maxDepth) + 0.18) }.toList
    _model = Model.new(5, 5, _maxDepth)
    _tileSize = Canvas.height / _model.height
    _hoverPos = null
    _sprites = []
    _animations = []
    _tools = [
      Tool.new("Shovel", 1, 2),
      Tool.new("Hand-Pick", 0, 1)
    ]
    _selectedTool = 0
    var i = 0
    _buttons = _tools.map {|tool|
      var name = tool.name
      var button = Button.new(name,
        Vec.new(_tileSize * (_model.width + 1), 16 + i * 24),
        Vec.new(name.count * 8 + 8, 16)
      )
      i = i + 1
      return button
    }.toList

    updateView()
  }

  update() {
    var i = 0
    _buttons.each {|button|
      if (button.update().clicked) {
        _selectedTool = i
      }
      i = i + 1
    }
    var events = []
    if (_animations.count > 0) {
      var block = _animations[0].update()
      if (_animations[0].done) {
        _animations.removeAt(0)
      }
      if (block) {
        return
      }
    }
    var pos = Mouse.pos
    _hoverPos = null
    if (pos.x >= 0 && pos.x < (_tileSize * _model.width) &&
        pos.y >= 0 && pos.y < (_tileSize * _model.height)) {
      pos.x = (pos.x / _tileSize).floor
      pos.y = (pos.y / _tileSize).floor
      var tool = _tools[_selectedTool]
      _hoverPos = tool.template.map{|spot| spot + pos }.toList
      if (Mouse["left"].justPressed) {
        events.addAll(_model.digWith(pos.x, pos.y, tool))
        updateView()
      }
    }
    for (event in events) {
      if (event[0] == "found") {
        _animations.add(ItemFoundAnimation.new(event[1], _tileSize))
      }
      if (event[0] == "complete") {
        _animations.add(ResultScreen.new(this, [ _model ]))
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
        var nextDepth = depth
        /*
        for (i in depth..._maxDepth) {
          if (_model.itemAt(x, y, i)) {
            nextDepth = _maxDepth - (i - depth)
            break
          }
        }
        */
        if (_model.itemAt(x, y)) {
        } else {
          sprites.add(GroundTile.new(Vec.new(x, y, (depth)), _tileSize, nextDepth))
        }
      }
    }
    sprites.sort {|a, b| a.pos.z > b.pos.z }
  }

  getDepthColor(depth) {
    return BROWNS[depth] || Color.lightgray
  }

  draw(alpha) {
    Canvas.cls(Color.darkblue)
    _sprites.each {|sprite| sprite.draw() }
    if (_hoverPos) {
      var border = 0
      for (spot in _hoverPos) {
        var x = spot.x
        var y = spot.y
        Canvas.rectfill(_tileSize * x - border, _tileSize * y - border, _tileSize + border * 2, _tileSize + border * 2, HOVER_COLOR)

      }
    }
    _buttons.each {|button| button.draw() }
    Canvas.print(">", _tileSize * (_model.width + 0.5), 16 + _selectedTool * 24 + 4, Color.yellow)
    if (_animations.count > 0) {
      _animations[0].draw()
    }
    Canvas.print(_model.movesTaken, Canvas.width - 8 * 2, 0, Color.white)
  }
}

class Animation {
  construct new() {}
  update() {}
  draw() {}
  done { true }
}

class ItemFoundAnimation is Animation {
  construct new(item, tileSize) {
    super()
    _pos = item.pos
    _t = 0
    _tileSize = tileSize
    _sprite = ItemSprite.new(item, tileSize)
  }

  update() {
    _t = _t + 1
  }
  t { _t }
  pos { _pos }
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
    _damage = 3 - item.health
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
    Resource.image("%(_itemType)-%(_damage)").draw(_tileSize * pos.x, _tileSize * pos.y)
  }
}

class GroundTile is Sprite {
  construct new(pos, size) {
    super(pos)
    _tileSize = size
    _showDepth = pos.z
  }
  construct new(pos, size, showDepth) {
    super(pos)
    _tileSize = size
    _showDepth = showDepth
  }

  draw() {
    var color = getDepthColor(_showDepth)
    Canvas.rectfill(_tileSize * pos.x, _tileSize * pos.y, _tileSize, _tileSize, color)
    Canvas.rect(_tileSize * pos.x, _tileSize * pos.y, _tileSize, _tileSize, Color.darkpurple)
  }

  getDepthColor(depth) {
    return BROWNS[depth.min(BROWNS.count - 1)] || Color.lightgray
  }
}

class ResultScreen is Animation {
  construct new(parent, data) {
    super()
    _parent = parent
    _score = data[0].calculateScore()
  }

  done { false }

  update() {
    super.update()
    if (Keyboard["space"].justPressed) {
      Profile.gain(_score)
      _parent.parent.loadScene("menu")
      return true
    }
    return true
  }

  draw() {
    Canvas.rectfill(16, 16, Canvas.width - 32, Canvas.height - 32, Color.lightgray)
    Canvas.print("Dig completed", 20, 20, Color.white)
    Canvas.print("Score: %(_score)", 20, 28, Color.white)

    Canvas.print("Press space to return to the menu", 20,  Canvas.height - 32, Color.lightgray)
  }

}
