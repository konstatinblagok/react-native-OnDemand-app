var LocalStrategy = require('passport-local').Strategy;
var FacebookStrategy = require('passport-facebook').Strategy;
var CONFIG = require('../config/config'); //configuration variables
var User = require('../model/mongodb.js').users;
var Tasker = require('../model/mongodb.js').tasker;
var jwt = require('jsonwebtoken');
var async = require("async");
var mailcontent = require('../model/mailcontent.js');
var bcrypt = require('bcrypt-nodejs');
//var flash = require('connect-flash');
var twilio = require('../model/twilio.js');
var db = require('../controller/adaptor/mongodb.js');
var mongoose = require("mongoose");
var library = require('../model/library.js');
var otp = require('otplib/lib/authenticator');

var secret = otp.utils.generateSecret();

function jwtSign(payload) {
    var token = jwt.sign(payload, CONFIG.SECRET_KEY);
    return token;
}

module.exports = function (passport, io) {

    var userLibrary = require('../model/user.js')(io);


    passport.serializeUser(function (user, done) {
        done(null, user);
    });

    passport.deserializeUser(function (user, done) {
        done(null, { id: user.id });
    });

    passport.use('site-register', new LocalStrategy({
        usernameField: 'email',
        passwordField: 'pwd',
        passReqToCallback: true
    },
        function (req, email, pwd, done) {
            process.nextTick(function () {
                db.GetOneDocument('users', {"phone.number": req.body.phone.number }, {}, {}, function (err, pdocdata) {
                    if (err) {
                        return done(err);
                    } else {
                        if (pdocdata && pdocdata.phone.code == req.body.phone.code && pdocdata.phone.number == req.body.phone.number) {
                            return done('PHONE NUMBER ALREADY EXISTS', false, null);
                          } else {
                            db.GetOneDocument('users', {'username': req.body.username }, {}, {}, function (err, user) {
                              if (err) {
                                return done(err);
                              } else {
                                  if (user && user.username == req.body.username) {
                                    return done('USER NAME ALREADY EXISTS', false, null);
                                  } else {
                                    db.GetOneDocument('users', {'email': email }, {}, {}, function (err, users) {
                                      if (err) {
                                        return done(err);
                                      }
                                      else {
                                        if (users && users.email == req.body.email) {
                                          return done('EMAIL ID  ALREADY EXISTS', false, null);
                                        }
                                  // return done('Email Id Or User name already exists', false, null);
                                         else {
                                         db.GetOneDocument('settings', { 'alias': 'sms' }, {}, {}, function (err, smsdocdata) {
                                         if (err || !smsdocdata) {
                                          res.send(err);
                                         } else {
                                          var newUser = {};
                                          var authHeader = jwtSign({ username: req.body.username });
                                          newUser.unique_code = library.randomString(8, '#A');
                                          newUser.username = req.body.username;
                                          newUser.email = req.body.email;
                                          newUser.password = bcrypt.hashSync(req.body.pwd, bcrypt.genSaltSync(8), null);
                                          newUser.role = req.body.role;
                                          newUser.status = 1;
                                          newUser.address = req.body.address;
                                          newUser.phone = req.body.phone;
                                          newUser.referalcode = req.body.referalcode;
                                         if (smsdocdata.settings.twilio.mode == 'production') {
                                          newUser.verification_code = [{ "mobile": otp.generate(secret) }];
                                          }
                                          newUser.name = { 'first_name': req.body.firstname, 'last_name': req.body.lastname };
                                          newUser.activity = { 'created': req.body.today, 'modified': req.body.today, 'last_login': req.body.today, 'last_logout': req.body.today };

                                         //req.session.passport.header = authHeader;
                                          userLibrary.userRegister({ 'newUser': newUser, 'smsdocdata': smsdocdata }, function (err, response) {
                                         if (err || !response) {
                                          return done(err);
                                        } else {
                                          if(!newUser.referalcode) {
                                            db.InsertDocument('walletReacharge', {
                                              'user_id': response._id,
                                              "total": 0,
                                              'type': 'wallet',
                                              "transactions": [{
                                                'credit_type': 'Welcome',
                                                'ref_id': '',
                                                'trans_amount': 0,
                                                'trans_date': Date.now(),
                                                'trans_id': mongoose.Types.ObjectId()
                                              }]
                                            }, function (err, result) {
                                              if(err){
                                                return done(err);
                                              }
                                              else {
												var sessionData = {};
												sessionData.user = response;
												sessionData.header = ({ username: newUser.username });
                                                //req.session.passport.header = ({ username: newUser.username });
                                                return done(null, sessionData, { message: 'Login Success' });
                                              }
                                            });
                                          }
                                          else{
											var sessionData = {};
											sessionData.user = response;
											sessionData.header = ({ username: newUser.username });
                                            //req.session.passport.header = ({ username: newUser.username });
                                            return done(null, sessionData, { message: 'Login Success' });
                                          }
                                                    }
                                                });
                                             }
                                         });
                                      }
                                    }
                                  });
                                }
                              }
                          });
                        }
                     }
                });
            });
        }));


    passport.use('tasker-register', new LocalStrategy({
        usernameField: 'email',
        passwordField: 'pwd',
        passReqToCallback: true
    }, function (req, email, pwd, done) {

        process.nextTick(function () {
            db.GetOneDocument('tasker', { 'username': req.body.username, 'email': email }, {}, {}, function (err, user) {
                if (err) {
                    return done(err);
                } else {
                    if (user) {
                        return done(null, false, req.flash('Error', 'That email or username is already .'));
                    } else {
                        //var authHeader = generateToken();
                        var authHeader = jwtSign({ username: req.body.username });

                        /*
                        function generateToken() {
                            var token = jwt.sign({
                                id: req.body.user_name + ':' + req.body.pwd
                            }, 'token_with_username_and_password', {
                                    expiresIn: 12000
                                });
                            return token;
                        }
                        */

                        var newUser = new Tasker();
                        newUser.username = req.body.username;
                        newUser.email = req.body.email;
                        newUser.password = newUser.generateHash(req.body.pwd);
                        newUser.role = req.body.role;

                        newUser.save(function (err) {
                            if (err) {
                                return done(null, false, req.flash('Error', 'That email or username is already taken.'));
                            }
                            req.session.passport.header = authHeader;
                            return done(null, newUser);
                        });
                    }
                }
            });
        });
    }));


    passport.use('adminLogin', new LocalStrategy({
        usernameField: 'username',
        passwordField: 'password',
        passReqToCallback: true
    }, function (req, username, password, done) {
        var authHeader = jwtSign({ username: username });
        db.GetOneDocument('admins', { 'username': username, 'role': { $in: ['admin', 'subadmin'] }, 'status': 1 }, {}, {}, function (err, user) {
            if (err) {
                return done(err);
            } else {
                if (!user || !user.validPassword(password)) {
                    return done(null, false, { message: 'You are not authorized to sign in. Verify that you are using valid credentials' });
                } else {
                    //req.session.passport.header = authHeader;
                    var data = { activity: {} };
                    data.activity.last_login = Date();
                    db.UpdateDocument('admins', { _id: user._id }, data, {}, function (err, docdata) {
                        if (err) {
                            res.send(err);
                        } else {
							var sessionData = {};
							sessionData.user = user;
							sessionData.header = authHeader;
                            return done(null, sessionData);
                        }
                    });
                }
            }
        });
    }));


    passport.use('local-site-login', new LocalStrategy({
        usernameField: 'username',
        passwordField: 'password',
        passReqToCallback: true
    }, function (req, username, password, done) {
        console.log("username", username);
        var authHeader = jwtSign({ username: username });
        db.GetOneDocument('users', { $or: [{ 'username': username }, { 'email': username }, { 'phone.number': username }], 'status': { $ne: 0 } }, {}, {}, function (err, user) {
            if (err) {
                return done(err);
            } else {
                if (user) {
                    db.GetOneDocument('settings', { 'alias': 'sms' }, {}, {}, function (err, settings) {
                        if (err || !settings) {
                            return done(null, false, { message: 'Unable to get data' });
                        } else {
                            if (settings) {
                                if (settings.settings.twilio.mode == 'production') { //production
                                    db.GetOneDocument('users', { '_id': user._id, 'verification_code.mobile': { $exists: false } }, {}, {}, function (err, user) {
                                        if (err || !user) {
                                            return done(null, false, { message: 'Verify Your Mobile Number' });
                                        } else {
                                            if (user.password) {
                                                if (!user.validPassword(password)) {
                                                    return done(null, false, { message: 'Incorrect username/password.' });
                                                } else {
                                                    if (user.status == 2) {
                                                        return done(null, false, { message: 'Your account has been suspended , Please activate your account' });
                                                    }
                                                    else {
                                                        //req.session.passport.header = authHeader;
                                                        var data = { activity: {} };
                                                        data.activity.last_login = Date();
                                                        db.UpdateDocument('users', { _id: user._id }, data, {}, function (err, docdata) {
                                                            if (err) {
                                                                res.send(err);
                                                            } else {
																var sessionData = {};
																sessionData.user = user;
																sessionData.header = authHeader;
                                                                return done(null, sessionData, { message: 'Login Success' });
                                                            }
                                                        });
                                                    }
                                                }
                                            } else {
                                                return done(null, false, { message: 'Invalid Login, Please try again' });
                                            }
                                        }
                                    });
                                } else {
                                    db.GetOneDocument('users', { '_id': user._id }, {}, {}, function (err, user) {
                                        if (err || !user) {
                                            return done(null, false, { message: 'Invalid User' });
                                        } else {
                                            if (user.password) {
                                                if (!user.validPassword(password)) {
                                                    return done(null, false, { message: 'Incorrect username/password.' });
                                                } else {
                                                    if (user.status == 2) {
                                                        return done(null, false, { message: 'Your account has been suspended , Please activate your account' });
                                                    }
                                                    else {
                                                        //req.session.passport.header = authHeader;
                                                        var data = { activity: {} };
                                                        data.activity.last_login = Date();
                                                        db.UpdateDocument('users', { _id: user._id }, data, {}, function (err, docdata) {
                                                            if (err) {
                                                                res.send(err);
                                                            } else {
																var sessionData = {};
																sessionData.user = user;
																sessionData.header = authHeader;
                                                                return done(null, sessionData, { message: 'Login Success' });
                                                            }
                                                        });
                                                    }
                                                }
                                            } else {
                                                return done(null, false, { message: 'Invalid Login, Please try again' });
                                            }
                                        }
                                    });
                                }
                            }
                        }
                    })
                } else {
                    return done(null, false, { message: 'Invalid Login, Please try again' });
                }
            }
        })
    }));

    passport.use('local-taskersite-login', new LocalStrategy({
        usernameField: 'username',
        passwordField: 'password',
        passReqToCallback: true // allows us to pass back the entire request to the callback
    }, function (req, username, password, done) {
        var authHeader = jwtSign({ username: username });
        console.log("username", username);
        db.GetOneDocument('tasker', { $or: [{ 'username': username }, { 'email': username }, { 'phone.number': username }], 'status': { $in: [1, 2, 3] } }, {}, {}, function (err, user) {
            if (err) {
                return done(err);
            } else {
                if (!user || !user.validPassword(password)) {
                    return done(null, false, { message: 'Incorrect username/password.' });
                } else if (user.status == 2) {
                    return done(null, false, { message: 'Your Account has been deactivated or unverified , Please contact admin for more details' });
                } else if (user.status == 3) {
                    return done(null, false, { message: 'Admin need to verify your account' });
                } else {
                    //req.session.passport.header = authHeader;
                    var data = { activity: {} };
                    data.activity.last_login = Date();
                    db.UpdateDocument('tasker', { _id: user._id }, data, {}, function (err, docdata) {
                        if (err) {
                            res.send(err);
                        } else {
							var sessionData = {};
							sessionData.user = user;
							sessionData.header = authHeader;
                            return done(null, sessionData, { message: 'Login Success' });
                        }
                    });
                }
            }
        });
    }));

    passport.use(new FacebookStrategy({
        clientID: CONFIG.SOCIAL_NETWORKS.facebookAuth.clientID,
        clientSecret: CONFIG.SOCIAL_NETWORKS.facebookAuth.clientSecret,
        callbackURL: CONFIG.SOCIAL_NETWORKS.facebookAuth.callbackURL,
        profileFields: ['id', 'email', 'gender', 'link', 'locale', 'name', 'timezone', 'updated_time', 'verified']
    }, function (req, token, refreshToken, profile, done) {
        process.nextTick(function () {
            var usernamecheck = profile.name.givenName + profile.name.familyName;
            User.findOne({ $or: [{ 'username': usernamecheck }, { 'email': profile.emails[0].value }] }, function (err, user) {
                console.log('310err, user', err, user);
                if (err) {

                    return done(err);
                }
                var authHeader = jwtSign({ username: profile.username });
                if (user) {
                    if (user.status == 0) {
                        user.status = 1;
                        user.save(function (err) {
                            console.log('319err', err);
                            if (err) {
                                return done(null, false, { error: err });
                            } else {
                                return done(null, { "user": user, "header": authHeader });
                            }
                        });
                    } else {
                        return done(null, { "user": user, "header": authHeader }); // user found, return that user
                    }
                } else {
                    var newUser = new User();
                    newUser.username = profile.name.givenName + profile.name.familyName;
                    newUser.email = profile.emails[0].value;
                    newUser.role = 'user';
                    newUser.type = 'facebook';
                    newUser.status = 1;
                    newUser.unique_code = library.randomString(8, '#A');
                    console.log("newUser", newUser);
                    newUser.save(function (err) {
                        console.log('338err', err);
                        if (err) {
                            console.log("errr");
                            return done(null, false, { error: err });
                        }
                        else {
                            var mailData = {};
                            mailData.template = 'Sighnupmessage';
                            mailData.to = newUser.email;
                            mailData.html = [];
                            mailData.html.push({ name: 'name', value: newUser.username });
                            mailData.html.push({ name: 'email', value: newUser.email });
                            mailData.html.push({ name: 'referal_code', value: newUser.unique_code });
                            mailcontent.sendmail(mailData, function (err, response) { });

                            return done(null, { "user": newUser, "header": authHeader });
                        }
                    });
                }
            });
        });
    }));


    /*
    passport.use('facebook-register', new LocalStrategy({
        usernameField: 'email',
        passwordField: 'pwd',
        passReqToCallback: true
    }, function (req, email, pwd, done) {
        process.nextTick(function () {

            console.log('FB With LocalStrategy');

            db.GetOneDocument('users', { 'username': req.body.username, 'email': email }, {}, {}, function (err, user) {
                if (err) {
                    return done(err);
                } else {
                    if (user) {
                        return done('Email Id Or User name already exists', false, null);
                    } else {
                        var authHeader = jwtSign({ username: req.body.username });
                        var newUser = {};
                        newUser.unique_code = library.randomString(8, '#A');
                        newUser.username = req.body.username;
                        newUser.email = req.body.email;
                        newUser.password = bcrypt.hashSync(req.body.pwd, bcrypt.genSaltSync(8), null);
                        newUser.role = req.body.role;
                        newUser.status = 1;
                        newUser.location = req.body.location;
                        newUser.phone = req.body.phone;
                        if (req.body.type) {
                            newUser.type = req.body.type;
                        }
                        newUser.address = { 'city': req.body.location }
                        newUser.name = { 'first_name': req.body.firstname, 'last_name': req.body.lastname };
                        newUser.activity = { 'created': req.body.today, 'modified': req.body.today, 'last_login': req.body.today, 'last_logout': req.body.today };

                        db.InsertDocument('users', newUser, function (err, user) {
                            if (err) {
                                return done(null, false, req.flash('Error', 'That email or username is already taken.'));
                            }
                            req.session.passport.header = authHeader;
                            var mailData = {};
                            mailData.template = 'Sighnupmessage';
                            mailData.to = user.email;
                            mailData.html = [];
                            mailData.html.push({ name: 'name', value: user.name.first_name });
                            mailData.html.push({ name: 'email', value: user.email });
                            mailData.html.push({ name: 'referal_code', value: user.unique_code });
                            mailcontent.sendmail(mailData, function (err, response) { });
                            var data = {};
                            if (req.body.referalcode) {
                                db.GetOneDocument('settings', { 'alias': 'general' }, {}, {}, function (err, settings) {
                                    if (err || !settings) {
                                        data.response = 'Unable to get settings';
                                        res.send(data);
                                    } else {
                                        db.GetOneDocument('users', { 'unique_code': req.body.referalcode }, {}, {}, function (err, referer) {
                                            if (err || !referer) {
                                                data.response = 'Unable to get referer';
                                                res.send(data);
                                            } else {
                                                db.GetOneDocument('walletReacharge', { 'user_id': referer._id }, {}, {}, function (err, referwallet) {
                                                    if (err) {
                                                        data.response = 'Unable to get referwallet';
                                                        res.send(data);
                                                    } else {
                                                        if (referwallet) {
                                                            var walletArr = {
                                                                'type': 'CREDIT',
                                                                'credit_type': 'Referel',
                                                                'trans_amount': settings.settings.referral.amount.referrer,
                                                                'avail_amount': settings.settings.referral.amount.referrer,
                                                                'trans_date': Date.now(),
                                                                'trans_id': ''
                                                            };
                                                            db.UpdateDocument('walletReacharge', { 'user_id': referer._id }, { $push: { transactions: walletArr }, $set: { "total": parseInt(referwallet.total) + parseInt(settings.settings.referral.amount.referrer) } }, {}, function (referupErr, referupRespo) {
                                                                if (referupErr || referupRespo.nModified == 0) {
                                                                    data.response = 'Unable to get referwallet';
                                                                    res.send(data);
                                                                } else {
                                                                    return done(null, user);
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
                                                                    'credit_type': 'Referel',
                                                                    'ref_id': '',
                                                                    'trans_amount': settings.settings.referral.amount.referrer,
                                                                    'trans_date': Date.now(),
                                                                    'trans_id': mongoose.Types.ObjectId()
                                                                }]
                                                            }, function (err, result) {
                                                                db.UpdateDocument('users', { '_id': referer._id }, { 'wallet_id': result._id }, {}, function (err, userupdate) {
                                                                    if (err || userupdate.nModified == 0) {
                                                                        data.response = 'Unable to get userupdate';
                                                                        res.send(data);
                                                                    } else {
                                                                        return done(null, user);
                                                                    }
                                                                });
                                                                return done(null, user);
                                                            });
                                                        }
                                                    }
                                                    db.InsertDocument('walletReacharge', {
                                                        'user_id': user._id,
                                                        "total": settings.settings.wallet.amount.welcome,
                                                        'type': 'wallet',
                                                        "transactions": [{
                                                            'credit_type': 'welcome',
                                                            'ref_id': '',
                                                            'trans_amount': settings.settings.wallet.amount.welcome,
                                                            'trans_date': Date.now(),
                                                            'trans_id': mongoose.Types.ObjectId()
                                                        }]
                                                    }, function (err, result) {
                                                        db.UpdateDocument('users', { '_id': user._id }, { 'wallet_id': result._id }, {}, function (err, userupdate) {
                                                            if (err || userupdate.nModified == 0) {
                                                                data.response = 'Unable to get userupdate';
                                                                res.send(data);
                                                            } else {
                                                                return done(null, user);
                                                            }
                                                        });
                                                        return done(null, user);
                                                    });
                                                });
                                            }
                                        });
                                    }
                                });
                            }
                            return done(null, user);
                        });
                    }
                }
            });
        });
    }));
    */
};
