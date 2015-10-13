var request = require('request');
var util = require('util');
var vm = require('vm');
var jetbrainsProducts = require('./jetbrains-products.json');

var jetbrains_versions_url = "https://www.jetbrains.com/js2/version.js"


var sandbox = {};
vm.createContext(sandbox);


request(jetbrains_versions_url, function (error, response, jsCode) {
    if (!error && response.statusCode == 200) {
        vm.runInContext(jsCode, sandbox);
        
        
        for (var product in jetbrainsProducts) {
            var variableName = jetbrainsProducts[product].variableName;
            var downloadUrl = jetbrainsProducts[product].downloadUrl.replace("%version%", sandbox[variableName]);
            
            console.log(product, downloadUrl)
        }
    }
})
