"use strict";

module.exports = function () {
    var mongoose = require('mongoose');
    var db = require('../../controller/adaptor/mongodb.js');
    var attachment = require('../../model/attachments.js');
    var Jimp = require("jimp");
    var fs = require("fs");

    var controller = {};
 
    controller.savepaymentprice = function (req, res) {
        req.checkBody('status', 'Invalid status').notEmpty();
        req.checkBody('name', 'Invalid name').notEmpty();
        req.checkBody('seo.title', 'Invalid title').notEmpty();        
        var errors = req.validationErrors();
        if (errors) {
            res.send(errors);
            return;
        }
        if (typeof req.files.image != 'undefined') {
            if (req.files.image.length > 0) {
                req.body.image = attachment.get_attachment(req.files.image[0].destination, req.files.image[0].filename);
                req.body.img_name = encodeURI(req.files.image[0].filename);
                req.body.img_path = req.files.image[0].destination.substring(2);
            }
        }   

        if (req.body._id) {
            db.UpdateDocument('posttask', { _id: req.body._id }, req.body, { multi: true }, function (err, docdata) {
                if (err) {
                    res.send(err);
                } else {
                    res.send(docdata);
                }
            });
        } else {            
            db.InsertDocument('posttask', req.body, function (err, result) {
                if (err) {
                    res.send(err);
                } else {
                    res.send(result);
                }
            });
        }
    }


    controller.edit = function (req, res) {
        db.GetOneDocument('posttask', { _id: req.body.id }, {}, {}, function (err, docdata) {
            if (err) {
                res.send(err);
            } else {
                res.send(docdata);
            }
        });
    };


    controller.getSetting = function (req, res) {
        db.GetDocument('settings', { alias: 'general' }, {}, {}, function (err, docdata) {
            if (err) {
                res.send(err);
            } else {
                res.send(docdata);
            }
        });
    };

    controller.list = function (req, res) {
        if (req.query.sort != "") {
            var sorted = req.query.sort;
        }
        var categoryQuery = [{
            "$match": { status: { $ne: 0 }, parent: { $exists: false } }
        }, {
            $project: {
                name: 1,
                description: 1,
                seo: 1,
                image: 1,
                status: 1,
                dname: { $toLower: '$' + sorted }
            }
        }, {
            $project: {
                name: 1,
                document: "$$ROOT"
            }
        }, {
            $group: { "_id": null, "count": { "$sum": 1 }, "documentData": { $push: "$document" } }
        }];

        var sorting = {};
        var searchs = '';


        if (Object.keys(req.query).length != 0) {
            categoryQuery.push({ $unwind: { path: "$documentData", preserveNullAndEmptyArrays: true } });

            if (req.query.search != '' && req.query.search != 'undefined' && req.query.search) {
                searchs = req.query.search;
                categoryQuery.push({ "$match": { "documentData.name": { $regex: searchs + '.*', $options: 'si' } } });
                //search limit
                categoryQuery.push({ $group: { "_id": null, "countvalue": { "$sum": 1 }, "documentData": { $push: "$documentData" } } });
                categoryQuery.push({ $unwind: { path: "$documentData", preserveNullAndEmptyArrays: true } });
                if (req.body.limit && req.body.skip >= 0) {
                    categoryQuery.push({ '$skip': parseInt(req.body.skip) }, { '$limit': parseInt(req.body.limit) });
                }
                categoryQuery.push({ $group: { "_id": null, "count": { "$first": "$countvalue" }, "documentData": { $push: "$documentData" } } });
                //search limit
            }
            if (req.query.sort !== '' && req.query.sort) {
                sorting = {};
                if (req.query.status == 'false') {
                    sorting["documentData.dname"] = -1;
                    categoryQuery.push({ $sort: sorting });
                } else {
                    sorting["documentData.dname"] = 1;
                    categoryQuery.push({ $sort: sorting });
                }
            }
            if (req.query.limit != 'undefined' && req.query.skip != 'undefined') {
                categoryQuery.push({ '$skip': parseInt(req.query.skip) }, { '$limit': parseInt(req.query.limit) });
            }
            //categoryQuery.push({ $group: { "_id": null, "count": { "$first": "$count" }, "documentData": { $push: "$documentData" } } });
            if (!req.body.search) {
                categoryQuery.push({ $group: { "_id": null, "count": { "$first": "$count" }, "documentData": { $push: "$documentData" } } });
            }
        }


        db.GetAggregation('posttask', categoryQuery, function (err, docdata) {
            if (err) {
                res.send(err);
            } else {
                if (docdata.length != 0) {
                    res.send([docdata[0].documentData, docdata[0].count]);
                } else {
                    res.send([0, 0]);
                }
            }
        });
    }

   


    controller.getpaymentlistdropdown = function (req, res) {
        db.GetDocument('posttask', { status: { $ne: 0 } }, {}, {}, function (err, docdata) {
            if (err) {
                res.send(err);
            } else {
                res.send(docdata);
            }
        });
    }

    controller.deletepage = function (req, res) {
        req.checkBody('delData', 'Invalid delData').notEmpty();
        var errors = req.validationErrors();
        if (errors) {
            res.send(errors, 400);
            return;
        }
        db.UpdateDocument('category', { _id: { $in: req.body.delData } }, { 'status': 0 }, { multi: true }, function (err, docdata) {

            // db.DeleteDocument('category', {_id:{$in:req.body.delData}},function(err,docdata){
            if (err) {
                res.send(err);
            } else {

                res.send(docdata);
            }
        });
    }

    controller.deletepaymentprice = function (req, res) {        
        req.checkBody('delData', 'Invalid delData').notEmpty();
        var errors = req.validationErrors();
        if (errors) {
            res.send(errors, 400);
            return;
        }
        db.UpdateDocument('posttask', { _id: { $in: req.body.delData } }, { 'status': 0 }, { multi: true }, function (err, docdata) {
             if (err) {
                        res.send(err);
                    } else {

                        res.send(docdata);
                    }

        });
    }   


    return controller;
}
