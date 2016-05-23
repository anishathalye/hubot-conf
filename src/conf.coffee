# Description:
#   A script that allows setting configuration variables.
#
# Commands:
#   hubot conf get <property> - get a property value
#   hubot conf get "<spaced property>" - get a property value
#   hubot conf set <property> "<value>" - set a property value
#   hubot conf set "<spaced property>" "<value>" - set a property value
#   hubot conf unset <property> - unset a property
#   hubot conf unset "<spaced property>" - unset a property
#   hubot conf dump - list all configuration values
#   hubot conf dump <prefix> - list all configuration values matching prefix
#   hubot conf dump "<spaced prefix>" - list all configuration values matching prefix
#
# Author:
#   anishathalye

common = require "./common"
IDENTIFIER = common.IDENTIFIER
SPACED_IDENTIFIER = common.SPACED_IDENTIFIER

module.exports = (robot) ->

  conf = new common.Conf robot

  unspaced = (spaced) ->
    spaced.replace /\s+/g, "."

  robot.respond ///conf\s+get\s+"(#{SPACED_IDENTIFIER})"///, (res) ->
    respondGet res, unspaced(res.match[1])

  robot.respond ///conf\s+get\s+(#{IDENTIFIER})///, (res) ->
    respondGet res, res.match[1]

  respondGet = (res, id) ->
    [value, set] = common.resolveStat conf, id
    if value?
      if set
        res.send "#{id} = `#{JSON.stringify value}`"
      else
        res.send "#{id} = `#{JSON.stringify value}` (environment variable)"
    else
      res.send "#{id} is unset"

  robot.respond ///conf\s+set\s+"(#{SPACED_IDENTIFIER})"\s+(".*")///, (res) ->
    respondSet res, unspaced(res.match[1]), res.match[2]

  robot.respond ///conf\s+set\s+(#{IDENTIFIER})\s+(".*")///, (res) ->
    respondSet res, res.match[1], res.match[2]

  respondSet = (res, id, value) ->
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

  robot.respond ///conf\s+unset\s+"(#{SPACED_IDENTIFIER})"///, (res) ->
    respondUnset res, unspaced(res.match[1])

  robot.respond ///conf\s+unset\s+(#{IDENTIFIER})///, (res) ->
    respondUnset res, res.match[1]

  respondUnset = (res, id) ->
    value = conf.unset id
    if value?
      res.send "#{id} unset (previously `#{JSON.stringify value}`)"
    else
      res.send "#{id} already unset"

  robot.respond ///conf\s+dump\s*$///, (res) ->
    respondDump res, null

  robot.respond ///conf\s+dump\s+"(#{SPACED_IDENTIFIER})"///, (res) ->
    respondDump res, unspaced(res.match[1])

  robot.respond ///conf\s+dump\s+(#{IDENTIFIER})///, (res) ->
    respondDump res, res.match[1]

  respondDump = (res, prefix) ->
    response = []
    for key in conf.keys()
      if (not prefix?) or key.indexOf(prefix) is 0
        response.push "#{key} = `#{JSON.stringify conf.get key}`"
    res.send response.join "\n"
