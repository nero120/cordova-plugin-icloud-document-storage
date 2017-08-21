var iCloudDocStorage = exports;

var exec = require('cordova/exec');
var cordova = require('cordova');

iCloudDocStorage.syncToCloud = function(fileUrl, success, error) {
  exec(success, error, "iCloudDocStorage", "syncToCloud", [fileUrl]);
};