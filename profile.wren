class Profile {
  static init() {
    __currency = 25
  }

  static currency { __currency }

  static gain(n) { __currency = (__currency + n).max(0) }

  static spend(n) {
    if (n >= __currency) {
      __currency = __currency - n
      return true
    }
    return false
  }
}

Profile.init()
