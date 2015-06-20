#
# Copyright 2015 Kenichi Sato
#
Git = require 'nodegit'

open_or_clone = (repo_local_path, origin_url)->
  clone_options =
    remoteCallbacks:
      certificateCheck: -> 1

  Git.Repository.open repo_local_path
  .catch (error)->
    Git.Clone.clone origin_url, repo_local_path, clone_options

exports.setup_repo = (origin_url, book_id, cb)->
  the_sig = null

  #
  # make initial commit
  #
  open_or_clone "repo/#{book_id}", origin_url
  .then (repo)->
    the_sig = Git.Signature.default repo
    if repo.isEmpty()
      repo.index()
      .then (index)->
        index.writeTree()
      .then (oid)->
        Git.Tree.lookup repo, oid
      .then (tree)->
        sig = the_sig
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
      remote.setCallbacks
        certificateCheck: -> return 1
      return remote.push specs, {}, null, null
  .then (error)->
    if error
      console.log 'push error:', error
    cb error == 0

  #
  # error catcher
  #
  .catch (error)->
    console.log 'catched error', error
    console.log origin_url, book_id
    cb false
