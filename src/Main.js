const Writable = require('stream').Writable;
"use strict";

const s = new Writable({
    write: function(chunk, enc, next) {
        console.log(chunk)
        next();
    }
});

exports.stdout = process.stdout;

exports.outputStream = s;

exports.streamToBuffer = function(callback) {
    return function (responseStream) {
        return function() {
            var os = new Writable({
                write: function(chunk, enc, next) {
                    callback(chunk)();
                    next();
                }
            });
            responseStream.pipe(os);
        }
    }
}