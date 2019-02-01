const common = require('./common')

module.exports = (pkg, robot) => {

  const conf = new common.Conf(robot)

  return (property, fallback) => {
    const id = common.makeId(pkg, property)
    if (!common.testId(id)) {
      throw new Error('malformed package or property name')
    }
    return common.resolve(conf, id, fallback)
  }
}
