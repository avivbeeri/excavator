import "graphics" for Canvas, Color
import "input" for Mouse
import "./model" for Model

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
