'use strict';

var fdModelApp = angular.module('fdModelApp');

fdModelApp.controller('fdModelController', function ($scope, $http, fdModelService) {

    $scope.fdPlayers = [];
    $scope.playersSum = null;
    fdModelService.getDayPlayers($scope);
    fdModelService.getDayEvents($scope);

    $scope.lineUpsChosen = [];

    $scope.inputModelUrl = window.location.href.replace("fdModel", "");
    $scope.toPmModelUrl = window.location.href.replace("fdModel", "pmModel");

    $scope.shouldHidePgs = false;
    $scope.shouldHideSgs = false;
    $scope.shouldHideSfs = false;
    $scope.shouldHidePfs = false;
    $scope.shouldHideCs = false;

    $scope.showHidPgs = function(){
        $scope.shouldHidePgs = !$scope.shouldHidePgs;
    }

    $scope.showHidSgs = function(){
        $scope.shouldHideSgs = !$scope.shouldHideSgs;
    }

    $scope.showHidSfs = function(){
        $scope.shouldHideSfs = !$scope.shouldHideSfs;
    }

    $scope.showHidPfs = function(){
        $scope.shouldHidePfs = !$scope.shouldHidePfs;
    }

    $scope.showHidCs = function(){
        $scope.shouldHideCs = !$scope.shouldHideCs;
    }


    $scope.getFirst = function(value){

       let x = 1
    }

    $scope.showHideText = function(pos){
        var shouldHide;
        if(pos == "pg"){
            shouldHide = $scope.shouldHidePgs;
        }else if(pos == "sg"){
            shouldHide = $scope.shouldHideSgs;
        }else if(pos == "sf"){
            shouldHide = $scope.shouldHideSfs;
        }else if(pos == "pf"){
            shouldHide = $scope.shouldHidePfs;
        }else if(pos == "c"){
            shouldHide = $scope.shouldHideCs;
        }

      return shouldHide ? "Show " : "Hide";
    }


    $scope.shouldHidePlayer = function(pos){
        if(pos == "PG"){
            return $scope.shouldHidePgs;
        }else if(pos == "SG"){
            return $scope.shouldHideSgs;
        }else if(pos == "SF"){
            return $scope.shouldHideSfs;
        }else if(pos == "PF"){
            return $scope.shouldHidePfs;
        }else if(pos == "C"){
            return $scope.shouldHideCs;
        }
    }

    $scope.submitLines = function(){
        fdModelService.submitLines($scope ,
            function (result){
                    $scope.dayEvents = result.data.first;
            }
        )
    }

    $scope.resetPlayers = function(){
        fdModelService.getTodaysPlayers($scope);
    }

    $scope.updatePlayers = function(){
        fdModelService.updatePlayers($scope);
    }

    $scope.hideInputs = false;

    $scope.hideShowInputsFn = function(){
        $scope.hideInputs = !$scope.hideInputs;
    }

    $scope.showHideInputsText = function(){
        return $scope.hideInputs  ? "Show " : "Hide ";
    }

    $scope.optimizeLineUps = function(){
        $scope.submitLines();
        fdModelService.optimizeLineUps($scope);
    }

    $scope.updateData = function(){
         fdModelService.updateData(
             function (result) {
                 fdModelService.updateData($scope);
                 fdModelService.getDayPlayers($scope);
             }
         )
    }

    $scope.removeLineUp = function(lineUp){
        for(var i = $scope.lineUpsChosen.length - 1; i >= 0; i--) {
            if($scope.lineUpsChosen[i] === lineUp) {
                $scope.lineUpsChosen.splice(i, 1);
                break;
            }
        }
//        $scope.lineUpsChosen.splice(lineUp);
    }

    $scope.addLineUp = function(lineUp){
        $scope.lineUpsChosen.push(lineUp);
    }

    $scope.generateCsv = function(){
        fdModelService.generateCsv($scope.lineUpsChosen);
    }
})
