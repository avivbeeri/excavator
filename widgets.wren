import "graphics" for Canvas, Color
import "input" for Mouse

class Widget {}
class Button is Widget {
  construct new(text, pos, size) {
    _text = text
    _pos = pos
    _size = size
    _corner = pos + size
    _clicked = false
    _hover = false
  }

  hover { _hover }
  clicked { _clicked }

  update() {
    var mouse = Mouse.pos
    _hover = mouse.x >= _pos.x && mouse.x < _corner.x && mouse.y >= _pos.y && mouse.y < _corner.y
    _clicked = _hover && Mouse["left"].justPressed
    return this
  }

  draw() {
    var c = Color.lightgray
    if (hover) {
      c = Color.darkgray
    }
    if (clicked) {
      c = Color.darkgray
    }
    Canvas.rectfill(_pos.x, _pos.y, _size.x, _size.y, c)
    var x = _pos.x + (_size.x - (_text.count * 8)) / 2
    Canvas.print(_text, _pos.x+4, _pos.y+4, Color.black)
  }
}
