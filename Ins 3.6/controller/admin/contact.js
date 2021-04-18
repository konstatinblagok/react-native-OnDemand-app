"use strict";
module.exports = function () {
    var db = require('../../controller/adaptor/mongodb.js')
        , CONFIG = require('../../config/config');

    var attachment = require('../../model/attachments.js');
    var middlewares = require('../../model/middlewares.js');
    var controller = {};

    controller.list = function (req, res) {

        var errors = req.validationErrors();
        if (errors) {
            res.send(errors, 400);
            return;
        }

        if (req.body.sort) {
            var sorted = req.body.sort.field;
        }


        var bannerQuery = [{
            "$match": { status: { $ne: 0 } }
        }, {
            $project: {
                name: 1,
                email: 1,
                mobile: 1,
                subject: 1,
                message: 1,
                createdAt: 1,

            }
        }, {
            $project: {
                name: 1,
                document: "$$ROOT"
            }
        }, {
            $group: { "_id": null, "count": { "$sum": 1 }, "documentData": { $push: "$document" } }
        }];


        bannerQuery.push({ $unwind: { path: "$documentData", preserveNullAndEmptyArrays: true } });

        if (req.body.search) {
            var searchs = req.body.search;
            bannerQuery.push({
                "$match": {
                    $or: [
                        { "documentData.name": { $regex: searchs + '.*', $options: 'si' } },
                        { "documentData.email": { $regex: searchs + '.*', $options: 'si' } },
                        { "documentData.mobile": { $regex: searchs + '.*', $options: 'si' } },
                        { "documentData.subject": { $regex: searchs + '.*', $options: 'si' } },
                        { "documentData.message": { $regex: searchs + '.*', $options: 'si' } }

                    ]
                }
            });

            //search limit
            bannerQuery.push({ $group: { "_id": null, "countvalue": { "$sum": 1 }, "documentData": { $push: "$documentData" } } });
            bannerQuery.push({ $unwind: { path: "$documentData", preserveNullAndEmptyArrays: true } });
            if (req.body.limit && req.body.skip >= 0) {
                bannerQuery.push({ '$skip': parseInt(req.body.skip) }, { '$limit': parseInt(req.body.limit) });
            }
            bannerQuery.push({ $group: { "_id": null, "count": { "$first": "$countvalue" }, "documentData": { $push: "$documentData" } } });
            //search limit
        }

        var sorting = {};
        if (req.body.sort) {
            var sorter = 'documentData.' + req.body.sort.field;
            sorting[sorter] = req.body.sort.order;
            bannerQuery.push({ $sort: sorting });
        } else {
            sorting["documentData.createdAt"] = -1;
            bannerQuery.push({ $sort: sorting });
        }

        if ((req.body.limit && req.body.skip >= 0) && !req.body.search) {
            bannerQuery.push({ '$skip': parseInt(req.body.skip) }, { '$limit': parseInt(req.body.limit) });
        }
        //bannerQuery.push({ $group: { "_id": null, "count": { "$first": "$count" }, "documentData": { $push: "$documentData" } } });

        if (!req.body.search) {
            bannerQuery.push({ $group: { "_id": null, "count": { "$first": "$count" }, "documentData": { $push: "$documentData" } } });
        }

        db.GetAggregation('contact', bannerQuery, function (err, docdata) {
            /*if (err || docdata.length <= 0) {
                res.send([0, 0]);
            } else {

                res.send([docdata[0].documentData, docdata[0].count]);
            }*/
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

    controller.edit = function (req, res) {

        db.GetDocument('contact', { _id: req.body.id }, {}, {}, function (err, data) {
            if (err) {
                res.send(err);
            } else {
                res.send(data);
            }
        });
    }

    controller.save = function (req, res) {
        var data = {};
        data.title = req.body.title;
        data.description = req.body.description;

        data.status = req.body.status;
        if (req.file) { data.image = attachment.get_attachment(req.file.destination, req.file.filename) }


        if (req.body._id) {
            db.UpdateDocument('contact', { _id: { $in: req.body._id } }, data, function (err, result) {
                if (err) {
                    res.send(err);
                } else {
                    res.send(result);
                }
            });
        } else {

            data.status = req.body.status;
            db.InsertDocument('contact', data, function (err, result) {
                if (err) {
                    res.send(err);
                } else {
                    res.send(result);
                }
            });
        }
    }

    controller.deletecontact = function (req, res) {

        req.checkBody('delData', 'Invalid contact delData').notEmpty();
        var errors = req.validationErrors();
        if (errors) {
            res.send(errors, 400);
            return;
        }

        db.UpdateDocument('contact', { _id: { $in: req.body.delData } }, { status: 0 }, { multi: true }, function (err, docdata) {

            if (err) {
                res.send(err);
            } else {
                res.send(docdata);
            }
        });
    }



    controller.sendMail = function (req, res) {
    }
    return controller;
}
