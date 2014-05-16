'use strict';

var ngnrailsModules = angular.module('ngnrails.modules', []);

ngnrailsModules.run(function($rootScope, $location) {
    $rootScope.isActive = function(path) {
        if ($location.path().substr(0, path.length) == path) {
            return true;
        }
        else {
            return false;
        }
    };
});
