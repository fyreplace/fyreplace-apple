const packages = require("/tmp/packages.json")
const plugins = []

for (const packageTuple of process.argv) {
    const [packageIdentity, targetName] = packageTuple.split(':')
    const package = packages.pins.find(p => p.identity === packageIdentity)
    
    if (package && packageIdentity && targetName) {
        plugins.push({
            fingerprint: package.state.revision,
            packageIdentity,
            targetName
        })
    }
}

console.log(JSON.stringify(plugins, null, 4))
