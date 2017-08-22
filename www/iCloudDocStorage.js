var iCloudDocStorage = exports;

var exec = require('cordova/exec');
var cordova = require('cordova');

iCloudDocStorage.initUbiquitousContainer = function(containerId, success, error) {
  exec(success, error, "iCloudDocStorage", "initUbiquitousContainer", [containerId]);
};

iCloudDocStorage.syncToCloud = function(fileUrl, success, error) {
  exec(success, error, "iCloudDocStorage", "syncToCloud", [fileUrl]);
};