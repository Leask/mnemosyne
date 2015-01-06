#!/usr/bin/env node
//

// load requirements
var env   = require('./env'),
    memo  = require('./memo'),
    table = require('tab');

// check configurations
if (!env) {
    console.log(':( Error loading configurations');
    process.exit(1);
}

// init
memo.Init(env);
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


// var getMemoById = function(id, callback) {
//     var db = new sqlite.Database(env.dbFile);
//     db.get(
//         'SELECT * FROM `memos` WHERE `id` = ?',
//         id,
//         function(err, data) {
//             db.close();
//             if (err) {
//                 console.log(':( ' + err);
//                 process.exit(1);
//             }
//             callback(data);
//         }
//     );
// };

var renderMemos = function(memos) {
    // instantiate
    var output = new table({
        head: ['ID', 'MEMO', 'HIT', 'CREATED', 'UPDATED', 'LAST MATCHED']
      , colWidths: [4, 20, 5, 10, 10, 10]
    });
    // table is an Array, so you can `push`, `unshift`, `splice` and friends
    for (var i = 0; i < memos.length; i++) {
        output.push([
            memos[i].rowid,
            memos[i].memo,
            memos[i].hits,
            memos[i].created_at,
            memos[i].updated_at,
            memos[i].last_matched
        ]);
    }
    console.log(output.toString());
}

memo.GetAll(function(err, data) {
    renderMemos(data);
});

var touchMemo = function(memo, callback) {

};

// memo.Touch('okok test 中asdfasdfsdf文', function(err, data) {
//     // console.log(data);
// })

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
