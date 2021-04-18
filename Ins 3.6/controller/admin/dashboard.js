"use strict";
module.exports = function () {

    var db = require('../../controller/adaptor/mongodb.js');
    var async = require("async");
    var path = require('path');
    var fs = require('fs');


    var controller = {};

    controller.skeleton = function (req, res) {
        res.render('admin/skeleton', { image: '' });
    }


    controller.userImport = function (req, res) {
        var users = JSON.parse(fs.readFileSync(path.join(__dirname, "../../db.old/users.json"), 'utf8'));
        //var testUsers = users.slice(1, 10);
        var count = 1;
        async.everySeries(users, function (user, callback) {

            delete user._id
            user.addressList = user.addressList.map(function (item) {
                delete item._id;
                return item;
            });

            console.log(user);

            var userData = {
                unique_code: user.unique_code,
                username: user.username,
                email: user.email,
                password: user.password,
                role: user.role,
                gender: user.gender,
                geo: user.geo,
                location: user.location,
                status: user.status,
                verification_code: user.verification_code,
                addressList: user.addressList,
                address: user.address,
                name: user.name,
                phone: user.phone
            };

            db.InsertDocument('users', userData, function (err, result) {
                console.log('Record :: ', err, result);
                callback(null, count);
            });

        }, function (err, result) {
            console.log('::::::::::::::::::::::::::::::::::::::::: :: ', err, result);
            // if result is true then every file exists
            var data = {};
            data.response = 1;
            res.send(data);
        });
    }

    controller.taskerImport = function (req, res) {

        var taskers = JSON.parse(fs.readFileSync(path.join(__dirname, "../../db.old/tasker.json"), 'utf8'));
        //var testTaskers = taskers.slice(1, 3);


        var count = 1;
        async.everySeries(taskers, function (tasker, callback) {


            tasker.profile_details = tasker.profile_details.map(function (item) {
                var newq = item.question.$oid
                delete item.question;
                item.question = newq;
                return item;
            });

            tasker.taskerskills = tasker.taskerskills.map(function (item) {
                if (item.categoryid) {
                    var newcategoryid = item.categoryid.$oid
                    var newchildid = item.childid.$oid
                    var newexperience = item.experience.$oid
                    delete item.categoryid;
                    delete item.childid;
                    delete item.experience;
                    item.categoryid = newcategoryid;
                    item.childid = newchildid;
                    item.experience = newexperience;
                    return item;
                }

            });

            var taskerData = {

                working_area: tasker.working_area,
                username: tasker.username,
                email: tasker.email,
                password: tasker.password,
                phone: tasker.phone,
                gender: tasker.gender,
                birthdate: tasker.birthdate,
                working_days: tasker.working_days,
                avatar: tasker.avatar,
                taskerskills: [], //tasker.taskerskills
                Map: [],
                location: tasker.location,
                name: tasker.name,
                address: tasker.address,
                tasker_area: tasker.tasker_area,
                profile_details: tasker.profile_details,
                tearms: tasker.tearms,
                radius: tasker.radius,
                availability: tasker.availability,
                availability_address: tasker.availability_address,
                img_name: tasker.img_name,
                img_path: tasker.img_path,
                tasker_status: tasker.tasker_status,
                status: tasker.status,
                role: tasker.role,
                geo: tasker.geo,
                verification_code: tasker.verification_code,
                //activity: tasker.activity,
                refer_history: tasker.refer_history,
                device_info: tasker.device_info,
                radiusby: tasker.radiusby,
                device_info: tasker.device_info,
            };


            console.log('Location : ', taskerData.location);

            db.InsertDocument('tasker', taskerData, function (err, result) {
                if (err) {
                    taskerData.location = { lng: taskerData.location.lng, lat: taskerData.location.lat };
                    db.InsertDocument('tasker', taskerData, function (err, result) {
                        callback(err, result);
                    });
                } else {
                    console.log('Record :: ', err);
                    count++;
                    callback(err, result);
                }
            });


        }, function (err, result) {
            console.log('::::::::::::::::::::::::::::::::::::::::: :: ', err, result);
            // if result is true then every file exists
            var data = {};
            data.response = 1;
            res.send(data);
        });
    }




    controller.locationUpdate = function (req, res) {
        db.GetDocument('tasker', {}, {}, {}, function (err, taskers) {
            if (err) {
                res.send(err);
            } else {
                var count = 1;
                async.everySeries(taskers, function (tasker, callback) {
                    console.log('Old Location : ', tasker.location);
                    if (tasker.location.lat) {
                        tasker.location = { lat: tasker.location.lat, lng: tasker.location.lng };
                    }
                    console.log('New Location : ', tasker.location);
                    console.log('==========');
                    //if (tasker.location.lng) {

                    db.UpdateDocument('tasker', { _id: tasker._id }, { location: tasker.location }, {}, function (err, docdata) {
                        callback(err, tasker);
                    });

                    //callback(null, tasker);

                    //} else {
                    //   callback(null, tasker);
                    //}
                }, function (err, result) {
                    //console.log('::::::::::::::::::::::::::::::::::::::::: :: ', err, result);
                    // if result is true then every file exists
                    var data = {};
                    data.response = 1;
                    res.send(data);
                });
            }
        });
    }




    return controller;
}
