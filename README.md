# hubot-conf

A configuration management system for hubot.

The system has two parts:

**For script implementers**: It can be used by hubot script implementers to
read configuration values, either ones that are dynamically set via chat or
statically set via environment variables.

**For users**: It can also be used by hubot users to dynamically set (or
override) configuration values through the chat interface.

## Demo

![Demo](https://raw.githubusercontent.com/anishathalye/hubot-conf/docs/demo.png)

## Chat Interface (for users)

If you're using scripts that make use of hubot-conf, it's good to enable the
chat interface so you can dynamically configure settings.

To do this, run the following command in your project repo:

`npm install hubot-conf --save`

Then add **hubot-conf** to your `external-scripts.json`:

```json
[
  "hubot-conf"
]
```

To see how to use the chat interface, say `{botname} help conf` in the chat.

If you prefer to use environment variables for settings, you can do so.
Configuration setting names are mapped as follows: `property.path` is mapped to
the `HUBOT_PROPERTY_PATH` environment variable (replace `.` with `_`, make
uppercase, and prepend with `HUBOT_`).

### Configuration

* `HUBOT_CONF_HIDDEN` - a comma-separated list of properties corresponding to
  environment variables that are hidden and not visible from the chat frontend.

## Library (for script implementers)

If you're a script implementer, you can use hubot-conf as a library to read
configuration values. The library supports both dynamically set values (through
the chat interface) and statically set values (as environment variables). If
the hubot user hasn't enabled the chat interface, the library will still work;
it will just read statically set values.

Properties are of the form `package.name.property.name`, where individual
components of the name are lowercase letters. Usually, the package name is a
single word matching the script name. Individual property names depend on the
script.

As an example, we will consider a fictional script `example`. When you use this
library, users can configure settings like `example.property` (dynamically) or
the corresponding `HUBOT_EXAMPLE_PROPERTY` (statically).

To use the library, run `npm install hubot-conf --save` in your project
repository. Here is a sample use of the library:

```coffee
module.exports = (robot) ->
  config = require('hubot-conf')('example', robot)

  robot.respond /hello/, (msg) ->
    # read the 'response.hello' property for the package 'example'
    #
    # it could be set by someone running something like
    #
    #     hubot conf set example.response.hello "Hello there!"
    #
    # or it could be set in the HUBOT_EXAMPLE_RESPONSE_HELLO environment
    # variable
    msg.send config('response.hello')

  robot.respond /goodbye/, (msg) ->
    # read the 'response.goodbye' property for the package 'example'
    #
    # this time, we have a fallback in case neither the config nor the
    # environment variable is set
    msg.send config('response.goodbye', "Goodbye.")
```

Here is an example transcript after setting the environment variable
`HUBOT_EXAMPLE_RESPONSE_HELLO='sup?'` (and nothing else):

```
hubot> hubot hello
sup?
hubot> hubot goodbye
Goodbye.
hubot> hubot conf get example.response.hello
example.response.hello = `"sup?"` (environment variable)
hubot> hubot conf set example.response.goodbye ":("
example.response.goodbye = `":("`
hubot> hubot goodbye
:(
```

For more in-depth uses of the library, take a look at
[hubot-group][hubot-group] and [hubot-shortcut][hubot-shortcut].

## License

Copyright (c) 2015-2019 Anish Athalye. Released under the MIT License. See
[LICENSE.md][license] for details.

[license]: LICENSE.md
[hubot-group]: https://github.com/anishathalye/hubot-group
[hubot-shortcut]: https://github.com/anishathalye/hubot-shortcut
