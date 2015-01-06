#!/usr/bin/env node
//

// load configurations
var env = require('./env');
if (!env) {
    console.log(':( Error loading configurations');
    process.exit(1);
}

// load requirements
var sqlite = require('sqlite3').verbose();
 // initMnemosyne() {
 //     if [ -e "$basePath" ]; then
 //         logFile="$basePath$logFile"
 //         echoWithLog "<<<<<<< Flora BlackBox >>>>>>>\n"
 //     else
 //         logFile=".$logFile"
 //         errorNotify 'BlackBox Missing'
 //         exit 1
 //     fi
 // }
 // # Mnemosyne configurations
 // dbPath=./

// db init

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

var touchMemo = function(memo, callback) {

};

// db.serialize(function() {
    //
// });
//

newMemo('okok test 中文', function(data) {
    console.log(data);
})

// searchForMemos()

// getAllMemos(function(data) {
//     console.log(data);
// })

var fetchStdin = function(callback) {
    var stdinChunk = null;
    process.stdin.setEncoding('utf8');
    process.stdin.on('readable', function() {
        var chunk = process.stdin.read();
        stdinChunk += chunk ? chunk : '';
    });
    process.stdin.on('end', function() {
        callback(null, stdinChunk);
    });
};

var help = function() {
    console.log('- new    : text');
    console.log('- search : text');
    console.log('- help   : text');
}

var unknownCommand = function() {
    console.log(':( Unknown command');
}

// main
process.argv.shift();
process.argv.shift();
var command = process.argv.shift();
var text    = process.argv.join(' ');
switch (command) {
    case 'new':
    case 'n':
        break;
    case 'search':
    case 's':
        break;
    case 'help':
    case 'h':
        help();
        break;
    default:
        unknownCommand();
        process.exit(1);
}
if (process.stdin._readableState.highWaterMark) {
    // fetchStdin(parseList);
} else {
    // fetchList(parseList);
}
