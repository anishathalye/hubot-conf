// Description:
//   A script that allows setting configuration variables.
//
// Configuration:
//   HUBOT_CONF_HIDDEN - a comma-separated list of properties corresponding to
//     environment variables that are hidden and not visible from the chat
//     frontend.
//
// Commands:
//   hubot conf get <property> - get a property value
//   hubot conf get "<spaced property>" - get a property value
//   hubot conf set <property> "<value>" - set a property value
//   hubot conf set "<spaced property>" "<value>" - set a property value
//   hubot conf unset <property> - unset a property
//   hubot conf unset "<spaced property>" - unset a property
//   hubot conf dump - list all configuration values
//   hubot conf dump <prefix> - list all configuration values matching prefix
//   hubot conf dump "<spaced prefix>" - list all configuration values matching prefix
//
// Author:
//   anishathalye

const common = require('./common')
const { IDENTIFIER, SPACED_IDENTIFIER } = common

module.exports = (robot) => {

  const conf = new common.Conf(robot)

  const unspaced = spaced => spaced.replace(/\s+/g, '.')

  const unique = (arr) => [...new Set(arr)]

  const hidden = (key) => {
    const list = process.env['HUBOT_CONF_HIDDEN']
    return (list != null) && (list.split(',').includes(key))
  }

  const formatKey = (key) => {
    const [value, set] = common.resolveStat(conf, key)
    if (value != null) {
      if (set) {
        return `${key} = \`${JSON.stringify(value)}\``
      } else {
        if (hidden(key)) {
          return `${key} (environment variable, hidden)`
        } else {
          return `${key} = \`${JSON.stringify(value)}\` (environment variable)`
        }
      }
    } else {
      return `${key} is unset`
    }
  }

  const respondDump = (res, prefix) => {
    let keys = conf.keys()
    const envs = Object.keys(process.env)
      .filter(key => key.indexOf('HUBOT_') === 0)
      .map(key => {
        return key.toLowerCase().replace(/_/g, '.').substring('HUBOT_'.length)
      })
    keys = unique(keys.concat(envs))
    keys.sort()
    const response = keys
      .filter(key => (prefix == null) || key.indexOf(prefix) === 0)
      .map(formatKey)
    res.send(response.join('\n'))
  }

  const respondGet = (res, id) => {
    res.send(formatKey(id))
  }

  const respondSet = (res, id, value) => {
    let parsed
    try {
      parsed = JSON.parse(value)
    } catch (err) {
      res.send('could not parse value')
      return
    }
    const old = conf.set(id, parsed)
    if (old != null) {
      res.send(`${id} = \`${JSON.stringify(parsed)}\` (previously \`${JSON.stringify(old)}\`)`)
    } else {
      res.send(`${id} = \`${JSON.stringify(parsed)}\``)
    }
  }

  const respondUnset = (res, id) => {
    const value = conf.unset(id)
    if (value != null) {
      res.send(`${id} unset (previously \`${JSON.stringify(value)}\`)`)
    } else {
      res.send(`${id} already unset`)
    }
  }

  robot.respond(new RegExp(`conf\\s+get\\s+"(${SPACED_IDENTIFIER})"`), res => {
    respondGet(res, unspaced(res.match[1]))
  })

  robot.respond(new RegExp(`conf\\s+get\\s+(${IDENTIFIER})`), res => {
    respondGet(res, res.match[1])
  })

  robot.respond(new RegExp(`conf\\s+set\\s+"(${SPACED_IDENTIFIER})"\\s+(["\\u201C].*["\\u201D])`), res => {
    respondSet(res, unspaced(res.match[1]), res.match[2].replace(/[\u201C\u201D]/g, '"'))
  })

  robot.respond(new RegExp(`conf\\s+set\\s+(${IDENTIFIER})\\s+(["\\u201C].*["\\u201D])`), res => {
    respondSet(res, res.match[1], res.match[2].replace(/[\u201C\u201D]/g, '"'))
  })

  robot.respond(new RegExp(`conf\\s+unset\\s+"(${SPACED_IDENTIFIER})"`), res => {
    respondUnset(res, unspaced(res.match[1]))
  })

  robot.respond(new RegExp(`conf\\s+unset\\s+(${IDENTIFIER})`), res => {
    respondUnset(res, res.match[1])
  })

  robot.respond(new RegExp(`conf\\s+dump\\s*$`), res => {
    respondDump(res, null)
  })

  robot.respond(new RegExp(`conf\\s+dump\\s+"(${SPACED_IDENTIFIER})"`), res => {
    respondDump(res, unspaced(res.match[1]))
  })

  robot.respond(new RegExp(`conf\\s+dump\\s+(${IDENTIFIER})`), res => {
    respondDump(res, res.match[1])
  })

}
