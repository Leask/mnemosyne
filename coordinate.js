'use strict';

var coordinate = function() {

    var _exec = require('child_process').exec;

    var _shell = function(command, callback) {
        return _exec(command, function(error, stdout, stderr) {
            return callback(
                error || (stderr || '').trim(), (stdout || '').trim()
            );
        });
    };

    var _get = function(callback) {
        return _shell('whereami', callback);
    };

    return {
        Get : _get
    };

}();

module.exports = coordinate;
