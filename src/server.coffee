#
# Copyright 2015 Kenichi Sato
#
express = require 'express'
morgan = require 'morgan'
bodyParser = require 'body-parser'
methodOverride = require 'method-override'
compression = require 'compression'
mongodb = require 'mongodb'

MongoClient = mongodb.MongoClient
GridStore = mongodb.GridStore

mongodb_credential = process.env.AOZORA_MONGODB_CREDENTIAL || ''
mongodb_host = process.env.AOZORA_MONGODB_HOST || 'localhost'
mongodb_port = process.env.AOZORA_MONGODB_PORT || '27017'
mongo_url = "mongodb://#{mongodb_credential}#{mongodb_host}:#{mongodb_port}/aozora"

app = express();

version = 'v0.1'
api_root = '/api/' + version

app.use express.static __dirname + '/../public'
app.use morgan 'dev'
app.use bodyParser.urlencoded
  extended: false
app.use bodyParser.json()
app.use methodOverride()
app.use compression()

app.route api_root + '/books'
  .get (req, res, next)->
    app.my.books.find {}, {_id: 0, author: 0}, (err, items)->
      items.toArray (err, docs)->
        if err
          console.log err
          return res.status(500).end()
        else
          res.json docs

app.route api_root + '/books/:book_id'
  .get (req, res, next)->
    book_id = parseInt req.params.book_id
    app.my.books.findOne {id: book_id}, {_id: 0}, (err, doc)->
      if err
        console.log err
        return res.status(404).end()
      else
        console.log doc
        res.json doc

content_type =
  'txt': 'text/plain; charset=shift_jis'

app.route api_root + '/books/:book_id/content'
  .get (req, res, next)->
    book_id = req.params.book_id
    ext = req.query.format
    GridStore.read app.my.db, "#{book_id}.#{ext}", (err, result)->
      if err
        console.log err
        return res.status(404).end()
      res.set 'Content-Type', content_type[ext] || 'application/octet-stream'
      res.send result

MongoClient.connect mongo_url, (err, db)->
  if err
    console.log err
    return -1
  port = process.env.PORT || 5000
  app.my = {}
  app.my.db = db
  app.my.books = db.collection('books')
  app.my.authors = db.collection('authors')
  app.listen port, ->
    console.log "Magic happens on port #{port}"
