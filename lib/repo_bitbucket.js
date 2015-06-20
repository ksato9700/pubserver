(function() {
  var BITBUCKET_APIBASE, BITBUCKET_PASS, BITBUCKET_USER, async, git_utils, request;

  request = require('request');

  async = require('async');

  git_utils = require('./git_utils');

  BITBUCKET_APIBASE = "https://api.bitbucket.org/2.0";

  BITBUCKET_USER = process.env.AOZORA_BITBUCKET_USER;

  BITBUCKET_PASS = process.env.AOZORA_BITBUCKET_PASS;

  exports.init_repo = function(title, author, book_id, is_private, cb) {
    var r, repo_url;
    if (!(title && author && book_id)) {
      cb(400);
      return;
    }
    repo_url = BITBUCKET_APIBASE + ("/repositories/" + BITBUCKET_USER + "/" + book_id);
    r = request.defaults({
      auth: {
        user: BITBUCKET_USER,
        pass: BITBUCKET_PASS
      },
      json: true
    });
    return r.post(repo_url, {
      body: {
        scm: "git",
        is_private: is_private,
        fork_policy: is_private ? "no_public_forks" : "allow_forks"
      }
    }, function(err, resp, body) {
      if (err || (body.error && body.error.message === !'Repository already exists.')) {
        console.log(err || body.error);
        cb(400);
        return;
      }
      return r.get(repo_url, function(err, resp, body) {
        return async.some(body.links.clone, function(entry, cb2) {
          var origin_url;
          if (entry.name === 'https') {
            origin_url = entry.href.replace('@', ":" + BITBUCKET_PASS + "@");
            return git_utils.setup_repo(origin_url, book_id, function(repo) {
              return cb2(true);
            });
          } else {
            return cb2(false);
          }
        }, function(result) {
          return cb(result ? 201 : 500);
        });
      });
    });
  };

}).call(this);
