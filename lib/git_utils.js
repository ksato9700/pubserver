(function() {
  var Git, open_or_clone, remote_callbacks, the_sig;

  Git = require('nodegit');

  remote_callbacks = null;

  the_sig = null;

  open_or_clone = function(repo_local_path, origin_url) {
    return Git.Repository.open(repo_local_path)["catch"](function(error) {
      return Git.Clone.clone(origin_url, repo_local_path, {
        remoteCallbacks: remote_callbacks
      });
    });
  };

  exports.set_credential = function(user, pass, email) {
    remote_callbacks = {
      certificateCheck: function() {
        return 1;
      },
      credentials: function() {
        return Git.Cred.userpassPlaintextNew(user, pass);
      }
    };
    return the_sig = Git.Signature.now(user, email);
  };

  exports.setup_repo = function(origin_url, book_id, cb) {
    return open_or_clone("repo/" + book_id, origin_url).then(function(repo) {
      if (repo.isEmpty()) {
        return repo.index().then(function(index) {
          return index.writeTree();
        }).then(function(oid) {
          return Git.Tree.lookup(repo, oid);
        }).then(function(tree) {
          return the_sig.dup().then(function(sig) {
            return Git.Commit.create(repo, "HEAD", sig, sig, null, "initial commit", tree, 0, []);
          }).then(function(oid) {
            return repo;
          });
        });
      } else {
        return repo;
      }
    }).then(function(repo) {
      return Git.Remote.lookup(repo, 'origin');
    }).then(function(remote) {
      remote.addPush("refs/heads/master:refs/heads/master");
      return remote.getPushRefspecs().then(function(specs) {
        remote.setCallbacks(remote_callbacks);
        return the_sig.dup().then(function(sig) {
          return remote.push(specs, {}, sig, null);
        }).then(function(error) {
          if (error) {
            console.log('push error:', error);
          }
          return cb(error === void 0);
        });
      });
    })["catch"](function(error) {
      console.log('catched error', error);
      console.log(origin_url, book_id);
      return cb(false);
    });
  };

}).call(this);
