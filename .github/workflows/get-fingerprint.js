const packages = require("/tmp/packages.json")
const packageName = process.argv[process.argv.length - 1]
const package = packages.pins.find(p => p.identity === packageName)
console.log(package.state.revision)
