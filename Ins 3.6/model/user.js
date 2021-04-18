module.exports = function (io) {

    var db = require('../controller/adaptor/mongodb.js');
    var async = require('async');

    var util = require('util');
    var CONFIG = require('../config/config');
    var push = require('../model/pushNotification.js')(io);
    var mail = require('../model/mail.js');
    var mailcontent = require('../model/mailcontent.js');
    var moment = require("moment");
    var timezone = require('moment-timezone');
    var library = require('../model/library.js');
    var bcrypt = require('bcrypt-nodejs');
    var CONFIG = require('../config/config'); //configuration variables
    var twilio = require('../model/twilio.js');
    var mongoose = require('mongoose');

    function walletRecharge(data, callback) {

        var transactions = [{
            'gateway_response': data.gateway_response
        }];

        var wallets = {
            'user_id': data.user,
            'type': 'wallet',
            "transactions": [{
                'type': 'CREDIT',
                'ref_id': '',
            }]
        };

        async.waterfall([
            function (callback) {
                db.GetOneDocument('walletReacharge', { "user_id": data.user }, {}, {}, function (err, wallet) {
                    callback(err, wallet);
                });
            },
            function (wallet, callback) {
                db.UpdateDocument('transaction', { '_id': data.transaction }, { 'transactions': transactions }, {}, function (err, transaction) {
                    callback(err, wallet);
                });
            },
            function (wallet, callback) {
                db.GetOneDocument('transaction', { _id: data.transaction }, {}, {}, function (err, transaction) {

                    wallets.total = transaction.amount;
                    wallets.transactions[0].trans_id = transaction._id;
                    wallets.transactions[0].avail_amount = transaction.amount;
                    wallets.transactions[0].trans_amount = transaction.amount;
                    wallets.transactions[0].trans_date = transaction.createdAt;
                    callback(err, wallet, transaction);
                });
            },
            function (wallet, transaction, callback) {
                if (wallet) {
                    wallets.total = parseInt(transaction.amount) + parseInt(wallet.total);
                    wallets.transactions[0].avail_amount = wallets.total;
                    db.UpdateDocument('walletReacharge', { 'user_id': data.user }, { total: wallets.total, $push: { 'transactions': wallets.transactions[0] } }, {}, function (err, docdata) {
                        callback(err, wallet);
                    });
                } else {
                    db.InsertDocument('walletReacharge', wallets, function (err, result) {
                        callback(err, wallet);
                    });
                }
            },
            function (wallet, callback) {
                db.GetOneDocument('walletReacharge', { "user_id": data.user }, {}, {}, function (err, wallet) {
                    callback(err, wallet);
                });
            },
        ], function (err, wallet) {
            if (err) {
                callback(err, null);
            } else {
                callback(err, { 'status': 1, 'response': 'Sucess', wallet: wallet });
            }

        });
    }

    function userRegister(dat, callback) {

        var newUser = dat.newUser;
        var smsdocdata = dat.smsdocdata;

        db.InsertDocument('users', newUser, function (err, user) {
            if (err) {
                callback(err, user);
            } else {
                db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settingdata) {
                    if (err || !settingdata) {
                        callback(err, user);
                    } else {
                        if (smsdocdata.settings.twilio.mode == 'production') {
                            var to = user.phone.code + user.phone.number;
                            var message = 'Thank you for register! Your OTP is: ' + newUser.verification_code[0].mobile;
                            twilio.createMessage(to, '', message, function (err, response) { });
                        }

                        var testingStatus = settingdata.settings.referral.status;
                        if (settingdata.settings.referral.status != 0) {
                            var mailData = {};
                            mailData.template = 'Sighnupmessage';
                            mailData.to = user.email;
                            mailData.html = [];
                            mailData.html.push({ name: 'testingStatus', value: settingdata.settings.referral.status });
                            mailData.html.push({ name: 'name', value: user.name.first_name });
                            mailData.html.push({ name: 'email', value: user.email });
                            mailData.html.push({ name: 'referal_code', value: user.unique_code });
                            mailData.html.push({ name: 'site_url', value: settingdata.settings.site_url });
                            mailData.html.push({ name: 'site_title', value: settingdata.settings.site_title });
                            mailData.html.push({ name: 'logo', value: settingdata.settings.logo });
                            mailcontent.sendmail(mailData, function (err, response) { });

                        } else {
                            var mailData2 = {};
                            mailData2.template = 'SighnupmessageWithoutreferal';
                            mailData2.to = user.email;
                            mailData2.html = [];
                            mailData2.html.push({ name: 'testingStatus', value: settingdata.settings.referral.status });
                            mailData2.html.push({ name: 'name', value: user.name.first_name });
                            mailData2.html.push({ name: 'email', value: user.email });
                            mailData2.html.push({ name: 'site_url', value: settingdata.settings.site_url });
                            mailData2.html.push({ name: 'site_title', value: settingdata.settings.site_title });
                            mailData2.html.push({ name: 'logo', value: settingdata.settings.logo });
                            mailcontent.sendmail(mailData2, function (err, response) { });
                        }


                        var mailData1 = {};
                        mailData1.template = 'usersignupmessagetoadmin';
                        mailData1.to = "";
                        mailData1.html = [];
                        mailData1.html.push({ name: 'name', value: user.name.first_name });
                        mailData1.html.push({ name: 'referal_code', value: user.unique_code });
                        mailData1.html.push({ name: 'site_url', value: settingdata.settings.site_url });
                        mailData1.html.push({ name: 'site_title', value: settingdata.settings.site_title });
                        mailData1.html.push({ name: 'logo', value: settingdata.settings.logo });
                        mailcontent.sendmail(mailData1, function (err, response) { });

                        var data = {};
                        if (newUser.referalcode) {
                            db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
                                if (err || !settings) {
                                    data.response = 'Unable to get settings';
                                    callback(err, data);
                                } else {
                                    var to = newUser.phone.code + newUser.phone.number;
                                    var message = 'Dear ' + newUser.username + ' ! Thank you for registering with ' + settings.settings.site_title;
                                    twilio.createMessage(to, '', message, function (err, response) { });

                                    db.GetOneDocument('users', { 'unique_code': newUser.referalcode }, {}, {}, function (err, referer) {
                                        if (err || !referer) {
                                            data.response = 'Unable to get referer';
                                            callback(err, data);
                                        } else {
                                            db.GetOneDocument('walletReacharge', { 'user_id': referer._id }, {}, {}, function (err, referwallet) {
                                                if (err) {
                                                    data.response = 'Unable to get referwallet';
                                                    callback(err, data);
                                                } else {
                                                    if (referwallet) {
                                                        var walletArr = {
                                                            'type': 'CREDIT',
                                                            'credit_type': 'Referral',
                                                            'trans_amount': parseInt(settings.settings.referral.amount.referrer),
                                                            'avail_amount': parseInt(settings.settings.referral.amount.referrer) + parseInt(referwallet.total),
                                                            'trans_date': new Date(),
                                                            //'trans_id': mongoose.Types.ObjectId(),
                                                            'ref_id': referer._id,
                                                        };
                                                        db.UpdateDocument('walletReacharge', { 'user_id': referer._id }, { $push: { transactions: walletArr }, $set: { "total": parseInt(referwallet.total) + parseInt(settings.settings.referral.amount.referrer) } }, {}, function (err, referupRespo) {
                                                            if (err || referupRespo.nModified == 0) {
                                                                data.response = 'Unable to get referwallet';
                                                                callback(err, null);
                                                            } else {
                                                                callback(null, user);
                                                            }
                                                        });
                                                    } else {

                                                        if (settings.settings.referral.amount.referrer) {
                                                            var totalValue = settings.settings.referral.amount.referrer;
                                                        } else {
                                                            var totalValue = 0;
                                                        }
                                                        db.InsertDocument('walletReacharge', {
                                                            'user_id': referer._id,
                                                            "total": totalValue,
                                                            'type': 'wallet',
                                                            "transactions": [{
                                                                'type': 'CREDIT',
                                                                'credit_type': 'Referral',
                                                                'ref_id': referer._id,
                                                                'trans_amount': settings.settings.referral.amount.referrer,
                                                                'avail_amount': settings.settings.referral.amount.referrer,
                                                                'trans_date': new Date()
                                                            }]
                                                        }, function (err, result) {
                                                            db.UpdateDocument('users', { '_id': referer._id }, { 'wallet_id': result._id }, {}, function (err, userupdate) {
                                                                if (err || userupdate.nModified == 0) {
                                                                    data.response = 'Unable to get ' + CONFIG.USER + 'update';
                                                                    callback(err, null);
                                                                } else {
                                                                    callback(null, user);
                                                                }
                                                            });
                                                            callback(null, user);
                                                        });
                                                    }
                                                } // \end
                                                db.InsertDocument('walletReacharge', {
                                                    'user_id': user._id,
                                                    "total": settings.settings.referral.amount.referral,
                                                    'type': 'wallet',
                                                    "transactions": [{
                                                        'credit_type': 'Referral',
                                                        'type': 'CREDIT',
                                                        'ref_id': referer._id,
                                                        'trans_amount': settings.settings.referral.amount.referral,
                                                        'avail_amount': settings.settings.referral.amount.referral,
                                                        'trans_date': new Date()
                                                    }]
                                                }, function (err, result) {
                                                    db.UpdateDocument('users', { '_id': user._id }, { 'wallet_id': result._id }, {}, function (err, userupdate) {
                                                        if (err || userupdate.nModified == 0) {
                                                            data.response = 'Unable to get ' + CONFIG.USER + 'update';
                                                            callback(err, null);
                                                        } else {
                                                           callback(null, user);
                                                        }
                                                    });
                                                  //  callback(null, user);
                                                });
                                            });
                                        }
                                    });
                                }
                            });
                        }
                        callback(null, user);
                    }
                });
            }
        });

    }

    return {
        walletRecharge: walletRecharge,
        userRegister: userRegister
    };

};
