module.exports = function (io) {


    var db = require('../controller/adaptor/mongodb.js');
    var async = require('async');
    var CONFIG = require('../config/config');
    var push = require('../model/pushNotification.js')(io);
    var mailcontent = require('../model/mailcontent.js');
    var moment = require("moment");
    var timezone = require('moment-timezone');
    var pdf = require('html-pdf');
    var mail = require('../model/mail.js');

    function taskPayment(data, callback) {


        var transactionup = {};
        var docdata = {};
        var history = {};

        var options = {};
        options.populate = 'tasker user task';
        db.GetOneDocument('transaction', { _id: data.transaction }, {}, options, function (err, transaction) {
            if (err || !transaction) {
                callback(err, null);
            } else {

                db.GetOneDocument('task', { _id: transaction.task._id }, {}, {}, function (err, taskdata) {
                    if (err) {
                        callback(err, null);
                    }
                    else {
                        var paymenttype;
                        if (taskdata) {
                            if (taskdata.payment_type == "wallet-other") {
                                paymenttype = "wallet-" + transaction.type;
                            }
                            else {
                                paymenttype = transaction.type;
                            }
                        }


                        var task = transaction.task;
                        var user = transaction.user;
                        var tasker = transaction.tasker;

                        var dataToUpdate = {};
                        dataToUpdate.status = 7;
                        dataToUpdate.invoice = task.invoice;
                        dataToUpdate.invoice.status = 1;
                        dataToUpdate.payee_status = 0;
                        dataToUpdate.invoice.amount.balance_amount = parseFloat(task.invoice.amount.balance_amount) - parseFloat(task.invoice.amount.balance_amount);
                        dataToUpdate.payment_type = paymenttype;
                        dataToUpdate.history = task.history;
                        dataToUpdate.history.job_closed_time = new Date();
                        var transactionsData = [{
                            'gateway_response': data.gateway_response
                        }];
                        async.parallel({
                            transaction: function (callback) {
                                db.UpdateDocument('transaction', { '_id': transaction._id }, { 'transactions': transactionsData }, {}, function (err, transaction) {
                                    callback(err, transaction);
                                });
                            },
                            task: function (callback) {
                                db.UpdateDocument('task', { _id: task._id }, dataToUpdate, function (err, task) {
                                    callback(err, task);
                                });
                            },
                            settings: function (callback) {
                                db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
                                    callback(err, settings.settings);
                                });
                            },
                            currencies: function (callback) {
                                db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
                                    callback(err, currencies);
                                });
                            },


                        }, function (err, result) {
                            if (err || !result.settings || !result.currencies || result.transaction.nModified == 0 || result.task.nModified == 0) {

                                callback(err, null);
                            } else {

                                db.GetDocument('emailtemplate', { name: { $in: ['PaymentDetailstoAdmin', 'PaymentDetailstoTasker', 'PaymentDetailstoUser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
                                    if (err) {
                                        callback(err, null);
                                    }
                                    else {
                                        task.payment_type = dataToUpdate.payment_type;
                                        var settings = result.settings;
                                        var currencies = result.currencies;

                                        var notifications = { 'job_id': task.booking_id, 'user_id': tasker._id };
                                        var message = CONFIG.NOTIFICATION.PAYMENT_COMPLETED;
                                        push.sendPushnotification(tasker._id, message, 'payment_paid', 'ANDROID', notifications, 'PROVIDER', function (err, response, body) { });
                                        push.sendPushnotification(user._id, message, 'payment_paid', 'ANDROID', notifications, 'USER', function (err, response, body) { });


                                        var MaterialFee, CouponCode, DateTime, BookingDate;
                                        if (task.invoice.amount.extra_amount) {
                                            MaterialFee = (task.invoice.amount.extra_amount).toFixed(2);
                                        } else {
                                            MaterialFee = '0.00';
                                        }
                                        if (task.invoice.amount.coupon) {
                                            CouponCode = currencies.symbol + task.invoice.amount.coupon;
                                        } else {
                                            CouponCode = 'Not assigned';
                                        }
                                        DateTime = moment(task.history.job_started_time).format('DD/MM/YYYY - HH:mm');
                                        BookingDate = moment(task.history.booking_date).format('DD/MM/YYYY');

                                        var html = template[0].email_content;

                                        // console.log(task,"taskkkkkkkkk");
                                        //
                                        // for(var i=0 ; i< template.length ;i++){
                                        //   console.log("template",template[i].name);
                                        // }

                                        html = html.replace(/{{mode}}/g, task.payment_type);
                                        html = html.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
                                        html = html.replace(/{{coupon}}/g, CouponCode);
                                        html = html.replace(/{{datetime}}/g, DateTime);
                                        html = html.replace(/{{bookingdata}}/g, BookingDate);
                                        html = html.replace(/{{site_url}}/g, settings.site_url);
                                        html = html.replace(/{{site_title}}/g, settings.site_title);
                                        html = html.replace(/{{logo}}/g, settings.site_url + settings.logo);
                                        html = html.replace(/{{t_username}}/g, tasker.name.first_name);
                                        html = html.replace(/{{taskeraddress}}/g, tasker.address.line1);
                                        html = html.replace(/{{taskeraddress1}}/g, tasker.address.city);
                                        html = html.replace(/{{taskeraddress2}}/g, tasker.address.state);
                                        html = html.replace(/{{bookingid}}/g, task.booking_id);
                                        html = html.replace(/{{u_username}}/g, user.username);
                                        html = html.replace(/{{useraddress}}/g, user.address.line1 || ' ');
                                        html = html.replace(/{{useraddress1}}/g, user.address.city || ' ');
                                        html = html.replace(/{{useraddress2}}/g, user.address.state || ' ');
                                        html = html.replace(/{{categoryname}}/g, task.booking_information.work_type);
                                        html = html.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (task.hourly_rate).toFixed(2));
                                        html = html.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (task.invoice.amount.minimum_cost).toFixed(2));
                                        html = html.replace(/{{totalhour}}/g, task.invoice.worked_hours_human);
                                        html = html.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (task.invoice.amount.grand_total).toFixed(2));
                                        html = html.replace(/{{total}}/g, currencies.symbol + ' ' + (task.invoice.amount.total).toFixed(2));
                                        html = html.replace(/{{amount}}/g, currencies.symbol + ' ' + (task.invoice.amount.grand_total - task.invoice.amount.admin_commission).toFixed(2));
                                        html = html.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((task.invoice.amount.grand_total - task.invoice.amount.admin_commission) - task.invoice.amount.service_tax).toFixed(2));
                                        html = html.replace(/{{adminamount}}/g, currencies.symbol + ' ' + (task.invoice.amount.admin_commission).toFixed(2));
                                        html = html.replace(/{{privacy}}/g, settings.site_url + 'pages/privacypolicy');
                                        html = html.replace(/{{terms}}/g, settings.site_url + 'pages/termsandconditions');
                                        html = html.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + task.invoice.amount.service_tax.toFixed(2));
                                        var options = { format: 'Letter' };
                                        var pdfname = new Date().getTime();

                                        pdf.create(html, options).toFile('./uploads/invoice/' + pdfname + '.pdf', function (err, document) {
                                            if (err) {
                                                callback(err, null);
                                            } else {

                                                var mailOptions = {
                                                    from: template[0].sender_email,
                                                    to: settings.email_address,
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

                                            mail.send(mailOptions, function (err, response) {


                                            });
                                        });


                                        var html2 = template[1].email_content;


                                        html2 = html2.replace(/{{mode}}/g, task.payment_type);
                                        html2 = html2.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
                                        html2 = html2.replace(/{{coupon}}/g, CouponCode);
                                        html2 = html2.replace(/{{datetime}}/g, DateTime);
                                        html2 = html2.replace(/{{bookingdata}}/g, BookingDate);
                                        html2 = html2.replace(/{{site_url}}/g, settings.site_url);
                                        html2 = html2.replace(/{{site_title}}/g, settings.site_title);
                                        html2 = html2.replace(/{{logo}}/g, settings.site_url + settings.logo);
                                        html2 = html2.replace(/{{t_username}}/g, tasker.name.first_name);
                                        html2 = html2.replace(/{{taskeraddress}}/g, tasker.address.line1);
                                        html2 = html2.replace(/{{taskeraddress1}}/g, tasker.address.city);
                                        html2 = html2.replace(/{{taskeraddress2}}/g, tasker.address.state);
                                        html2 = html2.replace(/{{bookingid}}/g, task.booking_id);
                                        html2 = html2.replace(/{{u_username}}/g, user.username);
                                        html2 = html2.replace(/{{useraddress}}/g, user.address.line1 || ' ');
                                        html2 = html2.replace(/{{useraddress1}}/g, user.address.city || ' ');
                                        html2 = html2.replace(/{{useraddress2}}/g, user.address.state || ' ');
                                        html2 = html2.replace(/{{categoryname}}/g, task.booking_information.work_type);
                                        html2 = html2.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (task.hourly_rate).toFixed(2));
                                        html2 = html2.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (task.invoice.amount.minimum_cost).toFixed(2));
                                        html2 = html2.replace(/{{totalhour}}/g, task.invoice.worked_hours_human);
                                        html2 = html2.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (task.invoice.amount.grand_total - task.invoice.amount.service_tax).toFixed(2));
                                        html2 = html2.replace(/{{total}}/g, currencies.symbol + ' ' + (task.invoice.amount.total).toFixed(2));
                                        html2 = html2.replace(/{{amount}}/g, currencies.symbol + ' ' + (task.invoice.amount.grand_total - task.invoice.amount.admin_commission).toFixed(2));
                                        html2 = html2.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((task.invoice.amount.grand_total - task.invoice.amount.admin_commission) - task.invoice.amount.service_tax).toFixed(2));
                                        html2 = html2.replace(/{{admincommission}}/g, currencies.symbol + ' ' + task.invoice.amount.admin_commission.toFixed(2));
                                        html2 = html2.replace(/{{privacy}}/g, settings.site_url + 'pages/privacypolicy');
                                        html2 = html2.replace(/{{terms}}/g, settings.site_url + 'pages/termsandconditions');
                                        html2 = html2.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + task.invoice.amount.service_tax.toFixed(2));
                                        var options = { format: 'Letter' };
                                        var pdfname1 = new Date().getTime();

                                        pdf.create(html2, options).toFile('./uploads/invoice/' + pdfname1 + '.pdf', function (err, document) {
                                            if (err) {
                                                callback(err, null);
                                            } else {

                                                var mailOptions1 = {
                                                    from: template[1].sender_email,
                                                    to: tasker.email,
                                                    subject: template[1].email_subject,
                                                    text: "Please Download the attachment to see Your Payment",
                                                    html: '<b>Please Download the attachment to see Your Payment</b>',
                                                    attachments: [{
                                                        filename: CONFIG.TASKER + ' Payment.pdf',
                                                        path: './uploads/invoice/' + pdfname1 + '.pdf',
                                                        contentType: 'application/pdf'
                                                    }],
                                                };
                                            }

                                            mail.send(mailOptions1, function (err, response) {

                                            });
                                        });

                                        var html3 = template[2].email_content;

                                        html3 = html3.replace(/{{mode}}/g, task.payment_type);
                                        html3 = html3.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
                                        html3 = html3.replace(/{{coupon}}/g, CouponCode);
                                        html3 = html3.replace(/{{datetime}}/g, DateTime);
                                        html3 = html3.replace(/{{bookingdata}}/g, BookingDate);
                                        html3 = html3.replace(/{{site_url}}/g, settings.site_url);
                                        html3 = html3.replace(/{{site_title}}/g, settings.site_title);
                                        html3 = html3.replace(/{{logo}}/g, settings.site_url + settings.logo);
                                        html3 = html3.replace(/{{t_username}}/g, tasker.name.first_name);
                                        html3 = html3.replace(/{{taskeraddress}}/g, tasker.address.line1);
                                        html3 = html3.replace(/{{taskeraddress1}}/g, tasker.address.city);
                                        html3 = html3.replace(/{{taskeraddress2}}/g, tasker.address.state);
                                        html3 = html3.replace(/{{bookingid}}/g, task.booking_id);
                                        html3 = html3.replace(/{{u_username}}/g, user.username);
                                        html3 = html3.replace(/{{useraddress}}/g, user.address.line1 || ' ');
                                        html3 = html3.replace(/{{useraddress1}}/g, user.address.city || ' ');
                                        html3 = html3.replace(/{{useraddress2}}/g, user.address.state || ' ');
                                        html3 = html3.replace(/{{categoryname}}/g, task.booking_information.work_type);
                                        html3 = html3.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (task.hourly_rate).toFixed(2));
                                        html3 = html3.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (task.invoice.amount.minimum_cost).toFixed(2));
                                        html3 = html3.replace(/{{totalhour}}/g, task.invoice.worked_hours_human);
                                        html3 = html3.replace(/{{totalamount}}/g, currencies.symbol + ' ' + task.invoice.amount.grand_total.toFixed(2));
                                        html3 = html3.replace(/{{total}}/g, currencies.symbol + ' ' + (task.invoice.amount.total).toFixed(2));
                                        html3 = html3.replace(/{{amount}}/g, currencies.symbol + ' ' + (task.invoice.amount.grand_total - task.invoice.amount.admin_commission).toFixed(2));
                                        html3 = html3.replace(/{{actualamount}}/g, currencies.symbol + ' ' + (task.invoice.amount.total - task.invoice.amount.grand_total).toFixed(2));
                                        html3 = html3.replace(/{{admincommission}}/g, currencies.symbol + ' ' + task.invoice.amount.admin_commission.toFixed(2));
                                        html3 = html3.replace(/{{privacy}}/g, settings.site_url + 'pages/privacypolicy');
                                        html3 = html3.replace(/{{terms}}/g, settings.site_url + 'pages/termsandconditions');
                                        html3 = html3.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + task.invoice.amount.service_tax.toFixed(2));
                                        var options = { format: 'Letter' };
                                        var pdfname2 = new Date().getTime();

                                        pdf.create(html3, options).toFile('./uploads/invoice/' + pdfname2 + '.pdf', function (err, document) {
                                            if (err) {
                                                callback(err, null);
                                            } else {

                                                var mailOptions2 = {
                                                    from: template[2].sender_email,
                                                    to: user.email,
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

                                            mail.send(mailOptions2, function (err, response) {

                                            });
                                        });


                                        callback(err, { 'status': 1, 'response': 'Sucess' });
                                    }
                                });

                            }
                        }
                        );
                    }
                });

            }
        });
    }


    function completeTask(data, callback) {

        var options = {};
        options.populate = 'user tasker category';
        db.GetOneDocument('task', { _id: data.task }, {}, options, function (err, task) {
            if (err) {
                callback(err, null);
            } else {
                if (data.request) {
                    var pricevalue = 0;
                    var miscellaneous = [];
                    for (var i = 0; i < data.request.length; i++) {
                        pricevalue = parseFloat(data.request[i].price) + parseFloat(pricevalue);
                        miscellaneous.push({ 'name': data.request[i].name, 'price': data.request[i].price });
                    }
                }

                var startTime = moment(task.history.job_started_time);
                var endTime = moment(new Date());
                var momentDiff = endTime.diff(startTime, 'minutes');
                var duration = moment.duration(momentDiff, 'minutes');
                var duration_hours = Math.floor(duration.asHours());
                var duration_minutes = Math.floor(duration.asMinutes()) - duration_hours * 60 || 1;
                var momentCal = (duration.asHours()).toFixed(2);
                if (duration_hours) {
                    var momentHuman = duration_hours + "hours " + duration_minutes + "minutes";
                } else {
                    if (duration_minutes == 1) {
                        var momentHuman = duration_minutes + "minute";
                    } else {
                        var momentHuman = duration_minutes + "minutes";
                    }
                }
                var provider_commision = 0;
                var invoice = {};
                invoice.worked_hours = duration_hours + '.' + duration_minutes;
                invoice.worked_hours_human = momentHuman;
                invoice.amount = {};
                invoice.amount.minimum_cost = parseFloat(task.category.commision);
                for (var i = 0; i < task.tasker.taskerskills.length; i++) {
                    if (task.tasker.taskerskills[i].childid == task.booking_information.work_id) {
                        provider_commision = (task.tasker.taskerskills[i].hour_rate).toFixed(2);
                    }
                }
                db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settingdata) {
                    if (err || !settingdata) {
                        callback(err);
                    } else {
                        invoice.amount.task_cost = parseFloat(provider_commision).toFixed(2);
                        invoice.amount.worked_hours_cost = parseFloat(invoice.amount.minimum_cost + (invoice.amount.task_cost * (Math.ceil(invoice.worked_hours) - 1))).toFixed(2);
                        invoice.amount.total = parseFloat(invoice.amount.worked_hours_cost).toFixed(2);
                        invoice.amount.service_tax = (parseFloat((settingdata.settings.service_tax) / 100) * invoice.amount.total).toFixed(2);
                        /*  if (invoice.worked_hours > 1) {
                              invoice.amount.total = parseFloat(invoice.amount.minimum_cost) + parseFloat(invoice.amount.worked_hours_cost);
                          } else {
                              invoice.amount.total = parseFloat(invoice.amount.minimum_cost);
                          }*/
                        if (settingdata.settings.categorycommission) {
                            if (settingdata.settings.categorycommission.status == 1) {
                                invoice.amount.admin_commission = parseFloat((task.category.admincommision / 100) * invoice.amount.total).toFixed(2);
                            } else {
                                invoice.amount.admin_commission = parseFloat((settingdata.settings.admin_commission / 100) * invoice.amount.total).toFixed(2);
                            }
                        }
                        else {
                            invoice.amount.admin_commission = parseFloat((settingdata.settings.admin_commission / 100) * invoice.amount.total).toFixed(2);
                        }

                        var addno = parseFloat(invoice.amount.total) + parseFloat(invoice.amount.service_tax);
                        var fulltotal = addno.toFixed(2);
                        if (data.request) {
                            var roundedprice = parseFloat(pricevalue);
                            var dummy = parseFloat(invoice.amount.total) + parseFloat(roundedprice);
                            var addno = (parseFloat((settingdata.settings.service_tax) / 100) * dummy).toFixed(2);
                            var fulltotal = addno;
                            invoice.amount.grand_total = parseFloat(dummy) + parseFloat(addno);
                            invoice.amount.balance_amount = parseFloat(dummy) + parseFloat(addno);
                            invoice.amount.extra_amount = parseFloat(roundedprice);
                            invoice.amount.service_tax = addno;
                            invoice.miscellaneous = miscellaneous;

                        } else {
                            invoice.amount.grand_total = fulltotal;
                            invoice.amount.balance_amount = fulltotal;
                        }
                        async.parallel({
                            updateresult: function (callback) {
                                db.UpdateDocument('task', { _id: task._id }, { 'status': 6, 'history.job_completed_time': new Date(), 'invoice': invoice }, {}, function (err, updateresult) {
                                    callback(err, updateresult);
                                });
                            },
                            currencies: function (callback) {
                                db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
                                    callback(err, currencies);
                                });
                            },
                            tasker: function (callback) {
                                if (task.bookingmode == 'booknow') {
                                    db.UpdateDocument('tasker', { _id: task.tasker._id }, { $unset: { current_task: "" } }, function (err, result) {
                                        if (err) { callback(err, task); }
                                        else { callback(err, task); }
                                    });
                                }
                                else {
                                    callback(err, task);
                                }
                            },
                        }, function (err, value) {
                            if (err || !value.currencies || value.updateresult.nModified == 0) {
                                callback(err, null);
                            } else {
                                db.GetOneDocument('task', { _id: data.task }, {}, options, function (err, task) {
                                    if (err) {
                                        callback(err, null);
                                    } else {

                                        var currencies = value.currencies;

                                        var MaterialFee, BookingDate, datetime;

                                        // var actualamount = parseInt(invoice.amount.grand_total) - parseInt(invoice.amount.admin_commission);
                                        var actualamount = invoice.amount.grand_total - invoice.amount.admin_commission - invoice.amount.service_tax;
                                        var actualamountsymbol = currencies.symbol + (actualamount).toFixed(2);
                                        //console.log("task.history////////////////",task.history);
                                        datetime = moment(task.history.job_completed_time).format('DD/MM/YYYY - HH:mm');
                                        BookingDate = moment(task.history.booking_date).format('DD/MM/YYYY');
                                        if (invoice.amount.extra_amount) {
                                            MaterialFee = (invoice.amount.extra_amount).toFixed(2);
                                        } else {
                                            MaterialFee = 0.00;
                                        }


                                        db.GetDocument('emailtemplate', { name: { $in: ['Invoice', 'Invoicetoadmin', 'Invoicetouser', 'Taskcompleted', 'Taskcompleteduser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
                                            if (err) {
                                                callback(err, null);
                                            }
                                            else {

                                                var html = template[1].email_content;
                                                html = html.replace(/{{t_username}}/g, task.tasker.name.first_name);
                                                html = html.replace(/{{u_username}}/g, task.user.name.first_name);
                                                html = html.replace(/{{categoryname}}/g, task.category.name);
                                                html = html.replace(/{{bookingid}}/g, task.booking_id);
                                                html = html.replace(/{{logo}}/g, settingdata.settings.site_url + settingdata.settings.logo);
                                                html = html.replace(/{{taskeraddress}}/g, task.tasker.address.line1);
                                                html = html.replace(/{{taskeraddress1}}/g, task.tasker.address.line2);
                                                html = html.replace(/{{taskeraddress2}}/g, task.tasker.address.city);
                                                html = html.replace(/{{useraddress}}/g, task.billing_address.line1);
                                                html = html.replace(/{{useraddress1}}/g, task.billing_address.city);
                                                html = html.replace(/{{useraddress2}}/g, task.billing_address.state);
                                                html = html.replace(/{{hourlyrate}}/g, currencies.symbol + (task.invoice.amount.minimum_cost).toFixed(2));
                                                html = html.replace(/{{hourlyrates}}/g, currencies.symbol + provider_commision);
                                                html = html.replace(/{{totalhour}}/g, invoice.worked_hours_human);
                                                html = html.replace(/{{totalamount}}/g, currencies.symbol + invoice.amount.grand_total);
                                                html = html.replace(/{{admincommission}}/g, currencies.symbol + invoice.amount.admin_commission);
                                                html = html.replace(/{{Servicetax}}/g, currencies.symbol + invoice.amount.service_tax);
                                                html = html.replace(/{{total}}/g, currencies.symbol + invoice.amount.total);
                                                html = html.replace(/{{actualamount}}/g, actualamountsymbol);
                                                html = html.replace(/{{materialfee}}/g, currencies.symbol + MaterialFee);
                                                html = html.replace(/{{datetime}}/g, datetime);
                                                html = html.replace(/{{bookingdata}}/g, BookingDate);
                                                html = html.replace(/{{site_url}}/g, settingdata.settings.site_url);
                                                html = html.replace(/{{site_title}}/g, settingdata.settings.site_title);
                                                html = html.replace(/{{Site_title}}/g, settingdata.settings.site_title);
                                                var options = { format: 'Letter' };
                                                var pdfname = new Date().getTime();
                                                pdf.create(html, options).toFile('./uploads/invoice/' + pdfname + '.pdf', function (err, document) {

                                                    if (err) {
                                                        callback(err, null);
                                                    } else {

                                                        var mailOptions = {
                                                            from: template[1].sender_email,
                                                            to: settingdata.settings.email_address,
                                                            subject: template[1].email_subject,
                                                            text: "Please Download the attachment to see Your Invoice",
                                                            html: '<b>Please Download the attachment to see Your Invoice</b>',
                                                            attachments: [{
                                                                filename: 'Maidac Admin Invoice.pdf',
                                                                path: './uploads/invoice/' + pdfname + '.pdf',
                                                                contentType: 'application/pdf'
                                                            }],
                                                        };
                                                    }

                                                    mail.send(mailOptions, function (err, response) { });
                                                });
                                                var html2 = template[2].email_content;
                                                html2 = html2.replace(/{{t_username}}/g, task.tasker.name.first_name);
                                                html2 = html2.replace(/{{u_username}}/g, task.user.name.first_name);
                                                html2 = html2.replace(/{{categoryname}}/g, task.category.name);
                                                html2 = html2.replace(/{{bookingid}}/g, task.booking_id);
                                                html2 = html2.replace(/{{logo}}/g, settingdata.settings.site_url + settingdata.settings.logo);
                                                html2 = html2.replace(/{{taskeraddress}}/g, task.tasker.address.line1);
                                                html2 = html2.replace(/{{taskeraddress1}}/g, task.tasker.address.city);
                                                html2 = html2.replace(/{{taskeraddress2}}/g, task.tasker.address.state);
                                                html2 = html2.replace(/{{useraddress}}/g, task.billing_address.line1);
                                                html2 = html2.replace(/{{useraddress1}}/g, task.billing_address.city);
                                                html2 = html2.replace(/{{useraddress2}}/g, task.billing_address.state);
                                                html2 = html2.replace(/{{hourlyrate}}/g, currencies.symbol + (task.invoice.amount.minimum_cost).toFixed(2));
                                                html2 = html2.replace(/{{hourlyrates}}/g, currencies.symbol + provider_commision);
                                                html2 = html2.replace(/{{totalhour}}/g, invoice.worked_hours_human);
                                                html2 = html2.replace(/{{totalamount}}/g, currencies.symbol + invoice.amount.grand_total);
                                                html2 = html2.replace(/{{admincommission}}/g, currencies.symbol + invoice.amount.admin_commission);
                                                html2 = html2.replace(/{{Servicetax}}/g, currencies.symbol + invoice.amount.service_tax);
                                                html2 = html2.replace(/{{total}}/g, currencies.symbol + invoice.amount.total);
                                                html2 = html2.replace(/{{actualamount}}/g, actualamountsymbol);
                                                html2 = html2.replace(/{{materialfee}}/g, currencies.symbol + MaterialFee);
                                                html2 = html2.replace(/{{datetime}}/g, datetime);
                                                html2 = html2.replace(/{{bookingdata}}/g, BookingDate);
                                                html2 = html2.replace(/{{site_url}}/g, settingdata.settings.site_url);
                                                html2 = html2.replace(/{{site_title}}/g, settingdata.settings.site_title);
                                                html2 = html2.replace(/{{Site_title}}/g, settingdata.settings.site_title);
                                                var options = { format: 'Letter' };
                                                var pdfname1 = new Date().getTime();
                                                pdf.create(html2, options).toFile('./uploads/invoice/' + pdfname1 + '.pdf', function (err, document) {

                                                    if (err) {
                                                        callback(err, null);
                                                    } else {

                                                        var mailOptions1 = {
                                                            from: template[2].sender_email,
                                                            to: task.user.email,
                                                            subject: template[2].email_subject,
                                                            text: "Please Download the attachment to see Your Invoice",
                                                            html: '<b>Please Download the attachment to see Your Invoice</b>',
                                                            attachments: [{
                                                                filename: 'Maidac ' + CONFIG.USER + ' Invoice.pdf',
                                                                path: './uploads/invoice/' + pdfname1 + '.pdf',
                                                                contentType: 'application/pdf'
                                                            }],
                                                        };
                                                        mail.send(mailOptions1, function (err, response) { });
                                                    }


                                                });


                                                var html3 = template[0].email_content;
                                                html3 = html3.replace(/{{t_username}}/g, task.tasker.name.first_name);
                                                html3 = html3.replace(/{{u_username}}/g, task.user.name.first_name);
                                                html3 = html3.replace(/{{categoryname}}/g, task.category.name);
                                                html3 = html3.replace(/{{bookingid}}/g, task.booking_id);
                                                html3 = html3.replace(/{{logo}}/g, settingdata.settings.site_url + settingdata.settings.logo);
                                                html3 = html3.replace(/{{taskeraddress}}/g, task.tasker.address.line1);
                                                html3 = html3.replace(/{{taskeraddress1}}/g, task.tasker.address.city);
                                                html3 = html3.replace(/{{taskeraddress2}}/g, task.tasker.address.state);
                                                html3 = html3.replace(/{{useraddress}}/g, task.billing_address.line1);
                                                html3 = html3.replace(/{{useraddress1}}/g, task.billing_address.city);
                                                html3 = html3.replace(/{{useraddress2}}/g, task.billing_address.state);
                                                html3 = html3.replace(/{{hourlyrate}}/g, currencies.symbol + (task.invoice.amount.minimum_cost).toFixed(2));
                                                html3 = html3.replace(/{{hourlyrates}}/g, currencies.symbol + provider_commision);
                                                html3 = html3.replace(/{{totalhour}}/g, invoice.worked_hours_human);
                                                html3 = html3.replace(/{{totalamount}}/g, currencies.symbol + (invoice.amount.grand_total - invoice.amount.service_tax).toFixed(2));
                                                html3 = html3.replace(/{{admincommission}}/g, currencies.symbol + invoice.amount.admin_commission);
                                                html3 = html3.replace(/{{Servicetax}}/g, currencies.symbol + invoice.amount.service_tax);
                                                html3 = html3.replace(/{{total}}/g, currencies.symbol + invoice.amount.total);
                                                html3 = html3.replace(/{{actualamount}}/g, actualamountsymbol);
                                                html3 = html3.replace(/{{materialfee}}/g, currencies.symbol + MaterialFee);
                                                html3 = html3.replace(/{{datetime}}/g, datetime);
                                                html3 = html3.replace(/{{bookingdata}}/g, BookingDate);
                                                html3 = html3.replace(/{{site_url}}/g, settingdata.settings.site_url);
                                                html3 = html3.replace(/{{site_title}}/g, settingdata.settings.site_title);
                                                html3 = html3.replace(/{{Site_title}}/g, settingdata.settings.site_title);

                                                var options = { format: 'Letter' };
                                                var pdfname2 = new Date().getTime();
                                                pdf.create(html3, options).toFile('./uploads/invoice/' + pdfname2 + '.pdf', function (err, document) {

                                                    if (err) {
                                                        callback(err, null);
                                                    } else {

                                                        var mailOptions2 = {
                                                            from: template[0].sender_email,
                                                            to: task.tasker.email,
                                                            subject: template[0].email_subject,
                                                            text: "Please Download the attachment to see Your Invoice",
                                                            html: '<b>Please Download the attachment to see Your Invoice</b>',
                                                            attachments: [{
                                                                filename: 'Maidac ' + CONFIG.TASKER + ' Invoice.pdf',
                                                                path: './uploads/invoice/' + pdfname2 + '.pdf',
                                                                contentType: 'application/pdf'
                                                            }],
                                                        };
                                                    }

                                                    mail.send(mailOptions2, function (err, response) { });
                                                });



                                                var html4 = template[3].email_content;
                                                html4 = html4.replace(/{{booking_id}}/g, task.booking_id || "");
                                                html4 = html4.replace(/{{Task}}/g, task.category.name || "");
                                                html4 = html4.replace(/{{taskername}}/g, task.tasker.username || "");
                                                html4 = html4.replace(/{{site_url}}/g, settingdata.settings.site_url || "");
                                                html4 = html4.replace(/{{site_title}}/g, settingdata.settings.site_title || "");
                                                html4 = html4.replace(/{{senderemail}}/g, template[3].sender_email);
                                                html4 = html4.replace(/{{logo}}/g, settingdata.settings.site_url + settingdata.settings.logo);
                                                var options = { format: 'Letter' };
                                                var pdfname3 = new Date().getTime();
                                                pdf.create(html4, options).toFile('./uploads/invoice/' + pdfname3 + '.pdf', function (err, document) {

                                                    if (err) {
                                                        callback(err, null);
                                                    } else {

                                                        var mailOptions3 = {
                                                            from: template[3].sender_email,
                                                            to: task.tasker.email,
                                                            subject: template[3].email_subject,
                                                            text: "Please Download the attachment to see Your Invoice",
                                                            html: '<b>Please Download the attachment to see Your Invoice</b>',
                                                            attachments: [{
                                                                filename: 'taskcompleted.pdf',
                                                                path: './uploads/invoice/' + pdfname3 + '.pdf',
                                                                contentType: 'application/pdf'
                                                            }],
                                                        };
                                                    }

                                                    mail.send(mailOptions3, function (err, response) { });
                                                });

                                                var html5 = template[4].email_content;
                                                html5 = html5.replace(/{{booking_id}}/g, task.booking_id || "");
                                                html5 = html5.replace(/{{Task}}/g, task.category.name || "");
                                                html5 = html5.replace(/{{username}}/g, task.user.username || "");
                                                html5 = html5.replace(/{{site_url}}/g, settingdata.settings.site_url || "");
                                                html5 = html5.replace(/{{site_title}}/g, settingdata.settings.site_title || "");
                                                html5 = html5.replace(/{{senderemail}}/g, template[4].sender_email);
                                                html5 = html5.replace(/{{logo}}/g, settingdata.settings.site_url + settingdata.settings.logo);
                                                var options = { format: 'Letter' };
                                                var pdfname4 = new Date().getTime();
                                                pdf.create(html5, options).toFile('./uploads/invoice/' + pdfname4 + '.pdf', function (err, document) {

                                                    if (err) {
                                                        callback(err, null);
                                                    } else {

                                                        var mailOptions4 = {
                                                            from: template[4].sender_email,
                                                            to: task.user.email,
                                                            subject: template[4].email_subject,
                                                            text: "Please Download the attachment to see Your Invoice",
                                                            html: '<b>Please Download the attachment to see Your Invoice</b>',
                                                            attachments: [{
                                                                filename: 'Taskcompleted' + CONFIG.USER + '.pdf',
                                                                path: './uploads/invoice/' + pdfname4 + '.pdf',
                                                                contentType: 'application/pdf'
                                                            }],
                                                        };
                                                    }

                                                    mail.send(mailOptions4, function (err, response) { });
                                                });

                                                // var mailData = {};
                                                // mailData.template = 'Invoicetoadmin';
                                                // mailData.to = settingdata.settings.email_address;
                                                // mailData.html = [];
                                                // mailData.html.push({ name: 't_username', value: task.tasker.name.first_name + "(" + task.tasker.username + ")" });
                                                // mailData.html.push({ name: 'u_username', value: task.user.name.first_name + "(" + task.user.username + ")" });
                                                // mailData.html.push({ name: 'categoryname', value: task.category.name });
                                                // mailData.html.push({ name: 'bookingid', value: task.booking_id });
                                                // mailData.html.push({ name: 'logo', value: settingdata.settings.logo });
                                                // mailData.html.push({ name: 'taskeraddress', value: task.tasker.address.line1 });
                                                // mailData.html.push({ name: 'taskeraddress1', value: task.tasker.address.line2 });
                                                // mailData.html.push({ name: 'taskeraddress2', value: task.tasker.address.city });
                                                // mailData.html.push({ name: 'useraddress', value: task.billing_address.line1 });
                                                // mailData.html.push({ name: 'useraddress1', value: task.billing_address.line2 });
                                                // mailData.html.push({ name: 'useraddress2', value: task.billing_address.city });
                                                // mailData.html.push({ name: 'hourlyrates', value: currencies.symbol + provider_commision });
                                                // mailData.html.push({ name: 'totalhour', value: invoice.worked_hours_human });
                                                // mailData.html.push({ name: 'totalamount', value: currencies.symbol + invoice.amount.grand_total });
                                                // mailData.html.push({ name: 'admincommission', value: currencies.symbol + invoice.amount.admin_commission });
                                                // mailData.html.push({ name: 'Servicetax', value: currencies.symbol + invoice.amount.service_tax.toFixed(2) });
                                                // mailData.html.push({ name: 'total', value: currencies.symbol + invoice.amount.total });
                                                // mailData.html.push({ name: 'actualamount', value: actualamountsymbol });
                                                // mailData.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
                                                // mailData.html.push({ name: 'datetime', value: datetime });
                                                // mailData.html.push({ name: 'bookingdata', value: BookingDate });
                                                // mailData.html.push({ name: 'site_url', value: settingdata.settings.site_url });
                                                // mailcontent.sendmail(mailData, function (err, response) { });

                                                // var booking_date = timezone.tz(task.history.booking_date, settingdata.settings.time_zone).format(settingdata.settings.date_format);
                                                // var booking_time = timezone.tz(task.history.booking_date, settingdata.settings.time_zone).format(settingdata.settings.time_format);

                                                // var mailData1 = {};
                                                // mailData1.template = 'Invoicetouser';
                                                // mailData1.to = task.user.email;
                                                // mailData1.html = [];
                                                // mailData1.html.push({ name: 't_username', value: task.tasker.name.first_name + "(" + task.tasker.username + ")" });
                                                // mailData1.html.push({ name: 'u_username', value: task.user.name.first_name + "(" + task.user.username + ")" });
                                                // mailData1.html.push({ name: 'categoryname', value: task.category.name });
                                                // mailData1.html.push({ name: 'bookingid', value: task.booking_id });
                                                // mailData1.html.push({ name: 'logo', value: settingdata.settings.logo });
                                                // mailData1.html.push({ name: 'taskeraddress', value: task.tasker.address.line1 });
                                                // mailData1.html.push({ name: 'taskeraddress1', value: task.tasker.address.line2 });
                                                // mailData1.html.push({ name: 'taskeraddress2', value: task.tasker.address.city });
                                                // mailData1.html.push({ name: 'useraddress', value: task.billing_address.line1 });
                                                // mailData1.html.push({ name: 'useraddress1', value: task.billing_address.line2 });
                                                // mailData1.html.push({ name: 'useraddress2', value: task.billing_address.city });
                                                // mailData1.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
                                                // mailData1.html.push({ name: 'datetime', value: datetime });
                                                // mailData1.html.push({ name: 'bookingdata', value: BookingDate });
                                                // mailData1.html.push({ name: 'hourlyrate', value: task.hourly_rate });
                                                // mailData1.html.push({ name: 'hourlyrates', value: currencies.symbol + provider_commision });
                                                // mailData1.html.push({ name: 'totalhour', value: invoice.worked_hours_human });
                                                // mailData1.html.push({ name: 'totalamount', value: currencies.symbol + invoice.amount.grand_total });
                                                // mailData1.html.push({ name: 'Servicetax', value: currencies.symbol + invoice.amount.service_tax.toFixed(2) });
                                                // mailData1.html.push({ name: 'total', value: currencies.symbol + invoice.amount.total });
                                                // mailData1.html.push({ name: 'actualamount', value: actualamountsymbol });
                                                // mailcontent.sendmail(mailData1, function (err, response) { });

                                                // var mailData2 = {};
                                                // mailData2.template = 'Invoice';
                                                // mailData2.to = task.tasker.email;
                                                // mailData2.html = [];

                                                // mailData2.html.push({ name: 't_username', value: task.tasker.name.first_name + "(" + task.tasker.username + ")" });
                                                // mailData2.html.push({ name: 'u_username', value: task.user.name.first_name + "(" + task.user.username + ")" });
                                                // mailData2.html.push({ name: 'categoryname', value: task.category.name });
                                                // mailData2.html.push({ name: 'bookingid', value: task.booking_id });
                                                // mailData2.html.push({ name: 'logo', value: settingdata.settings.logo });
                                                // mailData2.html.push({ name: 'taskeraddress', value: task.tasker.address.line1 });
                                                // mailData2.html.push({ name: 'taskeraddress1', value: task.tasker.address.line2 });
                                                // mailData2.html.push({ name: 'taskeraddress2', value: task.tasker.address.city });
                                                // mailData2.html.push({ name: 'useraddress', value: task.billing_address.line1 });
                                                // mailData2.html.push({ name: 'useraddress1', value: task.billing_address.line2 });
                                                // mailData2.html.push({ name: 'useraddress2', value: task.billing_address.city });
                                                // mailData2.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
                                                // mailData2.html.push({ name: 'datetime', value: datetime });
                                                // mailData2.html.push({ name: 'bookingdata', value: BookingDate });
                                                // mailData2.html.push({ name: 'hourlyrate', value: task.hourly_rate });
                                                // mailData2.html.push({ name: 'hourlyrates', value: currencies.symbol + provider_commision });
                                                // mailData2.html.push({ name: 'totalhour', value: invoice.worked_hours });
                                                // mailData2.html.push({ name: 'totalamount', value: currencies.symbol + invoice.amount.grand_total });
                                                // mailData2.html.push({ name: 'admincommission', value: currencies.symbol + invoice.amount.admin_commission });
                                                // mailData2.html.push({ name: 'actualamount', value: currencies.symbol + (((invoice.amount.grand_total - invoice.amount.admin_commission) - invoice.amount.service_tax)).toFixed(2) });
                                                // mailData2.html.push({ name: 'total', value: currencies.symbol + invoice.amount.total });
                                                // mailcontent.sendmail(mailData2, function (err, response) { });


                                                // var mailData3 = {};
                                                // mailData3.template = 'Taskcompleted';
                                                // mailData3.to = task.tasker.email;
                                                // mailData3.html = [];
                                                // mailData3.html.push({ name: 'booking_id', value: task.booking_id || "" });
                                                // mailData3.html.push({ name: 'Task', value: task.category.name || "" });
                                                // mailData3.html.push({ name: 'taskername', value: task.tasker.username || "" });
                                                // mailData3.html.push({ name: 'site_url', value: settingdata.settings.site_url || "" });
                                                // mailData3.html.push({ name: 'site_title', value: settingdata.settings.site_title || "" });
                                                // mailData3.html.push({ name: 'logo', value: settingdata.settings.logo || "" });
                                                // mailcontent.sendmail(mailData3, function (err, response) { });

                                                // var mailData4 = {};
                                                // mailData4.template = 'Taskcompleteduser';
                                                // mailData4.to = task.user.email;
                                                // mailData4.html = [];
                                                // mailData4.html.push({ name: 'booking_id', value: task.booking_id || "" });
                                                // mailData4.html.push({ name: 'Task', value: task.category.name || "" });
                                                // mailData4.html.push({ name: 'username', value: task.user.username || "" });
                                                // mailData4.html.push({ name: 'site_url', value: settingdata.settings.site_url || "" });
                                                // mailData4.html.push({ name: 'site_title', value: settingdata.settings.site_title || "" });
                                                // mailData4.html.push({ name: 'logo', value: settingdata.settings.logo || "" });
                                                // mailcontent.sendmail(mailData4, function (err, response) { });


                                                var notifications = { 'job_id': task.booking_id, 'user_id': task.user._id };
                                                var message = CONFIG.NOTIFICATION.YOUR_JOB_HAS_BEEN_COMPLETED;
                                                push.sendPushnotification(task.user._id, message, 'job_completed', 'ANDROID', notifications, 'USER', function (err, response, body) { });

                                                /* Response Manipulation*/
                                                task.currency = currencies;
                                                task.settings = settingdata.settings;
                                                /* /Response Manipulation*/

                                                callback(err, task);
                                            }
                                        });
                                    }
                                });
                            }
                        }
                        );
                    }
                });
            }
        });
    }

    function taskExpired(data, callback) {
        db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
            if (err || !settings) {
                callback(err, settings);
            } else {
                //var dateTimeNow = timezone.tz(new Date(), settings.settings.time_zone).toISOString();
                var dateTimeNow = timezone.tz(moment().subtract(1, "days"), settings.settings.time_zone).toISOString();
                //console.log(dateTimeNow);
                //console.log(dateTimeNow1);
                db.UpdateDocument('task', { 'status': 1, 'booking_information.booking_date': { $lt: new Date(dateTimeNow) } }, { 'status': 11 }, { multi: true }, function (err, docdata) {
                    callback(err, docdata);
                });
            }
        });
    }

    return {
        taskPayment: taskPayment,
        completeTask: completeTask,
        taskExpired: taskExpired
    };
};
