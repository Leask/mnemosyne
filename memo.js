'use strict';

// load requirements
var sqlite = require('sqlite3').verbose();

var memo = function(env) {

    var _getById = function(req, res) {

    };






var getAllMemos = function(callback) {
    var db = new sqlite.Database(env.dbFile);
    db.all(
        'SELECT * FROM `memos` WHERE '
      + "`status` != 'DELETED' "
      + 'ORDER BY `updated_at` DESC',
        function(err, data) {
            db.close();
            if (err) {
                console.log(':( ' + err);
                process.exit(1);
            }
            callback(data);
        }
    );
};

var searchForMemos = function(keyword, callback) {
    var db = new sqlite.Database(env.dbFile);
    db.all(
        'SELECT * FROM `memos` WHERE '
      + "`memo` LIKE '%keyword%'",
        function(err, data) {
            db.close();
            if (err) {
                console.log(':( ' + err);
                process.exit(1);
            }
            callback(data);
        }
    );
};

var getMemoById = function(id, callback) {
    var db = new sqlite.Database(env.dbFile);
    db.get(
        'SELECT * FROM `memos` WHERE `id` = ?',
        id,
        function(err, data) {
            db.close();
            if (err) {
                console.log(':( ' + err);
                process.exit(1);
            }
            callback(data);
        }
    );
};

var newMemo = function(memo, callback) {
    var db = new sqlite.Database(env.dbFile);
    db.run(
        'INSERT INTO `memos` '
      + '(`memo`, `created_at`, `updated_at`, `deleted_at`, `status`, `first_matched`, `last_matched`, `hits`) '
      + 'VALUES '
      + "(?, datetime('now'), datetime('now'), datetime('now'), 'NORMAL', datetime('now'), datetime('now'), 1)",
        memo,
        function(err) {
            db.close();
            if (err) {
                console.log(':( ' + err);
                process.exit(1);
            }
            getMemoById(this.lastID, callback);
        }
    );
};














    return {
        getById : _getById
    };

}();

module.exports = memo;
