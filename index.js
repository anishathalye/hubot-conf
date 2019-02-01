const path = require('path')

const SCRIPT_SRC = 'conf.js'
const LIB = './src/lib'

const loadLib = (...args) => require(LIB)(...args)

const loadPlugin = (robot, scripts) => {
  const scriptsPath = path.resolve(__dirname, 'src')
  return robot.loadFile(scriptsPath, SCRIPT_SRC)
}

module.exports = (...args) => {
  // hybrid plugin / library, switch based on type of argument
  if (typeof(args[0]) === 'string') {
    return loadLib(...args)
  } else {
    return loadPlugin(...args)
  }
}
