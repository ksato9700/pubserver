(function() {
  var GridStore, MongoClient, api_root, app, bodyParser, compression, content_type, express, methodOverride, mongo_url, mongodb, mongodb_credential, mongodb_host, mongodb_port, morgan, version;

  express = require('express');

  morgan = require('morgan');

  bodyParser = require('body-parser');

  methodOverride = require('method-override');

  compression = require('compression');

  mongodb = require('mongodb');

  MongoClient = mongodb.MongoClient;

  GridStore = mongodb.GridStore;

  mongodb_credential = process.env.AOZORA_MONGODB_CREDENTIAL || '';

  mongodb_host = process.env.AOZORA_MONGODB_HOST || 'localhost';

  mongodb_port = process.env.AOZORA_MONGODB_PORT || '27017';

  mongo_url = "mongodb://" + mongodb_credential + mongodb_host + ":" + mongodb_port + "/aozora";

  app = express();

  version = 'v0.1';

  api_root = '/api/' + version;

  app.use(express["static"](__dirname + '/../public'));

  app.use(morgan('dev'));

  app.use(bodyParser.urlencoded({
    extended: false
  }));

  app.use(bodyParser.json());

  app.use(methodOverride());

  app.use(compression());

  app.route(api_root + '/books').get(function(req, res, next) {
    var query;
    query = {};
    if (req.query.name) {
      query['title.name'] = req.query.name;
      console.log(query);
    }
    return app.my.books.find(query, {
      _id: 0,
      author: 0
    }, function(err, items) {
      return items.toArray(function(err, docs) {
        if (err) {
          console.log(err);
          return res.status(500).end();
        } else {
          return res.json(docs);
        }
      });
    });
  });

  app.route(api_root + '/books/:book_id').get(function(req, res, next) {
    var book_id;
    book_id = parseInt(req.params.book_id);
    return app.my.books.findOne({
      id: book_id
    }, {
      _id: 0
    }, function(err, doc) {
      if (err) {
        console.log(err);
        return res.status(404).end();
      } else {
        console.log(doc);
        return res.json(doc);
      }
    });
  });

  content_type = {
    'txt': 'text/plain; charset=shift_jis'
  };

  app.route(api_root + '/books/:book_id/content').get(function(req, res, next) {
    var book_id, ext;
    book_id = req.params.book_id;
    ext = req.query.format;
    return GridStore.read(app.my.db, book_id + "." + ext, function(err, result) {
      if (err) {
        console.log(err);
        return res.status(404).end();
      }
      res.set('Content-Type', content_type[ext] || 'application/octet-stream');
      return res.send(result);
    });
  });

  app.route(api_root + '/persons').get(function(req, res, next) {
    var query;
    query = {};
    if (req.query.name) {
      query.name = req.query.name;
    }
    return app.my.persons.find(query, {
      _id: 0
    }, function(err, items) {
      return items.toArray(function(err, docs) {
        if (err) {
          console.log(err);
          return res.status(500).end();
        } else {
          return res.json(docs);
        }
      });
    });
  });

  app.route(api_root + '/persons/:person_id').get(function(req, res, next) {
    var person_id;
    person_id = parseInt(req.params.person_id);
    return app.my.persons.findOne({
      id: person_id
    }, {
      _id: 0
    }, function(err, doc) {
      if (err) {
        console.log(err);
        return res.status(404).end();
      } else {
        console.log(doc);
        return res.json(doc);
      }
    });
  });

  app.route(api_root + '/workers').get(function(req, res, next) {
    var query;
    query = {};
    if (req.query.name) {
      query.name = req.query.name;
    }
    return app.my.workers.find(query, {
      _id: 0
    }, function(err, items) {
      return items.toArray(function(err, docs) {
        if (err) {
          console.log(err);
          return res.status(500).end();
        } else {
          return res.json(docs);
        }
      });
    });
  });

  app.route(api_root + '/workers/:worker_id').get(function(req, res, next) {
    var worker_id;
    worker_id = parseInt(req.params.worker_id);
    return app.my.workers.findOne({
      id: worker_id
    }, {
      _id: 0
    }, function(err, doc) {
      if (err) {
        console.log(err);
        return res.status(404).end();
      } else {
        console.log(doc);
        return res.json(doc);
      }
    });
  });

  MongoClient.connect(mongo_url, function(err, db) {
    var port;
    if (err) {
      console.log(err);
      return -1;
    }
    port = process.env.PORT || 5000;
    app.my = {};
    app.my.db = db;
    app.my.books = db.collection('books');
    app.my.authors = db.collection('authors');
    app.my.persons = db.collection('persons');
    app.my.workers = db.collection('workers');
    return app.listen(port, function() {
      return console.log("Magic happens on port " + port);
    });
  });

}).call(this);
