#!/usr/bin/env coffee
mongodb = require 'mongodb'
fs = require 'fs'
async = require 'async'
path = require 'path'

MongoClient = mongodb.MongoClient
GridStore = mongodb.GridStore

mongodb_credential = process.env.AOZORA_MONGODB_CREDENTIAL || ''
mongodb_host = process.env.AOZORA_MONGODB_HOST || 'localhost'
mongodb_port = process.env.AOZORA_MONGODB_PORT || '27017'
url = "mongodb://#{mongodb_credential}#{mongodb_host}:#{mongodb_port}/aozora"


upload_content = (db, book_id, source_file, cb)->
  gs = new GridStore db, book_id, "#{book_id}.txt", 'w'
  gs.writeFile source_file, cb

MongoClient.connect url, (err, db)->
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
      book_id = bookobj.id
      books.update {id: book_id}, bookobj, {upsert: true}, (err, doc)->
        if err
          cb err
        else
          source_file = (path.dirname f) + "/#{book_id}.txt"
          upload_content db, book_id, source_file, cb

  , (err, result)->
    if err
      console.log err
      return -1
    else
      console.log result.length
      db.close()
