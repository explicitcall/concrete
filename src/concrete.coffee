process.title = 'Concrete'
version = '0.0.3-1'

# cli colors
colors = require 'colors'

usage = 'Usage: concrete [-hpv] path_to_git_repo'
optimist = require 'optimist'
{argv} = optimist
        .usage('Usage: concrete [-hpv] path_to_git_repo'.green)
        .options('h', {
            alias: 'host',
            describe: "The hostname or ip of the host to bind to",
            default: '0.0.0.0'
        })
        .options('d', {
          alias: 'basedir',
          describe: "Application base path for mounted instances",
          default: "/"
        })
        .options('p', {
            alias: 'port',
            describe: "The port to listen on",
            default: 4567
        })
        .options('help', {
            describe: "Show this message"
        })
        .options('v', {
            alias: 'version',
            describe: "Show version"
        })

# check if all our settings are good to go
if argv.help
    optimist.showHelp()
    process.exit 1

# list the version
if argv.v
    console.log "Concrete v#{version}".green
    process.exit 1

# if there isn't a repo
if argv._.length == 0
    optimist.showHelp()
    console.log 'You must specify a Git repo'.red
    process.exit 1

# start server command
startServer = ->
  db = require 'benchdb/api'
  path = require 'path'
  dbName = path.basename(process.cwd()).replace /\./, "-"
  fullDbName = "concrete_#{ dbName }"
  concreteDb = new db '127.0.0.1', 5984, fullDbName
  concreteDb.checkExists (err) ->
    if err?
      console.log "Error while creating a couchdb database named '#{fullDbName}'"
    else
      # start the server
      global.currentNamespace = argv.d
      server = require './server'
      server.listen argv.p, argv.h
      console.log "Concrete listening on port %d with host %s in directory %s".green,
        argv.p, argv.h, argv.d

# check the path and start the git request
git = require './git'
git.init(argv._[0], startServer)
