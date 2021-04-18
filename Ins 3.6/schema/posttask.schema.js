var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var POSTTASK_SCHEMA = {};
POSTTASK_SCHEMA.POSTTASK = {
    name: String,    
    image: String,
    img_name:String,
    img_path:String,
    description: String,
    seo: {
        title: String        
    },
    status: { type:Number, default:1 }
};

module.exports = POSTTASK_SCHEMA;
