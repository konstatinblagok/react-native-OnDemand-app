var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var PEOPLECMD_SCHEMA = {};
PEOPLECMD_SCHEMA.PEOPLECMD = {
    name: String,  
    profession: String,  
    image: String,
    img_name:String,
    img_path:String,
    description: String,
    seo: {
        title: String        
    },
    status: { type:Number, default:1 }
};

module.exports = PEOPLECMD_SCHEMA;
