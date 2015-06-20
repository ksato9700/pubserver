#
# Copyright 2015 Kenichi Sato
#
Git = require 'nodegit'

remote_callbacks = null
the_sig = null

open_or_clone = (repo_local_path, origin_url)->
  Git.Repository.open repo_local_path
  .catch (error)->
    Git.Clone.clone origin_url, repo_local_path,
      remoteCallbacks: remote_callbacks

exports.set_credential = (user, pass, email)->
  remote_callbacks =
    certificateCheck: -> 1
    credentials: ->
      Git.Cred.userpassPlaintextNew user, pass
  the_sig = Git.Signature.now user, email

exports.setup_repo = (origin_url, book_id, cb)->
  #
  # make initial commit
  #
  open_or_clone "repo/#{book_id}", origin_url
  .then (repo)->
    if repo.isEmpty()
      repo.index()
      .then (index)->
        index.writeTree()
      .then (oid)->
        Git.Tree.lookup repo, oid
      .then (tree)->
        the_sig.dup()
        .then (sig)->
          Git.Commit.create repo, "HEAD", sig, sig, null, "initial commit", tree, 0, []
        .then (oid)->
          return repo
    else
      return repo
  #
  # push the change
  #
  .then (repo)->
     Git.Remote.lookup repo, 'origin'
  .then (remote)->
    remote.addPush("refs/heads/master:refs/heads/master")
    remote.getPushRefspecs()
    .then (specs)->
      remote.setCallbacks remote_callbacks
      the_sig.dup()
      .then (sig)->
        remote.push specs, {}, sig, null
      .then (error)->
        if error
          console.log 'push error:', error
        cb error == undefined

  #
  # error catcher
  #
  .catch (error)->
    console.log 'catched error', error
    console.log origin_url, book_id
    cb false
