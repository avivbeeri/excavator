import "graphics" for Canvas, Color
import "./profile" for Profile
import "./scene" for Scene
import "input" for Keyboard

class MenuScene is Scene {
  construct init(args) {
    super(args)
  }
  update() {
    if (Keyboard["space"].justPressed) {
      parent.loadScene("game")
    }
  }

  draw(alpha) {
    Canvas.cls()
    Canvas.print("Current earnings: %(Profile.currency)", 0, 0, Color.white)
    if (Profile.currency <= 0) {
      Canvas.print("You've run out of money!", 0, 8, Color.white)
      Canvas.print("Unfortunately you lose.", 0, 16, Color.white)
    } else {
      Canvas.print("Press SPACE to begin", 0, 8, Color.white)
    }
  }
}
