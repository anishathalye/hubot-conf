# Description:
#   A script that allows setting configuration variables.
#
# Commands:
#   hubot conf get <property> - get a property value
#   hubot conf set <property> "<value>" - set a property value
#   hubot conf unset <property> - unset a property
#   hubot conf dump - list all configuration values
#   hubot conf dump <prefix> - list all configuration values matching prefix
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
    old = conf.set id, parsed
    if old?
      res.send "#{id} = `#{JSON.stringify parsed}` (previously `#{JSON.stringify old}`)"
    else
      res.send "#{id} = `#{JSON.stringify parsed}`"

  robot.respond ///conf\s+unset\s+(#{IDENTIFIER})///, (res) ->
    id = res.match[1]
    value = conf.unset id
    if value?
      res.send "#{id} unset (previously `#{JSON.stringify value}`)"
    else
      res.send "#{id} already unset"

  robot.respond ///conf\s+dump(?:\s+(#{IDENTIFIER}))?///, (res) ->
    prefix = res.match[1]
    response = []
    for key in conf.keys()
      if (not prefix?) or key.indexOf(prefix) is 0
        response.push "#{key} = `#{JSON.stringify conf.get key}`"
    res.send response.join "\n"
