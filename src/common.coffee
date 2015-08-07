exports = module.exports = {}

exports.Conf = class Conf
  constructor: (@robot) ->
    @cache = {}

    @robot.brain.on "loaded", @load
    if @robot.brain.data.users.length
      @load()

  load: =>
    if @robot.brain.data.conf
      @cache = @robot.brain.data.conf
    else
      @robot.brain.data.conf = @cache

  exists: (key) =>
    return @cache[key]?

  get: (key) =>
    return @cache[key]

  set: (key, value) =>
    old = @cache[key]
    @cache[key] = value
    return old

  unset: (key) =>
    if @exists key
      value = @cache[key]
      delete @cache[key]
      return value
    else
      return null

  keys: =>
    return Object.keys(@cache).sort()

IDENTIFIER = exports.IDENTIFIER = "[a-z]+(?:\\.[a-z]+)*"

testId = exports.testId = (id) ->
  return ///^#{IDENTIFIER}$///.test(id)

makeId = exports.makeId = (pkg, property) ->
  return "#{pkg}.#{property}"

toEnvName = exports.toEnvName = (id) ->
  return "HUBOT_#{id.replace(/\./g, "_").toUpperCase()}"

resolveStat = exports.resolveStat = (conf, id) ->
  if conf.exists id
    return [conf.get(id), true]
  else
    envName = toEnvName id
    return [process.env[envName], false]

resolve = exports.resolve = (conf, id, fallback) ->
  [value, _] = resolveStat conf, id
  return value ? fallback
