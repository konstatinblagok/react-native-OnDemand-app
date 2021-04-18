var app = angular.module('handyforall.messages');
app.factory('MessageService', MessageService);
function MessageService($http, $q) {
    var MessageService = {
        saveChat: saveChat,
        getMessage: getMessage,
        deletemessage: deletemessage,
        chatHistory: chatHistory,
        deleteConversation: deleteConversation
    };
    return MessageService;

    function deletemessage(categoryinfo) {
        var deferred = $q.defer();
        $http({
            method: 'POST',
            url: '/site/chat/deletemessage',
            data: categoryinfo
        }).success(function (data) {
            deferred.resolve(data);
        }).error(function (err) {
            deferred.reject(err);
        });
        return deferred.promise;
    }
    function saveChat(data) {
        var deferred = $q.defer();
        $http({
            method: 'POST',
            url: '/site/chat/save',
            data: data,
        }).success(function (data) {
            deferred.resolve(data);
        }).error(function (err) {
            deferred.reject(err);
        });
        return deferred.promise;
    }

    function getMessage(currentuserid, currentusertype, page, itemsPerPage) {
        var deferred = $q.defer();
        var skip = 0;
        if (page > 1) {
            skip = (parseInt(page) - 1) * itemsPerPage;
        }
        $http({
            method: 'POST',
            url: '/site/chat/getmessage',
            data: { 'userId': currentuserid, 'currentusertype': currentusertype, skip: skip, limit: itemsPerPage }
        }).success(function (data) {
            deferred.resolve(data);
        }).error(function (err) {
            deferred.reject(err);
        });
        return deferred.promise;
    }

    function chatHistory(data) {
        var deferred = $q.defer();
        $http({
            method: 'POST',
            url: '/site/chat/chathistory',
            data: data
        }).success(function (data) {
            deferred.resolve(data);
        }).error(function (err) {
            deferred.reject(err);
        });
        return deferred.promise;
    }

    function deleteConversation(chatinfo, usertype) {
        var deferred = $q.defer();
        $http({
            method: 'POST',
            url: '/site/chat/deleteConversation',
            data: { 'chatinfo': chatinfo, 'usertype': usertype }
        }).success(function (data) {
            deferred.resolve(data);
        }).error(function (err) {
            deferred.reject(err);
        });
        return deferred.promise;
    }
}
