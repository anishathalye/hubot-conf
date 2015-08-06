common = require "./common"

module.exports = (pkg, robot) ->

  conf = new common.Conf robot

  return (property, fallback) ->
    id = common.makeId pkg, property
    if not common.testId id
      throw new Error "malformed package or property name"
    return common.resolve conf, id, fallback
