#
# Copyright 2015 Kenichi Sato
#
request = require 'request'
async = require 'async'
git_utils = require './git_utils'

BITBUCKET_APIBASE = "https://api.bitbucket.org/2.0"
BITBUCKET_USER = process.env.AOZORA_BITBUCKET_USER
BITBUCKET_PASS = process.env.AOZORA_BITBUCKET_PASS
BITBUCKET_EMAIL = process.env.AOZORA_BITBUCKET_EMAIL

exports.init_repo = (title, author, book_id, is_private, cb)->
  if not (title and author and book_id)
    cb 400
    return

  repo_url = BITBUCKET_APIBASE + "/repositories/#{BITBUCKET_USER}/#{book_id}"

  r = request.defaults
    auth:
      user: BITBUCKET_USER
      pass: BITBUCKET_PASS
    json: true

  r.post repo_url,
    body:
      scm: "git"
      is_private: is_private
      fork_policy: if is_private then "no_public_forks" else "allow_forks"
  , (err, resp, body)->
    if err or (body.error and body.error.message is not 'Repository already exists.')
      console.log err or body.error
      cb 400
      return

    r.get repo_url, (err, resp, body)->
      async.some body.links.clone, (entry, cb2)->
        if entry.name == 'https'
          git_utils.set_credential BITBUCKET_USER, BITBUCKET_PASS, BITBUCKET_EMAIL
          git_utils.setup_repo entry.href, book_id, (repo)->
            cb2 true
        else
          cb2 false
      , (result)->
        return cb if result then 201 else 500
