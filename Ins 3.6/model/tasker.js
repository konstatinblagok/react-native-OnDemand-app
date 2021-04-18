module.exports = function (io) {

    var db = require('../controller/adaptor/mongodb.js');
    var async = require('async');
    var CONFIG = require('../config/config');
    var push = require('../model/pushNotification.js')(io);
    var mail = require('../model/mail.js');
    var mailcontent = require('../model/mailcontent.js');
    var moment = require("moment");
    var timezone = require('moment-timezone');

    function updateAvailability(data, callback) {
        db.UpdateDocument('tasker', { _id: data.tasker }, { availability: data.availability }, function (error, tasker) {
            io.of('/notify').in(data.tasker).emit('availability status', { status: data.availability });
            callback(error, tasker);
        });
    }

    function taskerRegister(dat, callback) {
        var data = {}; console.log(dat, "      hhhhh");
        db.InsertDocument('tasker', dat, function (err, result) {
            if (err) {
                data.response = 'Unable save your data';
                callback(data);
            } else {
                async.waterfall([
                    function (callback) {
                        db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
                            if (err || !settings) { data.response = 'Configure your website settings'; callback(data); }
                            else { callback(err, settings.settings); }
                        });
                    },
                    function (settings, callback) {
                        db.GetDocument('emailtemplate', { name: { $in: ['Taskersignupmessagetoadmin', 'Taskersignupmessagetotasker'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
                            if (err || !template) { data.response = 'Unable to get email template'; callback(data); }
                            else { callback(err, settings, template); }
                        });
                    }
                ], function (err, settings, template) {
                    var name;
                    if (result.name) {
                        name = result.name.first_name + " (" + result.username + ")";
                    } else {
                        name = result.username;
                    }
                    var html = template[0].email_content;
                    html = html.replace(/{{username}}/g, name);
                    html = html.replace(/{{privacy}}/g, settings.site_url + 'pages/privacypolicy');
                    html = html.replace(/{{terms}}/g, settings.site_url + 'pages/termsandconditions');
                    html = html.replace(/{{senderemail}}/g, template[0].sender_email);
                    html = html.replace(/{{logo}}/g, settings.site_url + settings.logo);
                    html = html.replace(/{{site_title}}/g, settings.site_title);
                    html = html.replace(/{{site_url}}/g, settings.site_url);
                    html = html.replace(/{{email}}/g, dat.email);
                    var mailOptions = {
                        from: template[0].sender_email,
                        to: settings.email_address,
                        subject: template[0].email_subject,
                        text: html,
                        html: html
                    };
                    mail.send(mailOptions, function (err, response) { });

                    var html1 = template[1].email_content;
                    html1 = html1.replace(/{{username}}/g, name);
                    html1 = html1.replace(/{{privacy}}/g, settings.site_url + 'pages/privacypolicy');
                    html1 = html1.replace(/{{terms}}/g, settings.site_url + 'pages/termsandconditions');
                    html1 = html1.replace(/{{senderemail}}/g, template[1].sender_email);
                    html1 = html1.replace(/{{logo}}/g, settings.site_url + settings.logo);
                    html1 = html1.replace(/{{site_title}}/g, settings.site_title);
                    html1 = html1.replace(/{{site_url}}/g, settings.site_url);
                    html1 = html1.replace(/{{email}}/g, dat.email);
                    var mailOptions1 = {
                        from: template[1].sender_email,
                        to: dat.email,
                        subject: template[1].email_subject,
                        text: html1,
                        html: html1
                    };
                    mail.send(mailOptions1, function (err, response) { });

                    //var to = dat.phone.code + dat.phone.number;
                    //var message = 'Dear ' + req.body.username + '! Thank you for registering with' + settings.site_title;

                    //var message = util.format(CONFIG.SMS.TASKER_REGISTRATION, req.body.username, settings.site_title);
                    //twilio.createMessage(to, '', message, function (err, response) { });

                    callback(err, result);

                });
            }
        });
    }

    return {
        updateAvailability: updateAvailability,
        taskerRegister: taskerRegister
    };
};
