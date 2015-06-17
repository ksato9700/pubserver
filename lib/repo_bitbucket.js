(function() {
  var BITBUCKET_APIBASE, BITBUCKET_PASS, BITBUCKET_USER, request;

  request = require('request');

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
      }
    });
    return r.post(repo_url, {
      body: {
        scm: "git",
        is_private: is_private,
        fork_policy: is_private ? "no_public_forks" : "allow_forks"
      },
      json: true
    }, function(err, resp, body) {
      if (err || body.error) {
        console.log(err || body.error);
        cb(400);
        return;
      }
      console.log(body);
      return cb(201);
    });
  };

}).call(this);
