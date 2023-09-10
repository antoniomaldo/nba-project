'use strict';

var fdModelApp = angular.module('fdModelApp');

fdModelApp.factory('fdModelService', function ($http) {

    return {
      getDayEvents : function ($scope, successCallback){
       $http.get('getDayEvents').then(function (result) {
                              $scope.dayEvents = result.data.second
      });
      },

     getDayPlayers : function ($scope) {

            $http.get('getDayPlayers').then(function (result) {
                               $scope.fdPlayers = result.data;
                                                                       });

      },

     updatePlayers : function ($scope) {

            $http.get('forceUpdate').then(function (result) {
                               $scope.fdPlayers = result.data;
                                                                       });

      },


      updateData : function (successCallback){
         $http.get('updateData').then(
                  successCallback, function (result) {
                  });
      },

      optimizeLineUps : function ($scope) {
            $http.post('optimizeLineUps', $scope.fdPlayers).then(function (result) {
                               $scope.optimizedLineups = result.data['output'];
                               $scope.fdPlayers = result.data['players'];
                               $scope.playersSum = result.data['predSum']
                                                                          });

         },
       submitLines : function ($scope, successCallback){
        $http.post('submitLines', $scope.dayEvents).then(successCallback, function (result) {
                               $scope.latestTimeStamp = result.data.first;
                               $scope.dayEvents = result.data;
              });
       },
       generateCsv : function (chosenLineUp){
        $http.post('generateLineUps', chosenLineUp).then(function (result){
        });
       }
    }

})
