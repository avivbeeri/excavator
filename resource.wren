import "graphics" for ImageData

class Resource {
  static image(name) {
    return ImageData.loadFromFile("res/img/%(name).png")
  }
}
