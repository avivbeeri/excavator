import "./scene" for Scene

class Main {
  construct new() {}
  init() {
    _scene = Scene.init()
  }

  update() {
    _scene.update()
  }

  draw(alpha) {
    _scene.draw(alpha)
  }
}

var Game = Main.new()
