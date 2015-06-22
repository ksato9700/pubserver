#
# Copyright 2015 Kenichi Sato
#
AdmZip = require 'adm-zip'
parse = require 'csv-parse'
async = require 'async'

mongodb = require 'mongodb'
MongoClient = mongodb.MongoClient

mongodb_credential = process.env.AOZORA_MONGODB_CREDENTIAL || ''
mongodb_host = process.env.AOZORA_MONGODB_HOST || 'localhost'
mongodb_port = process.env.AOZORA_MONGODB_PORT || '27017'
mongo_url = "mongodb://#{mongodb_credential}#{mongodb_host}:#{mongodb_port}/aozora"

list_url_base = 'https://github.com/aozorabunko/aozorabunko/raw/master/index_pages/'
listfile_inp = 'list_inp_person_all_utf8.zip'
list_url_pub = 'list_person_all_extended_utf8.zip'

person_extended_attrs = [
  'book_id',
  'title',
  'title_yomi',
  'title_sort',
  'subtitle',
  'subtitle_yomi',
  'original_title',
  'first_appearance',
  'ndc_code',
  'font_kana_type',
  'copyright',
  'release_date',
  'last_modified',
  'card_url',
  'person_id',
  'last_name',
  'first_name',
  'last_name_yomi',
  'first_name_yomi',
  'last_name_sort',
  'first_name_sort',
  'last_name_roman',
  'first_name_roman',
  'role',
  'date_of_birth',
  'date_of_death',
  'author_copyright',
  'base_book_1',
  'base_book_1_publisher',
  'base_book_1_1st_edition'
  'base_book_1_edition_input',
  'base_book_1_eidtion_proofing',
  'base_book_1_parent',
  'base_book_1_parent_publisher',
  'base_book_1_parent_1st_edition',
  'base_book_2',
  'base_book_2_publisher',
  'base_book_2_1st_edition',
  'base_book_2_edition_input',
  'base_book_2_eidtion_proofing',
  'base_book_2_parent',
  'base_book_2_parent_publisher',
  'base_book_2_parent_1st_edition',
  'input',
  'proofing',
  'text_url',
  'text_last_modified',
  'text_encoding',
  'text_charset',
  'text_updated',
  'html_url',
  'html_last_modified',
  'html_encoding',
  'html_charset',
  'html_updated'
  ]


get_bookobj = (entry, batch)->
  obj = {}
  person_extended_attrs.forEach (e,i)->
    value = entry[i]
    if value != ''
      if e in ['book_id', 'person_id', 'text_updated', 'html_updated']
        value = parseInt value
      if e in ['release_date', 'last_modified', 'date_of_birth', 'date_of_death',
               'text_last_modified', 'html_last_modified']
        value = new Date value
      if e in ['copyright', 'author_copyright']
        value = value != 'なし'
      obj[e] = value
  batch.find({book_id: obj['book_id']}).upsert().replaceOne obj


MongoClient.connect mongo_url, (err, db)->
  if err
    console.log err
    return -1
  db = db
  books = db.collection('books')

  zip = AdmZip './' + list_url_pub
  entries = zip.getEntries()
  if entries.length != 1
    return -1
  buf = zip.readFile entries[0]
  parse buf, (err, data)->
    batch = books.initializeUnorderedBulkOp()
    get_bookobj entry, batch for entry in data[1..]

    batch.execute (err, result)->
      if err
        console.log 'err', err
      db.close()
