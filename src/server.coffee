#
# Copyright 2015 Kenichi Sato
#
express = require 'express'
morgan = require 'morgan'
bodyParser = require 'body-parser'
methodOverride = require 'method-override'

app = express();

version = 'v0.1'
api_root = '/api/' + version

app.use express.static __dirname + '/../public'
app.use morgan 'dev'
app.use bodyParser.urlencoded
  extended: false
app.use bodyParser.json()
app.use methodOverride()

app.route api_root + '/books'
  .get (req, res, next)->
    res.sendStatus(501)

app.route api_root + '/books/:book_id'
  .get (req, res, next)->
    res.sendFile req.params.book_id + '.json',
      root: __dirname + '/../books/'
    , (err)->
      if err
        console.log err
        return res.status(err.status).end()

app.route api_root + '/books/:book_id/content'
  .get (req, res, next)->
    res.sendFile req.params.book_id + '.' + req.query.format,
      root: __dirname + '/../books/'
    , (err)->
      if err
        console.log err
        return res.status(err.status).end()


port = 8000
app.listen port
console.log "Magic happens on port #{port}"
