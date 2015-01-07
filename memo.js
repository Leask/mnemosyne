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
            'SELECT `rowid`, * FROM `memos` WHERE '
          + "`status` != 'DELETED' "
          + 'ORDER BY `last_hit` DESC',
            callback
        );
    };

    var _touchByKeyword = function(keyword, callback) {
        _db.run(
            'UPDATE `memos` SET '
          + "`last_hit` = ?, "
          + "`hits`     = `hits` + 1 WHERE "
          + "`memo` LIKE '%" + _escape(keyword) + "%' AND " // MATCH
          + "`status`  != 'DELETED'",
            [_now()],
            callback
        );
    };

    var _touchById = function(id, callback) {
        _db.run(
            'UPDATE `memos` SET '
          + "`status`   = 'NORMAL', "
          + "`last_hit` = ?, "
          + '`hits`     = `hits` + 1 WHERE'
          + '`rowid`    = ?',
            [_now(), id],
            callback
        );
    };

    var _searchByKeyword = function(keyword, callback) {
        if (keyword) {
            _db.all(
                'SELECT `rowid`, * FROM `memos` WHERE '
              + "`memo` LIKE '%" + _escape(keyword) + "%' AND " // MATCH
              + "`status`  != 'DELETED' "
              + 'ORDER BY `last_hit` DESC',
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
        } else {
            _getAll(callback);
        }
    };

    var _searchAllByKeyword = function(keyword, callback) {
        _db.all(
            'SELECT `rowid`, * FROM `memos` WHERE `memo` MATCH ?',
            keyword,
            callback
        );
    };

    var _getById = function(id, callback) {
        _db.get(
            'SELECT `rowid`, * FROM `memos` WHERE `rowid` = ?',
            id,
            function(err, data) {
                if (err) {
                    return callback(err);
                }
                _touchById(id, function(tErr, tData) {
                    if (tErr) {
                        console.log(':( ' + tErr);
                    }
                    callback(null, data);
                })
            }
        );
    };

    var _delById = function(id, callback) {
        _db.run(
            'UPDATE `memos` SET '
          + "`status`     = 'DELETED', "
          + "`deleted_at` = ? WHERE "
          + '`rowid`      = ? AND '
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

    var _getTrash = function(callback) {
        _db.all(
            'SELECT   `rowid`, * FROM `memos` '
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
