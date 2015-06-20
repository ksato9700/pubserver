(function() {
  var Git, open_or_clone;

  Git = require('nodegit');

  open_or_clone = function(repo_local_path, origin_url) {
    var clone_options;
    clone_options = {
      remoteCallbacks: {
        certificateCheck: function() {
          return 1;
        }
      }
    };
    return Git.Repository.open(repo_local_path)["catch"](function(error) {
      return Git.Clone.clone(origin_url, repo_local_path, clone_options);
    });
  };

  exports.setup_repo = function(origin_url, book_id, cb) {
    var the_sig;
    the_sig = null;
    return open_or_clone("repo/" + book_id, origin_url).then(function(repo) {
      the_sig = Git.Signature["default"](repo);
      if (repo.isEmpty()) {
        return repo.index().then(function(index) {
          return index.writeTree();
        }).then(function(oid) {
          return Git.Tree.lookup(repo, oid);
        }).then(function(tree) {
          var sig;
          sig = the_sig;
          return Git.Commit.create(repo, "HEAD", sig, sig, null, "initial commit", tree, 0, []);
        }).then(function(oid) {
          return repo;
        });
      } else {
        return repo;
      }
    }).then(function(repo) {
      return Git.Remote.lookup(repo, 'origin');
    }).then(function(remote) {
      remote.addPush("refs/heads/master:refs/heads/master");
      return remote.getPushRefspecs().then(function(specs) {
        remote.setCallbacks({
          certificateCheck: function() {
            return 1;
          }
        });
        return remote.push(specs, {}, null, null);
      });
    }).then(function(error) {
      if (error) {
        console.log('push error:', error);
      }
      return cb(error === 0);
    })["catch"](function(error) {
      console.log('catched error', error);
      console.log(origin_url, book_id);
      return cb(false);
    });
  };

}).call(this);
