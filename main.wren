import "dome" for Window
import "graphics" for Canvas
import "./game" for GameScene
import "./menu" for MenuScene

class Main {
  construct new() {}
  init() {
    Window.title = "Excavator"
    Window.resize(320 * 2, 180 * 2)
    Canvas.resize(320, 180)
    _scenes = {
      "game": GameScene,
      "menu": MenuScene
    }
    loadScene("menu")
  }

  update() {
    _scene.update()
  }

  draw(alpha) {
    _scene.draw(alpha)
  }

  loadScene(name) { loadScene(name, []) }
  loadScene(name, args) {
    _scene = _scenes[name].init(args)
    _scene.parent = this
  }
}

var Game = Main.new()
