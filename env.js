'use strict';

// http://stackoverflow.com/questions/9080085/node-js-find-home-directory-in-platform-agnostic-way
var getUserHome = function() {
    return process.env[(process.platform === 'win32') ? 'USERPROFILE' : 'HOME'];
}

var env = {};

env.configDir = getUserHome() + '/.mnemosyne';
env.dbFile    = env.configDir + '/memos.db';

module.exports = env;
