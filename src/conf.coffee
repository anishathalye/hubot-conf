# Description:
#   A script that allows setting configuration variables.
#
# Configuration:
#   HUBOT_CONF_HIDDEN - a comma-separated list of properties corresponding to
#     environment variables that are hidden and not visible from the chat
#     frontend.
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

  unique = (arr) ->
    output = {}
    output[arr[key]] = arr[key] for key in [0...arr.length]
    value for key, value of output

  hidden = (key) ->
    list = process.env['HUBOT_CONF_HIDDEN']
    list? and key in list.split ','

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
        if hidden id
          res.send "#{id} (environment variable, hidden)"
        else
          res.send "#{id} = `#{JSON.stringify value}` (environment variable)"
    else
      res.send "#{id} is unset"

  robot.respond ///conf\s+set\s+"(#{SPACED_IDENTIFIER})"\s+(["\u201C].*["\u201D])///, (res) ->
    respondSet res, unspaced(res.match[1]), res.match[2].replace(/[\u201C\u201D]/g, '"')

  robot.respond ///conf\s+set\s+(#{IDENTIFIER})\s+(["\u201C].*["\u201D])///, (res) ->
    respondSet res, res.match[1], res.match[2].replace(/[\u201C\u201D]/g, '"')

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
    keys = conf.keys()
    fixCase = (key) ->
      key.toLowerCase().replace(/_/g, '.').substring('HUBOT_'.length)
    envs = (fixCase(key) for own key, val of process.env when key.indexOf('HUBOT_') is 0)
    keys = unique(keys.concat(envs))
    keys.sort()
    for key in keys
      if (not prefix?) or key.indexOf(prefix) is 0
        [value, set] = common.resolveStat conf, key
        if set
          response.push "#{key} = `#{JSON.stringify value}`"
        else
          if hidden key
            res.send "#{key} (environment variable, hidden)"
          else
            response.push "#{key} = `#{JSON.stringify value}` (environment variable)"
    res.send response.join "\n"
