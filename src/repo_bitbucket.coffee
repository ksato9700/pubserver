#
# Copyright 2015 Kenichi Sato
#
request = require 'request'

BITBUCKET_APIBASE = "https://api.bitbucket.org/2.0"
BITBUCKET_USER = process.env.AOZORA_BITBUCKET_USER
BITBUCKET_PASS = process.env.AOZORA_BITBUCKET_PASS

exports.init_repo = (title, author, book_id, is_private, cb)->
  if not (title and author and book_id)
    cb 400
    return

  repo_url = BITBUCKET_APIBASE + "/repositories/#{BITBUCKET_USER}/#{book_id}"

  r = request.defaults
    auth:
      user: BITBUCKET_USER
      pass: BITBUCKET_PASS

  r.post repo_url,
    body:
      scm: "git"
      is_private: is_private
      fork_policy: if is_private then "no_public_forks" else "allow_forks"
    json: true
  , (err, resp, body)->
    if err or body.error
      console.log err or body.error
      cb 400
      return
    console.log body
    cb 201
