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
          + 'ORDER BY `updated_at` DESC',
            callback
        );
    };

    var _searchByKeyword = function(keyword, callback) {
        _db.all(
            'SELECT rowid, * FROM `memos` WHERE '
          + "`memo` MATCH '" + keyword + "'",
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
        _db.run(
            'INSERT INTO `memos` '
          + '(`memo`, `created_at`, `updated_at`, `deleted_at`, `status`, `first_matched`, `last_matched`, `hits`) '
          + 'VALUES '
          + "(?, datetime('now'), datetime('now'), datetime('now'), 'NORMAL', datetime('now'), datetime('now'), 1)",
            memo,
            function(err) {
                if (err) {
                    return callback(err);
                }
                _getById(this.lastInsertRowID, callback);
            }
        );
    };

    var _touch = function(memo, callback) {
        _searchByKeyword(memo, function(err, data) {
            if (err) {
                return callback(err);
            }
            if (data.length) {
                callback(null, data)
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
