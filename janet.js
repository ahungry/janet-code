const janet = {
  plus: (a, b) => a + b,
  minus: (a, b) => a - b,
  star: (a, b) => a * b,
  slash: (a, b) => a / b,

  def: function (name, ...args) {
    if (args.length == 1) {
      janet[name] = args[0]
    } else {
      janet[name] = args.reverse()[0]
    }
    // console.log('define something: ', name, args)
  },

  pp: console.log,

  do: function (...args) {
    return args
  },

  // See if we can resolve it, otherwise just return it
  resolve: function (x) {
    return undefined === janet[x] ? x : janet[x]
  },

  nil: () => [],

  wrap: function (inner) {
    console.log('use args')

    console.log(inner)
    // Last thing in body is the return value
    // return [body.reverse()[0]]
    return inner
  },

  fn: function (f) {
    return function (..._args) {
      const result = f()
      //console.log(result)

      return result
    }
  },

  call: function (...args) {
    const f = args[0]

    if (undefined === janet[f]) {
      console.error('call to this was undefined: ', f)
      return
    }

    return janet[f].apply(janet, args.slice(1).map(janet.resolve))
  }
}

// Test stuff
// janet.call('do', janet.call('def', 'x', 3), janet.call('pp', janet.call('plus', 'x', 2)))

// janet.call('do', janet.call('def', 'three', '(three)__nl____nl__', janet.call('fn', 'three', janet.call('nil'), janet.call('plus', 1, 2))), janet.call('pp', janet.call('three')))

janet.call('def', 'ping', '(ping)__nl____nl__', janet.call('fn', () => janet.wrap('ping', janet.call('nil'), janet.call('pp', 'pong'))))

janet.call('ping')
janet.call('ping')
