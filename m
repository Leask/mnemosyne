#!/usr/bin/env node
//

// load requirements
var env    = require('./env'),
    memo   = require('./memo'),
    table  = require('cli-table'),
    moment = require('moment');

// check configurations
if (!env) {
    console.log(':( Error loading configurations');
    process.exit(1);
}

// patch prototypes
if (!String.prototype.trim) {
    String.prototype.trim = function () {
        return this.replace(/^\s+|\s+$/gm, '');
    };
}

// utilities
var type = function(object) {
    return Object.prototype.toString.call(object).slice(8, -1).toLowerCase();
}

var isArray = function(object) {
    return type(object) === 'array';
}

// init
memo.Init(env);

var absoluteTime = function(rawTime) {
    return new Date(rawTime).toString();
};

var relativeTime = function(rawTime) {
    return moment(rawTime).fromNow();
};

var renderMemo = function(memo) {
    console.log(
        'ID       : ' + memo.rowid                    + '\n'
      + 'HITS     : ' + memo.hits                     + '\n'
      + 'CREATED  : ' + absoluteTime(memo.created_at) + '\n'
      + 'UPDATED  : ' + absoluteTime(memo.updated_at) + '\n'
      + 'LAST HIT : ' + absoluteTime(memo.last_hit)   + '\n'
      + 'MEMO     : ' + memo.memo
    );
}

var renderMemos = function(memos) {
    var width = {
        ID       : 5,
        MEMO     : process.stdout.columns,
        HITS     : 5,
        CREATED  : 20,
        UPDATED  : 20,
        LAST_HIT : 20
    };
    for (var i in width) {
        if (i !== 'MEMO') {
            width.MEMO -= width[i] + 2;
        }
    }
    var output = new table({
        head      : ['ID', 'MEMO', 'HITS', 'CREATED', 'UPDATED', 'LAST HIT'],
        colWidths : [width.ID     , width.MEMO   , width.HITS,
                     width.CREATED, width.UPDATED, width.LAST_HIT]
    });
    console.log(
        'Mnemosyne found ' + memos.length + ' memo'
      + (memos.length > 1 ? 's' : '')
      + ' for you @ ' + new Date() + ': '
    )
    for (i = 0; i < memos.length; i++) {
        output.push([
            memos[i].rowid,
            memos[i].memo,
            memos[i].hits,
            relativeTime(memos[i].created_at),
            relativeTime(memos[i].updated_at),
            relativeTime(memos[i].last_hit)
        ]);
    }
    console.log(output.toString());
};

var render = function(data) {
    return isArray(data) ? renderMemos(data) : renderMemo(data);
};

var list = function() {
    memo.GetAll(function(err, data) {
        if (err) {
            console.log(':( ' + err);
            process.exit(1);
        }
        render(data);
    });
};

var get = function(id) {
    id = Number(id);
    if (isNaN(id)) {
        console.log(':( Error memo id');
        process.exit(1);
    }
    memo.GetById(id, function(err, data) {
        if (err) {
            console.log(':( ' + err);
            process.exit(1);
        }
        render(data);
    });
}

var touch = function(text) {
    memo.Touch(text, function(err, data) {
        if (err) {
            console.log(':( ' + err);
            process.exit(1);
        }
        render([data]);
    })
};

var search = function() {
    memo.Search(text, function(err, data) {
        if (err) {
            console.log(':( ' + err);
            process.exit(1);
        }
        render(data);
    })
};

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
    console.log('- l / list   : text');
    console.log('- g / get    : text');
    console.log('- t / touch  : text');
    console.log('- s / search : text');
    console.log('- h / help   : text');
}

var unknownCommand = function() {
    console.log(':( Unknown command');
};

// main
process.argv.shift();
process.argv.shift();
var command = process.argv.shift();
var text    = process.argv.join(' ').trim();
switch (command) {
    case 'list':
    case 'l':
        list();
        break;
    case 'get':
    case 'g':
        get(text);
        break;
    case 'touch':
    case 't':
        touch(text);
        break;
    case 'search':
    case 's':
        search(text);
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
