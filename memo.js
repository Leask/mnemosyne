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

    var _now = function() {
        return new Date().toISOString();
    }

    var _escape = function(str) {
        return str.replace('/', '//')
                  .replace("'", "''")
                  .replace('[', '/[')
                  .replace(']', '/]')
                  .replace('%', '/%')
                  .replace('&', '/&')
                  .replace('_', '/_')
                  .replace('(', '/(')
                  .replace(')', '/)');
    }

    var _getAll = function(callback) {
        _db.all(
            'SELECT * FROM `memos` WHERE '
          + "`status` != 'DELETED' "
          + 'ORDER BY `last_hit` DESC',
            callback
        );
    };

    var _touchById = function(id, callback) {
        _db.run(
            'UPDATE `memos` SET '
          + "`status`   = 'NORMAL', "
          + "`last_hit` = ?, "
          + '`hits`     = `hits` + 1 WHERE'
          + '`id`       = ?',
            [_now(), id],
            callback
        );
    };

    var _searchByKeyword = function(keyword, callback) {
        if (keyword) {
            _db.all(
                'SELECT * FROM `memos` WHERE '
              + "`memo` LIKE '%" + _escape(keyword) + "%' AND "
              + "`status` != 'DELETED' "
              + 'ORDER BY `last_hit` DESC',
                callback
            );
        } else {
            _getAll(callback);
        }
    };

    var _matchAll = function(memo, callback) {
        _db.all(
            'SELECT * FROM `memos` WHERE `memo` = ?',
            memo,
            callback
        );
    };

    var _getById = function(id, callback) {
        _db.get(
            'SELECT * FROM `memos` WHERE `id` = ?',
            id,
            function(err, data) {
                if (err) {
                    return callback(err);
                }
                _touchById(id, function(tErr, tData) {
                    callback(tErr, data);
                })
            }
        );
    };

    var _delById = function(id, callback) {
        _db.run(
            'UPDATE `memos` SET '
          + "`status`     = 'DELETED', "
          + "`deleted_at` = ? WHERE "
          + '`id`         = ? AND '
          + "`status`    != 'DELETED'",
            [_now(), id],
            function(err, data) {
                if (err) {
                    return callback(err);
                }
                if (!this.changes) {
                    return callback('Memo not found');
                }
                callback(err, data);
            }
        );
    };

    var _add = function(memo, callback) {
        _db.run(
            'INSERT INTO `memos` '
          + '(`memo`  , `created_at`, `updated_at`, `deleted_at`,'
          + ' `status`, `last_hit`  , `hits`) '
          + 'VALUES '
          + "(?, ?, ?, ?, 'NORMAL', ?, 1)",
            [memo, _now(), _now(), _now(), _now()],
            function(err) {
                if (err) {
                    return callback(err);
                }
                _getById(this.lastID, callback);
            }
        );
    };

    var _touch = function(memo, callback) {
        _matchAll(memo, function(err, data) {
            if (err) {
                return callback(err);
            }
            if (data.length) {
                _touchById(data[0].id, function(tErr, tData) {
                    callback(tErr, data[0]);
                });
            } else {
                _add(memo, callback);
            }
        });
    };

    var _getTrash = function(callback) {
        _db.all(
            'SELECT * FROM `memos` '
          + "WHERE    `status` = 'DELETED' "
          + 'ORDER BY `deleted_at` DESC',
            callback
        );
    };

    var _emptyTrash = function(callback) {
        _db.run(
            "DELETE FROM `memos` WHERE `status` = 'DELETED'",
            function(err, data) {
                if (err) {
                    return callback(err);
                }
                if (!this.changes) {
                    return callback('Trash is empty');
                }
                callback(err, data);
            }
        );
    }

    return {
        Init       : _init,
        Del        : _del,
        GetAll     : _getAll,
        Search     : _searchByKeyword,
        GetById    : _getById,
        DelById    : _delById,
        Add        : _add,
        Touch      : _touch,
        GetTrash   : _getTrash,
        EmptyTrash : _emptyTrash
    };

}();

module.exports = memo;
