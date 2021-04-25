import "dome" for Window
import "./game" for GameScene
import "./menu" for MenuScene

class Main {
  construct new() {}
  init() {
    Window.title = "Excavator"
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
