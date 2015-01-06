'use strict';

var memo = function(env) {

    // load requirements
    var _sqlite = require('sqlite3').verbose();

    var _db = null;

    var _init = function() {
        // db init
        if (!_db) {
            _db = new sqlite.Database(env.dbFile);
        }
    };

    var _del = function() {
        if (_db) {
            _db.close();
        }
    }

    var _getAll = function(callback) {
        _db.all(
            'SELECT * FROM `memos` WHERE '
          + "`status` != 'DELETED' "
          + 'ORDER BY `updated_at` DESC',
            callback
        );
    };

    var _searchByKeyword = function(keyword, callback) {
        _db.all(
            'SELECT * FROM `memos` WHERE '
          + "`memo` LIKE '%keyword%'",
            callback
        );
    };

    var _getById = function(id, callback) {
        _db.get(
            'SELECT * FROM `memos` WHERE `id` = ?',
            id,
            callback
        );
    };

    var _add = function(memo, callback) {
        db.run(
            'INSERT INTO `memos` '
          + '(`memo`, `created_at`, `updated_at`, `deleted_at`, `status`, `first_matched`, `last_matched`, `hits`) '
          + 'VALUES '
          + "(?, datetime('now'), datetime('now'), datetime('now'), 'NORMAL', datetime('now'), datetime('now'), 1)",
            memo,
            function(err) {
                if (err) {
                    return callback(err);
                }
                getMemoById(this.lastID, callback);
            }
        );
    };

    var _touch = function(memo, callback) {

    };

    return {
        Init            : _init,
        Del             : _del,
        GetAll          : _getAll,
        SearchByKeyword : _searchByKeyword,
        GetById         : _getById,
        Add             : _add
    };

}();

module.exports = memo;
