path = require "path"

SCRIPT_SRC = "conf.coffee"
LIB = "./src/lib"

loadLib = (args...) ->
  return require(LIB)(args...)

loadPlugin = (robot, scripts) ->
  scriptsPath = path.resolve(__dirname, "src")
  robot.loadFile(scriptsPath, SCRIPT_SRC)

module.exports = (args...) ->
  # hybrid plugin / library, switch based on type of argument
  if typeof args[0] is "string"
    return loadLib args...
  else
    loadPlugin args...
