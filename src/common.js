exports.Conf = class Conf {
  constructor(robot) {
    this.robot = robot
    this.cache = {}

    this.robot.brain.on('loaded', this.load.bind(this))
    if (this.robot.brain.data.users.length) {
      this.load()
    }
  }

  load() {
    if (this.robot.brain.data.conf) {
      this.cache = this.robot.brain.data.conf
    } else {
      this.robot.brain.data.conf = this.cache
    }
  }

  exists(key) {
    return this.cache[key] != null
  }

  get(key) {
    return this.cache[key]
  }

  set(key, value) {
    const old = this.cache[key]
    this.cache[key] = value
    return old
  }

  unset(key) {
    if (this.exists(key)) {
      const value = this.cache[key]
      delete this.cache[key]
      return value
    } else {
      return null
    }
  }

  keys() {
    return Object.keys(this.cache).sort()
  }
}

const IDENTIFIER = (exports.IDENTIFIER = '[a-z]+(?:\\.[a-z]+)*')
const SPACED_IDENTIFIER = (exports.SPACED_IDENTIFIER = '[a-z]+(?:\\s+[a-z]+)*')

exports.testId = id => new RegExp(`^${IDENTIFIER}$`).test(id)

exports.makeId = (pkg, property) => `${pkg}.${property}`

const toEnvName = (exports.toEnvName = id => {
  return `HUBOT_${id.replace(/\./g, '_').toUpperCase()}`
})

const resolveStat = (exports.resolveStat = (conf, id) => {
  if (conf.exists(id)) {
    return [conf.get(id), true]
  } else {
    const envName = toEnvName(id)
    return [process.env[envName], false]
  }
})

const resolve = (exports.resolve = (conf, id, fallback) => {
  const [value, _] = resolveStat(conf, id)
  return value != null ? value : fallback
})
