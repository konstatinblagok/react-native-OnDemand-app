module.exports = function (io,i18n) {

    var moment = require("moment");
    var db = require('../adaptor/mongodb.js');
    var push = require('../../model/pushNotification.js')(io);
    var multer = require('multer');
    var async = require("async");
    var mail = require('../../model/mail.js');
    var mongoose = require("mongoose");
    var fs = require('fs');
    var CONFIG = require('../../config/config');
    var stripe = require('stripe')('');
    var url = require('url');
    var twilio = require('../../model/twilio.js');
    var library = require('../../model/library.js');
    var mailcontent = require('../../model/mailcontent.js');
    var taskLibrary = require('../../model/task.js')(io);
    var pdf = require('html-pdf');


    var controller = {};
    controller.byCash = function (req, res) {
        var data = {};
        data.status = '0';
        var errors = [];
        req.checkBody('job_id', res.__('Job ID is Required')).notEmpty();
        req.checkBody('user_id', res.__(CONFIG.USER + ' ID is Required')).notEmpty();
        errors = req.validationErrors();
        if (errors) {
            res.send({
                "status": "0",
                "errors": errors[0].msg
            });
            return;
        }
        var user_id = req.body.user_id;
        var job_id = req.body.job_id;
        db.GetDocument('users', { '_id': user_id }, {}, {}, function (usersErr, usersRespo) {
            if (usersErr || !usersRespo) {
                data.response = res.__('Invalid ' + CONFIG.USER);
                res.send(data);
            } else {
                db.GetDocument('task', { 'booking_id': job_id, 'user': user_id, "status": 6 }, {}, {}, function (bookErr, bookRespo) {
                    if (bookErr || bookRespo.length == 0) {
                        data.response = res.__('Payment is already completed');
                        res.send(data);
                    } else {
                        db.GetDocument('tasker', { '_id': bookRespo[0].tasker }, {}, {}, function (proErr, proRespo) {
                            if (proErr || proRespo.length == 0) {
                                data.response = res.__('Invalid ' + CONFIG.TASKER);
                                res.send(data);
                            } else {
                                db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
                                    if (err || !currencies) {
                                        res.send({
                                            "status": 0,
                                            "message": res.__('Error')
                                        });
                                    }
                                    else {
                                        db.GetOneDocument('settings', { 'alias': 'sms' }, {}, {}, function (err, settings) {
                                            if (err || !settings) {
                                                data.response = res.__('Configure your website settings');
                                                res.send(data);
                                            } else {
                                                if (bookRespo[0].invoice.amount.grand_total) {
                                                    if (bookRespo[0].invoice.amount.balance_amount) {
                                                        amount_to_receive = (bookRespo[0].invoice.amount.balance_amount).toFixed(2);
                                                    }
                                                    else {
                                                        amount_to_receive = (bookRespo[0].invoice.amount.grand_total).toFixed(2);
                                                    }
                                                }
                                                var transaction = {
                                                    'user': user_id,
                                                    'tasker': bookRespo[0].tasker,
                                                    'task': bookRespo[0]._id,
                                                    'type': 'pay by cash',
                                                    'amount': amount_to_receive,
                                                    'task_date': bookRespo[0].createdAt,
                                                    'status': 1
                                                };
                                                db.InsertDocument('transaction', transaction, function (err, transaction) {
                                                    if (err || transaction.nModified == 0) { data.response = res.__('Error in data, Please check your data'); res.send(data); }
                                                    else {
                                                        var transactions = [transaction._id];
                                                        var paymenttype = "";
                                                        if (bookRespo[0].payment_type == "wallet-other") {
                                                            paymenttype = "wallet-cash"
                                                        }
                                                        else {
                                                            paymenttype = "cash"
                                                        }
                                                        db.UpdateDocument('task', { 'booking_id': job_id, 'user': user_id }, { $push: { transactions }, 'invoice.status': 1, 'status': 7, 'payment_type': paymenttype,'invoice.amount.balance_amount' : 0, 'history.job_closed_time': new Date() }, {}, function (err, upda) {
                                                            var provider_id = bookRespo[0].tasker;
                                                            var message = CONFIG.NOTIFICATION.PAYMENT_COMPLETED;
                                                            var amount_to_receive = 0.00;
                                                            var currency = currencies.code;
                                                            var options = {
                                                                'job_id': req.body.job_id,
                                                                'provider_id': provider_id,
                                                                'amount': amount_to_receive,
                                                                'currency': currency
                                                            };

                                                            push.sendPushnotification(bookRespo[0].user, message, 'payment_paid', 'ANDROID', options, 'USER', function (err, Response, body) { });
                                                            push.sendPushnotification(bookRespo[0].tasker, message, 'payment_paid', 'ANDROID', options, 'PROVIDER', function (err, Response, body) { });
                                                            db.GetDocument('emailtemplate', { name: { $in: ['PaymentDetailstoAdmin', 'PaymentDetailstoTasker', 'PaymentDetailstoUser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
                                                                if (err) {
                                                                    res.send(data);
                                                                }
                                                                else {

                                                                    db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, gensettings) {
                                                                        if (err || !gensettings) {
                                                                            data.response = res.__('Configure your website settings');
                                                                            res.send(data);
                                                                        }
                                                                        else {
                                                                            options.populate = 'tasker user categories';
                                                                            db.GetOneDocument('task', { 'booking_id': job_id }, {}, options, function (err, task) {
                                                                                if (err) {
                                                                                    data.response = res.__('Invalid Task');
                                                                                    res.send(data);
                                                                                }
                                                                                else {
                                                                                var MaterialFee, CouponCode, DateTime, BookingDate;
                                                                                if (task.invoice.amount.extra_amount) {
                                                                                    MaterialFee = (task.invoice.amount.extra_amount).toFixed(2);
                                                                                } else {
                                                                                    MaterialFee = '0.00';
                                                                                }
                                                                                if (task.invoice.amount.coupon) {
                                                                                    CouponCode = task.invoice.amount.coupon;
                                                                                } else {
                                                                                    CouponCode = 'Not assigned';
                                                                                }
																					if (task.user.name.first_name) {
																						var userfirstname = task.user.name.first_name;
																					}
																					else {
																						var userfirstname = task.user.username;
																					}
                                                                                DateTime = moment(task.history.job_started_time).format('DD/MM/YYYY - HH:mm');
                                                                                BookingDate = moment(task.history.booking_date).format('DD/MM/YYYY');

                                                                                console.log("ettt1",template[0].email_subject);
                                                                                console.log("ettt1",template[1].email_subject);
                                                                                console.log("ettt1",template[2].email_subject);

                                                                                var html = template[0].email_content;
                                                                                html = html.replace(/{{mode}}/g, 'cash');
                                                                                html = html.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
                                                                                html = html.replace(/{{coupon}}/g, CouponCode);
                                                                                html = html.replace(/{{datetime}}/g, DateTime);
                                                                                html = html.replace(/{{bookingdata}}/g, BookingDate);
                                                                                html = html.replace(/{{site_url}}/g, gensettings.settings.site_url);
                                                                                html = html.replace(/{{logo}}/g, gensettings.settings.site_url + gensettings.settings.logo);
                                                                                html = html.replace(/{{site_title}}/g, gensettings.settings.site_title);
                                                                                html = html.replace(/{{t_username}}/g, task.tasker.name.first_name);
                                                                                html = html.replace(/{{taskeraddress}}/g, task.tasker.address.line1);
                                                                                html = html.replace(/{{taskeraddress1}}/g, task.tasker.address.city);
                                                                                html = html.replace(/{{taskeraddress2}}/g, task.tasker.address.state);
                                                                                html = html.replace(/{{bookingid}}/g, task.booking_id);
                                                                                html = html.replace(/{{u_username}}/g, userfirstname);
                                                                                html = html.replace(/{{useraddress}}/g, task.user.address.line1 || ' ');
                                                                                html = html.replace(/{{useraddress1}}/g, task.user.address.city || ' ');
                                                                                html = html.replace(/{{useraddress2}}/g, task.user.address.state || ' ');
                                                                                html = html.replace(/{{categoryname}}/g, task.booking_information.work_type);
                                                                                html = html.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (task.hourly_rate).toFixed(2));
                                                                                html = html.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (task.invoice.amount.minimum_cost).toFixed(2));
                                                                                html = html.replace(/{{totalhour}}/g,  task.invoice.worked_hours_human);
                                                                                html = html.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (task.invoice.amount.grand_total).toFixed(2));
                                                                                html = html.replace(/{{total}}/g, currencies.symbol + ' ' + (task.invoice.amount.total).toFixed(2));
                                                                                html = html.replace(/{{amount}}/g, currencies.symbol + ' ' + (task.invoice.amount.grand_total - task.invoice.amount.admin_commission).toFixed(2));
                                                                                html = html.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((task.invoice.amount.grand_total - task.invoice.amount.admin_commission) - MaterialFee).toFixed(2));
                                                                                html = html.replace(/{{adminamount}}/g, currencies.symbol + ' ' + (task.invoice.amount.admin_commission).toFixed(2));
                                                                                html = html.replace(/{{privacy}}/g, gensettings.settings.site_url + 'pages/privacypolicy');
                                                                                html = html.replace(/{{terms}}/g, gensettings.settings.site_url + 'pages/termsandconditions');
                                                                                html = html.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + task.invoice.amount.service_tax.toFixed(2));
                                                                                var options = { format: 'Letter' };
                                                                                var pdfname = new Date().getTime();
                                                                                pdf.create(html, options).toFile('./uploads/invoice/' + pdfname + '.pdf', function (err, document) {
                                                                                    console.log("err, document", err, document)
                                                                                    if (err) {
                                                                                        res.send(err);
                                                                                    } else {
                                                                                        var mailOptions = {
                                                                                            from: template[0].sender_email,
                                                                                            to: gensettings.settings.email_address,
                                                                                            subject: template[0].email_subject,
                                                                                            text: "Please Download the attachment to see Your Payment",
                                                                                            html: '<b>Please Download the attachment to see Your Payment</b>',
                                                                                            attachments: [{
                                                                                                filename: 'Admin Payment.pdf',
                                                                                                path: './uploads/invoice/' + pdfname + '.pdf',
                                                                                                contentType: 'application/pdf'
                                                                                            }],
                                                                                        };
                                                                                    }

                                                                                    mail.send(mailOptions, function (err, response) { });
                                                                                });

                                                                                var html2 = template[1].email_content;
                                                                                html2 = html2.replace(/{{mode}}/g, 'cash');
                                                                                html2 = html2.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
                                                                                html2 = html2.replace(/{{coupon}}/g, CouponCode);
                                                                                html2 = html2.replace(/{{datetime}}/g, DateTime);
                                                                                html2 = html2.replace(/{{bookingdata}}/g, BookingDate);
                                                                                html2 = html2.replace(/{{site_url}}/g, gensettings.settings.site_url);
                                                                                html2 = html2.replace(/{{site_title}}/g, gensettings.settings.site_title);
                                                                                html2 = html2.replace(/{{logo}}/g, gensettings.settings.site_url + gensettings.settings.logo);
                                                                                html2 = html2.replace(/{{t_username}}/g, task.tasker.name.first_name);
                                                                                html2 = html2.replace(/{{taskeraddress}}/g, task.tasker.address.line1);
                                                                                html2 = html2.replace(/{{taskeraddress1}}/g, task.tasker.address.city);
                                                                                html2 = html2.replace(/{{taskeraddress2}}/g, task.tasker.address.state);
                                                                                html2 = html2.replace(/{{bookingid}}/g, task.booking_id);
                                                                                html2 = html2.replace(/{{u_username}}/g, userfirstname);
                                                                                html2 = html2.replace(/{{useraddress}}/g, task.user.address.line1 || ' ');
                                                                                html2 = html2.replace(/{{useraddress1}}/g, task.user.address.city || ' ');
                                                                                html2 = html2.replace(/{{useraddress2}}/g, task.user.address.state || ' ');
                                                                                html2 = html2.replace(/{{categoryname}}/g, task.booking_information.work_type);
                                                                                html2 = html2.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (task.hourly_rate).toFixed(2));
                                                                                html2 = html2.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (task.invoice.amount.minimum_cost).toFixed(2));
                                                                                html2 = html2.replace(/{{totalhour}}/g, task.invoice.worked_hours_human);
                                                                                html2 = html2.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (task.invoice.amount.grand_total - task.invoice.amount.service_tax).toFixed(2));
                                                                                html2 = html2.replace(/{{total}}/g, currencies.symbol + ' ' + (task.invoice.amount.total).toFixed(2));
                                                                                html2 = html2.replace(/{{amount}}/g, currencies.symbol + ' ' + (task.invoice.amount.grand_total - task.invoice.amount.admin_commission).toFixed(2));
                                                                                html2 = html2.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((task.invoice.amount.grand_total - task.invoice.amount.admin_commission) - task.invoice.amount.service_tax).toFixed(2));
                                                                                html2 = html2.replace(/{{admincommission}}/g, currencies.symbol + ' ' + task.invoice.amount.admin_commission.toFixed(2));
                                                                                html2 = html2.replace(/{{privacy}}/g, gensettings.settings.site_url + 'pages/privacypolicy');
                                                                                html2 = html2.replace(/{{terms}}/g, gensettings.settings.site_url + 'pages/termsandconditions');
                                                                                html2 = html2.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + task.invoice.amount.service_tax.toFixed(2));
                                                                                var options = { format: 'Letter' };
                                                                                var pdfname1 = new Date().getTime();
                                                                                pdf.create(html2, options).toFile('./uploads/invoice/' + pdfname1 + '.pdf', function (err, document) {
                                                                                    console.log("err, document", err, document)
                                                                                    if (err) {
                                                                                        res.send(err);
                                                                                    } else {

                                                                                        var mailOptions1 = {
                                                                                            from: template[1].sender_email,
                                                                                            to: task.tasker.email,
                                                                                            subject: template[1].email_subject,
                                                                                            text: "Please Download the attachment to see Your Payment",
                                                                                            html: '<b>Please Download the attachment to see Your Payment</b>',
                                                                                            attachments: [{
                                                                                                filename: 'Payment.pdf',
                                                                                                path: './uploads/invoice/' + pdfname1 + '.pdf',
                                                                                                contentType: 'application/pdf'
                                                                                            }],
                                                                                        };
                                                                                    }

                                                                                    mail.send(mailOptions1, function (err, response) { });
                                                                                });

                                                                                var html3 = template[2].email_content;
                                                                                html3 = html3.replace(/{{mode}}/g, 'cash');
                                                                                html3 = html3.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
                                                                                html3 = html3.replace(/{{coupon}}/g, CouponCode);
                                                                                html3 = html3.replace(/{{datetime}}/g, DateTime);
                                                                                html3 = html3.replace(/{{bookingdata}}/g, BookingDate);
                                                                                html3 = html3.replace(/{{site_url}}/g, gensettings.settings.site_url);
                                                                                html3 = html3.replace(/{{site_title}}/g, gensettings.settings.site_title);
                                                                                html3 = html3.replace(/{{logo}}/g, gensettings.settings.site_url + gensettings.settings.logo);
                                                                                html3 = html3.replace(/{{t_username}}/g, task.tasker.name.first_name);
                                                                                html3 = html3.replace(/{{taskeraddress}}/g, task.tasker.address.line1);
                                                                                html3 = html3.replace(/{{taskeraddress1}}/g, task.tasker.address.city);
                                                                                html3 = html3.replace(/{{taskeraddress2}}/g, task.tasker.address.state);
                                                                                html3 = html3.replace(/{{bookingid}}/g, task.booking_id);
                                                                                html3 = html3.replace(/{{u_username}}/g, userfirstname);
                                                                                html3 = html3.replace(/{{useraddress}}/g, task.user.address.line1 || ' ');
                                                                                html3 = html3.replace(/{{useraddress1}}/g, task.user.address.city || ' ');
                                                                                html3 = html3.replace(/{{useraddress2}}/g, task.user.address.state || ' ');
                                                                                html3 = html3.replace(/{{categoryname}}/g, task.booking_information.work_type);
                                                                                html3 = html3.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (task.hourly_rate).toFixed(2));
                                                                                html3 = html3.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (task.invoice.amount.minimum_cost).toFixed(2));
                                                                                html3 = html3.replace(/{{totalhour}}/g, task.invoice.worked_hours_human);
                                                                                html3 = html3.replace(/{{totalamount}}/g, currencies.symbol + ' ' + task.invoice.amount.grand_total.toFixed(2));
                                                                                html3 = html3.replace(/{{total}}/g, currencies.symbol + ' ' + (task.invoice.amount.total).toFixed(2));
                                                                                html3 = html3.replace(/{{amount}}/g, currencies.symbol + ' ' + (task.invoice.amount.grand_total - task.invoice.amount.admin_commission).toFixed(2));
                                                                                html3 = html3.replace(/{{actualamount}}/g, currencies.symbol + ' ' + (task.invoice.amount.total - task.invoice.amount.grand_total).toFixed(2));
                                                                                html3 = html3.replace(/{{admincommission}}/g, currencies.symbol + ' ' + task.invoice.amount.admin_commission.toFixed(2));
                                                                                html3 = html3.replace(/{{privacy}}/g, gensettings.settings.site_url + 'pages/privacypolicy');
                                                                                html3 = html3.replace(/{{terms}}/g, gensettings.settings.site_url + 'pages/termsandconditions');
                                                                                html3 = html3.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + task.invoice.amount.service_tax.toFixed(2));
                                                                                var options = { format: 'Letter' };
                                                                                var pdfname2 = new Date().getTime();
                                                                                pdf.create(html3, options).toFile('./uploads/invoice/' + pdfname2 + '.pdf', function (err, document) {
                                                                                    console.log("err, document", err, document)
                                                                                    if (err) {
                                                                                        res.send(err);
                                                                                    } else {

                                                                                        var mailOptions2 = {
                                                                                            from: template[2].sender_email,
                                                                                            to: task.user.email,
                                                                                            subject: template[2].email_subject,
                                                                                            text: "Please Download the attachment to see Your Payment",
                                                                                            html: '<b>Please Download the attachment to see Your Payment</b>',
                                                                                            attachments: [{
                                                                                                filename: 'Payment.pdf',
                                                                                                path: './uploads/invoice/' + pdfname2 + '.pdf',
                                                                                                contentType: 'application/pdf'
                                                                                            }],
                                                                                        };
                                                                                    }

                                                                                    mail.send(mailOptions2, function (err, response) { });
                                                                                });
                                                                            }

                                                                        });
                                                                }
                                                            });
                                                        }
                                                            });

                                                data.status = '1';
                                                data.response = res.__('Pay your bill by cash');
                                                res.send(data);
                                            });
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    }
});
            }
        });
    }

controller.byZero = function (req, res) {
    var errors = [];
    req.checkBody('job_id', res.__('Job ID is Required')).notEmpty();
    req.checkBody('user_id', res.__(CONFIG.USER + ' ID is Required')).notEmpty();
    errors = req.validationErrors();
    if (errors) {
        res.send({
            "status": "0",
            "errors": errors[0].msg
        });
        return;
    }
    var data = {};
    data.user_id = req.body.user_id;
    data.job_id = req.body.job_id;
    db.GetOneDocument('users', { '_id': req.body.user_id, 'status': 1 }, {}, {}, function (err, user) {
        if (err || !user) {
            res.send({
                'status': '0',
                'response': res.__('Invalid ' + CONFIG.USER)
            });
        } else {
            db.GetOneDocument('task', { 'booking_id': req.body.job_id, 'user': req.body.user_id }, {}, {}, function (bookErr, bookRespo) {
                if (bookErr || !bookRespo) {
                    res.send({
                        'status': '0',
                        'response': res.__('INVALID ERROR')
                    });
                } else {
                    if (bookRespo.status == 6) {
                        db.UpdateDocument('task', { 'booking_id': req.body.job_id, 'user': req.body.user_id }, { 'status': 7, 'invoice.status': 1 }, {}, function (err, response) {
                            if (err || response.nModified == 0) {
                                res.send({
                                    'status': '0',
                                    'response': res.__('INVALID ERROR')
                                });
                            }
                            else {
                                var message = CONFIG.NOTIFICATION.YOUR_BILLING_AMOUNT_PAID_SUCCESSFULLY;
                                var options = { 'job_id': data.job_id, 'user_id': data.user_id };
                                push.sendPushnotification(bookRespo.user, message, 'payment_paid', 'ANDROID', options, 'USER', function (err, response, body) { });

                                var message = CONFIG.NOTIFICATION.YOUR_BILLING_AMOUNT_PAID_SUCCESSFULLY;
                                var options = { 'job_id': data.job_id, 'user_id': data.user_id };
                                push.sendPushnotification(bookRespo.tasker, message, 'payment_paid', 'ANDROID', options, 'PROVIDER', function (err, response, body) { });
                                res.send({
                                    'status': '1',
                                    'response': res.__('Payment Completed')
                                });
                            }
                        });

                    } else {
                        res.send({
                            'status': '0',
                            'response': res.__('Sorry you can not make payment at this time')
                        });
                    }
                }
            });
        }
    });
}

controller.stripePaymentProcess = function (req, res) {

    var data = {};
    data.status = '0';
    var errors = [];
    req.checkBody('task_id', res.__('Job ID is Required')).notEmpty();
    req.checkBody('user_id', res.__(CONFIG.USER + ' ID is Required')).notEmpty();
    req.checkBody('card_number', res.__('Card_number is Required')).notEmpty();
    req.checkBody('exp_month', res.__('Exp_month  is Required')).notEmpty();
    req.checkBody('exp_year', res.__('Exp_year is Required')).notEmpty();
    req.checkBody('cvc_number', res.__('Card_cvv no is Required')).notEmpty();
    req.checkBody('transaction_id', res.__('Transaction_id no is Required')).notEmpty();
    errors = req.validationErrors();
    if (errors) {
        res.send({
            "status": "0",
            "errors": errors[0].msg
        });
        return;
    }
    req.sanitizeBody('task_id').trim();
    req.sanitizeBody('user_id').trim();
    req.sanitizeBody('card_number').trim();
    req.sanitizeBody('exp_month').trim();
    req.sanitizeBody('exp_year').trim();
    req.sanitizeBody('cvc_number').trim();
    req.sanitizeBody('transaction_id').trim();

    var request = {};
    request.task = req.body.task_id.replace(/^"(.*)"$/, '$1');
    request.user = req.body.user_id.replace(/^"(.*)"$/, '$1');
    request.transaction_id = req.body.transaction_id.replace(/^"(.*)"$/, '$1');

    var card = {};
    card.number = req.body.card_number;
    card.exp_month = req.body.exp_month;
    card.exp_year = req.body.exp_year;
    card.cvc = req.body.cvc_number;

    db.GetOneDocument('paymentgateway', { status: { $ne: 0 }, alias: 'stripe' }, {}, {}, function (err, paymentgateway) {
        if (err || !paymentgateway.settings.secret_key) {
            res.status(400).send({ 'message': 'Invalid payment method, Please contact the website administrator' });
        } else {
            stripe.setApiKey(paymentgateway.settings.secret_key);

            async.waterfall([
                function (callback) {
                    db.GetOneDocument('task', { '_id': request.task, 'status': 6 }, {}, {}, function (err, task) {
                        if (err || !task) {
                            data.response = res.__('Payment is already completed'); res.send(data);
                        }
                        else { callback(err, task); }
                    });
                },
                function (task, callback) {
                    db.GetOneDocument('tasker', { '_id': task.tasker }, {}, {}, function (err, tasker) {
                        if (err || !tasker) {
                            data.response = res.__('Invalid ' + CONFIG.TASKER ); res.send(data);
                        }
                        else { callback(err, task, tasker); }
                    });
                },
                function (task, tasker, callback) {
                    db.GetOneDocument('users', { '_id': request.user }, {}, {}, function (err, user) {
                        if (err || !user) {
                            data.response = res.__('Invalid ' + CONFIG.USER); res.send(data);
                        }
                        else { callback(err, task, tasker, user); }
                    });
                },
                function (task, tasker, user, callback) {
                  db.UpdateDocument('transaction', { '_id': request.transaction_id }, { 'type': 'card' }, {}, function (err, transaction) {
                    if (err || !user) {
                        data.response = res.__('Invalid ' + CONFIG.USER); res.send(data);
                       }
                 else { callback(err, task, tasker, user,transaction); }
             });
                },
                function (task, tasker, user, transaction,callback) {
                    stripe.tokens.create({ card: card }, function (err, token) {
                        if (err || !token) {
                            res.redirect("http://" + req.headers.host + '/mobile/mobile/failed');
                        }
                        else { callback(err, token, task, transaction,tasker); }
                    });
                },
                function (token, task, tasker,transaction, callback) {
                    var amount_to_receive = 0;
                    if (task.invoice.amount.grand_total) {
                        if (task.invoice.amount.balance_amount) {
                            amount_to_receive = parseFloat(task.invoice.amount.balance_amount).toFixed(2);
                        } else {
                            amount_to_receive = parseFloat(task.invoice.amount.grand_total).toFixed(2);
                        }
                    }
                    var test = parseInt(amount_to_receive * 100);
                    stripe.charges.create({
                        amount: test,
                        currency: "usd",
                        source: token.id,
                        description: "Payment From User",
                    }, function (err, charges) {
                        if (err || !charges) {
                            data.response = res.__('Error in stripe charge creation');
                            res.send(data);
                        } else {
                            callback(err, task, tasker, token, charges);
                        }
                    });
                }
            ], function (err, task, tasker, token, charges) {
                if (err) {
                    if (err) { data.response = res.__('Error in saving your data'); res.send(data); }
                } else {
                    taskLibrary.taskPayment({ 'transaction': request.transaction_id, 'gateway_response': charges ,'task': task}, function (err, response) {
                        if (err || !response) {
                            res.redirect("http://" + req.headers.host + '/mobile/payment/pay-failed');
                        } else {
                            res.redirect("http://" + req.headers.host + '/mobile/payment/pay-completed/bycard');
                        }
                    });
                }
            });
        }
    });
}

controller.byWallet = function (req, res) {
    var errors = [];
    req.checkBody('job_id', res.__('Job ID is Required')).notEmpty();
    req.checkBody('user_id', res.__(CONFIG.USER + ' ID is Required')).notEmpty();
    errors = req.validationErrors();
    if (errors) {
        res.send({ "status": "0", "errors": errors[0].msg });
        return;
    }
    var data = {};
    data.status = '0';
    var request = {};
    request.user_id = req.body.user_id;
    request.job_id = req.body.job_id;
    db.GetOneDocument('users', { '_id': request.user_id }, {}, {}, function (err, users) {
        if (err || users.length == 0) { data.response = res.__('Invalid ' + CONFIG.USER + ', Please check your data'); res.send(data); }
        else {
            db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
                if (err || !currencies) {
                    res.send({
                        "status": 0,
                        "message": res.__('Error')
                    });
                }
                else {
                    db.GetOneDocument('task', { 'booking_id': request.job_id, 'user': request.user_id, "status": 6 }, {}, {}, function (err, Bookings) {
                        if (err || !Bookings) { data.response = 'Job Invalid'; res.send(data); }
                        else {
                            db.GetOneDocument('walletReacharge', { "user_id": request.user_id }, {}, {}, function (err, wallet) {
                                if (err || !wallet) { data.response = res.__('Invalid ' + CONFIG.USER + ', Please check your data'); res.send(data); }
                                else {
                                    if (wallet.total == 0) {
                                        res.send({ 'status': '0', 'response': res.__('Sorry insufficient amount please recharge your wallet amount'), 'Amount neeeds': Bookings.invoice.amount.total });
                                    } else if (wallet.total < Bookings.invoice.amount.grand_total) {
                                        var provider_id = Bookings.tasker;
                                        var wallet_amount = 0.00;
                                        var job_charge = 0.00;
                                        if (wallet.total) { wallet_amount = parseFloat(wallet.total); }
                                        if (Bookings.invoice.amount.grand_total) { job_charge = parseFloat(Bookings.invoice.amount.balance_amount); }
                                        var balanceamount = {};
                                        balanceamount = job_charge - wallet_amount;
										console.log("job_charge",job_charge)
										console.log("wallet_amount",wallet_amount)
										console.log("balanceamount",balanceamount)
                                        var walletArr = {
                                            'type': 'DEBIT',
                                            'debit_type': 'payment',
                                            'ref_id': req.body.job_id,
                                            'trans_amount': parseFloat(wallet.total),
                                            'avail_amount': 0,
                                            'due_amount': job_charge - wallet_amount,
                                            'trans_date': new Date(),
                                            'trans_id': mongoose.Types.ObjectId()
                                        };
                                        db.UpdateDocument('walletReacharge', { 'user_id': req.body.user_id }, { $push: { transactions: walletArr }, $set: { "total": 0 } }, { multi: true }, function (walletUErr, walletURespo) {

                                            if (walletUErr || walletURespo.nModified == 0) {
                                                data.response = res.__('Error in data, Please check your data'); res.send(data);
                                            }
                                            else {
                                                db.UpdateDocument('task', { "booking_id": request.job_id }, { "invoice.amount.balance_amount": balanceamount, "payment_type": "wallet-other" }, function (err, docdata) {
												console.log("docdata",docdata)

                                                    if (err || docdata.nModified == 0) { data.response = res.__('Error data, Please check your data'); res.send(data); }
                                                    else {
                                                        var transaction = {
                                                            'user': request.user_id,
                                                            'tasker': Bookings.tasker,
                                                            'task': Bookings._id,
                                                            'type': 'wallet-other',
                                                            'amount': wallet.total,
                                                            //'amount':  Bookings.invoice.amount.grand_total,
                                                            'task_date': Bookings.createdAt,
                                                            'status': 1
                                                        };

                                                        db.InsertDocument('transaction', transaction, function (err, transaction) {
                                                            if (err || transaction.nModified == 0) { data.response = res.__('Error in data, Please check your data'); res.send(data); }
                                                            else {
                                                                var message = CONFIG.NOTIFICATION.PAYMENT_COMPLETED;
                                                                var options = { 'job_id': request.job_id, 'provider_id': provider_id };

                                                                // push.sendPushnotification(Bookings.user, message, 'payment_paid', 'ANDROID', options, 'USER', function (err, Response, body) { });
                                                                // push.sendPushnotification(provider_id, message, 'payment_paid', 'ANDROID', options, 'PROVIDER', function (err, Response, body) { });
                                                                res.send({
                                                                    'status': '2',
                                                                    'response': res.__('Transaction partially completed due to insufficient balance in your wallet account,Complete the transaction by recharging the wallet account or by using credit card.!!'),
                                                                    'due_amount': ((job_charge - wallet_amount) * currencies.value).toFixed(2),
                                                                    'used_amount': (wallet_amount * currencies.value).toFixed(2),
                                                                    'available_wallet_amount': '0'
                                                                });
                                                                //start mail
                                                                var options = {};
                                                                options.populate = 'tasker user category';
                                                                db.GetOneDocument('task', { 'booking_id': req.body.job_id }, {}, options, function (err, maildocdata) {
                                                                    if (err) {
                                                                        res.send(err);
                                                                    } else {
                                                                        db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
                                                                            if (err) {
                                                                                res.send(err);
                                                                            } else {
                                                                                // PARTIALLY PAID mail Content
                                                                                var notifications = { 'job_id': maildocdata.booking_id, 'user_id': maildocdata.tasker._id };
                                                                                var message = CONFIG.NOTIFICATION.BILLING_AMOUNT_PARTIALLY_PAID;
                                                                                push.sendPushnotification(maildocdata.tasker._id, message, 'partially_paid', 'ANDROID', notifications, 'PROVIDER', function (err, response, body) { });
                                                                                // push.sendPushnotification(maildocdata.user._id, message, 'payment_paid', 'ANDROID', notifications, 'USER', function (err, response, body) { });
                                                                                // res.send(maildocdata);
                                                                                db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
                                                                                    if (err) {
                                                                                        res.send(err);
                                                                                    } else {
                                                                                        var MaterialFee, CouponCode, DateTime, BookingDate;
                                                                                        if (maildocdata.invoice.amount.extra_amount) {
                                                                                            MaterialFee = (maildocdata.invoice.amount.extra_amount).toFixed(2);
                                                                                        } else {
                                                                                            MaterialFee = '0.00';
                                                                                        }
                                                                                        if (maildocdata.invoice.amount.coupon) {
                                                                                            CouponCode = maildocdata.invoice.amount.coupon;
                                                                                        } else {
                                                                                            CouponCode = 'Not assigned';
                                                                                        }
                                                                                        DateTime = moment(maildocdata.history.job_started_time).format('DD/MM/YYYY - HH:mm');
                                                                                        BookingDate = moment(maildocdata.history.booking_date).format('DD/MM/YYYY');
                                                                                        db.GetDocument('emailtemplate', { name: { $in: ['PartialPaymentToAdmin', 'PartialPaymentToTasker', 'PartialPaymentToUser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
                                                                                            if (err) {
                                                                                                res.send(err)
                                                                                            }
                                                                                            else {
                                                                                                var html = template[0].email_content;
                                                                                                html = html.replace(/{{mode}}/g, maildocdata.payment_type + "(Partially Paid )");
                                                                                                html = html.replace(/{{materialfee}}/g, currencies.symbol + MaterialFee);
                                                                                                html = html.replace(/{{coupon}}/g, currencies.symbol + ' ' + CouponCode);
                                                                                                html = html.replace(/{{datetime}}/g, DateTime);
                                                                                                html = html.replace(/{{bookingdata}}/g, BookingDate);
                                                                                                html = html.replace(/{{site_url}}/g, settings.settings.site_url);
                                                                                                html = html.replace(/{{site_title}}/g, settings.settings.site_title);
                                                                                                html = html.replace(/{{Site_title}}/g, settings.settings.site_title);
                                                                                                html = html.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
                                                                                                html = html.replace(/{{t_username}}/g, maildocdata.tasker.username);
                                                                                                html = html.replace(/{{taskeraddress}}/g, maildocdata.tasker.address.line1);
                                                                                                html = html.replace(/{{taskeraddress1}}/g, maildocdata.tasker.address.city);
                                                                                                html = html.replace(/{{taskeraddress2}}/g, maildocdata.tasker.address.state);
                                                                                                html = html.replace(/{{bookingid}}/g, maildocdata.booking_id);
                                                                                                html = html.replace(/{{u_username}}/g, maildocdata.user.username);
                                                                                                html = html.replace(/{{useraddress}}/g, maildocdata.user.address.line1 || ' ');
                                                                                                html = html.replace(/{{useraddress1}}/g, maildocdata.user.address.city || ' ');
                                                                                                html = html.replace(/{{useraddress2}}/g, maildocdata.user.address.state || ' ');
                                                                                                html = html.replace(/{{categoryname}}/g, maildocdata.booking_information.work_type);
                                                                                                html = html.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (maildocdata.hourly_rate).toFixed(2));
                                                                                                html = html.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.minimum_cost).toFixed(2));
                                                                                                html = html.replace(/{{totalhour}}/g, maildocdata.invoice.worked_hours_human);
                                                                                                html = html.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total).toFixed(2));
                                                                                                html = html.replace(/{{total}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.total).toFixed(2));
                                                                                                html = html.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2));
                                                                                                html = html.replace(/{{adminamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.admin_commission).toFixed(2));
                                                                                                html = html.replace(/{{amountpaid}}/g, currencies.symbol + ' ' + (wallet.total).toFixed(2));
                                                                                                html = html.replace(/{{balamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.balance_amount).toFixed(2));
                                                                                                html = html.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
                                                                                                html = html.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
                                                                                                html = html.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2));

                                                                                                var options = { format: 'Letter' };
                                                                                                var pdfname = new Date().getTime();
                                                                                                pdf.create(html, options).toFile('./uploads/invoice/' + pdfname + '.pdf', function (err, document) {
                                                                                                    console.log("err, document", err, document)
                                                                                                    if (err) {
                                                                                                        res.send(err);
                                                                                                    } else {

                                                                                                        var mailOptions = {
                                                                                                            from: template[0].sender_email,
                                                                                                            to: settings.settings.email_address,
                                                                                                            subject: template[0].email_subject,
                                                                                                            text: "Please Download the attachment to see Your Payment Details",
                                                                                                            html: '<b>Please Download the attachment to see Your Payment Details</b>',
                                                                                                            attachments: [{
                                                                                                                filename: 'Admin Payment.pdf',
                                                                                                                path: './uploads/invoice/' + pdfname + '.pdf',
                                                                                                                contentType: 'application/pdf'
                                                                                                            }],
                                                                                                        };

                                                                                                    }
                                                                                                    mail.send(mailOptions, function (err, response) { });
                                                                                                });
                                                                                                var html2 = template[1].email_content;
                                                                                                html2 = html2.replace(/{{mode}}/g, maildocdata.payment_type + "(Partially Paid )");
                                                                                                html2 = html2.replace(/{{materialfee}}/g, currencies.symbol + MaterialFee);
                                                                                                html2 = html2.replace(/{{coupon}}/g, currencies.symbol + ' ' + CouponCode);
                                                                                                html2 = html2.replace(/{{datetime}}/g, DateTime);
                                                                                                html2 = html2.replace(/{{bookingdata}}/g, BookingDate);
                                                                                                html2 = html2.replace(/{{site_url}}/g, settings.settings.site_url);
                                                                                                html2 = html2.replace(/{{site_title}}/g, settings.settings.site_title);
                                                                                                html2 = html2.replace(/{{Site_title}}/g, settings.settings.site_title);
                                                                                                html2 = html2.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
                                                                                                html2 = html2.replace(/{{t_username}}/g, maildocdata.tasker.username);
                                                                                                html2 = html2.replace(/{{taskeraddress}}/g, maildocdata.tasker.address.line1);
                                                                                                html2 = html2.replace(/{{taskeraddress1}}/g, maildocdata.tasker.address.city);
                                                                                                html2 = html2.replace(/{{taskeraddress2}}/g, maildocdata.tasker.address.state);
                                                                                                html2 = html2.replace(/{{bookingid}}/g, maildocdata.booking_id);
                                                                                                html2 = html2.replace(/{{u_username}}/g, maildocdata.user.username);
                                                                                                html2 = html2.replace(/{{useraddress}}/g, maildocdata.user.address.line1 || ' ');
                                                                                                html2 = html2.replace(/{{useraddress1}}/g, maildocdata.user.address.city || ' ');
                                                                                                html2 = html2.replace(/{{useraddress2}}/g, maildocdata.user.address.state || ' ');
                                                                                                html2 = html2.replace(/{{categoryname}}/g, maildocdata.booking_information.work_type);
                                                                                                html2 = html2.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (maildocdata.hourly_rate).toFixed(2));
                                                                                                html2 = html2.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.minimum_cost).toFixed(2));
                                                                                                html2 = html2.replace(/{{totalhour}}/g, maildocdata.invoice.worked_hours_human);
                                                                                                html2 = html2.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total).toFixed(2));
                                                                                                html2 = html2.replace(/{{total}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.total).toFixed(2));
                                                                                                html2 = html2.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2));
                                                                                                html2 = html2.replace(/{{amountpaid}}/g, currencies.symbol + ' ' + (wallet.total).toFixed(2));
                                                                                                html2 = html2.replace(/{{balamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.balance_amount).toFixed(2));
                                                                                                html2 = html2.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
                                                                                                html2 = html2.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
                                                                                                html2 = html2.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2));
                                                                                                html2 = html2.replace(/{{admincommission}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.admin_commission.toFixed(2));
                                                                                                html2 = html2.replace(/{{email}}/g, req.body.email);

                                                                                                var options = { format: 'Letter' };
                                                                                                var pdfname1 = new Date().getTime();
                                                                                                pdf.create(html2, options).toFile('./uploads/invoice/' + pdfname1 + '.pdf', function (err, document) {
                                                                                                    console.log("err, document", err, document)
                                                                                                    if (err) {
                                                                                                        res.send(err);
                                                                                                    } else {

                                                                                                        var mailOptions1 = {
                                                                                                            from: template[1].sender_email,
                                                                                                            to: maildocdata.tasker.email,
                                                                                                            subject: template[1].email_subject,
                                                                                                            text: "Please Download the attachment to see Your Payment Details",
                                                                                                            html: '<b>Please Download the attachment to see Your Payment Details</b>',
                                                                                                            attachments: [{
                                                                                                                filename: CONFIG.TASKER + ' Payment.pdf',
                                                                                                                path: './uploads/invoice/' + pdfname1 + '.pdf',
                                                                                                                contentType: 'application/pdf'
                                                                                                            }],
                                                                                                        };
                                                                                                    }

                                                                                                    mail.send(mailOptions1, function (err, response) { });
                                                                                                });



                                                                                                var html3 = template[2].email_content;
                                                                                                html3 = html3.replace(/{{mode}}/g, maildocdata.payment_type + "(Partially Paid )");
                                                                                                html3 = html3.replace(/{{materialfee}}/g, currencies.symbol + MaterialFee);
                                                                                                html3 = html3.replace(/{{coupon}}/g, currencies.symbol + ' ' + CouponCode);
                                                                                                html3 = html3.replace(/{{datetime}}/g, DateTime);
                                                                                                html3 = html3.replace(/{{bookingdata}}/g, BookingDate);
                                                                                                html3 = html3.replace(/{{site_url}}/g, settings.settings.site_url);
                                                                                                html3 = html3.replace(/{{site_title}}/g, settings.settings.site_title);
                                                                                                html3 = html3.replace(/{{Site_title}}/g, settings.settings.site_title);
                                                                                                html3 = html3.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
                                                                                                html3 = html3.replace(/{{t_username}}/g, maildocdata.tasker.username);
                                                                                                html3 = html3.replace(/{{taskeraddress}}/g, maildocdata.tasker.address.line1);
                                                                                                html3 = html3.replace(/{{taskeraddress1}}/g, maildocdata.tasker.address.city);
                                                                                                html3 = html3.replace(/{{taskeraddress2}}/g, maildocdata.tasker.address.state);
                                                                                                html3 = html3.replace(/{{bookingid}}/g, maildocdata.booking_id);
                                                                                                html3 = html3.replace(/{{u_username}}/g, maildocdata.user.username);
                                                                                                html3 = html3.replace(/{{useraddress}}/g, maildocdata.user.address.line1 || ' ');
                                                                                                html3 = html3.replace(/{{useraddress1}}/g, maildocdata.user.address.city || ' ');
                                                                                                html3 = html3.replace(/{{useraddress2}}/g, maildocdata.user.address.state || ' ');
                                                                                                html3 = html3.replace(/{{categoryname}}/g, maildocdata.booking_information.work_type);
                                                                                                html3 = html3.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (maildocdata.hourly_rate).toFixed(2));
                                                                                                html3 = html3.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.minimum_cost).toFixed(2));
                                                                                                html3 = html3.replace(/{{totalhour}}/g, maildocdata.invoice.worked_hours_human);
                                                                                                html3 = html3.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total).toFixed(2));
                                                                                                html3 = html3.replace(/{{total}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.total).toFixed(2));
                                                                                                html3 = html3.replace(/{{actualamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.total - maildocdata.invoice.amount.grand_total).toFixed(2));
                                                                                                html3 = html3.replace(/{{amountpaid}}/g, currencies.symbol + ' ' + (wallet.total).toFixed(2));
                                                                                                html3 = html3.replace(/{{balamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.balance_amount).toFixed(2));
                                                                                                html3 = html3.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
                                                                                                html3 = html3.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
                                                                                                html3 = html3.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2));
                                                                                                html3 = html3.replace(/{{admincommission}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.admin_commission.toFixed(2));
                                                                                                html3 = html3.replace(/{{email}}/g, req.body.email);

                                                                                                var options = { format: 'Letter' };
                                                                                                var pdfname2 = new Date().getTime();
                                                                                                pdf.create(html3, options).toFile('./uploads/invoice/' + pdfname2 + '.pdf', function (err, document) {
                                                                                                    console.log("err, document", err, document)
                                                                                                    if (err) {
                                                                                                        res.send(err);
                                                                                                    } else {

                                                                                                        var mailOptions2 = {
                                                                                                            from: template[2].sender_email,
                                                                                                            to: maildocdata.user.email,
                                                                                                            subject: template[2].email_subject,
                                                                                                            text: "Please Download the attachment to see Your Payment Details",
                                                                                                            html: '<b>Please Download the attachment to see Your Payment Details</b>',
                                                                                                            attachments: [{
                                                                                                                filename: CONFIG.USER + ' Payment.pdf',
                                                                                                                path: './uploads/invoice/' + pdfname2 + '.pdf',
                                                                                                                contentType: 'application/pdf'
                                                                                                            }],
                                                                                                        };
                                                                                                    }

                                                                                                    mail.send(mailOptions2, function (err, response) { });
                                                                                                });
                                                                                                // var mailData = {};
                                                                                                // mailData.template = 'PartialPaymentToAdmin';
                                                                                                // mailData.to = settings.settings.email_address;
                                                                                                // mailData.html = [];
                                                                                                // mailData.html.push({ name: 'mode', value: maildocdata.payment_type + "(Partial Paid )" });
                                                                                                // mailData.html.push({ name: 'materialfee', value: MaterialFee });
                                                                                                // mailData.html.push({ name: 'coupon', value: currencies.symbol + ' ' + CouponCode });
                                                                                                // mailData.html.push({ name: 'datetime', value: DateTime });
                                                                                                // mailData.html.push({ name: 'bookingdata', value: BookingDate });
                                                                                                // mailData.html.push({ name: 'site_url', value: settings.settings.site_url });
                                                                                                // mailData.html.push({ name: 'site_title', value: settings.settings.site_title });
                                                                                                // mailData.html.push({ name: 'logo', value: settings.settings.logo });
                                                                                                // mailData.html.push({ name: 't_username', value: maildocdata.tasker.username });
                                                                                                // mailData.html.push({ name: 'taskeraddress', value: maildocdata.tasker.address.line1 });
                                                                                                // mailData.html.push({ name: 'taskeraddress1', value: maildocdata.tasker.address.city });
                                                                                                // mailData.html.push({ name: 'taskeraddress2', value: maildocdata.tasker.address.state });
                                                                                                // mailData.html.push({ name: 'bookingid', value: maildocdata.booking_id });
                                                                                                // mailData.html.push({ name: 'u_username', value: maildocdata.user.username });
                                                                                                // mailData.html.push({ name: 'useraddress', value: maildocdata.user.address.line1 });
                                                                                                // mailData.html.push({ name: 'useraddress1', value: maildocdata.user.address.city });
                                                                                                // mailData.html.push({ name: 'useraddress2', value: maildocdata.user.address.state });
                                                                                                // mailData.html.push({ name: 'categoryname', value: maildocdata.booking_information.work_type });
                                                                                                // mailData.html.push({ name: 'hourlyrates', value: currencies.symbol + ' ' + (maildocdata.hourly_rate).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'totalhour', value: maildocdata.invoice.worked_hours_human });
                                                                                                // mailData.html.push({ name: 'totalamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'total', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.total).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'amount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'actualamount', value: currencies.symbol + ' ' + ((maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'adminamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.admin_commission).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'amountpaid', value: currencies.symbol + ' ' + (wallet.total).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'balamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.balance_amount).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
                                                                                                // mailData.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
                                                                                                // mailData.html.push({ name: 'Servicetax', value: currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2) });
                                                                                                // mailcontent.sendmail(mailData, function (err, response) { });




                                                                                                // var mailData2 = {};
                                                                                                // mailData2.template = 'PartialPaymentToTasker';
                                                                                                // mailData2.to = maildocdata.tasker.email;
                                                                                                // mailData2.html = [];
                                                                                                // mailData2.html.push({ name: 'mode', value: maildocdata.payment_type + "(Partial Paid )" });
                                                                                                // mailData2.html.push({ name: 'coupon', value: CouponCode });
                                                                                                // mailData2.html.push({ name: 'bookingdata', value: BookingDate });
                                                                                                // mailData2.html.push({ name: 'datetime', value: DateTime });
                                                                                                // mailData2.html.push({ name: 'materialfee', value: currencies.symbol + ' ' + MaterialFee });
                                                                                                // mailData2.html.push({ name: 'site_url', value: settings.settings.site_url });
                                                                                                // mailData2.html.push({ name: 'site_title', value: settings.settings.site_title });
                                                                                                // mailData2.html.push({ name: 'logo', value: settings.settings.logo });
                                                                                                // mailData2.html.push({ name: 't_username', value: maildocdata.tasker.username });
                                                                                                // mailData2.html.push({ name: 'taskeraddress', value: maildocdata.tasker.address.line1 });
                                                                                                // mailData2.html.push({ name: 'taskeraddress1', value: maildocdata.tasker.address.city });
                                                                                                // mailData2.html.push({ name: 'taskeraddress2', value: maildocdata.tasker.address.state });
                                                                                                // mailData2.html.push({ name: 'bookingid', value: maildocdata.booking_id });
                                                                                                // mailData2.html.push({ name: 'u_username', value: maildocdata.user.username });
                                                                                                // mailData2.html.push({ name: 'useraddress', value: maildocdata.user.address.line1 });
                                                                                                // mailData2.html.push({ name: 'useraddress1', value: maildocdata.user.address.city });
                                                                                                // mailData2.html.push({ name: 'useraddress2', value: maildocdata.user.address.state });
                                                                                                // mailData2.html.push({ name: 'categoryname', value: maildocdata.booking_information.work_type });
                                                                                                // mailData2.html.push({ name: 'hourlyrates', value: maildocdata.hourly_rate });
                                                                                                // mailData2.html.push({ name: 'totalhour', value: maildocdata.invoice.worked_hours_human });
                                                                                                // mailData2.html.push({ name: 'totalamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total).toFixed(2) });
                                                                                                // mailData2.html.push({ name: 'total', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.total).toFixed(2) });
                                                                                                // mailData2.html.push({ name: 'actualamount', value: currencies.symbol + ' ' + ((maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2) });
                                                                                                // mailData2.html.push({ name: 'amountpaid', value: currencies.symbol + ' ' + (wallet.total).toFixed(2) });
                                                                                                // mailData2.html.push({ name: 'balamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.balance_amount).toFixed(2) });
                                                                                                // mailData2.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
                                                                                                // mailData2.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
                                                                                                // mailData2.html.push({ name: 'admincommission', value: currencies.symbol + ' ' + maildocdata.invoice.amount.admin_commission.toFixed(2) });
                                                                                                // mailData2.html.push({ name: 'Servicetax', value: currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2) });
                                                                                                // mailData2.html.push({ name: 'email', value: req.body.email });
                                                                                                // mailcontent.sendmail(mailData2, function (err, response) { });

                                                                                                // var mailData3 = {};
                                                                                                // mailData3.template = 'PartialPaymentToUser';
                                                                                                // mailData3.to = maildocdata.user.email;
                                                                                                // mailData3.html = [];
                                                                                                // mailData3.html.push({ name: 'mode', value: maildocdata.payment_type + "(Partial Paid )" });
                                                                                                // mailData3.html.push({ name: 'datetime', value: DateTime });
                                                                                                // mailData3.html.push({ name: 'bookingdata', value: BookingDate });
                                                                                                // mailData3.html.push({ name: 'coupon', value: CouponCode });
                                                                                                // mailData3.html.push({ name: 'materialfee', value: currencies.symbol + ' ' + MaterialFee });
                                                                                                // mailData3.html.push({ name: 'site_url', value: settings.settings.site_url });
                                                                                                // mailData3.html.push({ name: 'site_title', value: settings.settings.site_title });
                                                                                                // mailData3.html.push({ name: 'logo', value: settings.settings.logo });
                                                                                                // mailData3.html.push({ name: 't_username', value: maildocdata.tasker.username });
                                                                                                // mailData3.html.push({ name: 'taskeraddress', value: maildocdata.tasker.address.line1 });
                                                                                                // mailData3.html.push({ name: 'taskeraddress1', value: maildocdata.tasker.address.city });
                                                                                                // mailData3.html.push({ name: 'taskeraddress2', value: maildocdata.tasker.address.state });
                                                                                                // mailData3.html.push({ name: 'bookingid', value: maildocdata.booking_id });
                                                                                                // mailData3.html.push({ name: 'u_username', value: maildocdata.user.username });
                                                                                                // mailData3.html.push({ name: 'useraddress', value: maildocdata.user.address.line1 });
                                                                                                // mailData3.html.push({ name: 'useraddress1', value: maildocdata.user.address.city });
                                                                                                // mailData3.html.push({ name: 'useraddress2', value: maildocdata.user.address.state });
                                                                                                // mailData3.html.push({ name: 'categoryname', value: maildocdata.booking_information.work_type });
                                                                                                // mailData3.html.push({ name: 'hourlyrates', value: currencies.symbol + ' ' + maildocdata.hourly_rate });
                                                                                                // mailData3.html.push({ name: 'totalhour', value: currencies.symbol + ' ' + maildocdata.invoice.worked_hours_human });
                                                                                                // mailData3.html.push({ name: 'totalamount', value: currencies.symbol + ' ' + maildocdata.invoice.amount.grand_total.toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'total', value: currencies.symbol + ' ' + maildocdata.invoice.amount.total.toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'actualamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.total - maildocdata.invoice.amount.grand_total).toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'admincommission', value: currencies.symbol + ' ' + maildocdata.invoice.amount.admin_commission.toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'amountpaid', value: (wallet.total).toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'balamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.balance_amount).toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
                                                                                                // mailData3.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
                                                                                                // mailData3.html.push({ name: 'Servicetax', value: currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'email', value: req.body.email });
                                                                                                // mailcontent.sendmail(mailData3, function (err, response) { });
                                                                                            }
                                                                                        });
                                                                                    }
                                                                                });
                                                                            }
                                                                        });
                                                                    }
                                                                });//end mail
                                                            }
                                                        });
                                                    }
                                                });
                                            }
                                        });
                                    } else {

                                        var paymenttype = {};
                                        if (Bookings.payment_type == 'wallet-other') {
                                            paymenttype = 'wallet-wallet';
                                        }
                                        else {
                                            paymenttype = 'wallet';
                                        }

                                        var provider_id = Bookings.tasker;
                                        var walletArr = {
                                            'type': 'DEBIT',
                                            'debit_type': 'payment',
                                            'ref_id': req.body.job_id,
                                            'trans_amount': parseFloat(Bookings.invoice.amount.balance_amount),
                                            'avail_amount': wallet.total - Bookings.invoice.amount.balance_amount,
                                            'trans_date': new Date(),
                                        };
                                        var totalwallet = wallet_amount - job_charge;
                                        db.UpdateDocument('walletReacharge', { 'user_id': request.user_id }, { $push: { transactions: walletArr }, $set: { "total": parseFloat(wallet.total - Bookings.invoice.amount.balance_amount) } }, { multi: true }, function (walletUErr, walletURespo) {
                                            if (walletUErr || walletURespo.nModified == 0) {

                                                data.response = res.__('Error in data, Please check your data'); res.send(data);
                                            }
                                            else {
                                                var transaction = {
                                                    'user': request.user_id,
                                                    'tasker': Bookings.tasker,
                                                    'task': Bookings._id,
                                                    'type': paymenttype,
                                                    'amount': Bookings.invoice.amount.balance_amount,
                                                    'task_date': Bookings.createdAt,
                                                    'status': 1
                                                };
                                                db.InsertDocument('transaction', transaction, function (err, transaction) {
                                                    if (err || transaction.nModified == 0) {
                                                        data.response = res.__('Error in data, Please check your data'); res.send(data);
                                                    }
                                                    else {
                                                        var transactions = [transaction._id];
                                                        db.UpdateDocument('task', { "booking_id": req.body.job_id }, { $push: { transactions }, 'invoice.status': '1', 'status': '7', 'payment_type': paymenttype, 'history.job_closed_time': new Date() }, function (err, docdata) {
                                                            if (err || docdata.nModified == 0) {
                                                                data.response = res.__('Error in data, Please check your data'); res.send(data);
                                                            }
                                                            else {
                                                                var message = CONFIG.NOTIFICATION.PAYMENT_COMPLETED;
                                                                var options = { 'job_id': request.job_id, 'provider_id': provider_id };
                                                                push.sendPushnotification(Bookings.user, message, 'payment_paid', 'ANDROID', options, 'USER', function (err, Response, body) { });
                                                                push.sendPushnotification(provider_id, message, 'payment_paid', 'ANDROID', options, 'PROVIDER', function (err, Response, body) { });
                                                                res.send({
                                                                    'status': '1',
                                                                    'message': res.__('Payment Completed Successfully'),
                                                                    'response': res.__('Wallet amount used successfully'),
                                                                    'used_amount': (Bookings.invoice.amount.balance_amount * currencies.value).toFixed(2),
                                                                    'available_wallet_amount': ((wallet.total - Bookings.invoice.amount.balance_amount) * currencies.value).toFixed(2)
                                                                });
                                                                //mail start
                                                                var options = {};
                                                                options.populate = 'tasker user category';
                                                                db.GetOneDocument('task', { 'booking_id': req.body.job_id }, {}, options, function (err, maildocdata) {
                                                                    if (err) {
                                                                        res.send(err);
                                                                    } else {
                                                                        db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
                                                                            if (err) {
                                                                                res.send(err);
                                                                            } else {


                                                                                db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
                                                                                    if (err) {
                                                                                        res.send(err);
                                                                                    } else {
                                                                                        var MaterialFee, CouponCode, DateTime, BookingDate;
                                                                                        if (maildocdata.invoice.amount.extra_amount) {
                                                                                            MaterialFee = (maildocdata.invoice.amount.extra_amount).toFixed(2);
                                                                                        } else {
                                                                                            MaterialFee = '0.00';
                                                                                        }
                                                                                        if (maildocdata.invoice.amount.coupon) {
                                                                                            CouponCode = maildocdata.invoice.amount.coupon;
                                                                                        } else {
                                                                                            CouponCode = 'Not assigned';
                                                                                        }
                                                                                        DateTime = moment(maildocdata.history.job_started_time).format('DD/MM/YYYY - HH:mm');
                                                                                        BookingDate = moment(maildocdata.history.booking_date).format('DD/MM/YYYY');
                                                                                        db.GetDocument('emailtemplate', { name: { $in: ['PaymentDetailstoAdmin', 'PaymentDetailstoTasker', 'PaymentDetailstoUser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
                                                                                            if (err) {
                                                                                                res.send(data);
                                                                                            }
                                                                                            else {

																							var userfirstname ='';
																							if (maildocdata.user.name.first_name) {
																							 userfirstname = maildocdata.user.name.first_name;
																							}

                                                                                                var html = template[0].email_content;
                                                                                                html = html.replace(/{{mode}}/g, maildocdata.payment_type);
                                                                                                html = html.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
                                                                                                html = html.replace(/{{coupon}}/g, CouponCode);
                                                                                                html = html.replace(/{{datetime}}/g, DateTime);
                                                                                                html = html.replace(/{{bookingdata}}/g, BookingDate);
                                                                                                html = html.replace(/{{site_url}}/g, settings.settings.site_url);
                                                                                                html = html.replace(/{{site_title}}/g, settings.settings.site_title);
                                                                                                html = html.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
                                                                                                html = html.replace(/{{t_username}}/g, maildocdata.tasker.name.first_name);
                                                                                                html = html.replace(/{{taskeraddress}}/g, maildocdata.tasker.address.line1);
                                                                                                html = html.replace(/{{taskeraddress1}}/g, maildocdata.tasker.address.city);
                                                                                                html = html.replace(/{{taskeraddress2}}/g, maildocdata.tasker.address.state);
                                                                                                html = html.replace(/{{bookingid}}/g, maildocdata.booking_id);
                                                                                                html = html.replace(/{{u_username}}/g, userfirstname);
                                                                                                html = html.replace(/{{useraddress}}/g, maildocdata.user.address.line1 || ' ');
                                                                                                html = html.replace(/{{useraddress1}}/g, maildocdata.user.address.city || ' ');
                                                                                                html = html.replace(/{{useraddress2}}/g, maildocdata.user.address.state || ' ');
                                                                                                html = html.replace(/{{categoryname}}/g, maildocdata.booking_information.work_type);
                                                                                                html = html.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (maildocdata.hourly_rate).toFixed(2));
                                                                                                html = html.replace(/{{totalhour}}/g, currencies.symbol + ' ' + maildocdata.invoice.worked_hours_human);
                                                                                                html = html.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total).toFixed(2));
                                                                                                html = html.replace(/{{total}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.total).toFixed(2));
                                                                                                html = html.replace(/{{amount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission).toFixed(2));
                                                                                                html = html.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2));
                                                                                                html = html.replace(/{{adminamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.admin_commission).toFixed(2));
                                                                                                html = html.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
                                                                                                html = html.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
                                                                                                html = html.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2));
                                                                                                var options = { format: 'Letter' };
                                                                                                var pdfname = new Date().getTime();
                                                                                                pdf.create(html, options).toFile('./uploads/invoice/' + pdfname + '.pdf', function (err, document) {
                                                                                                    console.log("err, document", err, document)
                                                                                                    if (err) {
                                                                                                        res.send(err);
                                                                                                    } else {

                                                                                                        var mailOptions = {
                                                                                                            from: template[0].sender_email,
                                                                                                            to: settings.settings.email_address,
                                                                                                            subject: template[0].email_subject,
                                                                                                            text: "Please Download the attachment to see Your Payment",
                                                                                                            html: '<b>Please Download the attachment to see Your Payment</b>',
                                                                                                            attachments: [{
                                                                                                                filename: 'Admin Partial Payment.pdf',
                                                                                                                path: './uploads/invoice/' + pdfname + '.pdf',
                                                                                                                contentType: 'application/pdf'
                                                                                                            }],
                                                                                                        };
                                                                                                    }

                                                                                                    mail.send(mailOptions, function (err, response) { });
                                                                                                });

                                                                                                var html2 = template[1].email_content;
                                                                                                html2 = html2.replace(/{{mode}}/g, maildocdata.payment_type);
                                                                                                html2 = html2.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
                                                                                                html2 = html2.replace(/{{coupon}}/g, CouponCode);
                                                                                                html2 = html2.replace(/{{datetime}}/g, DateTime);
                                                                                                html2 = html2.replace(/{{bookingdata}}/g, BookingDate);
                                                                                                html2 = html2.replace(/{{site_url}}/g, settings.settings.site_url);
                                                                                                html2 = html2.replace(/{{site_title}}/g, settings.settings.site_title);
                                                                                                html2 = html2.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
                                                                                                html2 = html2.replace(/{{t_username}}/g, maildocdata.tasker.name.first_name);
                                                                                                html2 = html2.replace(/{{taskeraddress}}/g, maildocdata.tasker.address.line1);
                                                                                                html2 = html2.replace(/{{taskeraddress1}}/g, maildocdata.tasker.address.city);
                                                                                                html2 = html2.replace(/{{taskeraddress2}}/g, maildocdata.tasker.address.state);
                                                                                                html2 = html2.replace(/{{bookingid}}/g, maildocdata.booking_id);
                                                                                                html2 = html2.replace(/{{u_username}}/g, userfirstname);
                                                                                                html2 = html2.replace(/{{useraddress}}/g, maildocdata.user.address.line1 || ' ');
                                                                                                html2 = html2.replace(/{{useraddress1}}/g, maildocdata.user.address.city || ' ');
                                                                                                html2 = html2.replace(/{{useraddress2}}/g, maildocdata.user.address.state || ' ');
                                                                                                html2 = html2.replace(/{{categoryname}}/g, maildocdata.booking_information.work_type);
                                                                                                html2 = html2.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (maildocdata.hourly_rate).toFixed(2));
                                                                                                html2 = html2.replace(/{{totalhour}}/g, currencies.symbol + ' ' + maildocdata.invoice.worked_hours_human);
                                                                                                html2 = html2.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.service_tax).toFixed(2));
                                                                                                html2 = html2.replace(/{{total}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.total).toFixed(2));
                                                                                                html2 = html2.replace(/{{amount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission).toFixed(2));
                                                                                                html2 = html2.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission) - maildocdata.invoice.amount.service_tax).toFixed(2));
                                                                                                html2 = html2.replace(/{{admincommission}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.admin_commission.toFixed(2));
                                                                                                html2 = html2.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
                                                                                                html2 = html2.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
                                                                                                html2 = html2.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2));
                                                                                                var options = { format: 'Letter' };
                                                                                                var pdfname1 = new Date().getTime();
                                                                                                pdf.create(html2, options).toFile('./uploads/invoice/' + pdfname1 + '.pdf', function (err, document) {
                                                                                                    console.log("err, document", err, document)
                                                                                                    if (err) {
                                                                                                        res.send(err);
                                                                                                    } else {

                                                                                                        var mailOptions1 = {
                                                                                                            from: template[1].sender_email,
                                                                                                            to: maildocdata.tasker.email,
                                                                                                            subject: template[1].email_subject,
                                                                                                            text: "Please Download the attachment to see Your Payment",
                                                                                                            html: '<b>Please Download the attachment to see Your Payment</b>',
                                                                                                            attachments: [{
                                                                                                                filename: CONFIG.TASKER + ' Partial Payment.pdf',
                                                                                                                path: './uploads/invoice/' + pdfname1 + '.pdf',
                                                                                                                contentType: 'application/pdf'
                                                                                                            }],
                                                                                                        };
                                                                                                    }

                                                                                                    mail.send(mailOptions1, function (err, response) { });
                                                                                                });

                                                                                                var html3 = template[2].email_content;
                                                                                                html3 = html3.replace(/{{mode}}/g, maildocdata.payment_type);
                                                                                                html3 = html3.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
                                                                                                html3 = html3.replace(/{{coupon}}/g, CouponCode);
                                                                                                html3 = html3.replace(/{{datetime}}/g, DateTime);
                                                                                                html3 = html3.replace(/{{bookingdata}}/g, BookingDate);
                                                                                                html3 = html3.replace(/{{site_url}}/g, settings.settings.site_url);
                                                                                                html3 = html3.replace(/{{site_title}}/g, settings.settings.site_title);
                                                                                                html3 = html3.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
                                                                                                html3 = html3.replace(/{{t_username}}/g, maildocdata.tasker.name.first_name);
                                                                                                html3 = html3.replace(/{{taskeraddress}}/g, maildocdata.tasker.address.line1);
                                                                                                html3 = html3.replace(/{{taskeraddress1}}/g, maildocdata.tasker.address.city);
                                                                                                html3 = html3.replace(/{{taskeraddress2}}/g, maildocdata.tasker.address.state);
                                                                                                html3 = html3.replace(/{{bookingid}}/g, maildocdata.booking_id);
                                                                                                html3 = html3.replace(/{{u_username}}/g, userfirstname);
                                                                                                html3 = html3.replace(/{{useraddress}}/g, maildocdata.user.address.line1 || ' ');
                                                                                                html3 = html3.replace(/{{useraddress1}}/g, maildocdata.user.address.city || ' ');
                                                                                                html3 = html3.replace(/{{useraddress2}}/g, maildocdata.user.address.state || ' ');
                                                                                                html3 = html3.replace(/{{categoryname}}/g, maildocdata.booking_information.work_type);
                                                                                                html3 = html3.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (maildocdata.hourly_rate).toFixed(2));
                                                                                                html3 = html3.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.minimum_cost).toFixed(2));
                                                                                                html3 = html3.replace(/{{totalhour}}/g,  maildocdata.invoice.worked_hours_human);
                                                                                                html3 = html3.replace(/{{totalamount}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.grand_total.toFixed(2));
                                                                                                html3 = html3.replace(/{{total}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.total).toFixed(2));
                                                                                                html3 = html3.replace(/{{amount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission).toFixed(2));
                                                                                                html3 = html3.replace(/{{actualamount}}/g, currencies.symbol + ' ' + (maildocdata.invoice.amount.total - maildocdata.invoice.amount.grand_total).toFixed(2));
                                                                                                html3 = html3.replace(/{{admincommission}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.admin_commission.toFixed(2));
                                                                                                html3 = html3.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
                                                                                                html3 = html3.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
                                                                                                html3 = html3.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2));
                                                                                                var options = { format: 'Letter' };
                                                                                                var pdfname2 = new Date().getTime();
                                                                                                pdf.create(html3, options).toFile('./uploads/invoice/' + pdfname2 + '.pdf', function (err, document) {
                                                                                                    console.log("err, document", err, document)
                                                                                                    if (err) {
                                                                                                        res.send(err);
                                                                                                    } else {

                                                                                                        var mailOptions2 = {
                                                                                                            from: template[2].sender_email,
                                                                                                            to: maildocdata.user.email,
                                                                                                            subject: template[2].email_subject,
                                                                                                            text: "Please Download the attachment to see Your Payment",
                                                                                                            html: '<b>Please Download the attachment to see Your Payment</b>',
                                                                                                            attachments: [{
                                                                                                                filename: CONFIG.USER + ' Payment.pdf',
                                                                                                                path: './uploads/invoice/' + pdfname2 + '.pdf',
                                                                                                                contentType: 'application/pdf'
                                                                                                            }],
                                                                                                        };
                                                                                                    }

                                                                                                    mail.send(mailOptions2, function (err, response) { });
                                                                                                });
                                                                                                // var mailData = {};
                                                                                                // mailData.template = 'PaymentDetailstoAdmin';
                                                                                                // mailData.to = settings.settings.email_address;
                                                                                                // mailData.html = [];
                                                                                                // mailData.html.push({ name: 'mode', value: maildocdata.payment_type });
                                                                                                // mailData.html.push({ name: 'materialfee', value: currencies.symbol + ' ' + MaterialFee });
                                                                                                // mailData.html.push({ name: 'coupon', value: CouponCode });
                                                                                                // mailData.html.push({ name: 'datetime', value: DateTime });
                                                                                                // mailData.html.push({ name: 'bookingdata', value: BookingDate });
                                                                                                // mailData.html.push({ name: 'site_url', value: settings.settings.site_url });
                                                                                                // mailData.html.push({ name: 'site_title', value: settings.settings.site_title });
                                                                                                // mailData.html.push({ name: 'logo', value: settings.settings.logo });
                                                                                                // mailData.html.push({ name: 't_username', value: maildocdata.tasker.name.first_name + "(" + maildocdata.tasker.username + ")" });
                                                                                                // mailData.html.push({ name: 'taskeraddress', value: maildocdata.tasker.address.line1 });
                                                                                                // mailData.html.push({ name: 'taskeraddress1', value: maildocdata.tasker.address.city });
                                                                                                // mailData.html.push({ name: 'taskeraddress2', value: maildocdata.tasker.address.state });
                                                                                                // mailData.html.push({ name: 'bookingid', value: maildocdata.booking_id });
                                                                                                // mailData.html.push({ name: 'u_username', value: maildocdata.user.name.first_name + "(" + maildocdata.user.username + ")" });
                                                                                                // mailData.html.push({ name: 'useraddress', value: maildocdata.user.address.line1 });
                                                                                                // mailData.html.push({ name: 'useraddress1', value: maildocdata.user.address.city });
                                                                                                // mailData.html.push({ name: 'useraddress2', value: maildocdata.user.address.state });
                                                                                                // mailData.html.push({ name: 'categoryname', value: maildocdata.booking_information.work_type });
                                                                                                // mailData.html.push({ name: 'hourlyrates', value: currencies.symbol + ' ' + (maildocdata.hourly_rate).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'totalhour', value: currencies.symbol + ' ' + maildocdata.invoice.worked_hours_human });
                                                                                                // mailData.html.push({ name: 'totalamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'total', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.total).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'amount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'actualamount', value: currencies.symbol + ' ' + ((maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'adminamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.admin_commission).toFixed(2) });
                                                                                                // mailData.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
                                                                                                // mailData.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
                                                                                                // //mailData.html.push({ name: 'senderemail', value: template[0].sender_email });
                                                                                                // mailData.html.push({ name: 'Servicetax', value: currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2) });
                                                                                                // //	mailData.html.push({ name: 'email', value: req.body.email });
                                                                                                // mailcontent.sendmail(mailData, function (err, response) { });

                                                                                                // var mailData2 = {};
                                                                                                // mailData2.template = 'PaymentDetailstoTasker';
                                                                                                // mailData2.to = maildocdata.tasker.email;
                                                                                                // mailData2.html = [];
                                                                                                // mailData2.html.push({ name: 'mode', value: maildocdata.payment_type });
                                                                                                // mailData2.html.push({ name: 'coupon', value: CouponCode });
                                                                                                // mailData2.html.push({ name: 'bookingdata', value: BookingDate });
                                                                                                // mailData2.html.push({ name: 'datetime', value: DateTime });
                                                                                                // mailData2.html.push({ name: 'materialfee', value: currencies.symbol + ' ' + MaterialFee });
                                                                                                // mailData2.html.push({ name: 'site_url', value: settings.settings.site_url });
                                                                                                // mailData2.html.push({ name: 'site_title', value: settings.settings.site_title });
                                                                                                // mailData2.html.push({ name: 'logo', value: settings.settings.logo });
                                                                                                // mailData2.html.push({ name: 't_username', value: maildocdata.tasker.name.first_name + "(" + maildocdata.tasker.username + ")" });
                                                                                                // mailData2.html.push({ name: 'taskeraddress', value: maildocdata.tasker.address.line1 });
                                                                                                // mailData2.html.push({ name: 'taskeraddress1', value: maildocdata.tasker.address.city });
                                                                                                // mailData2.html.push({ name: 'taskeraddress2', value: maildocdata.tasker.address.state });
                                                                                                // mailData2.html.push({ name: 'bookingid', value: maildocdata.booking_id });
                                                                                                // mailData2.html.push({ name: 'u_username', value: maildocdata.user.name.first_name + "(" + maildocdata.user.username + ")" });
                                                                                                // mailData2.html.push({ name: 'useraddress', value: maildocdata.user.address.line1 });
                                                                                                // mailData2.html.push({ name: 'useraddress1', value: maildocdata.user.address.city });
                                                                                                // mailData2.html.push({ name: 'useraddress2', value: maildocdata.user.address.state });
                                                                                                // mailData2.html.push({ name: 'categoryname', value: maildocdata.booking_information.work_type });
                                                                                                // mailData2.html.push({ name: 'hourlyrates', value: currencies.symbol + ' ' + maildocdata.hourly_rate });
                                                                                                // mailData2.html.push({ name: 'totalhour', value: currencies.symbol + ' ' + maildocdata.invoice.worked_hours_human });
                                                                                                // mailData2.html.push({ name: 'totalamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.service_tax).toFixed(2) });
                                                                                                // mailData2.html.push({ name: 'total', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.total).toFixed(2) });
                                                                                                // mailData2.html.push({ name: 'actualamount', value: currencies.symbol + ' ' + ((maildocdata.invoice.amount.grand_total - maildocdata.invoice.amount.admin_commission) - maildocdata.invoice.amount.service_tax).toFixed(2) });
                                                                                                // // mailData2.html.push({ name: 'adminamount', value: maildocdata.invoice.amount.admin_commission});
                                                                                                // mailData2.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
                                                                                                // mailData2.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
                                                                                                // mailData2.html.push({ name: 'admincommission', value: currencies.symbol + ' ' + maildocdata.invoice.amount.admin_commission.toFixed(2) });
                                                                                                // //	mailData2.html.push({ name: 'senderemail', value: template[0].sender_email });
                                                                                                // mailData2.html.push({ name: 'Servicetax', value: currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2) });
                                                                                                // mailData2.html.push({ name: 'email', value: req.body.email });
                                                                                                // mailcontent.sendmail(mailData2, function (err, response) { });
                                                                                                // var mailData3 = {};
                                                                                                // mailData3.template = 'PaymentDetailstoUser';
                                                                                                // mailData3.to = maildocdata.user.email;
                                                                                                // mailData3.html = [];
                                                                                                // mailData3.html.push({ name: 'mode', value: maildocdata.payment_type });
                                                                                                // mailData3.html.push({ name: 'datetime', value: DateTime });
                                                                                                // mailData3.html.push({ name: 'bookingdata', value: BookingDate });
                                                                                                // mailData3.html.push({ name: 'coupon', value: CouponCode });
                                                                                                // mailData3.html.push({ name: 'materialfee', value: currencies.symbol + ' ' + MaterialFee });
                                                                                                // mailData3.html.push({ name: 'site_url', value: settings.settings.site_url });
                                                                                                // mailData3.html.push({ name: 'site_title', value: settings.settings.site_title });
                                                                                                // mailData3.html.push({ name: 'logo', value: settings.settings.logo });
                                                                                                // mailData3.html.push({ name: 't_username', value: maildocdata.tasker.name.first_name + "(" + maildocdata.tasker.username + ")" });
                                                                                                // mailData3.html.push({ name: 'taskeraddress', value: maildocdata.tasker.address.line1 });
                                                                                                // mailData3.html.push({ name: 'taskeraddress1', value: maildocdata.tasker.address.city });
                                                                                                // mailData3.html.push({ name: 'taskeraddress2', value: maildocdata.tasker.address.state });
                                                                                                // mailData3.html.push({ name: 'bookingid', value: maildocdata.booking_id });
                                                                                                // mailData3.html.push({ name: 'u_username', value: maildocdata.user.name.first_name + "(" + maildocdata.user.username + ")" });
                                                                                                // mailData3.html.push({ name: 'useraddress', value: maildocdata.user.address.line1 });
                                                                                                // mailData3.html.push({ name: 'useraddress1', value: maildocdata.user.address.city });
                                                                                                // mailData3.html.push({ name: 'useraddress2', value: maildocdata.user.address.state });
                                                                                                // mailData3.html.push({ name: 'categoryname', value: maildocdata.booking_information.work_type });
                                                                                                // mailData3.html.push({ name: 'hourlyrates', value: currencies.symbol + ' ' + maildocdata.hourly_rate });
                                                                                                // mailData3.html.push({ name: 'totalhour', value: maildocdata.invoice.worked_hours_human });
                                                                                                // mailData3.html.push({ name: 'totalamount', value: currencies.symbol + ' ' + maildocdata.invoice.amount.grand_total.toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'total', value: currencies.symbol + ' ' + maildocdata.invoice.amount.total.toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'actualamount', value: currencies.symbol + ' ' + (maildocdata.invoice.amount.total - maildocdata.invoice.amount.grand_total).toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'admincommission', value: currencies.symbol + ' ' + maildocdata.invoice.amount.admin_commission.toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
                                                                                                // mailData3.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
                                                                                                // //mailData3.html.push({ name: 'senderemail', value: template[0].sender_email });
                                                                                                // mailData3.html.push({ name: 'Servicetax', value: currencies.symbol + ' ' + maildocdata.invoice.amount.service_tax.toFixed(2) });
                                                                                                // mailData3.html.push({ name: 'email', value: req.body.email });
                                                                                                // mailcontent.sendmail(mailData3, function (err, response) { });
                                                                                            }
                                                                                        });
                                                                                    }
                                                                                });
                                                                            }
                                                                        });
                                                                    }
                                                                });// mail end
                                                            }
                                                        });
                                                    }
                                                });
                                            }
                                        });
                                    }
                                }
                            });
                        }
                    });
                }
            });
        }
    });
}

controller.byGateway = function (req, res) {
    var errors = [];
    req.checkBody('job_id', res.__('Job ID is Required')).notEmpty();
    req.checkBody('user_id', res.__(CONFIG.USER + ' ID is Required')).notEmpty();
    req.checkBody('gateway', res.__('Gateway ID is Required')).notEmpty();
    errors = req.validationErrors();
    if (errors) {
        res.send({
            "status": "0",
            "errors": errors[0].msg
        });
        return;
    }
    var data = {};
    data.user_id = req.body.user_id;
    data.job_id = req.body.job_id;
    data.payment = req.body.gateway;

    req.sanitizeBody('job_id').trim();
    req.sanitizeBody('user_id').trim();
    req.sanitizeBody('gateway').trim();

    var request = {};
    request.job_id = req.body.job_id;
    request.user_id = req.body.user_id;
    request.gateway = req.body.gateway;

    var extension = {};
    extension.populate = 'tasker';
    db.GetOneDocument('task', { 'booking_id': request.job_id, 'user': request.user_id, 'status': 6 }, {}, extension, function (err, task) {
        if (err || !task) {
            res.send({
                'status': '0',
                'response': res.__('INVALID DATA')
            });
        } else {
            if (task.tasker) {
                db.GetDocument('paymentgateway', { 'alias': req.body.gateway, 'status': 1 }, {}, {}, function (paymentErr, paymentRespo) {
                    if (paymentErr || !paymentRespo) {
                        res.send({
                            'status': '0',
                            'response': res.__('INVALID  DATA')
                        });
                    } else {
                        if (task.invoice.amount.grand_total) {
                            if (task.invoice.amount.balance_amount) {
                                amount_to_receive = (task.invoice.amount.balance_amount).toFixed(2);
                            }
                            else {
                                amount_to_receive = (task.invoice.amount.grand_total).toFixed(2);
                            }
                            var transaction = {};
                            transaction.user = request.user_id;
                            transaction.tasker = task.tasker._id;
                            transaction.task = task._id;
                            transaction.type = request.gateway;
                            transaction.amount = amount_to_receive;
                            transaction.task_date = task.createdAt;
                            transaction.status = 2
                            db.InsertDocument('transaction', transaction, function (err, transaction) {
                                if (err || transaction.nModified == 0) { data.response = res.__('Error in saving your data'); res.send(data); }
                                else {
                                    res.send({
                                        'status': '1',
                                        'job_id': request.job_id,
                                        'mobile_id': transaction._id,

                                    });
                                }
                            });
                            //----------------Transcation status 2
                        }
                    }
                });
            } else {
                res.send({
                    'status': '0',
                    'response': res.__('INVALID DATA')
                });
            }
        }
    });
}



controller.applyCoupon = function (req, res) {

    var status = '0';
    var response = '';
    var errors = [];

    req.checkBody('user_id', res.__(CONFIG.USER + ' ID is Required')).notEmpty();
    req.checkBody('code', res.__('Coupon code is Required')).notEmpty();
    req.checkBody('pickup_date', res.__('Pick Up Date is Required')).notEmpty();
    errors = req.validationErrors();
    if (errors) {
        res.send({
            "status": "0",
            "response": errors[0].msg
        });
        return;
    }


    var data = {};
    data.user_id = req.body.user_id;
    data.code = req.body.code;
    data.reach_date = req.body.pickup_date;

    db.GetOneDocument('users', { _id: req.body.user_id }, {}, {}, function (err, userRespo) {
        if (userRespo) {
            db.GetOneDocument('coupon', { code: req.body.code }, {}, {}, function (promoErr, promoRespo) {
                if (err || !promoRespo) {
                    res.send({ "status": "0", "response": res.__("Invalid Coupon") });
                } else {
                    var valid_from = promoRespo.valid_from;
                    var valid_to = promoRespo.expiry_date;
                    var date_time = new Date(req.body.pickup_date);

                    if ((Date.parse(valid_from) <= Date.parse(date_time)) && (Date.parse(valid_to) >= Date.parse(date_time))) {
                        //if (promoRespo.total_coupons > promoRespo.per_user) {
                        /*
                        var coupon_usage = [];
                        var coupon_count = 0;
                        if (promoRespo.usage) {
                            coupon_usage = promoRespo[0].usage;
                            for (var i = 0; i < promoRespo[0].usage.length; i++) {
                                if (promoRespo[0].usage[i].user_id && promoRespo[0].usage[i].user_id == req.body.user_id) {
                                    coupon_count++;
                                }
                            }
                        }
                        if (coupon_count <= promoRespo[0].user_usage) {
                        */
                        res.send({
                            "status": "1",
                            "response": [{ "message": res.__("Coupon code applied."), "code": req.body.code }]
                        });
                        /*
                        }
                        } else {
                            res.send({ "status": "0", "response": "Coupon Expired" });
                        }
                        */
                    } else {
                        res.send({ "status": "0", "response": res.__("Coupon Expired") });
                    }
                }
            });
        } else {
            res.send({ "status": "0", "response": res.__("Invalid " + CONFIG.USER) });
        }
    });
};


return controller;

}
