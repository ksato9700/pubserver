#!/usr/bin/env coffee
mongodb = require 'mongodb'
fs = require 'fs'
async = require 'async'

mongodb_credential = process.env.AOZORA_MONGODB_CREDENTIAL || ''
mongodb_host = process.env.AOZORA_MONGODB_HOST || 'localhost'
mongodb_port = process.env.AOZORA_MONGODB_PORT || '27017'
url = "mongodb://#{mongodb_credential}#{mongodb_host}:#{mongodb_port}/aozora"

mongodb.MongoClient.connect url, (err, db)->
  if err
    console.log err
    return -1
  books = db.collection('books')
  async.map process.argv[2..], (f, cb)->
    fs.readFile f,
      encoding: 'utf8'
    , (err, data)->
      if err
        console.log err
        cb err
        return
      bookobj = JSON.parse data
      books.update {id: bookobj.id}, bookobj, {upsert: true}, cb
  , (err, result)->
    if err
      console.log err
      return -1
    else
      console.log result.length
      db.close()
