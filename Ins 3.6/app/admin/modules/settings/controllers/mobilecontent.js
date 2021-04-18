angular.module('handyforall.settings').controller('mobileContentCtrl', mobileContentCtrl);
mobileContentCtrl.$inject = ['mobileSettingsServiceResolve', 'SettingsService', 'toastr'];
function mobileContentCtrl(mobileSettingsServiceResolve, SettingsService, toastr) {
    var mcc = this;
    mcc.mobilecontent = mobileSettingsServiceResolve[0];

    mcc.mobilecontent.bundletasker = mobileSettingsServiceResolve[0].apns.tasker_bundle_id;
    mcc.mobilecontent.bundleuser = mobileSettingsServiceResolve[0].apns.user_bundle_id;
    mcc.mobilecontent.gcmuser = mobileSettingsServiceResolve[0].gcm.user;
    mcc.mobilecontent.gcmtasker = mobileSettingsServiceResolve[0].gcm.tasker;
    mcc.mobilecontent.userpem = mobileSettingsServiceResolve[0].apns.user_pem.replace(/^.*[\\\/]/, '');
    mcc.mobilecontent.taskerpem = mobileSettingsServiceResolve[0].apns.tasker_pem.replace(/^.*[\\\/]/, '');
    mcc.mobilecontent.mode = mobileSettingsServiceResolve[0].apns.mode;

    mcc.mobileSave = function mobileSave(isValid, data) {
        SettingsService.mobileSave(data).then(function (response) {
            toastr.success('Saved Successfully');
        }, function (err) {
        });
    };

    mcc.fileSave = function fileSave(isValid, data) {
	
        if (isValid) {
            SettingsService.fileSave(data).then(function (response) {

                mcc.mobilecontent.userpem = response.settings.apns.user_pem.replace(/^.*[\\\/]/, '');
                mcc.mobilecontent.taskerpem = response.settings.apns.tasker_pem.replace(/^.*[\\\/]/, '');
                toastr.success('File upload Successfully');
            }, function (err) {
            });
        }
    };

}
