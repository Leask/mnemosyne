'use strict';

var memo = function() {

    // load requirements
    var _sqlite = require('sqlite3').verbose();

    var _db  = null;

    var _env = null;

    var _init = function(env) {
        _env = env;
        if (!_db) {
            _db = new _sqlite.Database(_env.dbFile);
        }
    };

    var _del = function() {
        if (_db) {
            _db.close();
        }
    }

    var _getAll = function(callback) {
        _db.all(
            'SELECT rowid, * FROM `memos` WHERE '
          + "`status` != 'DELETED' "
          + 'ORDER BY `last_hit` DESC',
            callback
        );
    };

    var _touchByKeyword = function(keyword, callback) {
        var now = new Date().toString();
        _db.run(
            'UPDATE `memos` SET '
          + "`status` = 'NORMAL', "
          + "`last_hit` = ?, "
          + "`hits`     = `hits` + 1 WHERE "
          + '`memo` MATCH ? AND '
          + "`status`  != 'DELETED'",
            [now, keyword],
            callback
        );
    };

    var _touchById = function(id, callback) {
        var now = new Date().toString();
        _db.run(
            'UPDATE `memos` SET '
          + "`status`   = 'NORMAL', "
          + "`last_hit` = ?, "
          + '`hits`     = `hits` + 1 WHERE'
          + '`rowid`    = ? AND '
          + "`status`  != 'DELETED'",
            [now, id],
            callback
        );
    };

    var _searchByKeyword = function(keyword, callback) {
        _db.all(
            'SELECT rowid, * FROM `memos` WHERE '
          + '`memo` MATCH ? AND '
          + "`status`  != 'DELETED'",
            keyword,
            function(err, data) {
                if (err) {
                    return callback(err);
                }
                _touchByKeyword(keyword, function(tErr, tData) {
                    if (tErr) {
                        console.log(':( ' + tErr);
                    }
                    callback(null, data);
                });
            }
        );
    };

    var _searchAllByKeyword = function(keyword, callback) {
        _db.all(
            'SELECT rowid, * FROM `memos` WHERE `memo` MATCH ?',
            keyword,
            callback
        );
    };

    var _getById = function(id, callback) {
        _db.get(
            'SELECT rowid, * FROM `memos` WHERE `rowid` = ?',
            id,
            callback
        );
    };

    var _add = function(memo, callback) {
        var now = new Date().toString();
        _db.run(
            'INSERT INTO `memos` '
          + '(`memo`, `created_at`, `updated_at`, `deleted_at`, `status`, `last_hit`, `hits`) '
          + 'VALUES '
          + "(?, ?, ?, ?, 'NORMAL', ?, 1)",
            [memo, now, now, now, now],
            function(err) {
                if (err) {
                    return callback(err);
                }
                _getById(this.lastID, callback);
            }
        );
    };

    var _touch = function(memo, callback) {
        _searchAllByKeyword(memo, function(err, data) {
            if (err) {
                return callback(err);
            }
            if (data.length) {
                _touchById(data[0].rowid, function(tErr, tData) {
                    if (tErr) {
                        console.log(':( ' + tErr);
                    }
                    callback(null, data[0]);
                });
            } else {
                _add(memo, callback);
            }
        });
    };

    return {
        Init            : _init,
        Del             : _del,
        GetAll          : _getAll,
        SearchByKeyword : _searchByKeyword,
        GetById         : _getById,
        Add             : _add,
        Touch           : _touch
    };

}();

module.exports = memo;
