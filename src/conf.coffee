# Description:
#   A script that allows setting configuration variables.
#
# Commands:
#   hubot conf get <property> - get a property value
#   hubot conf set <property> "<value>" - set a property value
#   hubot conf unset <property> - unset a property
#   hubot conf dump - list all configuration values
#
# Author:
#   anishathalye

common = require "./common"
IDENTIFIER = common.IDENTIFIER

module.exports = (robot) ->

  conf = new common.Conf robot

  robot.respond ///conf\s+get\s+(#{IDENTIFIER})///, (res) ->
    id = res.match[1]
    [value, set] = common.resolveStat conf, id
    if value?
      if set
        res.send "#{id} = `#{JSON.stringify value}`"
      else
        res.send "#{id} = `#{JSON.stringify value}` (environment variable)"
    else
      res.send "#{id} is unset"

  robot.respond ///conf\s+set\s+(#{IDENTIFIER})\s+(".*")///, (res) ->
    id = res.match[1]
    value = res.match[2]
    try
      parsed = JSON.parse value
    catch err
      res.send "could not parse value"
      return
    conf.set id, parsed
    res.send "#{id} = `#{JSON.stringify parsed}`"

  robot.respond ///conf\s+unset\s+(#{IDENTIFIER})///, (res) ->
    id = res.match[1]
    if conf.unset id
      res.send "#{id} unset"
    else
      res.send "#{id} already unset"

  robot.respond ///conf\s+dump///, (res) ->
    response = []
    for key in conf.keys()
      response.push "#{key} = `#{JSON.stringify conf.get key}`"
    res.send response.join "\n"
