module.exports = function (io) {

	var bcrypt = require('bcrypt-nodejs');
	var db = require('../../controller/adaptor/mongodb.js')
	var attachment = require('../../model/attachments.js');
	var middlewares = require('../../model/middlewares.js');
	var mail = require('../../model/mail.js');
	var mailcontent = require('../../model/mailcontent.js');
	var async = require('async');
	var request = require('request');
	var mongoose = require('mongoose');
	var objectID = require('mongodb').ObjectID;
	var stripe = require('stripe')('');
	var twilio = require('../../model/twilio.js');
	var library = require('../../model/library.js');
	var paypal = require('paypal-rest-sdk');
	var CONFIG = require('../../config/config');
	var moment = require("moment");
	var pdf = require('html-pdf');
	var fs = require('fs');
	var pug = require('pug');
	var push = require('../../model/pushNotification.js')(io);
	var timezone = require('moment-timezone');
	var taskerLibrary = require('../../model/tasker.js')(io);
	var taskLibrary = require('../../model/task.js')(io);
	var userLibrary = require('../../model/user.js')(io);
	var util = require('util');

	var controller = {};
	controller.saveAccount = function saveAccount(req, res) {

		var data = {};
		data.address = {};
		data.name = {};
		data.name.first_name = req.body.name.first_name;
		data.name.last_name = req.body.name.last_name;
		data.email = req.body.email;
		data.phone = req.body.phone;
		data.about = req.body.about;
		data.gender = req.body.gender;
		data.address.line1 = req.body.address.line1;
		data.address.line2 = req.body.address.line2;
		data.address.city = req.body.address.city;
		data.address.state = req.body.address.state;
		data.address.country = req.body.address.country;
		data.address.zipcode = req.body.address.zipcode;
		data.avatarBase64 = req.body.avatarBase64;

		// Validation & Sanitization
		req.checkBody('name.first_name', 'Invalid First Name').notEmpty();
		req.checkBody('name.last_name', 'Invalid Last Name').notEmpty();
		req.checkBody('email', 'Invalid Email').notEmpty().withMessage('Email is Required').isEmail();
		req.checkBody('address.line1', 'Invalid Addressline').notEmpty();
		req.checkBody('address.city', 'Invalid city').optional();
		req.checkBody('address.state', 'Invalid state').optional();
		req.checkBody('address.country', 'Invalid country').optional();
		req.checkBody('address.zipcode', 'Invalid Zip Code').optional();
		req.sanitizeBody('name.first_name').trim();
		req.sanitizeBody('name.last_name').trim();
		req.sanitizeBody('email').normalizeEmail();
		req.sanitizeBody('line1').trim();
		req.sanitizeBody('line2').trim();
		req.sanitizeBody('city').trim();
		req.sanitizeBody('state').trim();
		req.sanitizeBody('country').trim();
		req.sanitizeBody('zipcode').trim();

		var errors = req.validationErrors();
		if (errors) {
			res.status(400).send(errors[0]);
			return;
		}

		if (data.avatarBase64) {
			var base64 = data.avatarBase64.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/);
			var fileName = Date.now().toString() + '.png';
			var file = './uploads/images/users/' + fileName;
			library.base64Upload({ file: file, base64: base64[2] }, function (err, response) { });
			data.avatar = 'uploads/images/users/' + fileName;
			data.img_name = fileName;
			data.img_path = 'uploads/images/users/';
		}
		db.UpdateDocument('users', { _id: req.body._id }, data, {}, function (err, result) {
			if (err) {
				res.send(err);
			} else {
				res.send(result);
			}
		});
	}

	controller.saveforgotpasswordinfo = function saveforgotpasswordinfo(req, res) {
		var data = {};
		var request = {};
		request.email = req.body.data;
		request.reset = library.randomString(8, '#A');
		async.waterfall([
			function (callback) {
				db.GetOneDocument('tasker', { 'email': request.email }, {}, {}, function (err, user) {
					callback(err, user);
				});
			},
			function (user, callback) {
				if (user) {
					db.UpdateDocument('tasker', { '_id': user._id }, { 'reset_code': request.reset }, {}, function (err, response) {
						callback(err, user);
					});
				} else {
					callback(null, user);
				}
			},
			function (user, callback) {
				db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
					if (err) { callback(err, callback); }
					else { callback(err, user, settings); }
				});
			}
		], function (err, user, settings) {
			if (err || !user) {
				data.status = '0';
				data.response = 'Errror!';
				res.status(400).send(data);
			} else {
				var name;
				if (user.name) {
					name = user.name.first_name + " (" + user.username + ")";
				} else {
					name = user.username;
				}
				var taskerid = user._id;
				var mailData = {};
				mailData.template = 'Forgotpassword';
				mailData.to = user.email;
				mailData.html = [];
				mailData.html.push({ name: 'name', value: name });
				mailData.html.push({ name: 'email', value: user.email });
				mailData.html.push({ name: 'url', value: settings.settings.site_url + 'forgotpwdtaskermail' + '/' + user._id + '/' + request.reset });
				mailData.html.push({ name: 'site_url', value: settings.settings.site_url });
				mailData.html.push({ name: 'logo', value: settings.settings.logo });
				mailData.html.push({ name: 'site_title', value: settings.settings.site_title });
				mailcontent.sendmail(mailData, function (err, response) { });
				/*
				var to = user.phone.code + user.phone.number;
				var message = 'Dear ' + user.username + '! Here is your verification code to reset your password ' + request.reset;
				console.log('usertaskerrrrrr');
				twilio.createMessage(to, '', message, function (err, response) { });
				*/
				data.status = '1';
				data.response = 'Reset Code Sent Successfully!';
				res.send(data);
			}
		});
	}
	controller.saveforgotpassworduser = function saveforgotpassworduser(req, res) {
		var data = {};
		var request = {};
		request.email = req.body.data;
		request.reset = library.randomString(8, '#A');
		async.waterfall([
			function (callback) {
				db.GetOneDocument('users', { 'email': request.email }, {}, {}, function (err, user) {
					callback(err, user);
				});
			},
			function (user, callback) {
				if (user) {
					db.UpdateDocument('users', { '_id': user._id }, { 'reset_code': request.reset }, {}, function (err, response) {
						callback(err, user);
					});
				} else {
					callback(null, user);
				}
			},
			function (user, callback) {
				db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
					if (err) { callback(err, callback); }
					else { callback(err, user, settings); }
				});
			}
		], function (err, user, settings) {
			if (err || !user) {
				data.status = '0';
				data.response = 'Errror!';
				res.status(400).send(data);
			} else {
				var name;
				if (user.name) {
					name = user.name.first_name + " (" + user.username + ")";
				} else {
					name = user.username;
				}
				var userid = user._id;
				var mailData = {};
				mailData.template = 'Forgotpassword';
				mailData.to = user.email;
				mailData.html = [];
				mailData.html.push({ name: 'name', value: name });
				mailData.html.push({ name: 'site_url', value: settings.settings.site_url });
				mailData.html.push({ name: 'logo', value: settings.settings.logo });
				mailData.html.push({ name: 'email', value: user.email });
				mailData.html.push({ name: 'url', value: settings.settings.site_url + 'forgotpwdusermail' + '/' + user._id + '/' + request.reset });
				mailcontent.sendmail(mailData, function (err, response) { });
				//var to = user.phone.code + user.phone.number;

				/*
				console.log('dfsaf35tregg');
				var message = 'Dear ' + user.username + '! Please check your mail to reset your password ';
				twilio.createMessage(to, '', message, function (err, response) { });
				*/

				data.status = '1';
				data.response = 'Reset Code Sent Successfully!';
				res.send(data);
			}
		});
	}

	controller.saveforgotpwdusermail = function saveforgotpwdusermail(req, res) {
		var id = req.body.data.userid;
		var data = bcrypt.hashSync(req.body.data.formData, bcrypt.genSaltSync(8), null);
		var resetid = req.body.data.resetid;
		db.UpdateDocument('users', { '_id': id, 'reset_code': resetid }, { 'password': data }, {}, function (err, docdata) {
			if (err || docdata.nModified == 0) {
				res.status(400).send(err);
			} else {
				res.send(docdata);
			}
		});
	}

	controller.getuserwallettransaction = function (req, res) {
		var extension = {
			options: {
				limit: req.body.limit,
				skip: req.body.skip
			},
			populate: 'user tasker',
			$sort: { transactions: -1 }
		};
		db.GetDocument('walletReacharge', { 'user_id': new mongoose.Types.ObjectId(req.body.id) }, {}, extension, function (err, response) {

			if (err) {
				res.send(err);
			}
			else {
				var data = [];
				if (response.length) {
					for (var i = 0; i < response[0].transactions.length; i++) {
						var title = '';
						var transacData = {};
						if (response[0].transactions[i].type == 'CREDIT') {
							if (response[0].transactions[i].credit_type == 'welcome') {
								title = 'Welcome Bonus';
							} else if (response[0].transactions[i].credit_type == 'Referral') {
								title = 'Referral reward';
								/*
								if (response[0].transactions[i].ref_id != null) {
									title = 'Wallet Recharge';
								}
								*/
							} else {
								title = 'Wallet Recharge';
							}
						} else if (response[0].transactions[i].type == 'DEBIT') {
							title = 'Payment by wallet';
						} else {
							title = 'Wallet Recharge';
						}

						transacData.type = response[0].transactions[i].type || '';
						transacData.trans_amount = response[0].transactions[i].trans_amount || 0;
						transacData.title = title;
						transacData.trans_date = new Date(response[0].transactions[i].trans_date);

						transacData.balance_amount = response[0].transactions[i].avail_amount;
						data.push(transacData);
					}
				}
				var count = data.length;
				res.send({ count: count, transaction: data });
			}
		});
	}
	controller.saveforgotpwdtaskermail = function saveforgotpwdtaskermail(req, res) {
		var id = req.body.data.userid;
		var data = bcrypt.hashSync(req.body.data.formData, bcrypt.genSaltSync(8), null);
		var resetid = req.body.data.resetid;
		db.UpdateDocument('tasker', { '_id': id, 'reset_code': resetid }, { 'password': data }, {}, function (err, docdata) {
			if (err || docdata.nModified == 0) {
				res.status(400).send(err);
			} else {
				res.send(docdata);
			}
		});
	}
	controller.paybywallet = function paybywallet(req, res) {
		db.GetOneDocument('walletReacharge', { "user_id": req.body.userid }, {}, {}, function (err, wallet) {
			if (err) {
				res.send(err);
			} else {
				if (wallet == "null") {
					res.send({ status: 0, message: 'Recharge Your Wallet' });
				}
				if (wallet) {
					if (wallet.total == 0) {
						res.send({ status: 0, message: 'Recharge Your Wallet' });
					} else if ((wallet.total < req.body.amount) && wallet.total != 0) {
						var wallettotal = {};
						wallettotal.newtotal = wallet.total - wallet.total;
						var walletArr = {
							'type': 'DEBIT',
							'debit_type': 'payment',
							'ref_id': req.body.taskid,
							'trans_amount': parseFloat(wallet.total),
							'avail_amount': parseFloat(wallettotal.newtotal),
							'trans_date': new Date(),
						};
						var balanceamount = {};
						balanceamount = parseFloat(req.body.amount) - parseFloat(wallet.total);
						db.UpdateDocument('walletReacharge', { "user_id": req.body.userid }, { total: wallettotal.newtotal, $push: { transactions: walletArr } }, function (err, docdata) {
							if (err) {
								res.send(err);
							} else {
								db.UpdateDocument('task', { "_id": req.body.taskid }, { "invoice.amount.balance_amount": balanceamount, "payment_type": "wallet-other" }, function (err, docdata) {
									if (err) {
										res.send(err);
									} else {
										var transaction = {
											'user': req.body.userid,
											'tasker': req.body.taskerid,
											'task': req.body.taskid,
											'type': 'wallet-other',
											'amount': wallet.total,
											'task_date': req.body.createdat,
											'status': 1
										};
										db.InsertDocument('transaction', transaction, function (err, transaction) {
											if (err) {
												res.send(err);
											} else {
												var options = {};
												options.populate = 'tasker user category';
												db.GetOneDocument('task', { _id: req.body.taskid }, {}, options, function (err, docdata) {
													if (err) {
														res.send(err);
													} else {
														db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
															if (err) {
																res.send(err);
															} else {

																var notifications = { 'job_id': docdata.booking_id, 'user_id': docdata.tasker._id };
																var message = CONFIG.NOTIFICATION.BILLING_AMOUNT_PARTIALLY_PAID;
																push.sendPushnotification(docdata.tasker._id, message, 'partially_paid', 'ANDROID', notifications, 'PROVIDER', function (err, response, body) { });
																push.sendPushnotification(docdata.user._id, message, 'partially_paid', 'ANDROID', notifications, 'USER', function (err, response, body) { });
																res.send(docdata);

																db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
																	if (err) {
																		res.send(err);
																	} else {

																		var MaterialFee, CouponCode, DateTime, BookingDate;
																		if (docdata.invoice.amount.extra_amount) {
																			MaterialFee = (docdata.invoice.amount.extra_amount).toFixed(2);
																		} else {
																			MaterialFee = '0.00';
																		}
																		if (docdata.invoice.amount.coupon) {
																			CouponCode = currencies.symbol + docdata.invoice.amount.coupon;
																		} else {
																			CouponCode = 'Not assigned';
																		}
																		DateTime = moment(docdata.history.job_started_time).format('DD/MM/YYYY - HH:mm');
																		BookingDate = moment(docdata.history.booking_date).format('DD/MM/YYYY');

																		db.GetDocument('emailtemplate', { name: { $in: ['PartialPaymentToAdmin', 'PartialPaymentToTasker', 'PartialPaymentToUser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
																			if (err) {
																				res.send(err)
																			}
																			else {
																				var html = template[0].email_content;
																				html = html.replace(/{{mode}}/g, docdata.payment_type + "(Partially Paid )");
																				html = html.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
																				html = html.replace(/{{coupon}}/g, CouponCode);
																				html = html.replace(/{{datetime}}/g, DateTime);
																				html = html.replace(/{{bookingdata}}/g, BookingDate);
																				html = html.replace(/{{site_url}}/g, settings.settings.site_url);
																				html = html.replace(/{{site_title}}/g, settings.settings.site_title);
																				html = html.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
																				html = html.replace(/{{t_username}}/g, docdata.tasker.name.first_name);
																				html = html.replace(/{{taskeraddress}}/g, docdata.tasker.address.line1);
																				html = html.replace(/{{taskeraddress1}}/g, docdata.tasker.address.city);
																				html = html.replace(/{{taskeraddress2}}/g, docdata.tasker.address.state);
																				html = html.replace(/{{bookingid}}/g, docdata.booking_id);
																				html = html.replace(/{{u_username}}/g, docdata.user.name.first_name);
																				html = html.replace(/{{useraddress}}/g, docdata.user.address.line1);
																				html = html.replace(/{{useraddress1}}/g, docdata.user.address.city);
																				html = html.replace(/{{useraddress2}}/g, docdata.user.address.state);
																				html = html.replace(/{{categoryname}}/g, docdata.booking_information.work_type);
																				html = html.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (docdata.hourly_rate).toFixed(2));
																				html = html.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.minimum_cost).toFixed(2));
																				html = html.replace(/{{totalhour}}/g, docdata.invoice.worked_hours_human);
																				html = html.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.grand_total).toFixed(2));
																				html = html.replace(/{{total}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.total).toFixed(2));
																				html = html.replace(/{{amount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission).toFixed(2));
																				html = html.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - docdata.invoice.amount.service_tax).toFixed(2));
																				html = html.replace(/{{adminamount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.admin_commission).toFixed(2));
																				html = html.replace(/{{amountpaid}}/g, currencies.symbol + ' ' + (wallet.total).toFixed(2));
																				html = html.replace(/{{balamount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.balance_amount).toFixed(2));
																				html = html.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
																				html = html.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
																				html = html.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + docdata.invoice.amount.service_tax.toFixed(2));
																				var options = { format: 'Letter' };
																				var pdfname = new Date().getTime();
																				console.log("template[0].email_subject", template[0].email_subject);
																				console.log("template[1].email_subject", template[1].email_subject);
																				console.log("template[2].email_subject", template[2].email_subject);
																				pdf.create(html, options).toFile('./uploads/invoice/' + pdfname + '.pdf', function (err, document) {
																					console.log("err, document", err, document);
																					console.log("docdata.admin.email", settings.settings.email_address);
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
																								filename: 'Admin Payment.pdf',
																								path: './uploads/invoice/' + pdfname + '.pdf',
																								contentType: 'application/pdf'
																							}],
																						};
																					}

																					mail.send(mailOptions, function (err, response) { });
																				});

																				var html2 = template[1].email_content;
																				html2 = html2.replace(/{{mode}}/g, docdata.payment_type + "(Partially Paid )");
																				html2 = html2.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
																				html2 = html2.replace(/{{coupon}}/g, CouponCode);
																				html2 = html2.replace(/{{datetime}}/g, DateTime);
																				html2 = html2.replace(/{{bookingdata}}/g, BookingDate);
																				html2 = html2.replace(/{{site_url}}/g, settings.settings.site_url);
																				html2 = html2.replace(/{{site_title}}/g, settings.settings.site_title);
																				html2 = html2.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
																				html2 = html2.replace(/{{t_username}}/g, docdata.tasker.name.first_name);
																				html2 = html2.replace(/{{taskeraddress}}/g, docdata.tasker.address.line1);
																				html2 = html2.replace(/{{taskeraddress1}}/g, docdata.tasker.address.city);
																				html2 = html2.replace(/{{taskeraddress2}}/g, docdata.tasker.address.state);
																				html2 = html2.replace(/{{bookingid}}/g, docdata.booking_id);
																				html2 = html2.replace(/{{u_username}}/g, docdata.user.name.first_name);
																				html2 = html2.replace(/{{useraddress}}/g, docdata.user.address.line1);
																				html2 = html2.replace(/{{useraddress1}}/g, docdata.user.address.city);
																				html2 = html2.replace(/{{useraddress2}}/g, docdata.user.address.state);
																				html2 = html2.replace(/{{categoryname}}/g, docdata.booking_information.work_type);
																				html2 = html2.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (docdata.hourly_rate).toFixed(2));
																				html2 = html2.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.minimum_cost).toFixed(2));
																				html2 = html2.replace(/{{totalhour}}/g, docdata.invoice.worked_hours_human);
																				html2 = html2.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.grand_total - docdata.invoice.amount.service_tax).toFixed(2));
																				html2 = html2.replace(/{{total}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.total).toFixed(2));
																				html2 = html2.replace(/{{amount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission).toFixed(2));
																				html2 = html2.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - docdata.invoice.amount.service_tax).toFixed(2));
																				html2 = html2.replace(/{{admincommission}}/g, currencies.symbol + ' ' + docdata.invoice.amount.admin_commission.toFixed(2));
																				html2 = html2.replace(/{{amountpaid}}/g, currencies.symbol + ' ' + (wallet.total).toFixed(2));
																				html2 = html2.replace(/{{balamount}}/g, currencies.symbol + ' ' + ((docdata.invoice.amount.balance_amount - docdata.invoice.amount.admin_commission) - docdata.invoice.amount.service_tax).toFixed(2));
																				html2 = html2.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
																				html2 = html2.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
																				html2 = html2.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + docdata.invoice.amount.service_tax.toFixed(2));
																				html2 = html2.replace(/{{email}}/g, docdata.user.email);

																				var options = { format: 'Letter' };
																				var pdfname1 = new Date().getTime();
																				pdf.create(html2, options).toFile('./uploads/invoice/' + pdfname1 + '.pdf', function (err, document) {
																					console.log("err, document", err, document);
																					console.log("docdata.tasker.email", docdata.tasker.email);
																					if (err) {
																						res.send(err);
																					} else {

																						var mailOptions1 = {
																							from: template[1].sender_email,
																							to: docdata.tasker.email,
																							subject: template[1].email_subject,
																							text: "Please Download the attachment to see Your Payment",
																							html: '<b>Please Download the attachment to see Your Payment</b>',
																							attachments: [{
																								filename: CONFIG.TASKER + ' partial Payment.pdf',
																								path: './uploads/invoice/' + pdfname1 + '.pdf',
																								contentType: 'application/pdf'
																							}],
																						};
																					}

																					mail.send(mailOptions1, function (err, response) { });
																				});

																				var html3 = template[2].email_content;
																				html3 = html3.replace(/{{mode}}/g, docdata.payment_type + "(Partially Paid )");
																				html3 = html3.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
																				html3 = html3.replace(/{{coupon}}/g, CouponCode);
																				html3 = html3.replace(/{{datetime}}/g, DateTime);
																				html3 = html3.replace(/{{bookingdata}}/g, BookingDate);
																				html3 = html3.replace(/{{site_url}}/g, settings.settings.site_url);
																				html3 = html3.replace(/{{site_title}}/g, settings.settings.site_title);
																				html3 = html3.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
																				html3 = html3.replace(/{{t_username}}/g, docdata.tasker.name.first_name);
																				html3 = html3.replace(/{{taskeraddress}}/g, docdata.tasker.address.line1);
																				html3 = html3.replace(/{{taskeraddress1}}/g, docdata.tasker.address.city);
																				html3 = html3.replace(/{{taskeraddress2}}/g, docdata.tasker.address.state);
																				html3 = html3.replace(/{{bookingid}}/g, docdata.booking_id);
																				html3 = html3.replace(/{{u_username}}/g, docdata.user.name.first_name);
																				html3 = html3.replace(/{{useraddress}}/g, docdata.user.address.line1);
																				html3 = html3.replace(/{{useraddress1}}/g, docdata.user.address.city);
																				html3 = html3.replace(/{{useraddress2}}/g, docdata.user.address.state);
																				html3 = html3.replace(/{{categoryname}}/g, docdata.booking_information.work_type);
																				html3 = html3.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (docdata.hourly_rate).toFixed(2));
																				html3 = html3.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.minimum_cost).toFixed(2));
																				html3 = html3.replace(/{{totalhour}}/g, docdata.invoice.worked_hours_human);
																				html3 = html3.replace(/{{totalamount}}/g, currencies.symbol + ' ' + docdata.invoice.amount.grand_total.toFixed(2));
																				html3 = html3.replace(/{{total}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.total).toFixed(2));
																				html3 = html3.replace(/{{amount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission).toFixed(2));
																				html3 = html3.replace(/{{actualamount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.total - docdata.invoice.amount.grand_total).toFixed(2));
																				html3 = html3.replace(/{{admincommission}}/g, currencies.symbol + ' ' + docdata.invoice.amount.admin_commission.toFixed(2));
																				html3 = html3.replace(/{{amountpaid}}/g, currencies.symbol + ' ' + (wallet.total).toFixed(2));
																				html3 = html3.replace(/{{balamount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.balance_amount).toFixed(2));
																				html3 = html3.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
																				html3 = html3.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
																				html3 = html3.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + docdata.invoice.amount.service_tax.toFixed(2));
																				html3 = html3.replace(/{{email}}/g, docdata.user.email);
																				var options = { format: 'Letter' };
																				var pdfname2 = new Date().getTime();
																				pdf.create(html3, options).toFile('./uploads/invoice/' + pdfname2 + '.pdf', function (err, document) {
																					console.log("err, document", err, document)
																					console.log("docdata.user.email", docdata.user.email);
																					if (err) {
																						res.send(err);
																					} else {

																						var mailOptions2 = {
																							from: template[2].sender_email,
																							to: docdata.user.email,
																							subject: template[2].email_subject,
																							text: "Please Download the attachment to see Your Payment",
																							html: '<b>Please Download the attachment to see Your Payment</b>',
																							attachments: [{
																								filename: CONFIG.USER + ' Partial Payment.pdf',
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
																				// mailData.html.push({ name: 'mode', value: docdata.payment_type + "(Partial Paid)" });
																				// mailData.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
																				// mailData.html.push({ name: 'coupon', value: CouponCode });
																				// mailData.html.push({ name: 'datetime', value: DateTime });
																				// mailData.html.push({ name: 'bookingdata', value: BookingDate });
																				// mailData.html.push({ name: 'site_url', value: settings.settings.site_url });
																				// mailData.html.push({ name: 'site_title', value: settings.settings.site_title });
																				// mailData.html.push({ name: 'logo', value: settings.settings.logo });
																				// mailData.html.push({ name: 't_username', value: docdata.tasker.name.first_name + "(" + docdata.tasker.username + ")" });
																				// mailData.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
																				// mailData.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
																				// mailData.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
																				// mailData.html.push({ name: 'bookingid', value: docdata.booking_id });
																				// mailData.html.push({ name: 'u_username', value: docdata.user.name.first_name + "(" + docdata.user.username + ")" });
																				// mailData.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
																				// mailData.html.push({ name: 'useraddress1', value: docdata.user.address.city });
																				// mailData.html.push({ name: 'useraddress2', value: docdata.user.address.state });
																				// mailData.html.push({ name: 'categoryname', value: docdata.booking_information.work_type });
																				// mailData.html.push({ name: 'hourlyrates', value: currencies.symbol + (docdata.hourly_rate).toFixed(2) });
																				// mailData.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
																				// mailData.html.push({ name: 'totalamount', value: currencies.symbol + (docdata.invoice.amount.grand_total).toFixed(2) });
																				// mailData.html.push({ name: 'total', value: currencies.symbol + (docdata.invoice.amount.total).toFixed(2) });
																				// mailData.html.push({ name: 'amount', value: currencies.symbol + (docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission).toFixed(2) });
																				// mailData.html.push({ name: 'actualamount', value: currencies.symbol + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2) });
																				// mailData.html.push({ name: 'adminamount', value: currencies.symbol + (docdata.invoice.amount.admin_commission).toFixed(2) });
																				// mailData.html.push({ name: 'amountpaid', value: currencies.symbol + (wallet.total).toFixed(2) });
																				// mailData.html.push({ name: 'balamount', value: currencies.symbol + (docdata.invoice.amount.balance_amount).toFixed(2) });
																				// mailData.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
																				// mailData.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
																				// mailData.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
																				// mailcontent.sendmail(mailData, function (err, response) { });

																				// var mailData2 = {};
																				// mailData2.template = 'PartialPaymentToTasker';
																				// mailData2.to = docdata.tasker.email;
																				// mailData2.html = [];
																				// mailData2.html.push({ name: 'mode', value: docdata.payment_type + "(Partial Paid)" });
																				// mailData2.html.push({ name: 'coupon', value: CouponCode });
																				// mailData2.html.push({ name: 'bookingdata', value: BookingDate });
																				// mailData2.html.push({ name: 'datetime', value: DateTime });
																				// mailData2.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
																				// mailData2.html.push({ name: 'site_url', value: settings.settings.site_url });
																				// mailData2.html.push({ name: 'site_title', value: settings.settings.site_title });
																				// mailData2.html.push({ name: 'logo', value: settings.settings.logo });
																				// mailData2.html.push({ name: 't_username', value: docdata.tasker.name.first_name + "(" + docdata.tasker.username + ")" });
																				// mailData2.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
																				// mailData2.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
																				// mailData2.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
																				// mailData2.html.push({ name: 'bookingid', value: docdata.booking_id });
																				// mailData2.html.push({ name: 'u_username', value: docdata.user.name.first_name + "(" + docdata.user.username + ")" });
																				// mailData2.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
																				// mailData2.html.push({ name: 'useraddress1', value: docdata.user.address.city });
																				// mailData2.html.push({ name: 'useraddress2', value: docdata.user.address.state });
																				// mailData2.html.push({ name: 'categoryname', value: docdata.booking_information.work_type });
																				// mailData2.html.push({ name: 'hourlyrates', value: currencies.symbol + docdata.hourly_rate });
																				// mailData2.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
																				// mailData2.html.push({ name: 'totalamount', value: currencies.symbol + (docdata.invoice.amount.grand_total).toFixed(2) });
																				// mailData2.html.push({ name: 'total', value: currencies.symbol + (docdata.invoice.amount.total).toFixed(2) });
																				// mailData2.html.push({ name: 'actualamount', value: currencies.symbol + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2) });
																				// mailData2.html.push({ name: 'amountpaid', value: currencies.symbol + (wallet.total).toFixed(2) });
																				// mailData2.html.push({ name: 'balamount', value: currencies.symbol + (docdata.invoice.amount.balance_amount).toFixed(2) });
																				// mailData2.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
																				// mailData2.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
																				// mailData2.html.push({ name: 'admincommission', value: currencies.symbol + docdata.invoice.amount.admin_commission.toFixed(2) });
																				// mailData2.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
																				// mailData2.html.push({ name: 'email', value: req.body.email });
																				// mailcontent.sendmail(mailData2, function (err, response) { });
																				// var mailData3 = {};
																				// mailData3.template = 'PartialPaymentToUser';
																				// mailData3.to = docdata.user.email;
																				// mailData3.html = [];
																				// mailData3.html.push({ name: 'mode', value: docdata.payment_type + "(Partial Paid)" });
																				// mailData3.html.push({ name: 'datetime', value: DateTime });
																				// mailData3.html.push({ name: 'bookingdata', value: BookingDate });
																				// mailData3.html.push({ name: 'coupon', value: CouponCode });
																				// mailData3.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
																				// mailData3.html.push({ name: 'site_url', value: settings.settings.site_url });
																				// mailData3.html.push({ name: 'site_title', value: settings.settings.site_title });
																				// mailData3.html.push({ name: 'logo', value: settings.settings.logo });
																				// mailData3.html.push({ name: 't_username', value: docdata.tasker.name.first_name + "(" + docdata.tasker.username + ")" });
																				// mailData3.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
																				// mailData3.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
																				// mailData3.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
																				// mailData3.html.push({ name: 'bookingid', value: docdata.booking_id });
																				// mailData3.html.push({ name: 'u_username', value: docdata.user.name.first_name + "(" + docdata.user.username + ")" });
																				// mailData3.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
																				// mailData3.html.push({ name: 'useraddress1', value: docdata.user.address.city });
																				// mailData3.html.push({ name: 'useraddress2', value: docdata.user.address.state });
																				// mailData3.html.push({ name: 'categoryname', value: docdata.booking_information.work_type });
																				// mailData3.html.push({ name: 'hourlyrates', value: currencies.symbol + docdata.hourly_rate });
																				// mailData3.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
																				// mailData3.html.push({ name: 'totalamount', value: currencies.symbol + docdata.invoice.amount.grand_total.toFixed(2) });
																				// mailData3.html.push({ name: 'total', value: currencies.symbol + docdata.invoice.amount.total.toFixed(2) });
																				// mailData3.html.push({ name: 'actualamount', value: currencies.symbol + (docdata.invoice.amount.total - docdata.invoice.amount.grand_total).toFixed(2) });
																				// mailData3.html.push({ name: 'admincommission', value: currencies.symbol + docdata.invoice.amount.admin_commission.toFixed(2) });
																				// mailData3.html.push({ name: 'amountpaid', value: currencies.symbol + (wallet.total).toFixed(2) });
																				// mailData3.html.push({ name: 'balamount', value: currencies.symbol + (docdata.invoice.amount.balance_amount).toFixed(2) });
																				// mailData3.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
																				// mailData3.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
																				// mailData3.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
																				// mailData3.html.push({ name: 'email', value: req.body.email });
																				// mailcontent.sendmail(mailData3, function (err, response) { });
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
						});
					} else {
						var wallettotal = {};
						wallettotal.newtotal = wallet.total - req.body.amount;
						var walletArr = {
							'type': 'DEBIT',
							'debit_type': 'payment',
							'ref_id': req.body.taskid,
							'trans_amount': parseFloat(req.body.amount),
							'avail_amount': parseFloat(wallettotal.newtotal),
							'trans_date': new Date(),
						};
						db.UpdateDocument('walletReacharge', { "user_id": req.body.userid }, { total: wallettotal.newtotal, $push: { transactions: walletArr } }, function (err, docdata) {
							if (err) {
								res.send(err);
							} else {
								db.GetOneDocument('task', { "_id": req.body.taskid }, {}, {}, function (err, task) {
									if (err) {
										res.send(err);
									} else {
										var balanceamount = {};
										balanceamount = parseFloat(task.invoice.amount.balance_amount) - parseFloat(req.body.amount);
										var paymenttype = {};
										if (task.payment_type == 'wallet-other') {
											paymenttype = 'wallet-wallet';
										}
										else {
											paymenttype = 'wallet';
										}
										db.UpdateDocument('task', { "_id": req.body.taskid }, { "invoice.status": "1", "status": "7", "payment_type": paymenttype, "invoice.amount.balance_amount": balanceamount, 'history.job_closed_time': new Date() }, function (err, docdata) {
											if (err) {
												res.send(err);
											} else {
												var transaction = {
													'user': req.body.userid,
													'tasker': req.body.taskerid,
													'task': req.body.taskid,
													'type': 'wallet-payment',
													'amount': req.body.amount,
													'task_date': req.body.createdat,
													'status': 1
												};
												db.InsertDocument('transaction', transaction, function (err, transaction) {
													if (err) {
														res.send(err);
													} else {
														var options = {};
														options.populate = 'tasker user category';
														db.GetOneDocument('task', { _id: req.body.taskid }, {}, options, function (err, docdata) {
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
																				if (docdata.invoice.amount.extra_amount) {
																					MaterialFee = (docdata.invoice.amount.extra_amount).toFixed(2);
																				} else {
																					MaterialFee = '0.00';
																				}
																				if (docdata.invoice.amount.coupon) {
																					CouponCode = currencies.symbol + docdata.invoice.amount.coupon;
																				} else {
																					CouponCode = 'Not assigned';
																				}
																				DateTime = moment(docdata.history.job_started_time).format('DD/MM/YYYY - HH:mm');
																				BookingDate = moment(docdata.history.booking_date).format('DD/MM/YYYY');

																				db.GetDocument('emailtemplate', { name: { $in: ['PaymentDetailstoAdmin', 'PaymentDetailstoTasker', 'PaymentDetailstoUser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
																					if (err) {
																						res.send(data);
																					}
																					else {
																						console.log("PaymentDetailstoAdmin cccc");
																						var html = template[0].email_content;
																						html = html.replace(/{{mode}}/g, docdata.payment_type);
																						html = html.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
																						html = html.replace(/{{coupon}}/g, CouponCode);
																						html = html.replace(/{{datetime}}/g, DateTime);
																						html = html.replace(/{{bookingdata}}/g, BookingDate);
																						html = html.replace(/{{site_url}}/g, settings.settings.site_url);
																						html = html.replace(/{{site_title}}/g, settings.settings.site_title);
																						html = html.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
																						html = html.replace(/{{t_username}}/g, docdata.tasker.name.first_name);
																						html = html.replace(/{{taskeraddress}}/g, docdata.tasker.address.line1);
																						html = html.replace(/{{taskeraddress1}}/g, docdata.tasker.address.city);
																						html = html.replace(/{{taskeraddress2}}/g, docdata.tasker.address.state);
																						html = html.replace(/{{bookingid}}/g, docdata.booking_id);
																						html = html.replace(/{{u_username}}/g, docdata.user.name.first_name);
																						html = html.replace(/{{useraddress}}/g, docdata.user.address.line1);
																						html = html.replace(/{{useraddress1}}/g, docdata.user.address.city);
																						html = html.replace(/{{useraddress2}}/g, docdata.user.address.state);
																						html = html.replace(/{{categoryname}}/g, docdata.booking_information.work_type);
																						html = html.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.minimum_cost).toFixed(2));
																						html = html.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (docdata.hourly_rate).toFixed(2));
																						html = html.replace(/{{totalhour}}/g, docdata.invoice.worked_hours_human);
																						html = html.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.grand_total).toFixed(2));
																						html = html.replace(/{{total}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.total).toFixed(2));
																						html = html.replace(/{{amount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission).toFixed(2));
																						html = html.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - docdata.invoice.amount.service_tax).toFixed(2));
																						html = html.replace(/{{adminamount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.admin_commission).toFixed(2));
																						html = html.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
																						html = html.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
																						html = html.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + docdata.invoice.amount.service_tax.toFixed(2));
																						var options = { format: 'Letter' };
																						var pdfname = new Date().getTime();
																						console.log("template[0].email_subject fff ", template[0].email_subject);
																						console.log("template[1].email_subject ff", template[1].email_subject);
																						console.log("template[2].email_subject ff", template[2].email_subject);
																						pdf.create(html, options).toFile('./uploads/invoice/' + pdfname + '.pdf', function (err, document) {
																							console.log("err, document", err, document);
																							console.log("docdata.admin.email", settings.settings.email_address);
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
																										filename: 'Admin Payment Details.pdf',
																										path: './uploads/invoice/' + pdfname + '.pdf',
																										contentType: 'application/pdf'
																									}],
																								};
																							}

																							mail.send(mailOptions, function (err, response) { });
																						});
																						console.log("PaymentDetailstoAdmin vbvbvb");
																						var html2 = template[1].email_content;
																						html2 = html2.replace(/{{mode}}/g, docdata.payment_type);
																						html2 = html2.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
																						html2 = html2.replace(/{{coupon}}/g, CouponCode);
																						html2 = html2.replace(/{{datetime}}/g, DateTime);
																						html2 = html2.replace(/{{bookingdata}}/g, BookingDate);
																						html2 = html2.replace(/{{site_url}}/g, settings.settings.site_url);
																						html2 = html2.replace(/{{site_title}}/g, settings.settings.site_title);
																						html2 = html2.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
																						html2 = html2.replace(/{{t_username}}/g, docdata.tasker.name.first_name);
																						html2 = html2.replace(/{{taskeraddress}}/g, docdata.tasker.address.line1);
																						html2 = html2.replace(/{{taskeraddress1}}/g, docdata.tasker.address.city);
																						html2 = html2.replace(/{{taskeraddress2}}/g, docdata.tasker.address.state);
																						html2 = html2.replace(/{{bookingid}}/g, docdata.booking_id);
																						html2 = html2.replace(/{{u_username}}/g, docdata.user.name.first_name);
																						html2 = html2.replace(/{{useraddress}}/g, docdata.user.address.line1);
																						html2 = html2.replace(/{{useraddress1}}/g, docdata.user.address.city);
																						html2 = html2.replace(/{{useraddress2}}/g, docdata.user.address.state);
																						html2 = html2.replace(/{{categoryname}}/g, docdata.booking_information.work_type);
																						html2 = html2.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.minimum_cost).toFixed(2));
																						html2 = html2.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (docdata.hourly_rate).toFixed(2));
																						html2 = html2.replace(/{{totalhour}}/g, docdata.invoice.worked_hours_human);
																						html2 = html2.replace(/{{totalamount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.grand_total - docdata.invoice.amount.service_tax).toFixed(2));
																						html2 = html2.replace(/{{total}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.total).toFixed(2));
																						html2 = html2.replace(/{{amount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission).toFixed(2));
																						html2 = html2.replace(/{{actualamount}}/g, currencies.symbol + ' ' + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - docdata.invoice.amount.service_tax).toFixed(2));
																						html2 = html2.replace(/{{admincommission}}/g, currencies.symbol + ' ' + docdata.invoice.amount.admin_commission.toFixed(2));
																						html2 = html2.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
																						html2 = html2.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
																						html2 = html2.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + docdata.invoice.amount.service_tax.toFixed(2));
																						var options = { format: 'Letter' };
																						var pdfname1 = new Date().getTime();
																						pdf.create(html2, options).toFile('./uploads/invoice/' + pdfname1 + '.pdf', function (err, document) {
																							console.log("err, document", err, document);
																							console.log("docdata.admin.docdata.user.tasker", docdata.tasker.email);
																							if (err) {
																								res.send(err);
																							} else {

																								var mailOptions1 = {
																									from: template[1].sender_email,
																									to: docdata.tasker.email,
																									subject: template[1].email_subject,
																									text: "Please Download the attachment to see Your Payment",
																									html: '<b>Please Download the attachment to see Your Payment</b>',
																									attachments: [{
																										filename: CONFIG.TASKER + ' Payment Details.pdf',
																										path: './uploads/invoice/' + pdfname1 + '.pdf',
																										contentType: 'application/pdf'
																									}],
																								};
																							}

																							mail.send(mailOptions1, function (err, response) { });
																						});
																						console.log("PaymentDetailstoAdmin fgfgfg");

																						var html3 = template[2].email_content;
																						html3 = html3.replace(/{{mode}}/g, docdata.payment_type);
																						html3 = html3.replace(/{{materialfee}}/g, currencies.symbol + ' ' + MaterialFee);
																						html3 = html3.replace(/{{coupon}}/g, CouponCode);
																						html3 = html3.replace(/{{datetime}}/g, DateTime);
																						html3 = html3.replace(/{{bookingdata}}/g, BookingDate);
																						html3 = html3.replace(/{{site_url}}/g, settings.settings.site_url);
																						html3 = html3.replace(/{{logo}}/g, settings.settings.site_url + settings.settings.logo);
																						html3 = html3.replace(/{{site_title}}/g, settings.settings.site_title);
																						html3 = html3.replace(/{{t_username}}/g, docdata.tasker.name.first_name);
																						html3 = html3.replace(/{{taskeraddress}}/g, docdata.tasker.address.line1);
																						html3 = html3.replace(/{{taskeraddress1}}/g, docdata.tasker.address.city);
																						html3 = html3.replace(/{{taskeraddress2}}/g, docdata.tasker.address.state);
																						html3 = html3.replace(/{{bookingid}}/g, docdata.booking_id);
																						html3 = html3.replace(/{{u_username}}/g, docdata.user.name.first_name);
																						html3 = html3.replace(/{{useraddress}}/g, docdata.user.address.line1);
																						html3 = html3.replace(/{{useraddress1}}/g, docdata.user.address.city);
																						html3 = html3.replace(/{{useraddress2}}/g, docdata.user.address.state);
																						html3 = html3.replace(/{{categoryname}}/g, docdata.booking_information.work_type);
																						html3 = html3.replace(/{{hourlyrate}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.minimum_cost).toFixed(2));
																						html3 = html3.replace(/{{hourlyrates}}/g, currencies.symbol + ' ' + (docdata.hourly_rate).toFixed(2));
																						html3 = html3.replace(/{{totalhour}}/g, docdata.invoice.worked_hours_human);
																						html3 = html3.replace(/{{totalamount}}/g, currencies.symbol + ' ' + docdata.invoice.amount.grand_total.toFixed(2));
																						html3 = html3.replace(/{{total}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.total).toFixed(2));
																						html3 = html3.replace(/{{amount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission).toFixed(2));
																						html3 = html3.replace(/{{actualamount}}/g, currencies.symbol + ' ' + (docdata.invoice.amount.total - docdata.invoice.amount.grand_total).toFixed(2));
																						html3 = html3.replace(/{{admincommission}}/g, currencies.symbol + ' ' + docdata.invoice.amount.admin_commission.toFixed(2));
																						html3 = html3.replace(/{{privacy}}/g, settings.settings.site_url + 'pages/privacypolicy');
																						html3 = html3.replace(/{{terms}}/g, settings.settings.site_url + 'pages/termsandconditions');
																						html3 = html3.replace(/{{Servicetax}}/g, currencies.symbol + ' ' + docdata.invoice.amount.service_tax.toFixed(2));
																						var options = { format: 'Letter' };
																						var pdfname2 = new Date().getTime();
																						pdf.create(html3, options).toFile('./uploads/invoice/' + pdfname2 + '.pdf', function (err, document) {
																							console.log("err, document", err, document);
																							console.log("docdata.admin.docdata.user.email", docdata.user.email);
																							if (err) {
																								res.send(err);
																							} else {

																								var mailOptions2 = {
																									from: template[2].sender_email,
																									to: docdata.user.email,
																									subject: template[2].email_subject,
																									text: "Please Download the attachment to see Your Payment",
																									html: '<b>Please Download the attachment to see Your Payment</b>',
																									attachments: [{
																										filename: CONFIG.USER + ' Payment Details.pdf',
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
																});// mail end
																var notifications = { 'job_id': docdata.booking_id, 'user_id': docdata.user._id };
																var message = CONFIG.NOTIFICATION.PAYMENT_COMPLETED;
																push.sendPushnotification(docdata.tasker._id, message, 'payment_paid', 'ANDROID', notifications, 'PROVIDER', function (err, response, body) { });
																push.sendPushnotification(docdata.user._id, message, 'payment_paid', 'ANDROID', notifications, 'USER', function (err, response, body) { });
																res.send(docdata);
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
				}
				else {
					res.status(400).send({ message: 'Recharge Your Wallet' });
				}
			}
		});
	}

	controller.couponCompletePayment = function couponCompletePayment(req, res) {
		var request = {};
		request.task = req.body.taskid;

		async.waterfall([
			function (callback) {
				db.GetOneDocument('task', { _id: req.body.taskid }, {}, {}, function (err, task) {
					callback(err, task);
				});
			},
			function (task, callback) {
				db.GetOneDocument('tasker', { _id: req.body.taskerid }, {}, {}, function (err, tasker) {
					callback(err, task, tasker);
				});
			},

			function (task, tasker, callback) {
				db.GetOneDocument('users', { _id: req.body.userid }, {}, {}, function (err, user) {
					callback(err, task, tasker, user);
				});
			},

			function (task, tasker, user, callback) {
				var transaction = {};
				transaction.user = task.user;
				transaction.tasker = task.tasker;
				transaction.task = request.task;
				if (task.payment_type == 'wallet-other') {
					transaction.type = 'wallet-gateway';
				} else {
					transaction.type = 'coupon';
				}
				transaction.amount = task.invoice.amount.balance_amount;
				transaction.task_date = task.createdAt;
				transaction.status = 1;
				db.InsertDocument('transaction', transaction, function (err, transactions) {
					request.transaction_id = transactions._id;
					request.trans_date = transactions.createdAt;
					request.avail_amount = transactions.amount;
					request.credit_type = transactions.type;
					callback(err, task, tasker, transactions);
				});
			},
			function (task, tasker, transactions, callback) {
				db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
					if (err || !settings) { data.response = 'Configure your website settings'; res.send(data); }
					else { callback(err, task, tasker, transactions, settings); }
				});
			},

			function (task, tasker, transactions, settings, callback) {
				if (request.transaction_id) {
					/*	var transactions = [{
							'gateway_response': charges
						}];*/
					db.UpdateDocument('transaction', { '_id': request.transaction_id }, { 'transactions': transactions }, {}, function (err, transaction) {
						callback(err, task, tasker, transaction, settings);
					});
				} else {
					callback(err, task, tasker, transactions, settings);
				}
			},

			function (task, tasker, transaction, settings, callback) {
				db.GetDocument('emailtemplate', { name: { $in: ['PaymentDetailstoAdmin', 'PaymentDetailstoTasker', 'PaymentDetailstoUser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {

					if (err || !template) { data.response = 'Unable to get email template'; res.send(data); }
					else { callback(err, task, tasker, transaction, settings, template); }

				});
			}
		], function (err, task, tasker, transaction, settings, template) {
			if (err) {
				res.status(400).send(err);
			} else {

				var dataToUpdate = {};
				dataToUpdate.status = 7;
				dataToUpdate.invoice = task.invoice;
				dataToUpdate.invoice.status = 1;
				dataToUpdate.payee_status = 0;
				dataToUpdate.invoice.amount.balance_amount = parseFloat(task.invoice.amount.balance_amount) - parseFloat(task.invoice.amount.balance_amount);
				dataToUpdate.payment_type = 'coupon';
				db.UpdateDocument('task', { _id: task._id }, dataToUpdate, function (err, docdata) {
					if (err) {
						res.send(err);
					} else {
						var options = {};
						options.populate = 'tasker user categories';
						db.GetOneDocument('task', { _id: task._id }, {}, options, function (err, reloadTask) {
							if (err) {
								res.send(err);
							} else {

								var notifications = { 'job_id': reloadTask.booking_id, 'user_id': reloadTask.tasker._id };
								var message = CONFIG.NOTIFICATION.PAYMENT_COMPLETED;
								push.sendPushnotification(reloadTask.tasker._id, message, 'payment_paid', 'ANDROID', notifications, 'PROVIDER', function (err, response, body) { });
								push.sendPushnotification(reloadTask.user._id, message, 'payment_paid', 'ANDROID', notifications, 'USER', function (err, response, body) { });

								res.send(reloadTask);
							}
						});
					}
				});
				// email templete
				var options = {};
				options.populate = 'tasker user categories';
				db.GetOneDocument('task', { _id: task._id }, {}, options, function (err, docdata) {

					if (err) {
						res.send(err);
					} else {

						db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
							if (err) {
								res.send(err);
							} else {
								var MaterialFee, CouponCode, DateTime, BookingDate;
								if (docdata.invoice.amount.extra_amount) {
									MaterialFee = (docdata.invoice.amount.extra_amount).toFixed(2);
								} else {
									MaterialFee = '0.00';
								}
								if (docdata.invoice.amount.coupon) {
									CouponCode = currencies.symbol + docdata.invoice.amount.coupon;

								} else {
									CouponCode = 'Not assigned';
								}
								DateTime = moment(docdata.history.job_started_time).format('DD/MM/YYYY - HH:mm');
								BookingDate = moment(docdata.history.booking_date).format('DD/MM/YYYY');

								var mailData = {};
								mailData.template = 'PaymentDetailstoAdmin';
								mailData.to = settings.settings.email_address;
								mailData.html = [];
								mailData.html.push({ name: 'mode', value: docdata.payment_type });
								mailData.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
								mailData.html.push({ name: 'coupon', value: CouponCode });
								mailData.html.push({ name: 'datetime', value: DateTime });
								mailData.html.push({ name: 'bookingdata', value: BookingDate });
								mailData.html.push({ name: 'site_url', value: settings.settings.site_url });
								mailData.html.push({ name: 'site_title', value: settings.settings.site_title });
								mailData.html.push({ name: 'logo', value: settings.settings.logo });
								mailData.html.push({ name: 't_username', value: docdata.tasker.username });
								mailData.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
								mailData.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
								mailData.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
								mailData.html.push({ name: 'bookingid', value: task.booking_id });
								mailData.html.push({ name: 'u_username', value: docdata.user.username });
								mailData.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
								mailData.html.push({ name: 'useraddress1', value: docdata.user.address.city });
								mailData.html.push({ name: 'useraddress2', value: docdata.user.address.state });
								mailData.html.push({ name: 'categoryname', value: task.booking_information.work_type });
								mailData.html.push({ name: 'hourlyrates', value: currencies.symbol + (docdata.hourly_rate).toFixed(2) });
								mailData.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
								mailData.html.push({ name: 'totalamount', value: currencies.symbol + (docdata.invoice.amount.grand_total).toFixed(2) });
								mailData.html.push({ name: 'total', value: currencies.symbol + (docdata.invoice.amount.total).toFixed(2) });
								mailData.html.push({ name: 'amount', value: currencies.symbol + (docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission).toFixed(2) });
								mailData.html.push({ name: 'actualamount', value: currencies.symbol + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2) });
								mailData.html.push({ name: 'adminamount', value: currencies.symbol + (docdata.invoice.amount.admin_commission).toFixed(2) });
								mailData.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
								mailData.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
								mailData.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
								mailcontent.sendmail(mailData, function (err, response) { });

								var mailData2 = {};
								mailData2.template = 'PaymentDetailstoTasker';
								mailData2.to = docdata.tasker.email;
								mailData2.html = [];
								mailData2.html.push({ name: 'mode', value: docdata.payment_type });
								mailData2.html.push({ name: 'coupon', value: CouponCode });
								mailData2.html.push({ name: 'bookingdata', value: BookingDate });
								mailData2.html.push({ name: 'datetime', value: DateTime });
								mailData2.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
								mailData2.html.push({ name: 'site_url', value: settings.settings.site_url });
								mailData2.html.push({ name: 'site_title', value: settings.settings.site_title });
								mailData2.html.push({ name: 'logo', value: settings.settings.logo });
								mailData2.html.push({ name: 't_username', value: docdata.tasker.username });
								mailData2.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
								mailData2.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
								mailData2.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
								mailData2.html.push({ name: 'bookingid', value: task.booking_id });
								mailData2.html.push({ name: 'u_username', value: docdata.user.username });
								mailData2.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
								mailData2.html.push({ name: 'useraddress1', value: docdata.user.address.city });
								mailData2.html.push({ name: 'useraddress2', value: docdata.user.address.state });
								mailData2.html.push({ name: 'categoryname', value: task.booking_information.work_type });
								mailData2.html.push({ name: 'hourlyrates', value: currencies.symbol + docdata.hourly_rate });
								mailData2.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
								mailData2.html.push({ name: 'totalamount', value: currencies.symbol + (docdata.invoice.amount.grand_total).toFixed(2) });
								mailData2.html.push({ name: 'total', value: currencies.symbol + (docdata.invoice.amount.total).toFixed(2) });
								mailData2.html.push({ name: 'actualamount', value: currencies.symbol + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2) });
								mailData2.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
								mailData2.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
								mailData2.html.push({ name: 'admincommission', value: currencies.symbol + docdata.invoice.amount.admin_commission.toFixed(2) });
								mailData2.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
								mailData2.html.push({ name: 'email', value: req.body.email });
								mailcontent.sendmail(mailData2, function (err, response) { });
								var mailData3 = {};
								mailData3.template = 'PaymentDetailstoUser';
								mailData3.to = docdata.user.email;
								mailData3.html = [];
								mailData3.html.push({ name: 'mode', value: docdata.payment_type });
								mailData3.html.push({ name: 'datetime', value: DateTime });
								mailData3.html.push({ name: 'bookingdata', value: BookingDate });
								mailData3.html.push({ name: 'coupon', value: CouponCode });
								mailData3.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
								mailData3.html.push({ name: 'site_url', value: settings.settings.site_url });
								mailData3.html.push({ name: 'site_title', value: settings.settings.site_title });
								mailData3.html.push({ name: 'logo', value: settings.settings.logo });
								mailData3.html.push({ name: 't_username', value: docdata.tasker.username });
								mailData3.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
								mailData3.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
								mailData3.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
								mailData3.html.push({ name: 'bookingid', value: task.booking_id });
								mailData3.html.push({ name: 'u_username', value: docdata.user.username });
								mailData3.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
								mailData3.html.push({ name: 'useraddress1', value: docdata.user.address.city });
								mailData3.html.push({ name: 'useraddress2', value: docdata.user.address.state });
								mailData3.html.push({ name: 'categoryname', value: task.booking_information.work_type });
								mailData3.html.push({ name: 'hourlyrates', value: currencies.symbol + docdata.hourly_rate });
								mailData3.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
								mailData3.html.push({ name: 'totalamount', value: currencies.symbol + docdata.invoice.amount.grand_total.toFixed(2) });
								mailData3.html.push({ name: 'total', value: currencies.symbol + docdata.invoice.amount.total.toFixed(2) });
								mailData3.html.push({ name: 'actualamount', value: currencies.symbol + (docdata.invoice.amount.total - docdata.invoice.amount.grand_total).toFixed(2) });
								mailData3.html.push({ name: 'admincommission', value: currencies.symbol + docdata.invoice.amount.admin_commission.toFixed(2) });
								mailData3.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
								mailData3.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
								mailData3.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
								mailData3.html.push({ name: 'email', value: req.body.email });
								mailcontent.sendmail(mailData3, function (err, response) { });
							}
						});
					}
				});// mail en
			}
		});
	}

	controller.saveAvailability = function saveAvailability(req, res) {
		var user = {};
		user.working_area = req.body.working_area;
		user.working_days = req.body.working_days;
		user.working_days = user.working_days.filter(function (n) { return n != undefined });
		user.location = req.body.location;
		user.availability_address = req.body.availability_address;
		user.radiusby = req.body.radiusby;
		user.radius = req.body.radius;
		db.UpdateDocument('tasker', { _id: req.body._id }, user, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				res.send(docdata);
			}
		});
	}
	controller.updateAvailability = function updateAvailability(req, res) {
		var data = {};
		data.tasker = req.body._id;
		data.availability = req.body.availability;
		taskerLibrary.updateAvailability(data, function (err, response) {
			if (err) {
				res.send(err);
			} else {
				res.send(response);
			}
		});
	}

	controller.edit = function (req, res) {
		db.GetDocument('tasker', { _id: req.body.id }, {}, {}, function (err, data) {
			if (err) {
				res.send(err);
			} else {
				res.send(data);
			}
		});
	};


	controller.disputeupdateTask = function taskercanceltask(req, res) {
		var options = {};
		options.populate = 'tasker user';
		db.GetOneDocument('task', { _id: req.body.data }, {}, options, function (err, docdata) {
			if (err || !docdata) {
				res.send(err);
			} else {

				db.UpdateDocument('task', { _id: req.body.data }, { status: req.body.status }, function (err, result) {

					if (err) {
						res.send(err);

					} else {
						res.send(result);
					}
				});
				async.waterfall([
					function (callback) {
						db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
							if (err || !settings) { data.response = 'Configure your website settings'; res.send(data); }
							else { callback(err, settings.settings); }
						});
					},
					function (settings, callback) {

						db.GetDocument('emailtemplate', { name: { $in: ['Taskcancelled', 'Admintaskcancelled', 'Taskertaskcancelled'] }, 'status': { $eq: 1 } }, {}, {}, function (err, template) {
							if (err || !template) { data.response = 'Unable to get email template'; res.send(data); }
							else { callback(err, settings, template); }
						});
					}
				], function (err, settings, template) {
					var html = template[0].email_content;
					html = html.replace(/{{username}}/g, docdata.user.username);
					html = html.replace(/{{taskername}}/g, docdata.tasker.username);
					html = html.replace(/{{taskname}}/g, docdata.booking_information.work_type);
					html = html.replace(/{{startdate}}/g, docdata.task_date);
					html = html.replace(/{{workingtime}}/g, docdata.task_hour);
					html = html.replace(/{{description}}/g, docdata.task_description);
					html = html.replace(/{{cancelreason}}/g, req.body.cancellationreason);
					html = html.replace(/{{privacy}}/g, settings.site_url + 'pages/privacypolicy');
					html = html.replace(/{{terms}}/g, settings.site_url + '/pages/termsandconditions');
					html = html.replace(/{{senderemail}}/g, template[1].sender_email);
					html = html.replace(/{{logo}}/g, settings.site_url + settings.logo);
					html = html.replace(/{{site_title}}/g, settings.site_title);
					html = html.replace(/{{site_url}}/g, settings.site_url);
					html = html.replace(/{{email}}/g, docdata.user.email);
					var mailOptions = {
						from: template[0].sender_email,
						to: docdata.user.email,
						subject: template[0].email_subject,
						text: html,
						html: html
					};

					mail.send(mailOptions, function (err, response) { });

					var html1 = template[2].email_content;
					html1 = html1.replace(/{{username}}/g, docdata.user.username);
					html1 = html1.replace(/{{taskname}}/g, docdata.booking_information.work_type);
					html1 = html1.replace(/{{taskername}}/g, docdata.tasker.username);
					html1 = html1.replace(/{{startdate}}/g, docdata.task_date);
					html1 = html1.replace(/{{workingtime}}/g, docdata.task_hour);
					html1 = html1.replace(/{{description}}/g, docdata.task_description);
					html1 = html1.replace(/{{cancelreason}}/g, req.body.cancellationreason);
					html1 = html1.replace(/{{privacy}}/g, settings.site_url + 'pages/privacypolicy');
					html1 = html1.replace(/{{terms}}/g, settings.site_url + '/pages/termsandconditions');
					html1 = html1.replace(/{{senderemail}}/g, template[2].sender_email);
					html1 = html1.replace(/{{logo}}/g, settings.site_url + settings.logo);
					html1 = html1.replace(/{{site_title}}/g, settings.site_title);
					html1 = html.replace(/{{site_url}}/g, settings.site_url);
					html1 = html1.replace(/{{email}}/g, docdata.tasker.email);
					var mailOptions1 = {
						from: template[2].sender_email,
						to: docdata.tasker.email,
						subject: template[2].email_subject,
						text: html1,
						html: html1
					};

					mail.send(mailOptions1, function (err, response) { });

					var html2 = template[1].email_content;
					html2 = html2.replace(/{{username}}/g, docdata.user.username);
					html2 = html2.replace(/{{taskername}}/g, docdata.tasker.username);
					html2 = html2.replace(/{{taskname}}/g, docdata.booking_information.work_type);
					html2 = html2.replace(/{{startdate}}/g, docdata.task_date);
					html2 = html2.replace(/{{workingtime}}/g, docdata.task_hour);
					html2 = html2.replace(/{{description}}/g, docdata.task_description);
					html2 = html2.replace(/{{cancelreason}}/g, req.body.cancellationreason);
					html2 = html2.replace(/{{privacy}}/g, settings.site_url + 'pages/privacypolicy');
					html2 = html2.replace(/{{terms}}/g, settings.site_url + '/pages/termsandconditions');
					html2 = html2.replace(/{{senderemail}}/g, template[0].sender_email);
					html2 = html2.replace(/{{logo}}/g, settings.site_url + settings.logo);
					html2 = html.replace(/{{site_url}}/g, settings.site_url);
					html2 = html2.replace(/{{site_title}}/g, settings.site_title);
					html2 = html2.replace(/{{email}}/g, docdata.user.email);
					var mailOptions2 = {
						from: template[1].sender_email,
						to: template[1].sender_email,
						subject: template[1].email_subject,
						text: html2,
						html: html2
					};

					mail.send(mailOptions2, function (err, response) { });
				});
			}
		});
	}



	controller.savePassword = function savePassword(req, res) {
		// Validation & Sanitization
		req.checkBody('userId', 'Enter Your Valid Userid').notEmpty();
		req.checkBody('old', 'Enter Your existing password').notEmpty();
		req.checkBody('newpassword', 'Enter Your New password').notEmpty();
		req.checkBody('new_confirmed', 'Enter Your New password Again to Confirm').notEmpty();

		req.sanitizeBody('userId').trim();
		req.sanitizeBody('old').trim();
		req.sanitizeBody('newpassword').trim();
		req.sanitizeBody('new_confirmed').trim();
		// Validation & Sanitization

		var errors = req.validationErrors();
		if (errors) {
			res.status(400).send(errors[0]);
			return;
		}
		db.GetOneDocument('users', { _id: req.body.userId }, { password: 1 }, {}, function (err, docdata) {

			if (err) {
				res.send(err);
			} else {

				bcrypt.compare(req.body.old, docdata.password, function (err, result) {
					if (result == true) {
						if (req.body.old == req.body.newpassword) {

							res.status(400).send({ message: "Current password and new password should not be same" });
						}
						else {
							req.body.password = bcrypt.hashSync(req.body.new_confirmed, bcrypt.genSaltSync(8), null);
							db.UpdateDocument('users', { _id: req.body.userId }, req.body, function (err, docdata) {
								if (err) {
									res.send(err);
								} else {
									res.send(docdata);
								}
							});
						}
					} else {
						res.status(400).send({ message: "Current password is wrong" });
					}
				});
			}
		});
	}

	controller.getReview = function getReview(req, res) {
		var extension = {
			options: {
				limit: req.body.limit,
				skip: req.body.skip,
				sort: { updatedAt: -1 }
			},
			populate: 'user tasker task category'
		};
		if (req.body.role == 'user') {
			db.GetDocument('review', { 'user': new mongoose.Types.ObjectId(req.body.id), type: 'tasker' }, {}, extension, function (err, docdata) {
				if (err) {
					res.send(err);
				} else {
					db.GetCount('review', { 'user': new mongoose.Types.ObjectId(req.body.id), type: 'tasker' }, function (err, count) {
						if (err) {
							res.send(err);
						} else {
							res.send({ count: count, result: docdata });
						}
					});
				}
			});
		} else {
			db.GetDocument('review', { 'tasker': new mongoose.Types.ObjectId(req.body.id), type: 'user' }, {}, extension, function (err, docdata) {
				if (err) {
					res.send(err);
				} else {
					db.GetCount('review', { 'tasker': new mongoose.Types.ObjectId(req.body.id), type: 'user' }, function (err, count) {
						if (err) {
							res.send(err);
						} else {
							res.send({ count: count, result: docdata });
						}
					});
				}
			});

		}
	};


	controller.getuserReview = function getuserReview(req, res) {

		var extension = {
			options: {
				limit: req.body.limit,
				skip: req.body.skip,
				sort: { updatedAt: -1 }
			},
			populate: 'user tasker task'
		};

		if (req.body.role == 'user') {


			db.GetDocument('review', { 'user': new mongoose.Types.ObjectId(req.body.id), type: 'user' }, {}, extension, function (err, docdata) {
				if (err) {
					res.send(err);
				} else {
					db.GetCount('review', { 'user': new mongoose.Types.ObjectId(req.body.id), type: 'user' }, function (err, count) {
						if (err) {
							res.send(err);
						} else {
							res.send({ count: count, result: docdata });
						}
					});
				}
			});
		} else {

			db.GetDocument('review', { 'tasker': new mongoose.Types.ObjectId(req.body.id), type: 'tasker' }, {}, extension, function (err, docdata) {
				if (err) {
					res.send(err);
				} else {
					db.GetCount('review', { 'tasker': new mongoose.Types.ObjectId(req.body.id), type: 'tasker' }, function (err, count) {
						if (err) {
							res.send(err);
						} else {
							res.send({ count: count, result: docdata });
						}
					});
				}
			});
		}

	};


	controller.getTaskList = function getTaskList(req, res) {

		taskLibrary.taskExpired({}, function (err, response) {

			var limit = 12;
			var skip = 0;
			if (typeof req.body.limit != 'undefined' && typeof req.body.skip != 'undefined') {
				limit = parseInt(req.body.limit);
				if (limit) {
					var tmp = parseInt(limit);
					if (tmp != NaN && tmp > 0) {
						limit = tmp;
					} else {
						limit = 12;
					}
				}
				if (req.body.skip) {
					var tmp = parseInt(req.body.skip);
					if (tmp != NaN && tmp > 0) {
						skip = tmp;
					}
				}
			}
			var status = [];
			var stat = status[0];
			switch (req.body.status) {
				case 'assigned':
				default:
					status = [1];
					break;
				case 'ongoing':
					status = [2, 3, 4, 5];
					break;
				case 'completed':
					status = [6, 7];
					break;
				case 'cancelled':
					status = [8];
					break;
			}
			var request = {};
			request.sortby = req.body.sortby || 'updatedAt';
			var sorting = {};
			sorting[request.sortby] = -1;

			var aggregationData = [
				{ $match: { 'status': { "$in": status }, 'user': new mongoose.Types.ObjectId(req.body._id) } },
				{ $lookup: { from: "categories", localField: "category", foreignField: "_id", as: "category" } },
				{ $lookup: { from: "tasker", localField: "tasker", foreignField: "_id", as: "tasker" } },
				{ $sort: { updatedAt: -1 } },
				{ $unwind: { path: "$category", preserveNullAndEmptyArrays: true } },
				{ $unwind: { path: "$tasker", preserveNullAndEmptyArrays: true } },
				{ $lookup: { from: 'reviews', localField: '_id', foreignField: 'task', as: 'rating' } },
				{ $project: { document: "$$ROOT" } },
				{ $group: { "_id": null, "count": { "$sum": 1 }, "TaskDetails": { $push: "$document" } } },
				{ $unwind: { path: "$TaskDetails", preserveNullAndEmptyArrays: true } },
				{ '$skip': req.body.skip },
				{ '$limit': req.body.limit },
				{ $group: { "_id": null, "count": { "$first": "$count" }, "TaskDetails": { $push: "$TaskDetails" } } }
			];

			if (objectID.isValid(req.body._id)) {
				db.GetAggregation('task', aggregationData, function (err, doc) {
					if (err) {
						res.send(err);
					} else {
						res.send(doc);
					}
				});
			} else {
				res.send({ TaskDetails: [], count: 0 });
			}
		});
	};


	controller.getTaskDetailsByStaus = function getTaskDetailsByStaus(req, res) {

		taskLibrary.taskExpired({}, function (err, response) {

			var limit = 12;
			var skip = 0;
			if (typeof req.body.limit != 'undefined' && typeof req.body.skip != 'undefined') {
				limit = parseInt(req.body.limit);
				if (limit) {
					var tmp = parseInt(limit);
					if (tmp != NaN && tmp > 0) {
						limit = tmp;
					} else {
						limit = 12;
					}
				}
				if (req.body.skip) {
					var tmp = parseInt(req.body.skip);
					if (tmp != NaN && tmp > 0) {
						skip = tmp;
					}
				}
			}
			var status = [];
			var stat = status[0];

			switch (req.body.status) {
				case 'assigned':
				default:
					status = [1];
					break;
				case 'ongoing':
					status = [2, 3, 4, 5];
					break;
				case 'completed':
					status = [6, 7];
					break;
				case 'cancelled':
					status = [8];
					break;
				case 'disputed':
					status = [9];
					break;
			}

			var aggregationData = [
				{ $match: { status: { "$in": status }, tasker: new mongoose.Types.ObjectId(req.body._id) } },
				{ $sort: { updatedAt: -1 } },
				{ $lookup: { from: "categories", localField: "category", foreignField: "_id", as: "category" } },
				{ $lookup: { from: "users", localField: "user", foreignField: "_id", as: "user" } },
				{ $unwind: { path: "$user", preserveNullAndEmptyArrays: true } },
				{ $lookup: { from: 'reviews', localField: 'user._id', foreignField: 'user', as: 'userrating' } },
				{ $lookup: { from: 'reviews', localField: '_id', foreignField: 'task', as: 'taskrating' } },
				{ $unwind: { path: "$userrating", preserveNullAndEmptyArrays: true } },
				{
					$group: {
						"_id": "$_id",
						"createdAt": { $first: "$createdAt" },
						"category": { $first: "$category" },
						"user": { $first: "$user" },
						"billing_address": { $first: "$billing_address" },
						"task_address": { $first: "$task_address" },
						"amount": { $first: "$amount" },
						"invoice": { $first: "$invoice" },
						"booking_information": { $first: "$booking_information" },
						"worked_hours": { $first: "$worked_hours" },
						"usertaskcancellationreason": { $first: "$usertaskcancellationreason" },
						"tasker": { $first: "$tasker" },
						"status": { $first: "$status" },
						"task_description": { $first: "$task_description" },
						"history": { $first: "$history" },
						"hourly_rate": { $first: "$hourly_rate" },
						"booking_id": { $first: "$booking_id" },
						"taskrating": { $first: "$taskrating" },
						"reviews": {
							"$sum": {
								"$cond": [{ "$eq": ["$userrating.type", "tasker"] }, "$userrating.rating", 0]
							}
						},
						"total_reviews": {
							"$sum": {
								"$cond": [{ "$eq": ["$userrating.type", "tasker"] }, 1, 0]
							}
						},
					}
				},
				{ $unwind: { path: "$category", preserveNullAndEmptyArrays: true } },
				{ $unwind: { path: "$user", preserveNullAndEmptyArrays: true } },
				{ $project: { document: "$$ROOT" } },
				{ $group: { "_id": null, "count": { "$sum": 1 }, "TaskDetails": { $push: "$document" } } },
				{ $project: { TaskDetails: { $slice: ["$TaskDetails", skip, limit] }, count: 1 } }


			];
			if (objectID.isValid(req.body._id)) {
				db.GetAggregation('task', aggregationData, function (err, doc) {
					if (err) {
						res.send(err);
					} else {
						if (doc[0]) {
							for (var i = 0; i < doc[0].TaskDetails.length; i++) {
								if (doc[0].TaskDetails[i].user) {
									if (!doc[0].TaskDetails[i].user.avatar || doc[0].TaskDetails[i].user.avatar == '') {
										doc[0].TaskDetails[i].user.avatar = CONFIG.USER_PROFILE_IMAGE_DEFAULT;
									} else {
										doc[0].TaskDetails[i].user.avatar = doc[0].TaskDetails[i].user.avatar;
									}
								}
							}
						}
						res.send(doc);
					}
				});
			} else {
				res.send({ TaskDetails: [], count: 0 });
			}
		});
	};

	controller.getTaskDetailsBytaskid = function getTaskDetailsBytaskid(req, res) {

		var aggregationData = [
			{ $match: { status: { $eq: req.body.status }, _id: new mongoose.Types.ObjectId(req.body.id) } },
			{ $lookup: { from: "categories", localField: "category", foreignField: "_id", as: "category" } },
			{ $lookup: { from: "users", localField: "user", foreignField: "_id", as: "user" } },
			{ $lookup: { from: "tasker", localField: "tasker", foreignField: "_id", as: "tasker" } },
			{ $unwind: { path: "$category", preserveNullAndEmptyArrays: true } },
			{ $unwind: { path: "$user", preserveNullAndEmptyArrays: true } },
			{ $unwind: { path: "$tasker", preserveNullAndEmptyArrays: true } },
			{
				$project: {
					"user": 1,
					"tasker": 1,
					"category": 1
				}
			},
			{ $project: { document: "$$ROOT" } },
			{ $project: { OngoingTaskDetails: { $push: "$document" } } }
		];


		if (objectID.isValid(req.body.id)) {
			db.GetAggregation('task', aggregationData, function (err, doc) {
				if (err) {
					res.send(err);
				} else {
					res.send(doc);
				}
			});
		} else {
			res.send({ OngoingTaskDetails: [], count: 0 });
		}

	}



	controller.getUserTaskDetailsByStaus = function getUserTaskDetailsByStaus(req, res) {

		var limit = 12;
		var skip = 0;
		if (typeof req.body.limit != 'undefined' && typeof req.body.skip != 'undefined') {
			limit = parseInt(req.body.limit);
			if (limit) {
				var tmp = parseInt(limit);
				if (tmp != NaN && tmp > 0) {
					limit = tmp;
				} else {
					limit = 12;
				}
			}
			if (req.body.skip) {
				var tmp = parseInt(req.body.skip);
				if (tmp != NaN && tmp > 0) {
					skip = tmp;
				}
			}
		}
		var status = [];
		var stat = status[0];

		switch (req.body.status) {
			case 'assigned':
			default:
				status = [1];
				break;
			case 'ongoing':
				status = [2, 3, 4, 5];
				break;
			case 'completed':
				status = [6, 7];
				break;
			case 'cancelled':
				status = [8];
				break;
			case 'disputed':
				status = [9];
				break;
		}

		var aggregationData = [
			{ $match: { status: { "$in": status }, tasker: new mongoose.Types.ObjectId(req.body._id) } },
			{ $sort: { updatedAt: -1 } },
			{ $lookup: { from: "categories", localField: "category", foreignField: "_id", as: "category" } },
			{ $lookup: { from: "tasker", localField: "tasker", foreignField: "_id", as: "tasker" } },
			{ $lookup: { from: 'reviews', localField: '_id', foreignField: 'task', as: 'rating' } },
			{ $unwind: { path: "$category", preserveNullAndEmptyArrays: true } },
			{ $unwind: { path: "$tasker", preserveNullAndEmptyArrays: true } },
			{
				$project: {
					"taskerRating": { $filter: { input: "$rating", as: "item", cond: { $eq: ["$$item.type", "user"] } } },
					"category": 1,
					"billing_address": 1,
					"amount": 1,
					"invoice": 1,
					"worked_hours": 1,
					"booking_id": 1,
					"usertaskcancellationreason": 1,
					"tasker": 1,
					"status": 1,
					"task_description": 1,
					"hourly_rate": 1
				}
			},
			{ $project: { document: "$$ROOT" } },
			{ $group: { "_id": null, "count": { "$sum": 1 }, "TaskDetails": { $push: "$document" } } },
			{ $project: { TaskDetails: { $slice: ["$TaskDetails", skip, limit] }, count: 1 } }
		];

		if (objectID.isValid(req.body._id)) {
			db.GetAggregation('task', aggregationData, function (err, doc) {
				if (err) {
					res.send(err);
				} else {
					res.send(doc);
				}
			});
		} else {
			res.send({ TaskDetails: [], count: 0 });
		}
	};

	controller.getTaskDetailsBytaskid = function getTaskDetailsBytaskid(req, res) {

		var aggregationData = [
			{ $match: { status: { $eq: req.body.status }, _id: new mongoose.Types.ObjectId(req.body.id) } },
			{ $lookup: { from: "categories", localField: "category", foreignField: "_id", as: "category" } },
			{ $lookup: { from: "users", localField: "user", foreignField: "_id", as: "user" } },
			{ $lookup: { from: "tasker", localField: "tasker", foreignField: "_id", as: "tasker" } },
			{ $unwind: { path: "$category", preserveNullAndEmptyArrays: true } },
			{ $unwind: { path: "$user", preserveNullAndEmptyArrays: true } },
			{ $unwind: { path: "$tasker", preserveNullAndEmptyArrays: true } },
			{
				$project: {
					"user": 1,
					"tasker": 1,
					"category": 1
				}
			},
			{ $project: { document: "$$ROOT" } },
			{ $project: { OngoingTaskDetails: { $push: "$document" } } }
		];


		if (objectID.isValid(req.body.id)) {
			db.GetAggregation('task', aggregationData, function (err, doc) {
				if (err) {
					res.send(err);
				} else {
					res.send(doc);
				}
			});
		} else {
			res.send({ OngoingTaskDetails: [], count: 0 });
		}

	}



	controller.getusercategories = function getusercategories(req, res) {
		var options = {};
		options.populate = 'taskerskills.childid';
		db.GetOneDocument('tasker', { _id: req.body._id }, { taskerskills: 1 }, options, function (err, docdata) {
			if (err || !docdata) {
				res.send(err);
			} else {
				if (docdata.taskerskills) {
					res.send(docdata.taskerskills);
				} else {
					res.send(docdata);
				}
			}
		});
	}

	controller.transcationhis = function transcationhis(req, res) {
		var extension = {
			options: {
				limit: req.body.limit,
				skip: req.body.skip,
				sort: { updatedAt: -1 }
			},
			populate: 'user task tasker category transaction'
		};

		//options1.populate   = 'task.category';

		db.GetDocument('task', { "tasker": new mongoose.Types.ObjectId(req.body.id), status: { $eq: 7 } }, {}, extension, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				db.GetCount('task', { 'tasker': new mongoose.Types.ObjectId(req.body.id), status: { $eq: 7 } }, function (err, count) {
					if (err) {
						res.send(err);
					} else {
						res.send({ count: count, result: docdata });
					}
				});
			}
		});
	}



	controller.usertranscation = function usertranscation(req, res) {
		var extension = {
			options: {
				limit: req.body.limit,
				skip: req.body.skip,
				sort: { updatedAt: -1 }
			},
			populate: 'user task tasker category transaction'
		};

		db.GetDocument('task', { "user": new mongoose.Types.ObjectId(req.body.id), status: { $eq: 7 } }, {}, extension, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				db.GetCount('task', { 'user': new mongoose.Types.ObjectId(req.body.id), status: { $eq: 7 } }, function (err, count) {
					if (err) {
						res.send(err);
					} else {
						res.send({ count: count, result: docdata });
					}
				});
			}
		});
	}


	controller.getchild = function getchild(req, res) {

		db.GetOneDocument('category', { _id: req.body.id }, {}, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				res.send(docdata);
			}
		});

	}

	controller.getCategories = function getCategories(req, res) {
		db.GetDocument('category', { status: 1 }, {}, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				res.send(docdata);
			}
		});
	}

	controller.getmaincatname = function getmaincatname(req, res) {
		db.GetOneDocument('category', { '_id': new mongoose.Types.ObjectId(req.body.data) }, {}, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				db.GetOneDocument('category', { '_id': new mongoose.Types.ObjectId(docdata.parent) }, {}, {}, function (err, maincategorydata) {
					if (err) {
						res.send(err);
					}
					else {
						res.send(maincategorydata);
					}
				});
			}
		});
	}

	controller.getwalletdetails = function getwalletdetails(req, res) {
		db.GetOneDocument('walletReacharge', { "user_id": req.body.data }, {}, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				res.send(docdata);
			}
		});
	}

	controller.updatewalletdatapaypal = function updatewalletdatapaypal(req, res) {

		var data = {};
		data.status = 1;
		var request = {};
		request.amount = req.body.data.amount;
		request.user = req.body.user;
		db.GetOneDocument('users', { _id: request.user }, {}, {}, function (err, user) {
			if (err || !user) {
				res.send(err);
			} else {
				async.waterfall([
					function (callback) {
						db.GetOneDocument('paymentgateway', { status: { $ne: 0 }, alias: 'paypal' }, {}, {}, function (err, paymentgateway) {
							callback(err, paymentgateway);
						});
					},
					function (paymentgateway, callback) {
						var transaction = {
							'user': request.user_id,
							'type': 'wallet',
							'amount': request.amount,
							'status': 1
						};
						db.InsertDocument('transaction', transaction, function (err, transaction) {
							request.transaction_id = transaction._id;
							request.trans_id = transaction._id;
							request.trans_date = transaction.createdAt;
							request.avail_amount = transaction.amount;
							request.credit_type = transaction.type;
							callback(err, paymentgateway, transaction);
						});
					},
					function (paymentgateway, transaction, callback) {
						db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
							if (err || !settings) { data.response = 'Configure your website settings'; res.send(data); }
							else { callback(err, paymentgateway, transaction, settings.settings); }
						});
					},
					function (paymentgateway, transaction, settings, callback) {
						db.GetDocument('emailtemplate', { name: { $in: ['PaymentDetailstoAdmin', 'PaymentDetailstoTasker', 'PaymentDetailstoUser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
							if (err || !template) { data.response = 'Unable to get email template'; res.send(data); }
							else { callback(err, paymentgateway, transaction, settings, template); }
						});
					}
				], function (err, paymentgateway, transaction, settings, template) {
					if (err) {
						res.status(400).send(err);
					} else {
						paypal.configure({
							'mode': paymentgateway.settings.mode,
							'client_id': paymentgateway.settings.client_id,
							'client_secret': paymentgateway.settings.client_secret
						});

						var json = {
							"intent": "sale",
							"payer": {
								"payment_method": "paypal"
							},
							"redirect_urls": {},
							"transactions": [{
								"item_list": {
									"items": []
								},
								"amount": {
									"currency": "USD",
									"details": {}
								},
								"description": "This is the payment description."
							}]
						};

						var item = {};
						item.name = settings.site_title;
						item.price = request.amount;
						item.currency = 'USD';
						item.quantity = 1;
						json.transactions[0].item_list.items.push(item);
						json.transactions[0].amount.total = request.amount;
						json.transactions[0].amount.currency = 'USD';
						json.redirect_urls.return_url = "http://" + req.headers.host + "/site/account/walletpaypal-execute?user=" + request.user + "&transaction=" + transaction._id;
						json.redirect_urls.cancel_url = "http://" + req.headers.host + "/walletpayment-failed";

						paypal.payment.create(json, function (error, payment) {
							if (error) {
								data.response = 'Unable to get email template';
								res.send(data);
							} else {
								for (var i = 0; i < payment.links.length; i++) {
									var link = payment.links[i];
									if (link.method === 'REDIRECT') {
										data.redirectUrl = link.href;
									}
								}
								data.payment_mode = 'paypal';
								res.send(data);
							}
						});

					}
				});
			}
		});
	}

	controller.walletpaypalExecute = function walletpaypalExecute(req, res) {

		var data = {};
		data.status = 0;
		var request = {};
		request.transaction = req.query.transaction;
		request.paymentId = req.query.paymentId;
		request.token = req.query.token;
		request.PayerID = req.query.PayerID;
		request.user = req.query.user;

		db.GetOneDocument('transaction', { _id: request.transaction }, {}, {}, function (err, transaction) {
			var taskid = transaction.task;
			if (err) {
				res.send(err);
			} else {
				async.waterfall([
					function (callback) {
						db.GetOneDocument('paymentgateway', { status: { $ne: 0 }, alias: 'paypal' }, {}, {}, function (err, paymentgateway) {
							callback(err, paymentgateway);
						});
					},
					function (paymentgateway, callback) {
						db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
							if (err || !settings) { data.response = 'Configure your website settings'; res.send(data); }
							else { callback(err, paymentgateway, settings.settings); }
						});
					},
					function (paymentgateway, settings, callback) {
						db.GetDocument('emailtemplate', { name: { $in: ['PaymentDetailstoAdmin', 'PaymentDetailstoTasker', 'PaymentDetailstoUser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
							if (err || !template) { data.response = 'Unable to get email template'; res.send(data); }
							else { callback(err, paymentgateway, settings, template); }
						});
					}
				], function (err, paymentgateway, settings, template) {
					if (err) {
						res.status(400).send(err);
					} else {
						paypal.configure({
							'mode': 'sandbox',
							'client_id': paymentgateway.settings.client_id,
							'client_secret': paymentgateway.settings.client_secret
						});

						paypal.payment.execute(request.paymentId, { "payer_id": request.PayerID }, function (err, result) {
							if (err) {
								res.redirect("/payment-failed/" + request.user);
							} else {
								if (result.transactions[0].related_resources[0].sale.state != 'completed') {
									data.response = 'Transaction Failed';
									res.redirect("/payment-failed/" + request.user);
								} else {
									userLibrary.walletRecharge({ 'user': request.user, 'transaction': transaction._id, 'gateway_response': result, 'task': taskid }, function (err, response) {
										if (err || !response) {
											res.redirect("/payment-failed/" + request.user);
										} else {
											res.redirect("/payment-success");
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



	controller.getExperience = function getExperience(req, res) {
		db.GetDocument('experience', { status: 1 }, {}, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				res.send(docdata);
			}
		});
	}

	controller.updatetaskstatus = function updatetaskstatus(req, res) {
		var dateupdate = {};
		db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
			if (err || !settings) {
				res.send(err);
			} else {
        //var formatedDate = moment(new Date()).format('YYYY-MM-DD HH:mm:ss');
				//var time = timezone.tz(formatedDate, settings.settings.time_zone);
		 		if (req.body.data.status == 3) {
		 			dateupdate = { 'status': 3, 'history.provider_start_off_time': new Date() }
		 		}
		 		else if (req.body.data.status == 4) {
		 			dateupdate = { 'status': 4, 'history.location_arrived_time': new Date() }
		 		}
		 		else if (req.body.data.status == 5) {
		 			dateupdate = { 'status': 5, 'history.job_started_time': new Date() }
		 		}
		 		else if (req.body.data.status == 6) {
		 			dateupdate = { 'history.request_payment': new Date() }
		 		}
		 		var statusCheck = req.body.data.status - 1;
		 		if (req.body.data.status == 6) {
		 			statusCheck = req.body.data.status;
		 		}

				db.GetOneDocument('task', { _id: req.body.data.taskid }, {}, {}, function (err, task) {
					if (err || !task) {
						res.send(err);
					} else {
						if (task.status == statusCheck) {
							db.UpdateDocument('task', { _id: req.body.data.taskid }, dateupdate, function (err, updatedata) {
								if (err) {
									res.send(err);
								} else {
									var extension = {};
									extension.populate = { path: 'user tasker' };
									db.GetOneDocument('task', { _id: req.body.data.taskid }, {}, extension, function (err, task) {
										if (err || !task) {
											res.send(err);
										} else {
											var message = ''
											var job_date = timezone.tz(task.booking_information.booking_date, settings.settings.time_zone).format(settings.settings.date_format);
											var mail_job_time = timezone.tz(task.booking_information.booking_date, settings.settings.time_zone).format(settings.settings.time_format);
											var mailData = {};
											if (task.status == 3) {
												mailData.template = 'Start_off';
												mailData.to = task.user.email;
												mailData.html = [];
												mailData.html.push({ name: 'username', value: task.user.name.first_name + "(" + task.user.username + ")" || "" });
												mailData.html.push({ name: 'taskername', value: task.tasker.name.first_name + "(" + task.tasker.username + ")" || "" });
												mailData.html.push({ name: 'taskname', value: task.booking_information.service_type || "" });
												mailData.html.push({ name: 'startdate', value: job_date || "" });
												mailData.html.push({ name: 'workingtime', value: mail_job_time || "" });
												mailData.html.push({ name: 'site_url', value: settings.settings.site_url || "" });
												mailData.html.push({ name: 'site_title', value: settings.settings.site_title || "" });
												mailData.html.push({ name: 'logo', value: settings.settings.logo || "" });
												mailcontent.sendmail(mailData, function (err, response) {
													console.log("mail start", err, response);
												});
												message = CONFIG.NOTIFICATION.PROVIDER_START_OFF_YOUR_JOB;
												var options = { 'job_id': task.booking_id, 'user_id': task.user._id };
												push.sendPushnotification(task.user._id, message, 'start_off', 'ANDROID', options, 'USER', function (err, response, body) { });
											} else if (task.status == 4) {
												mailData.template = 'Tasker_Arrived';
												mailData.to = task.user.email;
												mailData.html = [];
												mailData.html.push({ name: 'username', value: task.user.name.first_name + "(" + task.user.username + ")" || "" });
												mailData.html.push({ name: 'taskername', value: task.tasker.name.first_name + "(" + task.tasker.username + ")" || "" });
												mailData.html.push({ name: 'site_url', value: settings.settings.site_url || "" });
												mailData.html.push({ name: 'site_title', value: settings.settings.site_title || "" });
												mailData.html.push({ name: 'logo', value: settings.settings.logo || "" });
												mailcontent.sendmail(mailData, function (err, response) { console.log("mail arrive", err, response) });
												message = CONFIG.NOTIFICATION.PROVIDER_ARRIVED_ON_YOUR_PLACE;
												var options = { 'job_id': task.booking_id, 'user_id': task.user._id };
												push.sendPushnotification(task.user._id, message, 'provider_reached', 'ANDROID', options, 'USER', function (err, response, body) { });
											} else if (task.status == 5) {
												mailData.template = 'Task_started';
												mailData.to = task.user.email;
												mailData.html = [];
												mailData.html.push({ name: 'username', value: task.user.name.first_name + "(" + task.user.username + ")" || "" });
												mailData.html.push({ name: 'taskername', value: task.tasker.name.first_name + "(" + task.tasker.username + ")" || "" });
												mailData.html.push({ name: 'taskname', value: task.booking_information.service_type || "" });
												mailData.html.push({ name: 'data', value: job_date || "" });
												mailData.html.push({ name: 'time', value: mail_job_time || "" });
												mailData.html.push({ name: 'site_url', value: settings.settings.site_url || "" });
												mailData.html.push({ name: 'site_title', value: settings.settings.site_title || "" });
												mailData.html.push({ name: 'logo', value: settings.settings.logo || "" });
												mailcontent.sendmail(mailData, function (err, response) { });
												message = CONFIG.NOTIFICATION.PROVIDER_STARTED_YOUR_JOB;
												var options = { 'job_id': task.booking_id, 'user_id': task.user._id };
												push.sendPushnotification(task.user._id, message, 'job_started', 'ANDROID', options, 'USER', function (err, response, body) { });
											}
											else if (task.status == 6) {
												message = CONFIG.NOTIFICATION.PROVIDER_SENT_REQUEST_FOR_PAYMENT;
												var options = { 'job_id': task.booking_id, 'user_id': task.user._id };
												push.sendPushnotification(task.user._id, message, 'job_started', 'ANDROID', options, 'USER', function (err, response, body) { });
											}
											res.send(task);
										}
									});
								}
							});
						} else {
							res.send({ 'error': 'Job Expired' });
						}
					}
				});
			}
		});
	}


	controller.updatetaskstatuscash = function updatetaskstatuscash(req, res) {

		var dateupdate = {};
		var extension = {};
		extension.populate = {
			path: 'user tasker'
		};
		db.GetOneDocument('task', { _id: req.body.data.taskid }, {}, extension, function (err, bookings) {
			if (err || !bookings) {
				res.send(err);
			} else {
				if (bookings.status == 6) {
					var pay_summary = 'Cash';
					var paymentInfo = {
						'invoice.status': 1,
						status: 7,
						'history.job_closed_time ': new Date()
					};
					var transactions = {};
					transactions.type = 'cash';
					transactions.trans_date = new Date();
					transactions.amount = bookings.invoice.amount.grand_total;
					transactions.user = bookings.user._id;
					transactions.task = bookings._id;

					async.waterfall([
						function (callback) {
							db.UpdateDocument('task', { '_id': req.body.data.taskid }, paymentInfo, {}, function (err, response) {
								callback(err, response);
							});
						},
						function (response, callback) {
							db.InsertDocument('transaction', transactions, function (err, response) {
								callback(err, response);
							});
						}
					], function (err, result) {
						if (err) {
							res.send(err);
						} else {
							db.UpdateDocument('task', { '_id': req.body.data.taskid }, { 'payment_type': 'cash' }, {}, function (err, responses) {
								if (err) {
									res.send(err)
								} else {
									db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
										if (err) {
											res.send(err);
										} else {
											var options = {};
											options.populate = 'tasker user categories';
											db.GetOneDocument('task', { '_id': req.body.data.taskid }, {}, options, function (err, docdata) {
												if (err) {
													res.send(err);
												} else {
													db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
														if (err) {
															res.send(err);
														} else {
															var MaterialFee, CouponCode, DateTime, BookingDate;
															if (docdata.invoice.amount.extra_amount) {
																MaterialFee = (docdata.invoice.amount.extra_amount).toFixed(2);
															} else {
																MaterialFee = '0.00';
															}
															if (docdata.invoice.amount.coupon) {
																CouponCode = currencies.symbol + docdata.invoice.amount.coupon;

															} else {
																CouponCode = 'Not assigned';
															}
															DateTime = moment(docdata.history.job_started_time).format('DD/MM/YYYY - HH:mm');
															BookingDate = moment(docdata.history.booking_date).format('DD/MM/YYYY');

															var mailData = {};
															mailData.template = 'PaymentDetailstoAdmin';
															mailData.to = settings.settings.email_address;
															mailData.html = [];
															mailData.html.push({ name: 'mode', value: docdata.payment_type });
															mailData.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
															mailData.html.push({ name: 'coupon', value: CouponCode });
															mailData.html.push({ name: 'datetime', value: DateTime });
															mailData.html.push({ name: 'bookingdata', value: BookingDate });
															mailData.html.push({ name: 'site_url', value: settings.settings.site_url });
															mailData.html.push({ name: 'site_title', value: settings.settings.site_title });
															mailData.html.push({ name: 'logo', value: settings.settings.logo });
															mailData.html.push({ name: 't_username', value: docdata.tasker.username });
															mailData.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
															mailData.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
															mailData.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
															mailData.html.push({ name: 'bookingid', value: docdata.booking_id });
															mailData.html.push({ name: 'u_username', value: docdata.user.username });
															mailData.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
															mailData.html.push({ name: 'useraddress1', value: docdata.user.address.city });
															mailData.html.push({ name: 'useraddress2', value: docdata.user.address.state });
															mailData.html.push({ name: 'categoryname', value: docdata.booking_information.work_type });
															mailData.html.push({ name: 'hourlyrates', value: currencies.symbol + (docdata.hourly_rate).toFixed(2) });
															mailData.html.push({ name: 'hourlyrate', value: currencies.symbol + (docdata.invoice.amount.minimum_cost).toFixed(2) });
															mailData.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
															mailData.html.push({ name: 'totalamount', value: currencies.symbol + (docdata.invoice.amount.grand_total).toFixed(2) });
															mailData.html.push({ name: 'total', value: currencies.symbol + (docdata.invoice.amount.total).toFixed(2) });
															mailData.html.push({ name: 'amount', value: currencies.symbol + (docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission).toFixed(2) });
															mailData.html.push({ name: 'actualamount', value: currencies.symbol + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2) });
															mailData.html.push({ name: 'adminamount', value: currencies.symbol + (docdata.invoice.amount.admin_commission).toFixed(2) });
															mailData.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
															mailData.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
															//mailData.html.push({ name: 'senderemail', value: template[0].sender_email });
															mailData.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
															//	mailData.html.push({ name: 'email', value: req.body.email });
															mailcontent.sendmail(mailData, function (err, response) { });

															var mailData2 = {};
															mailData2.template = 'PaymentDetailstoTasker';
															mailData2.to = docdata.tasker.email;
															mailData2.html = [];
															mailData2.html.push({ name: 'mode', value: docdata.payment_type });
															mailData2.html.push({ name: 'coupon', value: CouponCode });
															mailData2.html.push({ name: 'bookingdata', value: BookingDate });
															mailData2.html.push({ name: 'datetime', value: DateTime });
															mailData2.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
															mailData2.html.push({ name: 'site_url', value: settings.settings.site_url });
															mailData2.html.push({ name: 'site_title', value: settings.settings.site_title });
															mailData2.html.push({ name: 'logo', value: settings.settings.logo });
															mailData2.html.push({ name: 't_username', value: docdata.tasker.username });
															mailData2.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
															mailData2.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
															mailData2.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
															mailData2.html.push({ name: 'bookingid', value: docdata.booking_id });
															mailData2.html.push({ name: 'u_username', value: docdata.user.username });
															mailData2.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
															mailData2.html.push({ name: 'useraddress1', value: docdata.user.address.city });
															mailData2.html.push({ name: 'useraddress2', value: docdata.user.address.state });
															mailData2.html.push({ name: 'categoryname', value: docdata.booking_information.work_type });
															mailData2.html.push({ name: 'hourlyrates', value: currencies.symbol + docdata.hourly_rate });
															mailData2.html.push({ name: 'hourlyrate', value: currencies.symbol + (docdata.invoice.amount.minimum_cost).toFixed(2) });
															mailData2.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
															mailData2.html.push({ name: 'totalamount', value: currencies.symbol + (docdata.invoice.amount.grand_total).toFixed(2) });
															mailData2.html.push({ name: 'total', value: currencies.symbol + (docdata.invoice.amount.total).toFixed(2) });
															mailData2.html.push({ name: 'actualamount', value: currencies.symbol + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2) });
															// mailData2.html.push({ name: 'adminamount', value: docdata.invoice.amount.admin_commission});
															mailData2.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
															mailData2.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
															mailData2.html.push({ name: 'admincommission', value: currencies.symbol + docdata.invoice.amount.admin_commission.toFixed(2) });
															//	mailData2.html.push({ name: 'senderemail', value: template[0].sender_email });
															mailData2.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
															mailData2.html.push({ name: 'email', value: req.body.email });
															mailcontent.sendmail(mailData2, function (err, response) { });
															var mailData3 = {};
															mailData3.template = 'PaymentDetailstoUser';
															mailData3.to = docdata.user.email;
															mailData3.html = [];
															mailData3.html.push({ name: 'mode', value: docdata.payment_type });
															mailData3.html.push({ name: 'datetime', value: DateTime });
															mailData3.html.push({ name: 'bookingdata', value: BookingDate });
															mailData3.html.push({ name: 'coupon', value: CouponCode });
															mailData3.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
															mailData3.html.push({ name: 'site_url', value: settings.settings.site_url });
															mailData3.html.push({ name: 'site_title', value: settings.settings.site_title });
															mailData3.html.push({ name: 'logo', value: settings.settings.logo });
															mailData3.html.push({ name: 't_username', value: docdata.tasker.username });
															mailData3.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
															mailData3.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
															mailData3.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
															mailData3.html.push({ name: 'bookingid', value: docdata.booking_id });
															mailData3.html.push({ name: 'u_username', value: docdata.user.username });
															mailData3.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
															mailData3.html.push({ name: 'useraddress1', value: docdata.user.address.city });
															mailData3.html.push({ name: 'useraddress2', value: docdata.user.address.state });
															mailData3.html.push({ name: 'categoryname', value: docdata.booking_information.work_type });
															mailData3.html.push({ name: 'hourlyrates', value: currencies.symbol + docdata.hourly_rate });
															mailData3.html.push({ name: 'hourlyrate', value: currencies.symbol + (docdata.invoice.amount.minimum_cost).toFixed(2) });
															mailData3.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
															mailData3.html.push({ name: 'totalamount', value: currencies.symbol + docdata.invoice.amount.grand_total.toFixed(2) });
															mailData3.html.push({ name: 'total', value: currencies.symbol + docdata.invoice.amount.total.toFixed(2) });
															mailData3.html.push({ name: 'actualamount', value: currencies.symbol + (docdata.invoice.amount.total - docdata.invoice.amount.grand_total).toFixed(2) });
															mailData3.html.push({ name: 'admincommission', value: currencies.symbol + docdata.invoice.amount.admin_commission.toFixed(2) });
															mailData3.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
															mailData3.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
															//mailData3.html.push({ name: 'senderemail', value: template[0].sender_email });
															mailData3.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
															mailData3.html.push({ name: 'email', value: req.body.email });
															mailcontent.sendmail(mailData3, function (err, response) { });
														}
													});
												}
											});// mail end
										}
									}); // settings
								}
								var notifications = { 'job_id': bookings.booking_id, 'user_id': bookings.tasker._id };
								// var message = 'Payment Completed';
								var message = CONFIG.NOTIFICATION.PAYMENT_COMPLETED;
								push.sendPushnotification(bookings.tasker._id, message, 'payment_paid', 'ANDROID', notifications, 'PROVIDER', function (err, response, body) { });
								push.sendPushnotification(bookings.user._id, message, 'payment_paid', 'ANDROID', notifications, 'USER', function (err, response, body) { });
								res.send(responses);

							});
						}
					});
				} else {
					res.send({ 'error': 'You cannot do this action right now.' });

				}
			}
		});
	}

	controller.updatewalletdata = function updatewalletdata(req, res) {
		db.GetOneDocument('paymentgateway', { status: { $ne: 0 }, alias: 'stripe' }, {}, {}, function (err, paymentgateway) {
			if (err || !paymentgateway.settings.secret_key) {
				res.status(400).send({ 'message': 'Invalid payment method, Please contact the website administrator' });
			} else {
				stripe.setApiKey(paymentgateway.settings.secret_key);
				var request = {};
				request.user_id = req.body.user;
				request.card = req.body.data.walletrecharge.card;
				request.total_amount = parseFloat(req.body.data.walletamount).toFixed(2);

				request.card = {};
				request.card.number = req.body.data.walletrecharge.card.number;
				request.card.exp_month = req.body.data.walletrecharge.card.exp_month;
				request.card.exp_year = req.body.data.walletrecharge.card.exp_year;
				request.card.cvc = req.body.data.walletrecharge.card.cvv;

				async.waterfall([
					function (callback) {
						db.GetOneDocument('settings', { "alias": "general" }, { 'settings': 1 }, {}, function (err, settings) {
							callback(err, settings.settings);
						});
					},
					function (settings, callback) {
						var transaction = {
							'user': request.user_id,
							'type': 'wallet',
							'amount': request.total_amount,
							'status': 1
						};
						db.InsertDocument('transaction', transaction, function (err, transaction) {
							request.transaction_id = transaction._id;
							request.trans_id = transaction._id;
							request.trans_date = transaction.createdAt;
							request.avail_amount = transaction.amount;
							request.credit_type = transaction.type;
							callback(err, settings);
						});
					}, function (settings, callback) {
						stripe.tokens.create({ card: request.card }, function (err, token) {
							callback(err, settings, token);
						});

					},
					function (settings, token, callback) {
						var charge = {};
						charge.amount = request.total_amount * 100;
						charge.currency = 'usd';
						charge.source = token.id;
						charge.description = 'Wallet Recharge';
						stripe.charges.create(charge, function (err, charges) {
							callback(err, settings, charges);
						});
					}
				], function (err, settings, charges, callback) {
					if (err) {
						res.send(err);
					} else {
						userLibrary.walletRecharge({ 'user': request.user_id, 'transaction': request.transaction_id, 'gateway_response': charges }, function (err, response) {
							if (err || !response) {
								res.send(err);
							} else {
								res.send(response);
							}
						});
					}
				});
			}
		});
	};

	controller.updateprofiledetails = function updateprofiledetails(req, res) {
		db.UpdateDocument('tasker', { _id: req.body._id }, { 'profile_details': req.body.profile_details }, function (err, result) {
			if (err) {
				res.send(err);
			} else {
				res.send(result);
			}
		});
	}

	controller.ignoreTask = function ignoreTask(req, res) {
		var options = {};
		options.populate = 'tasker task user category';
		db.GetOneDocument('task', { _id: req.body.userid }, {}, options, function (err, docdata) {
			if (err || !docdata) {
				res.send(err);
			} else {
				db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settingdata) {
					if (err || !docdata) {
						res.send(err);
					} else {
						//var formatedDate = moment(new Date()).format('YYYY-MM-DD HH:mm:ss');
						//var time = timezone.tz(formatedDate, settingdata.settings.time_zone);
						db.UpdateDocument('task', { _id: req.body.userid }, { status: req.body.taskstatus, usertaskcancellationreason: req.body.reason, 'history.job_cancellation_time': new Date() }, function (err, result) {
							if (err) {
								res.send(err);
							} else {
								var notifications = { 'job_id': docdata.booking_id, 'user_id': docdata.user._id };
								var message = CONFIG.NOTIFICATION.YOUR_JOB_IS_REJECTED;
								push.sendPushnotification(docdata.user._id, message, 'job_reassign', 'ANDROID', notifications, 'USER', function (err, response, body) { });
								res.send(result);
							}
						});
						var job_date = timezone.tz(docdata.booking_information.booking_date, settingdata.settings.time_zone).format(settingdata.settings.date_format);
						var job_time = timezone.tz(docdata.booking_information.booking_date, settingdata.settings.time_zone).format(settingdata.settings.time_format);


						var mailData = {};
						mailData.template = 'Adminrejected';
						mailData.to = "";
						mailData.html = [];
						mailData.html.push({ name: 'site_url', value: settingdata.settings.site_url });
						mailData.html.push({ name: 'site_title', value: settingdata.settings.site_title });
						mailData.html.push({ name: 'logo', value: settingdata.settings.logo });
						mailData.html.push({ name: 'username', value: docdata.user.username });
						mailData.html.push({ name: 'taskername', value: docdata.tasker.username });
						mailData.html.push({ name: 'taskname', value: docdata.category.name });
						mailData.html.push({ name: 'startdate', value: job_date });
						mailData.html.push({ name: 'workingtime', value: job_time });
						mailData.html.push({ name: 'bookingid', value: docdata.booking_id });
						mailData.html.push({ name: 'cancelreason', value: req.body.reason });
						mailcontent.sendmail(mailData, function (err, response) { });

						var mailData1 = {};
						mailData1.template = 'Taskrejectedbytasker';
						mailData1.to = docdata.tasker.email;
						mailData1.html = [];
						mailData1.html.push({ name: 'site_url', value: settingdata.settings.site_url });
						mailData1.html.push({ name: 'site_title', value: settingdata.settings.site_title });
						mailData1.html.push({ name: 'logo', value: settingdata.settings.logo });
						mailData1.html.push({ name: 'username', value: docdata.user.username });
						mailData1.html.push({ name: 'taskername', value: docdata.tasker.username });
						mailData1.html.push({ name: 'bookingid', value: docdata.booking_id });
						mailData1.html.push({ name: 'taskname', value: docdata.category.name });
						mailData1.html.push({ name: 'startdate', value: job_date });
						mailData1.html.push({ name: 'workingtime', value: job_time });
						mailData1.html.push({ name: 'cancelreason', value: req.body.reason });
						mailcontent.sendmail(mailData1, function (err, response) { });


						var mailData2 = {};
						mailData2.template = 'Taskrejectedmailtouser';
						mailData2.to = docdata.user.email;
						mailData2.html = [];
						mailData2.html.push({ name: 'site_url', value: settingdata.settings.site_url });
						mailData2.html.push({ name: 'site_title', value: settingdata.settings.site_title });
						mailData2.html.push({ name: 'logo', value: settingdata.settings.logo });
						mailData2.html.push({ name: 'username', value: docdata.user.username });
						mailData2.html.push({ name: 'taskername', value: docdata.tasker.username });
						mailData2.html.push({ name: 'taskname', value: docdata.category.name });
						mailData2.html.push({ name: 'bookingid', value: docdata.booking_id });
						mailData2.html.push({ name: 'startdate', value: job_date });
						mailData2.html.push({ name: 'workingtime', value: job_time });
						mailData2.html.push({ name: 'cancelreason', value: req.body.reason });
						mailcontent.sendmail(mailData2, function (err, response) { });

					}
				});
			}
		});
	}


	controller.taskerconfirmtask = function taskerconfirmtask(req, res) {
		var options = {};
		options.populate = 'tasker user category';
		db.GetOneDocument('task', { _id: req.body.taskid }, {}, options, function (err, docdata) {
			if (err || !docdata) {
				res.send(err);
			} else {
				var history = {};
				history.provider_assigned = new Date();
				if (docdata.status == 8) {
					res.status(400).send({ err: 'User already Cancelled the job' });
				} else {
					db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settingdata) {
						if (err || !docdata) {
							res.send(err);
						} else {
							//new code
							console.log("provider_assigned aaccountt")
							//var formatedDate = moment(new Date()).format('YYYY-MM-DD HH:mm:ss');
							//history.provider_assigned = timezone.tz(formatedDate, settingdata.settings.time_zone);
							db.GetOneDocument('task', { '_id': req.body.taskid }, {}, {}, function (err, taskdetails) {
								if (err || !taskdetails) {
									res.send(err);
								} else {
									db.GetAggregation('task', [
										{
											"$match": {
												$and: [{ "tasker": new mongoose.Types.ObjectId(req.body.taskerid) }, { status: { $eq: req.body.taskstatus } }]
											}
										}
									], function (err, taskdata) {
										if (err || !taskdata) {
											res.send(err);
										} else {
											var trueValue = true;
											if (taskdata.length != 0) {
												for (var i = 0; i < taskdata.length; i++) {
													if (taskdata[i].task_day == taskdetails.task_day && taskdata[i].task_date == taskdetails.task_date && taskdata[i].task_hour == taskdetails.task_hour) {
														trueValue = false;
													}
												}
												if (trueValue == true) {
													// new code
													db.UpdateDocument('task', { _id: req.body.taskid }, { status: req.body.taskstatus, 'history.provider_assigned': history.provider_assigned }, function (err, result) {
														if (err) {
															res.send(err);
														} else {
															console.log("result/////////////", result);
															var notifications = { 'job_id': docdata.booking_id, 'user_id': docdata.user._id };
															var message = CONFIG.NOTIFICATION.YOUR_JOB_IS_ACCEPTED;
															push.sendPushnotification(docdata.user._id, message, 'job_accepted', 'ANDROID', notifications, 'USER', function (err, response, body) { });

															var job_date = timezone.tz(docdata.booking_information.booking_date, settingdata.settings.time_zone).format(settingdata.settings.date_format);
															var job_time = timezone.tz(docdata.booking_information.booking_date, settingdata.settings.time_zone).format(settingdata.settings.time_format);

															var mailData = {};
															mailData.template = 'Admintaskselected';
															mailData.to = settingdata.settings.email_address;
															mailData.html = [];
															mailData.html.push({ name: 'site_url', value: settingdata.settings.site_url });
															mailData.html.push({ name: 'site_title', value: settingdata.settings.site_title });
															mailData.html.push({ name: 'taskname', value: docdata.category.name });
															mailData.html.push({ name: 'bookingid', value: docdata.booking_id });
															mailData.html.push({ name: 'logo', value: settingdata.settings.logo });
															mailData.html.push({ name: 'startdate', value: job_date });
															mailData.html.push({ name: 'workingtime', value: job_time });
															mailData.html.push({ name: 'username', value: docdata.user.username });
															mailData.html.push({ name: 'username', value: docdata.user.name.first_name + "(" + docdata.user.username + ")" });
															mailData.html.push({ name: 'taskername', value: docdata.tasker.name.first_name + "(" + docdata.tasker.username + ")" });
															mailcontent.sendmail(mailData, function (err, response) { });

															var mailData1 = {};
															mailData1.template = 'Taskconfirmbytasker';
															mailData1.to = docdata.tasker.email;
															mailData1.html = [];
															mailData1.html.push({ name: 'site_url', value: settingdata.settings.site_url });
															mailData1.html.push({ name: 'site_title', value: settingdata.settings.site_title });
															mailData1.html.push({ name: 'logo', value: settingdata.settings.logo });
															mailData1.html.push({ name: 'username', value: docdata.user.name.first_name + "(" + docdata.user.username + ")" });
															mailData1.html.push({ name: 'taskername', value: docdata.tasker.name.first_name + "(" + docdata.tasker.username + ")" });
															mailData1.html.push({ name: 'taskname', value: docdata.category.name });
															mailData1.html.push({ name: 'bookingid', value: docdata.booking_id });
															mailData1.html.push({ name: 'startdate', value: job_date });
															mailData1.html.push({ name: 'workingtime', value: job_time });
															mailData1.html.push({ name: 'description', value: docdata.task_description });
															mailData1.html.push({ name: 'taskname', value: docdata.category.name });
															mailcontent.sendmail(mailData1, function (err, response) { });

															var mailData2 = {};
															mailData2.template = 'Taskselected';
															mailData2.to = docdata.user.email;
															mailData2.html = [];
															mailData2.html.push({ name: 'site_url', value: settingdata.settings.site_url });
															mailData2.html.push({ name: 'site_title', value: settingdata.settings.site_title });
															mailData2.html.push({ name: 'logo', value: settingdata.settings.logo });
															mailData2.html.push({ name: 'username', value: docdata.user.name.first_name + "(" + docdata.user.username + ")" });
															mailData2.html.push({ name: 'taskername', value: docdata.tasker.name.first_name + "(" + docdata.tasker.username + ")" });
															mailData2.html.push({ name: 'taskname', value: docdata.category.name });
															mailData2.html.push({ name: 'bookingid', value: docdata.booking_id });
															mailData2.html.push({ name: 'startdate', value: job_date });
															mailData2.html.push({ name: 'workingtime', value: job_time });
															mailData2.html.push({ name: 'taskname', value: docdata.category.name });
															mailData2.html.push({ name: 'description', value: docdata.task_description });
															mailcontent.sendmail(mailData2, function (err, response) { });

															res.send(result);
														}
													});
													// new code
												} else {
													var msg = "You have already booked a job in the chosen time, please choose a different time slot to perform job.";
													res.send(msg);
												}

											} else {
												db.UpdateDocument('task', { _id: req.body.taskid }, { status: req.body.taskstatus, 'history.provider_assigned': history.provider_assigned }, function (err, result) {
													if (err) {
														res.send(err);
													} else {
														var notifications = { 'job_id': docdata.booking_id, 'user_id': docdata.user._id };
														var message = CONFIG.NOTIFICATION.YOUR_JOB_IS_ACCEPTED;
														push.sendPushnotification(docdata.user._id, message, 'job_accepted', 'ANDROID', notifications, 'USER', function (err, response, body) { });

														var job_date = timezone.tz(docdata.booking_information.booking_date, settingdata.settings.time_zone).format(settingdata.settings.date_format);
														var job_time = timezone.tz(docdata.booking_information.booking_date, settingdata.settings.time_zone).format(settingdata.settings.time_format);

														var mailData = {};
														mailData.template = 'Admintaskselected';
														mailData.to = "";
														mailData.html = [];
														mailData.html.push({ name: 'site_url', value: settingdata.settings.site_url });
														mailData.html.push({ name: 'site_title', value: settingdata.settings.site_title });
														mailData.html.push({ name: 'taskname', value: docdata.category.name });
														mailData.html.push({ name: 'bookingid', value: docdata.booking_id });
														mailData.html.push({ name: 'logo', value: settingdata.settings.logo });
														mailData.html.push({ name: 'startdate', value: job_date });
														mailData.html.push({ name: 'workingtime', value: job_time });
														mailData.html.push({ name: 'username', value: docdata.user.username });
														mailData.html.push({ name: 'username', value: docdata.user.name.first_name + "(" + docdata.user.username + ")" });
														mailData.html.push({ name: 'taskername', value: docdata.tasker.name.first_name + "(" + docdata.tasker.username + ")" });
														mailcontent.sendmail(mailData, function (err, response) { });

														var mailData1 = {};
														mailData1.template = 'Taskconfirmbytasker';
														mailData1.to = docdata.tasker.email;
														mailData1.html = [];
														mailData1.html.push({ name: 'site_url', value: settingdata.settings.site_url });
														mailData1.html.push({ name: 'site_title', value: settingdata.settings.site_title });
														mailData1.html.push({ name: 'logo', value: settingdata.settings.logo });
														mailData1.html.push({ name: 'username', value: docdata.user.name.first_name + "(" + docdata.user.username + ")" });
														mailData1.html.push({ name: 'taskername', value: docdata.tasker.name.first_name + "(" + docdata.tasker.username + ")" });
														mailData1.html.push({ name: 'taskname', value: docdata.category.name });
														mailData1.html.push({ name: 'bookingid', value: docdata.booking_id });
														mailData1.html.push({ name: 'startdate', value: job_date });
														mailData1.html.push({ name: 'workingtime', value: job_time });
														mailData1.html.push({ name: 'description', value: docdata.task_description });
														mailData1.html.push({ name: 'taskname', value: docdata.category.name });
														mailcontent.sendmail(mailData1, function (err, response) { });

														var mailData2 = {};
														mailData2.template = 'Taskselected';
														mailData2.to = docdata.user.email;
														mailData2.html = [];
														mailData2.html.push({ name: 'site_url', value: settingdata.settings.site_url });
														mailData2.html.push({ name: 'site_title', value: settingdata.settings.site_title });
														mailData2.html.push({ name: 'logo', value: settingdata.settings.logo });
														mailData2.html.push({ name: 'username', value: docdata.user.name.first_name + "(" + docdata.user.username + ")" });
														mailData2.html.push({ name: 'taskername', value: docdata.tasker.name.first_name + "(" + docdata.tasker.username + ")" });
														mailData2.html.push({ name: 'taskname', value: docdata.category.name });
														mailData2.html.push({ name: 'bookingid', value: docdata.booking_id });
														mailData2.html.push({ name: 'startdate', value: job_date });
														mailData2.html.push({ name: 'workingtime', value: job_time });
														mailData2.html.push({ name: 'taskname', value: docdata.category.name });
														mailData2.html.push({ name: 'description', value: docdata.task_description });
														mailcontent.sendmail(mailData2, function (err, response) { });

														res.send(result);
													}
												});
											}
											// new code

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

	controller.getQuestion = function getQuestion(req, res) {
		db.GetDocument('question', { status: 1 }, {}, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				res.send(docdata);
			}
		});
	};

	controller.getsettings = function getsettings(req, res) {
		db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
			if (err) {
				res.send(err);
			} else {
				res.send(settings);
			}
		});
	};

	controller.updateTaskcompletion = function updateTaskcompletion(req, res) {
		taskLibrary.completeTask({ 'task': req.body.taskid, 'request': req.body.newdata }, function (err, response) {
			if (err || !response) {
				res.send(err);
			} else {
				res.send(response);
			}
		});
	};

	controller.insertaskerReview = function insertaskerReview(req, res) {
		db.InsertDocument('review', req.body, function (err, result) {
			if (err) {
				res.send(err);
			} else {
				res.send(result);
			}
		});
	}


	controller.updateTask = function updateTask(req, res) {
		var data = {};
		data.status = 4;
		data.invoice = {};
		data.invoice.amount = {};
		data.invoice.amount.total = req.body.total;
		data.invoice.amount.task_cost = req.body.taskinfo[0].amount;
		data.invoice.amount.reimbursement = req.body.reimbursement;
		data.invoice.amount.admin_commission = ((req.body.total - req.body.reimbursement) * req.body.categorycom / 100);
		data.invoice.amount.worked_hours_cost = (req.body.total) - (data.invoice.amount.admin_commission);
		db.UpdateDocument('task', { _id: req.body.taskinfo[0]._id }, data, function (err, result) {
			if (err) {
				res.send(err);

			} else {
				res.send(result);
			}
		});

		var options = {};
		options.populate = 'user tasker category';
		db.GetDocument('task', { _id: req.body.taskinfo[0]._id }, {}, options, function (err, result) {

			var mailcredentials = {};
			mailcredentials.taskname = result[0].category.name;
			mailcredentials.username = result[0].user.username;
			mailcredentials.taskername = result[0].tasker.username;
			mailcredentials.taskeremail = result[0].tasker.email;
			mailcredentials.useremail = result[0].user.email;
			mailcredentials.taskdate = result[0].task_date;
			mailcredentials.taskhour = result[0].task_hour;
			mailcredentials.taskdescription = result[0].task_description;
			if (err) {
				res.send(err);
			} else {

				var mailData = {};
				mailData.template = 'Admintaskselected';
				mailData.to = "";
				mailData.html = [];
				mailData.html.push({ name: 'username', value: result[0].user.name.first_name + "(" + mailcredentials.username + ")" });
				mailData.html.push({ name: 'taskername', value: result[0].tasker.username + "(" + mailcredentials.taskername + ")" });
				mailcontent.sendmail(mailData, function (err, response) { });


				var mailData1 = {};
				mailData1.template = 'Taskconfirmbytasker';
				mailData1.to = mailcredentials.taskeremail;
				mailData1.html = [];
				mailData1.html.push({ name: 'username', value: result[0].user.name.first_name + "(" + mailcredentials.username + ")" });
				mailData1.html.push({ name: 'taskername', value: result[0].tasker.username + "(" + mailcredentials.taskername + ")" });
				mailData1.html.push({ name: 'taskname', value: mailcredentials.taskname });
				mailData1.html.push({ name: 'startdate', value: mailcredentials.taskdate });
				mailData1.html.push({ name: 'workingtime', value: mailcredentials.taskhour });
				mailData1.html.push({ name: 'description', value: mailcredentials.taskdescription });
				mailcontent.sendmail(mailData1, function (err, response) { });

				var mailData2 = {};
				mailData2.template = 'Taskselected';
				mailData2.to = mailcredentials.useremail;
				mailData2.html = [];
				mailData2.html.push({ name: 'username', value: result[0].user.name.first_name + "(" + mailcredentials.username + ")" });
				mailData2.html.push({ name: 'taskername', value: result[0].tasker.username + "(" + mailcredentials.taskername + ")" });
				mailData2.html.push({ name: 'taskname', value: mailcredentials.taskname });
				mailData2.html.push({ name: 'startdate', value: mailcredentials.taskdate });
				mailData2.html.push({ name: 'workingtime', value: mailcredentials.taskhour });
				mailData2.html.push({ name: 'description', value: mailcredentials.taskdescription });
				mailcontent.sendmail(mailData2, function (err, response) { });


			}
		});
	}


	controller.usercanceltask = function usercanceltask(req, res) {
		var options = {};
		options.populate = 'tasker user';
		db.GetOneDocument('task', { _id: req.body.userid }, {}, options, function (err, docdata) {
			if (err || !docdata) {
				res.send(err);
			} else {
				db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settingdata) {
					if (err || !docdata) {
						res.send(err);
					} else {
						//var formatedDate = moment(new Date()).format('YYYY-MM-DD HH:mm:ss');
						//var time = timezone.tz(formatedDate, settingdata.settings.time_zone);
						db.UpdateDocument('task', { _id: req.body.userid }, { status: req.body.taskstatus, usertaskcancellationreason: req.body.reason, 'history.job_cancellation_time': new Date() }, function (err, result) {
							if (err) {
								res.send(err);
							} else {
								var job_date = timezone.tz(docdata.booking_information.booking_date, settingdata.settings.time_zone).format(settingdata.settings.date_format);
								var job_time = timezone.tz(docdata.booking_information.booking_date, settingdata.settings.time_zone).format(settingdata.settings.time_format);

								var mailData = {};
								mailData.template = 'Admintaskcancelled';
								mailData.to = "";
								mailData.html = [];
								mailData.html.push({ name: 'username', value: docdata.user.username });
								mailData.html.push({ name: 'privacy', value: settingdata.settings.site_url + 'pages/privacypolicy' });
								mailData.html.push({ name: 'teams', value: settingdata.settings.site_url + '/pages/termsandconditions' });
								mailData.html.push({ name: 'taskername', value: docdata.tasker.username });
								mailData.html.push({ name: 'taskname', value: docdata.booking_information.work_type });
								mailData.html.push({ name: 'bookingid', value: docdata.booking_id });
								mailData.html.push({ name: 'startdate', value: job_date });
								mailData.html.push({ name: 'workingtime', value: job_time });
								mailData.html.push({ name: 'description', value: docdata.task_description });
								mailData.html.push({ name: 'cancelreason', value: req.body.reason });
								mailData.html.push({ name: 'site_url', value: settingdata.settings.site_url });
								mailData.html.push({ name: 'site_title', value: settingdata.settings.site_title });
								mailData.html.push({ name: 'logo', value: settingdata.settings.logo });
								mailcontent.sendmail(mailData, function (err, response) { });

								var mailData1 = {};
								mailData1.template = 'Taskertaskcancelled';
								mailData1.to = docdata.tasker.email;
								mailData1.html = [];
								mailData1.html.push({ name: 'username', value: docdata.user.username });
								mailData1.html.push({ name: 'taskername', value: docdata.tasker.username });
								mailData1.html.push({ name: 'privacy', value: settingdata.settings.site_url + 'pages/privacypolicy' });
								mailData1.html.push({ name: 'teams', value: settingdata.settings.site_url + '/pages/termsandconditions' });
								mailData1.html.push({ name: 'taskname', value: docdata.booking_information.work_type });
								mailData1.html.push({ name: 'bookingid', value: docdata.booking_id });
								mailData1.html.push({ name: 'startdate', value: job_date });
								mailData1.html.push({ name: 'workingtime', value: job_time });
								mailData1.html.push({ name: 'description', value: docdata.task_description });
								mailData1.html.push({ name: 'cancelreason', value: req.body.reason });
								mailData1.html.push({ name: 'site_url', value: settingdata.settings.site_url });
								mailData1.html.push({ name: 'site_title', value: settingdata.settings.site_title });
								mailData1.html.push({ name: 'logo', value: settingdata.settings.logo });
								mailcontent.sendmail(mailData1, function (err, response) { });

								var mailData2 = {};
								mailData2.template = 'Taskcancelled';
								mailData2.to = docdata.user.email;
								mailData2.html = [];
								mailData2.html.push({ name: 'username', value: docdata.user.username });
								mailData2.html.push({ name: 'taskername', value: docdata.tasker.username });
								mailData.html.push({ name: 'privacy', value: settingdata.settings.site_url + 'pages/privacypolicy' });
								mailData.html.push({ name: 'teams', value: settingdata.settings.site_url + '/pages/termsandconditions' });
								mailData2.html.push({ name: 'taskname', value: docdata.booking_information.work_type });
								mailData2.html.push({ name: 'bookingid', value: docdata.booking_id });
								mailData2.html.push({ name: 'startdate', value: job_date });
								mailData2.html.push({ name: 'workingtime', value: job_time });
								mailData2.html.push({ name: 'description', value: docdata.task_description });
								mailData2.html.push({ name: 'cancelreason', value: req.body.reason });
								mailData2.html.push({ name: 'site_url', value: settingdata.settings.site_url });
								mailData2.html.push({ name: 'site_title', value: settingdata.settings.site_title });
								mailData2.html.push({ name: 'logo', value: settingdata.settings.logo });
								mailcontent.sendmail(mailData2, function (err, response) { });

								var notifications = { 'job_id': docdata.booking_id, 'user_id': docdata.tasker._id };
								var message = CONFIG.NOTIFICATION.JOB_REJECTED_BY_USER;
								push.sendPushnotification(docdata.tasker._id, message, 'rejecting_task', 'ANDROID', notifications, 'PROVIDER', function (err, response, body) { });
								res.send(result);
							}
						});
					}
				});
			}
		});
	}


	controller.updateCategory = function updateCategory(req, res) {
		var data = {};
		data.taskerskills = {};
		var userid = req.body.userid;
		var skills = [];
		if (req.file) {
			data.taskerskills.file = req.file.destination + req.file.filename;
		}
		data.taskerskills.experience = req.body.experience;
		data.taskerskills.hour_rate = req.body.hour_rate;
		data.taskerskills.quick_pitch = req.body.quick_pitch;
		data.taskerskills.categoryid = req.body.categoryid;
		data.taskerskills.childid = req.body.childid;
		data.taskerskills.skills = req.body.skills;
		data.taskerskills.terms = req.body.terms;
		data.taskerskills.status = 1;

		db.GetOneDocument('tasker', { _id: userid, 'taskerskills.childid': data.taskerskills.childid }, { taskerskills: 1 }, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else if (docdata) {
				db.UpdateDocument('tasker', { _id: userid, 'taskerskills.childid': data.taskerskills.childid }, { $set: { "taskerskills.$": data.taskerskills } }, { multi: true }, function (err, result) {
					if (err) {
						res.send(err);
					} else {
						res.send(result);
					}
				});
			} else {
				db.UpdateDocument('tasker', { _id: userid }, { $addToSet: { "taskerskills": data.taskerskills } }, { "multi": true }, function (err, result) {
					if (err) {
						res.send(err);
					} else {
						db.GetOneDocument('tasker', { _id: userid }, {}, {}, function (err, taskerdocdata) {
							if (err) {
								res.send(err);
							}
							else {
								db.GetDocument('category', { '_id': data.taskerskills.childid }, {}, {}, function (err, categorydocdata) {
									if (err) {
										res.send(err);
									}
									else {
										var mailData = {};
										mailData.template = 'taskeraddedcategory';
										mailData.to = '';
										mailData.html = [];
										mailData.html.push({ name: 'taskername', value: taskerdocdata.username });
										mailData.html.push({ name: 'categoryname', value: categorydocdata[0].name });
										mailcontent.sendmail(mailData, function (err, response) { });
										res.send(result);
									}
								});
							}
						});
					}
				});
			}
		});
	}


	controller.deleteCategory = function deleteCategory(req, res) {
		console.log(req.body);
		db.UpdateDocument('tasker', { _id: req.body.userid }, { $pull: { "taskerskills": { childid: req.body.categoryid } } }, function (err, result) {
			if (err) {
				res.send(err);
			} else {
				res.send(result);
				db.GetOneDocument('tasker', { _id: req.body.userid }, {}, {}, function (err, docdata) {
					if (err) {
						res.send(err);
					} else {
						db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
							if (err) {
								res.send(err);
							} else {
								var mailData = {};
								mailData.template = 'CategoryDeleted';
								mailData.to = docdata.email;
								mailData.html = [];
								mailData.html.push({ name: 'username', value: docdata.name.first_name + "(" + docdata.username + ")" });
								mailData.html.push({ name: 'categoryname', value: req.body.categoryname });
								mailData.html.push({ name: 'senderemail', value: mailData.template.sender_email });
								mailData.html.push({ name: 'logo', value: settings.settings.logo });
								mailData.html.push({ name: 'site_url', value: settings.settings.site_url });
								mailData.html.push({ name: 'site_title', value: settings.settings.site_title });
								mailcontent.sendmail(mailData, function (err, response) { });
								var mailData1 = {};
								mailData1.template = 'CategoryDeletedtoadmin';
								mailData1.to = settings.settings.email_address;
								mailData1.html = [];
								mailData1.html.push({ name: 'username', value: docdata.name.first_name + "(" + docdata.username + ")" });
								mailData1.html.push({ name: 'categoryname', value: req.body.categoryname });
								mailData1.html.push({ name: 'senderemail', value: mailData.template[0].sender_email });
								mailData1.html.push({ name: 'logo', value: settings.settings.logo });
								mailData1.html.push({ name: 'site_url', value: settings.settings.site_url });
								mailData1.html.push({ name: 'site_title', value: settings.settings.site_title });
								mailcontent.sendmail(mailData1, function (err, response) { });
							}
						});
					}
				});
			}
		});
	}

	controller.deactivate = function deactivate(req, res) {
		db.GetDocument('users', { _id: req.body.userid }, { username: 1, email: 1, role: 1 }, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settingdata) {
					if (err || !docdata) {
						res.send(err);
					} else {
						db.UpdateDocument('users', { _id: req.body.userid }, { status: 2 }, function (err, result) {
							if (err) {
								res.send(err);
							} else {
								res.send(result);
							}
						});
						var mailData = {};
						mailData.template = 'Deactivatemessage';
						mailData.to = docdata[0].email;
						mailData.html = [];
						mailData.html.push({ name: 'username', value: docdata[0].username });
						mailData.html.push({ name: 'role', value: docdata[0].role });
						mailcontent.sendmail(mailData, function (err, response) { });
						var mailData1 = {};
						mailData1.template = 'Deactivatemessagetoadmin';
						mailData1.to = "";
						mailData1.html = [];
						mailData1.html.push({ name: 'username', value: docdata[0].username });
						mailData1.html.push({ name: 'role', value: docdata[0].role });
						mailcontent.sendmail(mailData1, function (err, response) { });
					}
				});
			}
		});

	}

	controller.addReview = function addReview(req, res) {
		var data = {};
		data.user = req.body.data.user;
		data.tasker = req.body.data.tasker;
		data.task = req.body.data.task;
		data.type = req.body.data.type;
		data.comments = req.body.data.review.comments;
		data.rating = req.body.data.review.rating;
		db.InsertDocument('review', data, function (err, result) {
			if (err) {
				res.send(err);
			} else {
				var getQuery = [{
					"$match": { status: { $ne: 0 }, "_id": new mongoose.Types.ObjectId(data.tasker) }
				},
				{ $unwind: { path: "$taskerskills", preserveNullAndEmptyArrays: true } },
				{ $lookup: { from: 'categories', localField: "taskerskills.childid", foreignField: "_id", as: "taskerskills.childid" } },
				{ $unwind: { path: "$taskerskills", preserveNullAndEmptyArrays: true } },
				{ $group: { "_id": "$_id", 'taskercategory': { '$push': '$taskerskills' }, "taskerskills": { "$first": "$taskerskills" }, "createdAt": { "$first": "$createdAt" } } },
				{ $lookup: { from: 'reviews', localField: "_id", foreignField: "tasker", as: "rate" } },
				{ $unwind: { path: "$rate", preserveNullAndEmptyArrays: true } },
				{ $lookup: { from: 'task', localField: "_id", foreignField: "tasker", as: "task" } },
				{ $lookup: { from: 'task', localField: "rate.task", foreignField: "_id", as: "taskcategory" } },
				{ $unwind: { path: "$taskcategory", preserveNullAndEmptyArrays: true } },
				{ $lookup: { from: 'categories', localField: "taskcategory.category", foreignField: "_id", as: "category" } },
				{
					$project: {
						rate: 1,
						task: 1,
						rating: 1,
						taskcategory: 1,
						taskercategory: 1,
						category: 1,
						tasker: {
							$cond: { if: { $eq: ["$task.status", 6] }, then: "$task", else: "" }
						},
						username: 1,
						email: 1,
						role: 1,
						working_days: 1,
						location: 1,
						tasker_status: 1,
						address: 1,
						name: 1,
						avatar: 1,
						working_area: 1,
						birthdate: 1,
						gender: 1,
						phone: 1,
						stripe_connect: 1,
						taskerskills: 1,
						profile_details: 1,
						createdAt: 1
					}
				}, {
					$project: {
						name: 1,
						rate: 1,
						document: "$$ROOT"
					}
				},
				{
					$group: { "_id": "$_id", "count": { "$sum": 1 }, "induvidualrating": { "$sum": "$rate.rating" }, "documentData": { $push: "$document" } }
				},
				{
					$group: {
						"_id": "$_id", "induvidualrating": { $first: "$induvidualrating" }, "avg": { $sum: { $divide: ["$induvidualrating", "$count"] } }, "documentData": { $first: "$documentData" }
					}
				}];

				db.GetAggregation('tasker', getQuery, function (err, docdata) {
					if (err) {
						res.send(err);
					} else {
						if (docdata.length != 0) {
							var avgreview = parseFloat(docdata[0].avg);
							var totalreview = docdata[0].documentData[0].task.length;

							db.UpdateDocument('tasker', { _id: data.tasker }, { "avg_review": avgreview, "total_review": totalreview }, function (err, tasker) {
								if (err) {
									res.send(err);
								}
								else {
									res.send([docdata[0].documentData, docdata[0].avg]);
								}
							});
						}
						else {
							res.send(result);
						}
					}
				});
			}
		});
	}

	//Tasker
	controller.saveTaskerAccount = function saveTaskerAccount(req, res) {

		var data = {};
		data.address = {};
		data.name = {};

		data.name.first_name = req.body.name.first_name;
		data.name.last_name = req.body.name.last_name;
		data.email = req.body.email;
		data.phone = req.body.phone;
		data.gender = req.body.gender;
		data.address.line1 = req.body.address.line1;
		data.address.line2 = req.body.address.line2;
		data.address.city = req.body.address.city;
		data.address.state = req.body.address.state;
		data.address.country = req.body.address.country;
		data.address.zipcode = req.body.address.zipcode;
		data.avatarBase64 = req.body.avatarBase64;

		req.checkBody('name.first_name', 'Invalid First Name').notEmpty();
		req.checkBody('name.last_name', 'Invalid Last Name').notEmpty();
		req.checkBody('email', 'Invalid Email').notEmpty().withMessage('Email is Required').isEmail();
		req.checkBody('address.line1', 'Invalid Addressline').notEmpty();
		req.checkBody('address.city', 'Invalid city').optional();
		req.checkBody('address.state', 'Invalid state').optional();
		req.checkBody('address.country', 'Invalid country').optional();
		req.checkBody('address.zipcode', 'Invalid Zip Code').optional();

		req.sanitizeBody('name.first_name').trim();
		req.sanitizeBody('name.last_name').trim();
		req.sanitizeBody('email').normalizeEmail();
		req.sanitizeBody('line1').trim();
		req.sanitizeBody('line2').trim();
		req.sanitizeBody('city').trim();
		req.sanitizeBody('state').trim();
		req.sanitizeBody('country').trim();
		req.sanitizeBody('zipcode').trim();
		// Validation & Sanitization

		// Throw Validation Error
		var errors = req.validationErrors();
		if (errors) {
			res.status(400).send(errors[0]);
			return;
		}
		// Throw Validation Error

		if (data.avatarBase64) {
			var base64 = data.avatarBase64.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/);
			var fileName = Date.now().toString() + '.png';
			var file = './uploads/images/users/' + fileName;
			library.base64Upload({ file: file, base64: base64[2] }, function (err, response) { console.log(err, response); });
			data.avatar = 'uploads/images/users/' + fileName;
			data.img_name = fileName;
			data.img_path = 'uploads/images/users/';
		}
		db.UpdateDocument('tasker', { _id: req.body._id }, data, {}, function (err, result) {
			if (err) {
				res.send(err);
			} else {
				res.send(result);
			}
		});
	}

	controller.saveTaskerPassword = function saveTaskerPassword(req, res) {
		// Validation & Sanitization
		req.checkBody('userId', 'Enter Your Valid Userid').notEmpty();
		req.checkBody('old', 'Enter Your existing password').notEmpty();
		req.checkBody('newpassword', 'Enter Your New password').notEmpty();
		req.checkBody('new_confirmed', 'Enter Your New password Again to Confirm').notEmpty();

		req.sanitizeBody('userId').trim();
		req.sanitizeBody('old').trim();
		req.sanitizeBody('newpassword').trim();
		req.sanitizeBody('new_confirmed').trim();
		// Validation & Sanitization

		var errors = req.validationErrors();
		if (errors) {
			res.status(400).send(errors[0]);
			return;
		}
		db.GetOneDocument('tasker', { _id: req.body.userId }, { password: 1 }, {}, function (err, docdata) {

			if (err) {
				res.send(err);
			} else {
				bcrypt.compare(req.body.old, docdata.password, function (err, result) {
					if (result == true) {
						if (req.body.old == req.body.newpassword) {

							res.status(400).send("Current password and new password should not be same");
						}
						else {
							req.body.password = bcrypt.hashSync(req.body.new_confirmed, bcrypt.genSaltSync(8), null);
							db.UpdateDocument('tasker', { _id: req.body.userId }, req.body, function (err, docdata) {
								if (err) {
									res.send(err);
								} else {
									res.send(docdata);
								}
							});
						}
					} else {
						res.status(400).send("Current password is wrong");
					}
				});
			}
		});
	}

	controller.deactivateTasker = function deactivateTasker(req, res) {

		db.GetDocument('tasker', { _id: req.body.userid }, { username: 1, email: 1, role: 1 }, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {


				db.UpdateDocument('tasker', { _id: req.body.userid }, { status: 2 }, function (err, result) {
					if (err) {
						res.send(err);
					} else {
						res.send(result);
					}
				});

				var mailData = {};
				mailData.template = 'Deactivatemessage';
				mailData.to = docdata[0].email;
				mailData.html = [];
				mailData.html.push({ name: 'username', value: docdata[0].username });
				mailData.html.push({ name: 'role', value: docdata[0].role });
				mailcontent.sendmail(mailData, function (err, response) { });

				var mailData1 = {};
				mailData1.template = 'Deactivatemessagetoadmin';
				mailData1.to = "";
				mailData1.html = [];
				mailData1.html.push({ name: 'username', value: docdata[0].username });
				mailData1.html.push({ name: 'role', value: docdata[0].role });
				mailcontent.sendmail(mailData1, function (err, response) { });

			}
		});

	}

	controller.taskinfo = function taskinfo(req, res) {
		db.GetDocument('task', { _id: req.body.data }, {}, {}, function (err, docdata) {
			if (err || !docdata) {
				res.send(err);
			} else {
				res.send(docdata);
			}
		});
	}

	controller.gettaskbyid = function gettaskbyid(req, res) {

		var options = {};
		options.populate = 'category user tasker';
		db.GetDocument('task', { _id: req.body.task }, {}, options, function (err, docdata) {
			if (err || !docdata) {
				res.send(err);
			} else {
				if (docdata[0]) {
					if (!docdata[0].user.avatar || docdata[0].user.avatar == '') {
						docdata[0].user.avatar = './' + CONFIG.USER_PROFILE_IMAGE_DEFAULT;
					}
					if (!docdata[0].tasker.avatar || docdata[0].tasker.avatar == '') {
						docdata[0].tasker.avatar = './' + CONFIG.USER_PROFILE_IMAGE_DEFAULT;
					}
					db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
						if (err) {
							res.send(err);
						}
						else {
							var response = {};
							response.taskdata = docdata;
							response.settingsdata = settings;
							res.send(response);
						}
					});
				}
			}
		});
	}

	controller.confirmtask = function confirmtask(req, res) {
		db.GetOneDocument('paymentgateway', { status: { $ne: 0 }, alias: 'stripe' }, {}, {}, function (err, paymentgateway) {
			if (err || !paymentgateway.settings.secret_key) {
				res.status(400).send({ 'message': 'Invalid payment method, Please contact the website administrator' });
			} else {
				stripe.setApiKey(paymentgateway.settings.secret_key);

				var request = {};
				request.task = req.body.taskid;
				var card = {};
				card.number = req.body.card.number;
				card.exp_month = req.body.card.exp_month;
				card.exp_year = req.body.card.exp_year;
				card.cvc = req.body.card.cvv;
				async.waterfall([
					function (callback) {
						db.GetOneDocument('task', { _id: request.task }, {}, {}, function (err, task) {
							callback(err, task);
						});
					},
					function (task, callback) {
						db.GetOneDocument('tasker', { _id: task.tasker }, {}, {}, function (err, tasker) {
							callback(err, task, tasker);
						});
					},
					function (task, tasker, callback) {
						db.GetOneDocument('users', { _id: task.user }, {}, {}, function (err, user) {
							callback(err, task, tasker, user);
						});
					},
					function (task, tasker, user, callback) {
						var transaction = {};
						transaction.user = task.user;
						transaction.tasker = task.tasker;
						transaction.task = request.task;
						if (task.payment_type == 'wallet-other') {
							transaction.type = 'wallet-gateway';
						} else {
							transaction.type = 'stripe';
						}
						transaction.amount = task.invoice.amount.balance_amount;
						transaction.task_date = task.createdAt;
						transaction.status = 1;
						db.InsertDocument('transaction', transaction, function (err, transactions) {
							request.transaction_id = transactions._id;
							request.trans_date = transaction.createdAt;
							request.avail_amount = transaction.amount;
							request.credit_type = transaction.type;
							callback(err, task, tasker, transaction);
						});
					},
					function (task, tasker, transaction, callback) {
						stripe.tokens.create({ card: card }, function (err, token) {
							callback(err, token, task, tasker);
						});
					},
					function (token, task, tasker, callback) {
						stripe.charges.create({
							amount: parseInt(task.invoice.amount.balance_amount) * 100,
							currency: "usd",
							source: token.id,
							description: "Payment From User",
						}, function (err, charges) {
							callback(err, task, tasker, token, charges);
						});
					},
					function (task, tasker, token, charges, callback) {
						if (request.transaction_id) {
							var transactions = [{
								'gateway_response': charges
							}];
							db.UpdateDocument('transaction', { '_id': request.transaction_id }, { 'transactions': transactions }, {}, function (err, transaction) {
								callback(err, task, tasker, token, charges);
							});
						} else {
							callback(err, task, tasker, token, charges);
						}
					}
				], function (err, task, tasker, token, charges) {
					if (err) {
						res.status(400).send(err);
					} else {
						if (charges.status == 'succeeded') {
							taskLibrary.taskPayment({ 'transaction': request.transaction_id, 'gateway_response': charges }, function (err, response) {
								console.log(err, response);
								if (err || !response) {
									res.send(err);
								} else {
									res.send(response);
								}
							});
						} else {
							res.send(err);
						}

						/*
						var dataToUpdate = {};
						dataToUpdate.status = 7;
						dataToUpdate.invoice = task.invoice;
						dataToUpdate.invoice.status = 0;
						dataToUpdate.payee_status = 0;
						console.log("task.invoice.amount.balance_amount 3700 ", task.invoice.amount.balance_amount);
						dataToUpdate.invoice.amount.balance_amount = parseFloat(task.invoice.amount.balance_amount) - parseFloat(task.invoice.amount.balance_amount);
						if (charges.status == 'succeeded') {
							dataToUpdate.invoice.status = 1;
						}
						if (task.payment_type == 'wallet-other') {
							dataToUpdate.payment_type = 'wallet-gateway';
						}
						else {
							dataToUpdate.payment_type = 'stripe';
						}
						db.UpdateDocument('task', { _id: task._id }, dataToUpdate, function (err, docdata) {
							if (err) {
								res.send(err);
							} else {
								db.UpdateDocument('task', { _id: task._id }, { 'history.job_closed_time': new Date() }, {}, function (err, history) {
									if (err) {
										res.send(err);
									} else {
										var options = {};
										options.populate = 'tasker user categories';
										db.GetOneDocument('task', { _id: task._id }, {}, options, function (err, reloadTask) {
											if (err) {
												res.send(err);
											} else {

												var notifications = { 'job_id': reloadTask.booking_id, 'user_id': reloadTask.tasker._id };
												var message = CONFIG.NOTIFICATION.PAYMENT_COMPLETED;
												push.sendPushnotification(reloadTask.tasker._id, message, 'payment_paid', 'ANDROID', notifications, 'PROVIDER', function (err, response, body) { });
												push.sendPushnotification(reloadTask.user._id, message, 'payment_paid', 'ANDROID', notifications, 'USER', function (err, response, body) { });
												res.send(reloadTask);
											}
										});
									}
								});
							}
						});
						// email templete
						var options = {};
						options.populate = 'tasker user categories';
						db.GetOneDocument('task', { _id: task._id }, {}, options, function (err, docdata) {
							if (err) {
								res.send(err);
							} else {
								db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
									if (err) {
										res.send(err);
									} else {
										var MaterialFee, CouponCode, DateTime, BookingDate;
										if (docdata.invoice.amount.extra_amount) {
											MaterialFee = (docdata.invoice.amount.extra_amount).toFixed(2);
										} else {
											MaterialFee = '0.00';
										}
										if (docdata.invoice.amount.coupon) {
											CouponCode = currencies.symbol + docdata.invoice.amount.coupon;
										} else {
											CouponCode = 'Not assigned';
										}
										DateTime = moment(docdata.history.job_started_time).format('DD/MM/YYYY - HH:mm');
										BookingDate = moment(docdata.history.booking_date).format('DD/MM/YYYY');

										var mailData = {};
										mailData.template = 'PaymentDetailstoAdmin';
										mailData.to = settings.settings.email_address;
										mailData.html = [];
										mailData.html.push({ name: 'mode', value: docdata.payment_type });
										mailData.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
										mailData.html.push({ name: 'coupon', value: CouponCode });
										mailData.html.push({ name: 'datetime', value: DateTime });
										mailData.html.push({ name: 'bookingdata', value: BookingDate });
										mailData.html.push({ name: 'site_url', value: settings.settings.site_url });
										mailData.html.push({ name: 'site_title', value: settings.settings.site_title });
										mailData.html.push({ name: 'logo', value: settings.settings.logo });
										mailData.html.push({ name: 't_username', value: docdata.tasker.username });
										mailData.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
										mailData.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
										mailData.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
										mailData.html.push({ name: 'bookingid', value: task.booking_id });
										mailData.html.push({ name: 'u_username', value: docdata.user.username });
										mailData.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
										mailData.html.push({ name: 'useraddress1', value: docdata.user.address.city });
										mailData.html.push({ name: 'useraddress2', value: docdata.user.address.state });
										mailData.html.push({ name: 'categoryname', value: task.booking_information.work_type });
										mailData.html.push({ name: 'hourlyrates', value: currencies.symbol + (docdata.hourly_rate).toFixed(2) });
										mailData.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
										mailData.html.push({ name: 'totalamount', value: currencies.symbol + (docdata.invoice.amount.grand_total).toFixed(2) });
										mailData.html.push({ name: 'total', value: currencies.symbol + (docdata.invoice.amount.total).toFixed(2) });
										mailData.html.push({ name: 'amount', value: currencies.symbol + (docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission).toFixed(2) });
										mailData.html.push({ name: 'actualamount', value: currencies.symbol + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - MaterialFee).toFixed(2) });
										mailData.html.push({ name: 'adminamount', value: currencies.symbol + (docdata.invoice.amount.admin_commission).toFixed(2) });
										mailData.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
										mailData.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
										mailData.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
										mailcontent.sendmail(mailData, function (err, response) { });

										var mailData2 = {};
										mailData2.template = 'PaymentDetailstoTasker';
										mailData2.to = docdata.tasker.email;
										mailData2.html = [];
										mailData2.html.push({ name: 'mode', value: docdata.payment_type });
										mailData2.html.push({ name: 'coupon', value: CouponCode });
										mailData2.html.push({ name: 'bookingdata', value: BookingDate });
										mailData2.html.push({ name: 'datetime', value: DateTime });
										mailData2.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
										mailData2.html.push({ name: 'site_url', value: settings.settings.site_url });
										mailData2.html.push({ name: 'site_title', value: settings.settings.site_title });
										mailData2.html.push({ name: 'logo', value: settings.settings.logo });
										mailData2.html.push({ name: 't_username', value: docdata.tasker.username });
										mailData2.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
										mailData2.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
										mailData2.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
										mailData2.html.push({ name: 'bookingid', value: task.booking_id });
										mailData2.html.push({ name: 'u_username', value: docdata.user.username });
										mailData2.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
										mailData2.html.push({ name: 'useraddress1', value: docdata.user.address.city });
										mailData2.html.push({ name: 'useraddress2', value: docdata.user.address.state });
										mailData2.html.push({ name: 'categoryname', value: task.booking_information.work_type });
										mailData2.html.push({ name: 'hourlyrates', value: currencies.symbol + docdata.hourly_rate });
										mailData2.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
										mailData2.html.push({ name: 'totalamount', value: currencies.symbol + (docdata.invoice.amount.grand_total - docdata.invoice.amount.service_tax).toFixed(2) });
										mailData2.html.push({ name: 'total', value: currencies.symbol + (docdata.invoice.amount.total).toFixed(2) });
										mailData2.html.push({ name: 'actualamount', value: currencies.symbol + ((docdata.invoice.amount.grand_total - docdata.invoice.amount.admin_commission) - docdata.invoice.amount.service_tax).toFixed(2) });
										mailData2.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
										mailData2.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
										mailData2.html.push({ name: 'admincommission', value: docdata.invoice.amount.admin_commission.toFixed(2) });
										mailData2.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
										mailData2.html.push({ name: 'email', value: req.body.email });
										mailcontent.sendmail(mailData2, function (err, response) { });
										var mailData3 = {};
										mailData3.template = 'PaymentDetailstoUser';
										mailData3.to = docdata.user.email;
										mailData3.html = [];
										mailData3.html.push({ name: 'mode', value: docdata.payment_type });
										mailData3.html.push({ name: 'datetime', value: DateTime });
										mailData3.html.push({ name: 'bookingdata', value: BookingDate });
										mailData3.html.push({ name: 'coupon', value: CouponCode });
										mailData3.html.push({ name: 'materialfee', value: currencies.symbol + MaterialFee });
										mailData3.html.push({ name: 'site_url', value: settings.settings.site_url });
										mailData3.html.push({ name: 'site_title', value: settings.settings.site_title });
										mailData3.html.push({ name: 'logo', value: settings.settings.logo });
										mailData3.html.push({ name: 't_username', value: docdata.tasker.username });
										mailData3.html.push({ name: 'taskeraddress', value: docdata.tasker.address.line1 });
										mailData3.html.push({ name: 'taskeraddress1', value: docdata.tasker.address.city });
										mailData3.html.push({ name: 'taskeraddress2', value: docdata.tasker.address.state });
										mailData3.html.push({ name: 'bookingid', value: task.booking_id });
										mailData3.html.push({ name: 'u_username', value: docdata.user.username });
										mailData3.html.push({ name: 'useraddress', value: docdata.user.address.line1 });
										mailData3.html.push({ name: 'useraddress1', value: docdata.user.address.city });
										mailData3.html.push({ name: 'useraddress2', value: docdata.user.address.state });
										mailData3.html.push({ name: 'categoryname', value: task.booking_information.work_type });
										mailData3.html.push({ name: 'hourlyrates', value: currencies.symbol + docdata.hourly_rate });
										mailData3.html.push({ name: 'totalhour', value: docdata.invoice.worked_hours_human });
										mailData3.html.push({ name: 'totalamount', value: currencies.symbol + docdata.invoice.amount.grand_total.toFixed(2) });
										mailData3.html.push({ name: 'total', value: docdata.invoice.amount.total.toFixed(2) });
										mailData3.html.push({ name: 'actualamount', value: currencies.symbol + (docdata.invoice.amount.total - docdata.invoice.amount.grand_total).toFixed(2) });
										mailData3.html.push({ name: 'admincommission', value: currencies.symbol + docdata.invoice.amount.admin_commission.toFixed(2) });
										mailData3.html.push({ name: 'privacy', value: settings.settings.site_url + 'pages/privacypolicy' });
										mailData3.html.push({ name: 'terms', value: settings.settings.site_url + 'pages/termsandconditions' });
										mailData3.html.push({ name: 'Servicetax', value: currencies.symbol + docdata.invoice.amount.service_tax.toFixed(2) });
										mailData3.html.push({ name: 'email', value: req.body.email });
										mailcontent.sendmail(mailData3, function (err, response) { });
									}
								});
							}
						});// mail end
						*/
					}
				});
			}
		});
	}



	controller.paypalPayment = function paypalPayment(req, res) {

		var data = {};
		data.status = 1;

		var request = {};
		request.task = req.body.task;
		request.user = req.body.user;

		var options = {};
		options.populate = 'user category tasker';
		db.GetOneDocument('task', { _id: request.task }, {}, options, function (err, task) {
			if (err || !task) {
				res.send(err);
			} else {
				async.waterfall([
					function (callback) {
						db.GetOneDocument('paymentgateway', { status: { $ne: 0 }, alias: 'paypal' }, {}, {}, function (err, paymentgateway) {
							callback(err, paymentgateway);
						});
					},
					function (paymentgateway, callback) {
						var transaction = {};
						transaction.user = task.user;
						transaction.tasker = task.tasker;
						transaction.task = request.task;
						transaction.type = 'paypal';
						/* if (transaction.amount = task.invoice.amount.balance_amount) {
							transaction.amount = task.invoice.amount.balance_amount;
						} else {
							transaction.amount = task.invoice.amount.grand_total;
						} */
						transaction.amount = task.invoice.amount.balance_amount;
						transaction.task_date = task.createdAt;
						transaction.status = 1
						db.InsertDocument('transaction', transaction, function (err, transaction) {
							request.transaction_id = transaction._id;
							request.trans_date = transaction.createdAt;
							request.avail_amount = transaction.amount;
							request.credit_type = transaction.type;
							callback(err, paymentgateway, transaction);
						});
					},
					function (paymentgateway, transaction, callback) {
						db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
							if (err || !settings) { data.response = 'Configure your website settings'; res.send(data); }
							else { callback(err, paymentgateway, transaction, settings.settings); }
						});
					},
					function (paymentgateway, transaction, settings, callback) {
						db.GetDocument('emailtemplate', { name: { $in: ['PaymentDetailstoAdmin', 'PaymentDetailstoTasker', 'PaymentDetailstoUser'] }, 'status': { $ne: 0 } }, {}, {}, function (err, template) {
							if (err || !template) { data.response = 'Unable to get email template'; res.send(data); }
							else { callback(err, paymentgateway, transaction, settings, template); }
						});
					},
					function (paymentgateway, transaction, settings, template, callback) {
						db.GetOneDocument('currencies', { 'default': 1, status: { $ne: 0 } }, {}, {}, function (err, currency) {
							if (err || !template) { data.response = 'Unable to get currency'; res.send(data); }
							else { callback(err, paymentgateway, transaction, settings, template, currency); }
						});
					}
				], function (err, paymentgateway, transaction, settings, template, currency) {
					if (err) {
						res.status(400).send(err);
					} else {
						paypal.configure({
							'mode': paymentgateway.settings.mode,
							'client_id': paymentgateway.settings.client_id,
							'client_secret': paymentgateway.settings.client_secret
						});

						var json = {
							"intent": "sale",
							"payer": {
								"payment_method": "paypal"
							},
							"redirect_urls": {},
							"transactions": [{
								"item_list": {
									"items": []
								},
								"amount": {
									"currency": currency.code,
									"details": {}
								},
								"description": CONFIG.USER + " Payment"
							}]
						};

						var amountForPaypal = parseFloat(task.invoice.amount.balance_amount * currency.value).toFixed(2);
						var item = {};
						item.name = settings.site_title;
						item.price = amountForPaypal;
						item.currency = currency.code;
						item.quantity = 1;
						json.transactions[0].item_list.items.push(item);

						json.transactions[0].amount.details.subtotal = amountForPaypal;
						json.transactions[0].amount.details.tax = 0.00;
						json.transactions[0].amount.total = amountForPaypal;
						json.transactions[0].amount.currency = currency.code;

						json.redirect_urls.return_url = "http://" + req.headers.host + "/site/account/paypal-execute/?task=" + task._id + "&transaction=" + transaction._id;
						json.redirect_urls.cancel_url = "http://" + req.headers.host + "/payment-failed/" + task._id;

						paypal.payment.create(json, function (error, payment) {
							if (error) {
								data.response = 'Unable to get email template';
								res.send(data);
							} else {
								for (var i = 0; i < payment.links.length; i++) {
									var link = payment.links[i];
									if (link.method === 'REDIRECT') {
										data.redirectUrl = link.href;
									}
								}
								data.payment_mode = 'paypal';
								res.send(data);
							}
						});
					}
				});
			}
		});
	}

	controller.paypalExecute = function paypalExecute(req, res) {

		var data = {};
		data.status = 0;

		var request = {};
		request.task = req.query.task;
		request.transaction = req.query.transaction;
		request.paymentId = req.query.paymentId;
		request.token = req.query.token;
		request.PayerID = req.query.PayerID;

		var options = {};
		options.populate = 'tasker user task';
		db.GetOneDocument('transaction', { _id: request.transaction }, {}, options, function (err, transaction) {
			if (err) {
				res.send(err);
			} else {
				async.waterfall([
					function (callback) {
						db.GetOneDocument('paymentgateway', { status: { $ne: 0 }, alias: 'paypal' }, {}, {}, function (err, paymentgateway) {
							callback(err, paymentgateway);
						});
					}
				], function (err, paymentgateway, settings) {
					if (err) {
						res.status(400).send(err);
					} else {
						paypal.configure({
							'mode': 'sandbox',
							'client_id': paymentgateway.settings.client_id,
							'client_secret': paymentgateway.settings.client_secret
						});

						paypal.payment.execute(request.paymentId, { "payer_id": request.PayerID }, function (err, result) {
							if (err) {
								res.redirect("/payment-failed/" + req.query.task);
							} else {
								if (result.state != 'approved') {
									res.redirect("/payment-failed/" + req.query.task);
								} else {
									taskLibrary.taskPayment({ 'transaction': transaction._id, 'gateway_response': result }, function (err, response) {
										if (err || !response) {
											res.redirect("/payment-failed/" + req.query.task);
										} else {
											res.redirect("/payment-success");
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

	controller.applyCoupon = function applyCoupon(req, res) {
		var request = {};
		var date = new Date();
		// var isodate = date.toISOString();
		/*var previousDay = new Date(date);
		previousDay.setDate(date.getDate()-1);
		var isodate = previousDay.toISOString();*/
		var previousDay = new Date(date);
		previousDay.setDate(date.getDate() - 1);
		var isodate = new Date(previousDay);
		request.task = req.body.taskid;
		db.GetDocument('coupon', { $and: [{ status: { $ne: 2 } }, { code: req.body.coupon }] }, {}, {}, function (err, coupondata) {
			if (err || coupondata.length == 0) {
				res.status(400).send({ message: 'Invalid Coupon Code' });
			} else {
				db.GetDocument('coupon', { 'code': req.body.coupon, "valid_from": { "$lte": new Date() } }, {}, {}, function (err, data) {
					if (err) {
						res.status(400).send({ message: 'Coupon Code Date Not Valid From Today' });
					} if (data.length == 0) {
						res.status(400).send({ message: 'Coupon Code Date Not Valid From Today' });
					} else {
						db.GetDocument('coupon', { 'code': req.body.coupon, "expiry_date": { "$gte": isodate }, "valid_from": { "$lte": new Date() } }, {}, {}, function (err, data) {
							if (err) {
								res.status(400).send({ message: 'Coupon Code Date Expired' });
							} if (data.length == 0) {
								res.status(400).send({ message: 'Coupon Code Date Expired' });
							} else {
								db.GetAggregation('task', [
									{ $match: { 'invoice.coupon': req.body.coupon } },
									{ $group: { _id: "$invoice.coupon", total: { $sum: 1 } } },
								], function (err, taskdata) {
									if (err) {
										res.send(err);
									} else {
										var total_coupons = 0;
										if (taskdata[0]) {
											if (taskdata[0].total) {
												total_coupons = taskdata[0].total;
											}
										}
										db.GetDocument('coupon', { 'code': req.body.coupon, "usage.total_coupons": { "$gt": total_coupons } }, {}, {}, function (err, couponlimit) {
											if (err) {
												res.status(400).send({ message: 'Coupon Code Limit Exceed' });
											} else {
												if (couponlimit.length == 0) {
													res.status(400).send({ message: 'Coupon Code Limit Exceed' });
												} else {
													db.GetAggregation('task', [
														{ $match: { 'user': new mongoose.Types.ObjectId(req.body.user), 'invoice.status': 1, 'invoice.coupon': req.body.coupon } },
														{ $group: { _id: "$user", total: { $sum: 1 } } },
													], function (err, usagedata) {
														if (err) {
															res.status(400).send({ message: 'Coupon Code Usage Limit Exceed' });
														} else {
															var usage_coupons = 0;
															if (usagedata[0]) {
																if (usagedata[0].total) {
																	usage_coupons = usagedata[0].total;
																}
															}
															db.GetDocument('coupon', { 'code': req.body.coupon, "usage.per_user": { "$gt": usage_coupons } }, {}, {}, function (err, usagelimit) {
																if (err) {
																	res.status(400).send({ message: '1' });
																} if (usagelimit.length == 0) {
																	res.status(400).send({ message: 'Coupon Code Usage Limit Exceed' });
																} else {
																	db.GetDocument('task', { _id: new mongoose.Types.ObjectId(req.body.task) }, {}, {}, function (err, taskdata) {
																		if (err) {
																			res.status(400).send({ message: 'Error In Coupon code' });
																		} else {
																			db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settingdata) {
																				if (err) {
																					res.status(400).send({ message: 'Settings Not Available' });
																				}
																				else {

																					var invoice = {};
																					invoice.amount = {};
																					invoice.amount.discount = 0.00;
																					for (var i = 0; i < data.length; i++) {
																						if (data[i].code == req.body.coupon) {
																							if (data[i].discount_type == "Flat") {
																								if (taskdata[0].invoice.amount.grand_total > data[i].amount_percentage) {
																									if(taskdata[0].invoice.amount.extra_amount && taskdata[0].invoice.amount.extra_amount != ''){
																									var temporaryprice =  parseInt(taskdata[0].invoice.amount.total) + parseInt(taskdata[0].invoice.amount.extra_amount);
																									invoice.amount.discount = (parseInt(data[i].amount_percentage)).toFixed(2);
																									}
																									else{
																									var temporaryprice =  parseInt(taskdata[0].invoice.amount.total);
																									invoice.amount.discount = (parseInt(data[i].amount_percentage)).toFixed(2);
																									}
																								}
																								else if (taskdata[0].invoice.amount.grand_total < data[i].amount_percentage) {
																									invoice.amount.discount = temporaryprice.toFixed(2);
																								} else {
																									invoice.amount.discount = temporaryprice.toFixed(2);
																								}
																							} else {


																							if(taskdata[0].invoice.amount.extra_amount && taskdata[0].invoice.amount.extra_amount != ''){
																								var temporaryprice =  parseInt(taskdata[0].invoice.amount.total) + parseInt(taskdata[0].invoice.amount.extra_amount);
																							}
																							else{
																								var temporaryprice =  parseInt(taskdata[0].invoice.amount.total);
																							}

																							var a = (parseFloat(temporaryprice) * (parseFloat(data[i].amount_percentage) / 100)).toFixed(2);
																								if (a > data[i].amount_percentage) {
																									invoice.amount.discount = (parseFloat(temporaryprice) * (parseFloat(data[i].amount_percentage) / 100)).toFixed(2);
																									//invoice.amount.discount = (parseFloat(data[i].amount_percentage)).toFixed(2);
																								} else if (a < data[i].amount_percentage) {
																									invoice.amount.discount = (parseFloat(temporaryprice) * (parseFloat(data[i].amount_percentage) / 100)).toFixed(2);
																								} else {
																									invoice.amount.discount = (parseFloat(temporaryprice) * (parseFloat(data[i].amount_percentage) / 100)).toFixed(2);
																								}
																							}
																							var taxa = parseFloat(temporaryprice) - parseFloat(invoice.amount.discount);
																							console.log("temporaryprice",temporaryprice)
																							console.log("taxa",taxa)

																						}
																					}
																					invoice.amount.grand_total = (parseFloat((taskdata[0].invoice.amount.grand_total))).toFixed(2);
																					var newtax = (parseFloat((settingdata.settings.service_tax) / 100) * taxa).toFixed(2);

																					console.log("newtax",newtax)

																					invoice.amount.service_tax = newtax;
																					invoice.amount.balance_amount = (parseFloat(taxa) + parseFloat(newtax));
																					invoice.coupon = req.body.coupon;
																					/*if (invoice.amount.discount >= taskdata[0].invoice.amount.grand_total) {
																						invoice.amount.discount = taskdata[0].invoice.amount.grand_total;
																					}*/
																					if (invoice.amount.discount >= taskdata[0].invoice.amount.total) {
																						invoice.amount.discount = taskdata[0].invoice.amount.total;
																					}
																					/*if (invoice.amount.discount >= taskdata[0].invoice.amount.balance_amount) {
																						invoice.amount.discount = taskdata[0].invoice.amount.balance_amount;
																					}*/
																					if (invoice.amount.grand_total <= 0) {
																						invoice.amount.grand_total = 0;
																					}
																					if (invoice.amount.balance_amount <= 0) {
																						invoice.amount.balance_amount = 0;
																					}
																					var update = { 'invoice.amount.coupon': invoice.amount.discount, 'invoice.coupon': invoice.amount.discount, 'invoice.amount.discount': invoice.amount.discount, 'invoice.amount.grand_total': invoice.amount.grand_total, 'invoice.amount.balance_amount': invoice.amount.balance_amount,'invoice.amount.service_tax': invoice.amount.service_tax };


																					console.log("update",update)


																					db.UpdateDocument('task', { _id: new mongoose.Types.ObjectId(req.body.task) }, update, function (err, result) {
																						if (err) {
																							res.send(err);
																						} else {
																							db.GetDocument('task', { _id: new mongoose.Types.ObjectId(req.body.task) }, {}, {}, function (err, tasklastdata) {
																								res.send(tasklastdata);
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
	};


	controller.removeCoupon = function removeCoupon(req, res) {
		db.GetDocument('task', { _id: new mongoose.Types.ObjectId(req.body.task), 'invoice.coupon': req.body.coupon }, {}, {}, function (err, taskdata) {
			var invoice = {};
			invoice.amount = {};
			invoice.amount.coupon = 0;
			invoice.amount.discount = 0;
			invoice.amount.balance_amount = parseFloat((taskdata[0].invoice.amount.balance_amount) + (taskdata[0].invoice.amount.coupon));
			invoice.coupon = "";
			var update = { 'invoice.amount.balance_amount': invoice.amount.balance_amount, 'invoice.coupon': invoice.coupon, 'invoice.amount.coupon': invoice.amount.coupon, 'invoice.amount.discount': invoice.amount.discount };
			db.UpdateDocument('task', { _id: new mongoose.Types.ObjectId(req.body.task) }, update, function (err, result) {
				if (err) {
					res.send(err);
				} else {
					db.GetDocument('task', { _id: new mongoose.Types.ObjectId(req.body.task) }, {}, {}, function (err, tasklastdata) {
						res.send(tasklastdata);
					});
				}
			});
		});
	};


	controller.removeCouponold = function removeCouponold(req, res) {
		var request = {};
		request.task = req.body.taskid;

		db.GetDocument('task', { _id: req.body.coupon }, {}, {}, function (err, docdata) {
			if (err || !docdata) {
				res.send(err);
			} else {
				async.parallel([
					function (callback) {
						db.GetOneDocument('task', { _id: request.task }, {}, {}, function (err, task) {
							callback(err, task);
						});
					},
					function (callback) {
						db.GetOneDocument('tasker', { _id: task.tasker }, {}, {}, function (err, tasker) {
							callback(err, task, tasker);
						});
					}
				], function (err) {



					if (err) {
						res.status(400).send(err);
					} else {
						var dataToUpdate = {};
						dataToUpdate.invoice = task.invoice;
						dataToUpdate.invoice.status = 0;

					}
				});
			}
		});
	}

	controller.getTaskDetails = function getTaskDetails(req, res) {
		db.GetDocument('review', { 'user': req.body._id }, {}, {}, function (err, data) {
			if (err) {
				res.send(err);
			} else {
				res.send(data);
			}
		});
	}

	controller.gettaskreview = function getTaskDetails(req, res) {
		db.GetDocument('review', { 'task': req.body.taskid, 'type': 'user' }, {}, {}, function (err, data) {
			if (err) {
				res.send(err);
			} else {
				res.send(data);
			}
		});
	}

	controller.downloadPdf = function downloadPdf(req, res) {
		var options = {};
		options.populate = 'tasker user category transactions';
		db.GetOneDocument('task', { _id: req.query.trans }, {}, { options }, function (err, task) {
			if (err) {
			} else {
				db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
					if (err || !currencies) {
					} else {
						db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {

							if (err || !settings) {
							} else {
								var data = {};
								data.admin_commission = currencies.symbol + " " + (task.invoice.amount.admin_commission * req.query.value).toFixed(2);
								data.grand_total = req.query.symbol + " " + ((task.invoice.amount.total - task.invoice.amount.admin_commission) * req.query.value).toFixed(2);
								data.Tasker_Earnings = req.query.symbol + " " + ((task.invoice.amount.grand_total - task.invoice.amount.service_tax) * req.query.value).toFixed(2);
								if (task.invoice.amount.extra_amount) {
									data.extra_amount = req.query.symbol + " " + ((task.invoice.amount.extra_amount) * req.query.value).toFixed(2) || 0;
								} else {
									data.extra_amount = req.query.symbol + " " + 0
								}
								data.first_name = task.tasker.name.first_name;
								data.last_name = task.tasker.name.last_name;
								data.Category_Name = task.category.name;
								data.User_Name = task.user.name.first_name;
								data.Task_Address = task.user.address.city;
								data.Total_Hours = task.invoice.worked_hours_human;
								data.minimum_cost = req.query.symbol + " " + (task.invoice.amount.minimum_cost * req.query.value).toFixed(2);
								data.perHour = req.query.symbol + " " + (task.hourly_rate * req.query.value).toFixed(2);
								data.Billing_Address = task.billing_address.line1 + ',\n ' + task.billing_address.line2 + ',\n ' + task.billing_address.city + ',' + task.billing_address.state + ',' + task.billing_address.country + ',' + task.billing_address.zipcode;
								data.Booking_Date = moment(task.history.booking_date).format(settings.settings.date_format);
								data.Job_Completed_Date = moment(task.history.job_completed_time).format(settings.settings.date_format);
								data.booking_id = task.booking_id;
								data.site_title = settings.settings.site_title;
								data.site_url = settings.settings.site_url;
								data.email = settings.settings.email_address;
								data.logo = settings.settings.site_url + settings.settings.logo;
								fs.readFile('./views/invoice/template.pug', 'utf8', function (err, invoice) {
									if (err) {
										throw err;
									} else {
										var fn = pug.compile(invoice);
										var html = fn(data);
										var options = { format: 'Letter' };
										var filename = new Date().getTime();
										pdf.create(html, options).toFile('./uploads/invoice/' + filename + '.pdf', function (err, document) {
											if (err) {
												res.send(err);
											} else {
												res.download(document.filename);
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

	controller.userdownloadPdf = function userdownloadPdf(req, res) {
		console.log("req.query.value", req.query.value)

		var options = {};
		options.populate = 'tasker user category transactions';
		db.GetOneDocument('task', { _id: req.query.trans }, {}, { options }, function (err, task) {
			if (err) {
			} else {
				db.GetOneDocument('currencies', { 'default': 1 }, {}, {}, function (err, currencies) {
					if (err || !currencies) {
					} else {
						db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
							if (err || !settings) {
							} else {
								var data = {};
								data.service_tax = req.query.symbol + " " + (task.invoice.amount.service_tax * req.query.value).toFixed(2);
								data.grand_total = req.query.symbol + " " + (task.invoice.amount.grand_total * req.query.value).toFixed(2);
								data.Total_Hours = req.query.symbol + " " + (task.invoice.amount.total * req.query.value).toFixed(2);
								if (task.invoice.amount.extra_amount) {
									data.extra_amount = req.query.symbol + " " + ((task.invoice.amount.extra_amount) * req.query.value).toFixed(2) || 0;
								} else {
									data.extra_amount = req.query.symbol + " " + 0
								}
								data.first_name = task.tasker.name.first_name;
								data.last_name = task.tasker.name.last_name;
								data.Category_Name = task.category.name;
								data.User_Name = task.user.name.first_name;
								data.Task_Address = task.user.address.city;
								data.Total_Hrs = task.invoice.worked_hours;
								data.Total_Hours = task.invoice.worked_hours_human;
								data.symbol = req.query.symbol;
								data.minimum_cost = req.query.symbol + " " + (task.invoice.amount.minimum_cost * req.query.value).toFixed(2);
								if (task.invoice.amount.coupon) {
									data.Discount = (task.invoice.amount.coupon * req.query.value).toFixed(2) || 0;
								}
								else {
									data.Discount = req.query.symbol + " " + 0;
								}
								data.total = req.query.symbol + " " + (task.invoice.amount.total * req.query.value).toFixed(2);
								data.perHour = req.query.symbol + " " + (task.hourly_rate * req.query.value).toFixed(2);
								data.Billing_Address = task.billing_address.line1 + ',\n ' + task.billing_address.line2 + '\n ' + task.billing_address.city + ',' + task.billing_address.state + ',' + task.billing_address.country + ',' + task.billing_address.zipcode;
								data.Booking_Date = moment(task.history.booking_date).format(settings.settings.date_format);
								data.Job_Completed_Date = moment(task.history.job_completed_time).format(settings.settings.date_format);
								data.booking_id = task.booking_id;
								data.site_title = settings.settings.site_title;
								data.site_url = settings.settings.site_url;
								data.email = settings.settings.email_address;
								data.logo = settings.settings.site_url + settings.settings.logo;

								fs.readFile('./views/invoice/usertemplate.pug', 'utf8', function (err, invoice) {
									if (err) {
										throw err;
									} else {
										var fn = pug.compile(invoice);
										var html = fn(data);
										var options = { format: 'Letter' };
										var filename = new Date().getTime();
										pdf.create(html, options).toFile('./uploads/invoice/' + filename + '.pdf', function (err, document) {
											if (err) {
												res.send(err);
											} else {
												res.download(document.filename);
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


	controller.getcancelreason = function getcancelreason(req, res) {
		var query = {};
		if (req.body.type == 'user') {
			query = { 'type': 'user', 'status': 1 }
		} else {
			query = { 'type': 'tasker', 'status': 1 }
		}
		db.GetDocument('cancellation', query, {}, {}, function (err, data) {
			if (err) {
				res.send(err);
			} else {
				res.send(data);
			}
		});
	}

	controller.saveaccountinfo = function (req, res) {
		var request = {};
		request.userid = req.body.userId;
		request.banking = {};
		request.banking.acc_holder_name = req.body.acc_holder_name;
		request.banking.acc_holder_address = req.body.acc_holder_address;
		request.banking.acc_number = req.body.acc_number;
		request.banking.bank_name = req.body.bank_name;
		request.banking.branch_name = req.body.branch_name;
		request.banking.branch_address = req.body.branch_address;
		request.banking.swift_code = req.body.swift_code;
		request.banking.routing_number = req.body.routing_number;

		db.UpdateDocument('tasker', { '_id': request.userid }, { 'banking': request.banking }, {}, function (err, response) {
			if (err || response.nModified == 0) {
				res.send(err);
			} else {
				res.send(response);
			}
		});
	}

	controller.paymentmode = function paymentmode(req, res) {

		db.GetDocument('paymentgateway', { $and: [{ status: { $ne: 0 } }, { status: { $ne: 2 } }] }, {}, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
					if (err) {
						res.send(err);
					} else {
						var paymentArr = [];
						if (settings.settings.wallet.status == 1) {
							paymentArr.push({ 'name': 'Pay Using Wallet', 'code': 'wallet' });
						}
						for (var i = 0; i < docdata.length; i++) {
							if (docdata[i].alias == "stripe") {
								docdata[i].gateway_name = "Pay Using Card";
								paymentArr.push({ 'name': docdata[i].gateway_name, 'code': docdata[i].alias });
							}
							if (docdata[i].alias == "paypal") {
								docdata[i].gateway_name = "Pay Using " + docdata[i].gateway_name;
								paymentArr.push({ 'name': docdata[i].gateway_name, 'code': docdata[i].alias });
							}
						}
						res.send(paymentArr);
					}
				});
			}
		});
	}

	controller.checkphoneno = function (req, res) {
		db.GetDocument('tasker', { "phone.code": req.body.code, "phone.number": req.body.number }, {}, {}, function (err, docdata) {
			if (err) {
				res.send(err);
			} else {
				res.send(docdata);
			}
		});
	};

	controller.getPaymentdetails = function (req, res) {
		db.GetDocument('paymentgateway', {}, {}, {}, function (err, paymentgateway) {
			if (err) {
				res.send(err);
			} else {
				res.send(paymentgateway);
			}
		});
	};
	return controller;
};
