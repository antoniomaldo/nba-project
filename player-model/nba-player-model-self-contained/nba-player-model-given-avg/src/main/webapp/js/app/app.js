'use strict';


var fdModelApp = angular.module('fdModelApp', [
                                     'ngRoute', 'ui.bootstrap', 'LocalStorageModule']);
var pmModelApp = angular.module("pmModelApp",['ngRoute', 'ui.bootstrap', 'LocalStorageModule']);

angular
   .module("CombineModule", ["pmModelApp", "fdModelApp"])
    .config(function ($routeProvider) {
            $routeProvider
                 .when('/', {
                     templateUrl: 'views/inputs.html',
                     controller: 'pmModelController'
                 })
                 .when('/pmModel', {
                     templateUrl: 'views/pmModel.html',
                     controller: 'pmModelController'
                 })
                  .when('/fdModel', {
                     templateUrl: 'views/fanduelModel.html',
                     controller: 'fdModelController'
                 })
                .otherwise({
                    redirectTo: '/'
                });
        });
