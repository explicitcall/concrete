db = require 'benchdb/api'
Type = require 'benchdb'
path = require 'path'
dbName = path.basename(process.cwd()).replace(/\./, "-")
_ = require 'underscore'
a = require 'async'

concreteDb = new db '127.0.0.1', 5984, "concrete_#{ dbName }"

jobType = new Type concreteDb, 'job'

jobs = module.exports =
  current: null
  addJob: (next) ->
    jobType.instance true, (error, instance) ->
      _(instance.data).extend
        addedTime: new Date().getTime()
        log: ''
        running: false
        finished: false
      instance.save ->
        next(instance.data)

  getQueued: (next) ->
    getJobs running: false, next

  getRunning: (next) ->
    getJobs running: true, next

  getAll: (cb) ->
    jobType.filterByFields include_docs: true, (err, res) ->
      cb (job.data for job in res.instances)

  getLast: (next) ->
    jobType.filterByField {
      sort: 'addedTime'
      descending: true
      limit: 1
      include_docs: true }, (error, res) ->
        collection = res.instances
        if collection.length > 0
          next collection[0].data
        else
          next()

  get: (id, next) ->
    concreteDb.retrieve id, (error, job) ->
      if error?
        next "No job found with the id '#{id}'"
      else
        next job

  clear: (cb) ->
    jobType.all (err, res) ->
      a.each res.instances, ((one, next) -> concreteDb.remove one.data, next), ->
        cb res.instances

  getLog: (id, next) ->
    concreteDb.retrieve id, (error, job) ->
      if error?
        next "No job found with the id '#{id}'"
      else
        next job.log

  updateLog: (id, string, next) ->
    concreteDb.retrieve id, (error, job) ->
      if error?
        return false
      else
        job.log += "#{string} <br />"
        concreteDb.modify job, (err, res) ->
          next()

  currentComplete: (success, next) ->
    concreteDb.retrieve @current, (error, job) ->
      if error?
        return false
      else
        job.running = false
        job.finished = true
        job.failed = not success
        job.finishedTime = new Date().getTime()
        jobs.current = null
        concreteDb.modify job, ->
          next()

  next: (next) ->
    jobType.filterByFields {sort: ['addedTime'], limit: 1},
      {running: no, finished: no}, (error, res) ->
        job = res.instances[0]
        return false if not job?
        job.data.running = true
        job.data.startedTime = new Date().getTime()
        jobs.current = job.id
        job.save -> next()

getJobs = (filter, next) ->
  if filter?
    jobType.filterByFields {sort: ['addedTime'], include_docs: true}, filter,
      (error, res) ->
        next (job.data for job in res.instances)
  else
    jobType.filterByFields {sort: ['addedTime'], include_docs: true},
      (error, res) ->
        next (job.data for job in res.instances)
