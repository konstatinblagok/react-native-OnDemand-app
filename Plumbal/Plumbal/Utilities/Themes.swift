//
//  Themes.swift
//  Plumbal
//
//  Created by Casperon Tech on 07/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import SDWebImage
import SAWaveToast
import RKDropdownAlert

class Themes:NSObject,MFMessageComposeViewControllerDelegate{
    var amount : String = String()
    let Back_ImageView:UIImageView=UIImageView(frame: CGRect(x: 0, y: 3, width: 25, height: 25))
    let screenSize: CGRect = UIScreen.main.bounds
    let block: SDExternalCompletionBlock! = nil
    let  codename:NSArray=["Afghanistan(+93)", "Albania(+355)","Algeria(+213)","American Samoa(+1684)","Andorra(+376)","Angola(+244)","Anguilla(+1264)","Antarctica(+672)","Antigua and Barbuda(+1268)","Argentina(+54)","Armenia(+374)","Aruba(+297)","Australia(+61)","Austria(+43)","Azerbaijan(+994)","Bahamas(+1242)","Bahrain(+973)","Bangladesh(+880)","Barbados(+1246)","Belarus(+375)","Belgium(+32)","Belize(+501)","Benin(+229)","Bermuda(+1441)","Bhutan(+975)","Bolivia(+591)","Bosnia and Herzegovina(+387)","Botswana(+267)","Brazil(+55)","British Virgin Islands(+1284)","Brunei(+673)","Bulgaria(+359)","Burkina Faso(+226)","Burma (Myanmar)(+95)","Burundi(+257)","Cambodia(+855)","Cameroon(+237)","Canada(+1)","Cape Verde(+238)","Cayman Islands(+1345)","Central African Republic(+236)","Chad(+235)","Chile(+56)","China(+86)","Christmas Island(+61)","Cocos (Keeling) Islands(+61)","Colombia(+57)","Comoros(+269)","Cook Islands(+682)","Costa Rica(+506)","Croatia(+385)","Cuba(+53)","Cyprus(+357)","Czech Republic(+420)","Democratic Republic of the Congo(+243)","Denmark(+45)","Djibouti(+253)","Dominica(+1767)","Dominican Republic(+1809)","Ecuador(+593)","Egypt(+20)","El Salvador(+503)","Equatorial Guinea(+240)","Eritrea(+291)","Estonia(+372)","Ethiopia(+251)","Falkland Islands(+500)","Faroe Islands(+298)","Fiji(+679)","Finland(+358)","France (+33)","French Polynesia(+689)","Gabon(+241)","Gambia(+220)","Gaza Strip(+970)","Georgia(+995)","Germany(+49)","Ghana(+233)","Gibraltar(+350)","Greece(+30)","Greenland(+299)","Grenada(+1473)","Guam(+1671)","Guatemala(+502)","Guinea(+224)","Guinea-Bissau(+245)","Guyana(+592)","Haiti(+509)","Holy See (Vatican City)(+39)","Honduras(+504)","Hong Kong(+852)","Hungary(+36)","Iceland(+354)","India(+91)","Indonesia(+62)","Iran(+98)","Iraq(+964)","Ireland(+353)","Isle of Man(+44)","Israel(+972)","Italy(+39)","Ivory Coast(+225)","Jamaica(+1876)","Japan(+81)","Jordan(+962)","Kazakhstan(+7)","Kenya(+254)","Kiribati(+686)","Kosovo(+381)","Kuwait(+965)","Kyrgyzstan(+996)","Laos(+856)","Latvia(+371)","Lebanon(+961)","Lesotho(+266)","Liberia(+231)","Libya(+218)","Liechtenstein(+423)","Lithuania(+370)","Luxembourg(+352)","Macau(+853)","Macedonia(+389)","Madagascar(+261)","Malawi(+265)","Malaysia(+60)","Maldives(+960)","Mali(+223)","Malta(+356)","MarshallIslands(+692)","Mauritania(+222)","Mauritius(+230)","Mayotte(+262)","Mexico(+52)","Micronesia(+691)","Moldova(+373)","Monaco(+377)","Mongolia(+976)","Montenegro(+382)","Montserrat(+1664)","Morocco(+212)","Mozambique(+258)","Namibia(+264)","Nauru(+674)","Nepal(+977)","Netherlands(+31)","Netherlands Antilles(+599)","New Caledonia(+687)","New Zealand(+64)","Nicaragua(+505)","Niger(+227)","Nigeria(+234)","Niue(+683)","Norfolk Island(+672)","North Korea (+850)","Northern Mariana Islands(+1670)","Norway(+47)","Oman(+968)","Pakistan(+92)","Palau(+680)","Panama(+507)","Papua New Guinea(+675)","Paraguay(+595)","Peru(+51)","Philippines(+63)","Pitcairn Islands(+870)","Poland(+48)","Portugal(+351)","Puerto Rico(+1)","Qatar(+974)","Republic of the Congo(+242)","Romania(+40)","Russia(+7)","Rwanda(+250)","Saint Barthelemy(+590)","Saint Helena(+290)","Saint Kitts and Nevis(+1869)","Saint Lucia(+1758)","Saint Martin(+1599)","Saint Pierre and Miquelon(+508)","Saint Vincent and the Grenadines(+1784)","Samoa(+685)","San Marino(+378)","Sao Tome and Principe(+239)","Saudi Arabia(+966)","Senegal(+221)","Serbia(+381)","Seychelles(+248)","Sierra Leone(+232)","Singapore(+65)","Slovakia(+421)","Slovenia(+386)","Solomon Islands(+677)","Somalia(+252)","South Africa(+27)","South Korea(+82)","Spain(+34)","Sri Lanka(+94)","Sudan(+249)","Suriname(+597)","Swaziland(+268)","Sweden(+46)","Switzerland(+41)","Syria(+963)","Taiwan(+886)","Tajikistan(+992)","Tanzania(+255)","Thailand(+66)","Timor-Leste(+670)","Togo(+228)","Tokelau(+690)","Tonga(+676)","Trinidad and Tobago(+1868)","Tunisia(+216)","Turkey(+90)","Turkmenistan(+993)","Turks and Caicos Islands(+1649)","Tuvalu(+688)","Uganda(+256)","Ukraine(+380)","United Arab Emirates(+971)","United Kingdom(+44)","United States(+1)","Uruguay(+598)","US Virgin Islands(+1340)","Uzbekistan(+998)","Vanuatu(+678)","Venezuela(+58)","Vietnam(+84)","Wallis and Futuna(+681)","West Bank(970)","Yemen(+967)","Zambia(+260)","Zimbabwe(+263)"];
    let code:NSArray=["+93", "+355","+213","+1684","+376","+244","+1264","+672","+1268","+54","+374","+297","+61","+43","+994","+1242","+973","+880","+1246","+375","+32","+501","+229","+1441","+975","+591"," +387","+267","+55","+1284","+673","+359","+226","+95","+257","+855","+237","+1","+238","+1345","+236","+235","+56","+86","+61","+61","+57","+269","+682","+506","+385","+53","+357","+420","+243","+45","+253","+1767","+1809","+593","+20","+503","+240","+291","+372","+251"," +500","+298","+679","+358","+33","+689","+241","+220"," +970","+995","+49","+233","+350","+30","+299","+1473","+1671","+502","+224","+245","+592","+509","+39","+504","+852","+36","+354","+91","+62","+98","+964","+353","+44","+972","+39","+225","+1876","+81","+962","+7","+254","+686","+381","+965","+996","+856","+371","+961","+266","+231","+218","+423","+370","+352","+853","+389","+261","+265","+60","+960","+223","+356","+692","+222","+230","+262","+52","+691","+373","+377","+976","+382","+1664","+212","+258","+264","+674","+977","+31","+599","+687","+64","+505","+227","+234","+683","+672","+850","+1670","+47","+968","+92","+680","+507","+675","+595","+51","+63","+870","+48","+351","+1","+974","+242","+40","+7","+250","+590","+290","+1869","+1758","+1599","+508","+1784","+685","+378","+239","+966","+221","+381","+248","+232","+65","+421","+386","+677","+252","+27","+82","+34","+94","+249","+597","+268","+46","+41","+963","+886","+992","+255","+66","+670","+228","+690","+676","+1868","+216","+90","+993","+1649","+688","+256","+380","+971","+44","+1","+598","+1340","+998","+678","+58","+84","+681","+970","+967","+260","+263"];
    
    //MARK:- Function
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func CheckNullValue(_ value : Any?) -> String? {
        var  pureStr:String=""
        if value is NSNull || value == nil{
            return pureStr
        }
        pureStr = String(describing: value!)
        return pureStr
    }
    
    func getAddressForLatLng(_ latitude: String, longitude: String)->String {
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(constant.GooglemapAPI)&language=\(themes.getAppLanguage())")
        let data = try? Data(contentsOf: url!)
        var fullAddress = ""
        if data != nil{
            let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray {
                if(result.count != 0){
                    var result1 = NSArray()
                  
                        if let address = (result[0] as AnyObject)["address_components"] as? NSArray{
                            result1 = address
                        }
                        
                   
                    if result1.count != 0 {
                        //print("get current location \(result[1]["address_components"])")
                        var street : String = ""
                        var city : String = ""
                        var locality : String = ""
                        var state : String = ""
                        var country : String = ""
                        var zipcode : String = ""
                        
                        let streetNameStr : NSMutableString = NSMutableString()
                        
                        for item in result1{
                            let item1 = (item as AnyObject)["types"] as! NSArray
                            
                            if((item1.object(at: 0) as! String == "street_number") || (item1.object(at: 0) as! String == "premise") || (item1.object(at: 0) as! String == "route")) {
                                let number1 = (item as AnyObject)["long_name"] as! String
                                streetNameStr.append(number1)
                                street = streetNameStr  as String
                                
                            }else if(item1.object(at: 0) as! String == "locality"){
                                let city1 = (item as AnyObject)["long_name"]
                                city = city1 as! String
                                locality = ""
                            }else if(item1.object(at: 0) as! String == "administrative_area_level_2" || item1.object(at: 0) as! String == "political") {
                                let city1 = (item as AnyObject)["long_name"]
                                locality = city1 as! String
                            }else if(item1.object(at: 0) as! String == "administrative_area_level_1" || item1.object(at: 0) as! String == "political") {
                                let city1 = (item as AnyObject)["long_name"]
                                state = city1 as! String
                            }else if(item1.object(at: 0) as! String == "country")  {
                                let city1 = (item as AnyObject)["long_name"]
                                country = city1 as! String
                            }else if(item1.object(at: 0) as! String == "postal_code" ) {
                                let city1 = (item as AnyObject)["long_name"]
                                zipcode = city1 as! String
                            }
                        }
                        fullAddress = "\(street)$\(city)$\(locality)$\(state)$\(country)$\(zipcode)"
                        if themes.getAppLanguage() == "ta"{
                            if let address = (result[1] as AnyObject)["formatted_address"] as? String{
                                return address
                            }else{
                                return fullAddress
                            }
                            
                        }else{
                            if let address = (result[0] as AnyObject)["formatted_address"] as? String{
                                return address
                            }else{
                                return fullAddress
                            }
                            
                        }
                        
                        
                    }
                }
            }
        }
        return ""
    }

    func  UpdateUserLanguage()  {
        
        if(themes.Check_userID() != "")
        {
            let Param: Dictionary = ["userid":themes.getUserID(),"langcode":"\(self.getAppLanguage())"]
            // print(Param)
            URLhandler.sharedInstance.makeCall(constant.UpdateLanguage, param: Param as NSDictionary) {
                (responseObject, error) -> () in
                
                if(error != nil)
                {
                    
                }
                else
                {
                    if(responseObject != nil)
                    {
                        let status:NSString=self.CheckNullValue(responseObject?.object(forKey: "status"))! as! NSString
                        if(status == "1")
                        {
                        }
                        else
                        {
                            
                        }
                        
                        
                    }else{
                        
                    }
                }
            }
        }
        
    }
    
    func getCountryList() -> (NSDictionary) {
        let dict = [
            "AF" : ["Afghanistan", "93"],
            "AX" : ["Aland Islands", "358"],
            "AL" : ["Albania", "355"],
            "DZ" : ["Algeria", "213"],
            "AS" : ["American Samoa", "1"],
            "AD" : ["Andorra", "376"],
            "AO" : ["Angola", "244"],
            "AI" : ["Anguilla", "1"],
            "AQ" : ["Antarctica", "672"],
            "AG" : ["Antigua and Barbuda", "1"],
            "AR" : ["Argentina", "54"],
            "AM" : ["Armenia", "374"],
            "AW" : ["Aruba", "297"],
            "AU" : ["Australia", "61"],
            "AT" : ["Austria", "43"],
            "AZ" : ["Azerbaijan", "994"],
            "BS" : ["Bahamas", "1"],
            "BH" : ["Bahrain", "973"],
            "BD" : ["Bangladesh", "880"],
            "BB" : ["Barbados", "1"],
            "BY" : ["Belarus", "375"],
            "BE" : ["Belgium", "32"],
            "BZ" : ["Belize", "501"],
            "BJ" : ["Benin", "229"],
            "BM" : ["Bermuda", "1"],
            "BT" : ["Bhutan", "975"],
            "BO" : ["Bolivia", "591"],
            "BA" : ["Bosnia and Herzegovina", "387"],
            "BW" : ["Botswana", "267"],
            "BV" : ["Bouvet Island", "47"],
            "BQ" : ["BQ", "599"],
            "BR" : ["Brazil", "55"],
            "IO" : ["British Indian Ocean Territory", "246"],
            "VG" : ["British Virgin Islands", "1"],
            "BN" : ["Brunei Darussalam", "673"],
            "BG" : ["Bulgaria", "359"],
            "BF" : ["Burkina Faso", "226"],
            "BI" : ["Burundi", "257"],
            "KH" : ["Cambodia", "855"],
            "CM" : ["Cameroon", "237"],
            "CA" : ["Canada", "1"],
            "CV" : ["Cape Verde", "238"],
            "KY" : ["Cayman Islands", "345"],
            "CF" : ["Central African Republic", "236"],
            "TD" : ["Chad", "235"],
            "CL" : ["Chile", "56"],
            "CN" : ["China", "86"],
            "CX" : ["Christmas Island", "61"],
            "CC" : ["Cocos (Keeling) Islands", "61"],
            "CO" : ["Colombia", "57"],
            "KM" : ["Comoros", "269"],
            "CG" : ["Congo (Brazzaville)", "242"],
            "CD" : ["Congo, Democratic Republic of the", "243"],
            "CK" : ["Cook Islands", "682"],
            "CR" : ["Costa Rica", "506"],
            "CI" : ["Côte d'Ivoire", "225"],
            "HR" : ["Croatia", "385"],
            "CU" : ["Cuba", "53"],
            "CW" : ["Curacao", "599"],
            "CY" : ["Cyprus", "537"],
            "CZ" : ["Czech Republic", "420"],
            "DK" : ["Denmark", "45"],
            "DJ" : ["Djibouti", "253"],
            "DM" : ["Dominica", "1"],
            "DO" : ["Dominican Republic", "1"],
            "EC" : ["Ecuador", "593"],
            "EG" : ["Egypt", "20"],
            "SV" : ["El Salvador", "503"],
            "GQ" : ["Equatorial Guinea", "240"],
            "ER" : ["Eritrea", "291"],
            "EE" : ["Estonia", "372"],
            "ET" : ["Ethiopia", "251"],
            "FK" : ["Falkland Islands (Malvinas)", "500"],
            "FO" : ["Faroe Islands", "298"],
            "FJ" : ["Fiji", "679"],
            "FI" : ["Finland", "358"],
            "FR" : ["France", "33"],
            "GF" : ["French Guiana", "594"],
            "PF" : ["French Polynesia", "689"],
            "TF" : ["French Southern Territories", "689"],
            "GA" : ["Gabon", "241"],
            "GM" : ["Gambia", "220"],
            "GE" : ["Georgia", "995"],
            "DE" : ["Germany", "49"],
            "GH" : ["Ghana", "233"],
            "GI" : ["Gibraltar", "350"],
            "GR" : ["Greece", "30"],
            "GL" : ["Greenland", "299"],
            "GD" : ["Grenada", "1"],
            "GP" : ["Guadeloupe", "590"],
            "GU" : ["Guam", "1"],
            "GT" : ["Guatemala", "502"],
            "GG" : ["Guernsey", "44"],
            "GN" : ["Guinea", "224"],
            "GW" : ["Guinea-Bissau", "245"],
            "GY" : ["Guyana", "595"],
            "HT" : ["Haiti", "509"],
            "VA" : ["Holy See (Vatican City State)", "379"],
            "HN" : ["Honduras", "504"],
            "HK" : ["Hong Kong, Special Administrative Region of China", "852"],
            "HU" : ["Hungary", "36"],
            "IS" : ["Iceland", "354"],
            "IN" : ["India", "91"],
            "ID" : ["Indonesia", "62"],
            "IR" : ["Iran, Islamic Republic of", "98"],
            "IQ" : ["Iraq", "964"],
            "IE" : ["Ireland", "353"],
            "IM" : ["Isle of Man", "44"],
            "IL" : ["Israel", "972"],
            "IT" : ["Italy", "39"],
            "JM" : ["Jamaica", "1"],
            "JP" : ["Japan", "81"],
            "JE" : ["Jersey", "44"],
            "JO" : ["Jordan", "962"],
            "KZ" : ["Kazakhstan", "77"],
            "KE" : ["Kenya", "254"],
            "KI" : ["Kiribati", "686"],
            "KP" : ["Korea, Democratic People's Republic of", "850"],
            "KR" : ["Korea, Republic of", "82"],
            "KW" : ["Kuwait", "965"],
            "KG" : ["Kyrgyzstan", "996"],
            "LA" : ["Lao PDR", "856"],
            "LV" : ["Latvia", "371"],
            "LB" : ["Lebanon", "961"],
            "LS" : ["Lesotho", "266"],
            "LR" : ["Liberia", "231"],
            "LY" : ["Libya", "218"],
            "LI" : ["Liechtenstein", "423"],
            "LT" : ["Lithuania", "370"],
            "LU" : ["Luxembourg", "352"],
            "MO" : ["Macao, Special Administrative Region of China", "853"],
            "MK" : ["Macedonia, Republic of", "389"],
            "MG" : ["Madagascar", "261"],
            "MW" : ["Malawi", "265"],
            "MY" : ["Malaysia", "60"],
            "MV" : ["Maldives", "960"],
            "ML" : ["Mali", "223"],
            "MT" : ["Malta", "356"],
            "MH" : ["Marshall Islands", "692"],
            "MQ" : ["Martinique", "596"],
            "MR" : ["Mauritania", "222"],
            "MU" : ["Mauritius", "230"],
            "YT" : ["Mayotte", "262"],
            "MX" : ["Mexico", "52"],
            "FM" : ["Micronesia, Federated States of", "691"],
            "MD" : ["Moldova", "373"],
            "MC" : ["Monaco", "377"],
            "MN" : ["Mongolia", "976"],
            "ME" : ["Montenegro", "382"],
            "MS" : ["Montserrat", "1"],
            "MA" : ["Morocco", "212"],
            "MZ" : ["Mozambique", "258"],
            "MM" : ["Myanmar", "95"],
            "NA" : ["Namibia", "264"],
            "NR" : ["Nauru", "674"],
            "NP" : ["Nepal", "977"],
            "NL" : ["Netherlands", "31"],
            "AN" : ["Netherlands Antilles", "599"],
            "NC" : ["New Caledonia", "687"],
            "NZ" : ["New Zealand", "64"],
            "NI" : ["Nicaragua", "505"],
            "NE" : ["Niger", "227"],
            "NG" : ["Nigeria", "234"],
            "NU" : ["Niue", "683"],
            "NF" : ["Norfolk Island", "672"],
            "MP" : ["Northern Mariana Islands", "1"],
            "NO" : ["Norway", "47"],
            "OM" : ["Oman", "968"],
            "PK" : ["Pakistan", "92"],
            "PW" : ["Palau", "680"],
            "PS" : ["Palestinian Territory, Occupied", "970"],
            "PA" : ["Panama", "507"],
            "PG" : ["Papua New Guinea", "675"],
            "PY" : ["Paraguay", "595"],
            "PE" : ["Peru", "51"],
            "PH" : ["Philippines", "63"],
            "PN" : ["Pitcairn", "872"],
            "PL" : ["Poland", "48"],
            "PT" : ["Portugal", "351"],
            "PR" : ["Puerto Rico", "1"],
            "QA" : ["Qatar", "974"],
            "RE" : ["Réunion", "262"],
            "RO" : ["Romania", "40"],
            "RU" : ["Russian Federation", "7"],
            "RW" : ["Rwanda", "250"],
            "SH" : ["Saint Helena", "290"],
            "KN" : ["Saint Kitts and Nevis", "1"],
            "LC" : ["Saint Lucia", "1"],
            "PM" : ["Saint Pierre and Miquelon", "508"],
            "VC" : ["Saint Vincent and Grenadines", "1"],
            "BL" : ["Saint-Barthélemy", "590"],
            "MF" : ["Saint-Martin (French part)", "590"],
            "WS" : ["Samoa", "685"],
            "SM" : ["San Marino", "378"],
            "ST" : ["Sao Tome and Principe", "239"],
            "SA" : ["Saudi Arabia", "966"],
            "SN" : ["Senegal", "221"],
            "RS" : ["Serbia", "381"],
            "SC" : ["Seychelles", "248"],
            "SL" : ["Sierra Leone", "232"],
            "SG" : ["Singapore", "65"],
            "SX" : ["Sint Maarten", "1"],
            "SK" : ["Slovakia", "421"],
            "SI" : ["Slovenia", "386"],
            "SB" : ["Solomon Islands", "677"],
            "SO" : ["Somalia", "252"],
            "ZA" : ["South Africa", "27"],
            "GS" : ["South Georgia and the South Sandwich Islands", "500"],
            "SS​" : ["South Sudan", "211"],
            "ES" : ["Spain", "34"],
            "LK" : ["Sri Lanka", "94"],
            "SD" : ["Sudan", "249"],
            "SR" : ["Suriname", "597"],
            "SJ" : ["Svalbard and Jan Mayen Islands", "47"],
            "SZ" : ["Swaziland", "268"],
            "SE" : ["Sweden", "46"],
            "CH" : ["Switzerland", "41"],
            "SY" : ["Syrian Arab Republic (Syria)", "963"],
            "TW" : ["Taiwan, Republic of China", "886"],
            "TJ" : ["Tajikistan", "992"],
            "TZ" : ["Tanzania, United Republic of", "255"],
            "TH" : ["Thailand", "66"],
            "TL" : ["Timor-Leste", "670"],
            "TG" : ["Togo", "228"],
            "TK" : ["Tokelau", "690"],
            "TO" : ["Tonga", "676"],
            "TT" : ["Trinidad and Tobago", "1"],
            "TN" : ["Tunisia", "216"],
            "TR" : ["Turkey", "90"],
            "TM" : ["Turkmenistan", "993"],
            "TC" : ["Turks and Caicos Islands", "1"],
            "TV" : ["Tuvalu", "688"],
            "UG" : ["Uganda", "256"],
            "UA" : ["Ukraine", "380"],
            "AE" : ["United Arab Emirates", "971"],
            "GB" : ["United Kingdom", "44"],
            "US" : ["United States of America", "1"],
            "UY" : ["Uruguay", "598"],
            "UZ" : ["Uzbekistan", "998"],
            "VU" : ["Vanuatu", "678"],
            "VE" : ["Venezuela (Bolivarian Republic of)", "58"],
            "VN" : ["Viet Nam", "84"],
            "VI" : ["Virgin Islands, US", "1"],
            "WF" : ["Wallis and Futuna Islands", "681"],
            "EH" : ["Western Sahara", "212"],
            "YE" : ["Yemen", "967"],
            "ZM" : ["Zambia", "260"],
            "ZW" : ["Zimbabwe", "263"]
        ]
        
        return dict as (NSDictionary)
    }
    func validpasword(_ str: String) -> Bool {
        var lowerCaseLetter: Bool = false
        var digit: Bool = false
        for i in 0..<(str as NSString).length {
            let c: unichar = (str as NSString).character(at: i)
            if !lowerCaseLetter {
                lowerCaseLetter = CharacterSet.lowercaseLetters.contains(UnicodeScalar(c)!)
            }
            if !digit {
                digit = CharacterSet.decimalDigits.contains(UnicodeScalar(c)!)
            }
        }
        var isValid: Bool = false
        if digit && lowerCaseLetter  {
            isValid = true
        }
        return isValid
    }
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,1", "iPad5,3", "iPad5,4":           return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    func Currency_Symbol(_ Currency_code:String)->String{
        //        let localeComponents = [NSLocaleCurrencyCode: Currency_code]
        //        let localeIdentifier = NSLocale.localeIdentifierFromComponents(localeComponents)
        //        let locale = NSLocale(localeIdentifier: localeIdentifier)
        //        var currencySymbol = locale.objectForKey(NSLocaleCurrencySymbol) as! String
        //        let fmtr = NSNumberFormatter()
        //        fmtr.locale = locale
        //        fmtr.numberStyle = .CurrencyStyle
        //        currencySymbol = fmtr.currencySymbol!
        //        if currencySymbol.count > 1 {
        //            currencySymbol = currencySymbol.substringFromIndex(currencySymbol.startIndex.advancedBy(currencySymbol.count - 1))
        //        }
        //        return currencySymbol
        
        let currencyCode = Currency_code
        let currencySymbols  = Locale.availableIdentifiers
            .map { Locale(identifier: $0) }
            .filter {
                if let localeCurrencyCode = ($0 as NSLocale).object(forKey: NSLocale.Key.currencyCode) as? String {
                    return localeCurrencyCode == currencyCode
                } else {
                    return false
                }
            }
            .map {
                ($0.identifier, ($0 as NSLocale).object(forKey: NSLocale.Key.currencySymbol)!)
        }
        print( currencySymbols)
        return CheckNullValue((currencySymbols.first?.1))!
    }
    
    func applyBlurEffect(_ image: UIImage)->UIImage{
        let imageToBlur = CIImage(image: image)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(5, forKey: kCIInputRadiusKey)
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.value(forKey: "outputImage")! as! CIImage
        var blurredImage = UIImage(ciImage: resultImage)
        let cropped:CIImage=resultImage.cropping(to: CGRect(x: 0, y: 0,width: imageToBlur!.extent.size.width, height: imageToBlur!.extent.size.height))
        blurredImage = UIImage(ciImage: cropped)
        return blurredImage
    }
    
    func addBlur(_ view:UIView)->UIView {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha=0.8
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        view.addSubview(blurEffectView)
        return view
    }
    
    func RoundView(_ width:CGFloat)->CGFloat{
        return width/2
    }
    
    func Showtoast(_ ToastString:String)->SAWaveToast{
        let waveToast = SAWaveToast(text: "\(ToastString)", font: UIFont(name: "Raleway-Bold", size: 16.0), fontColor: UIColor.white)
        return waveToast
    }
    
    func saveCounrtyphone(_ countrycode: String) {
        UserDefaults.standard.set(countrycode, forKey: "countryphone")
        UserDefaults.standard.synchronize()
    }
    
    func getCounrtyphone() -> String {
        if UserDefaults.standard.object(forKey: "countryphone") != nil{
            return UserDefaults.standard.object(forKey: "countryphone") as! String
        }else{
            return ""
        }
    }
    
    func AlertView(_ title:String,Message:String,ButtonTitle:String){
        if(Message == kErrorMsg){
            RKDropdownAlert.title(Appname, message: Message as String, backgroundColor: UIColor.white , textColor: UIColor.red)
          return
        }
        RKDropdownAlert.dismissAllAlert()
        RKDropdownAlert.title(Appname, message: Message as String, backgroundColor: UIColor.white , textColor: PlumberThemeColor)
    }
    
    func calculateHeightForString(_ inString:String) -> CGFloat {
        let messageString = inString
        let attrString:NSAttributedString? = NSAttributedString(string: messageString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)])
        let rect:CGRect = attrString!.boundingRect(with: CGSize(width: 300.0,height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context:nil )//hear u will get nearer height not the exact value
        let requredSize:CGRect = rect
        return requredSize.height  //to include button's in your tableview
    }
    
    func saveLocationname(_ Locationname: String) {
        UserDefaults.standard.set(Locationname, forKey: "LocationName")
        UserDefaults.standard.synchronize()
    }
    
    func getLocationname() -> String {
        if (UserDefaults.standard.object(forKey: "LocationName") != nil){
            return UserDefaults.standard.object(forKey: "LocationName") as! String
        } else{
            return ""
        }
    }
    
    func saveLocationID(_ LocationID: String) {
        UserDefaults.standard.set(LocationID, forKey: "LocationID")
        UserDefaults.standard.synchronize()
    }
    
    func getLocationID() -> String {
        if ( UserDefaults.standard.object(forKey: "LocationID")  != nil) {
            return UserDefaults.standard.object(forKey: "LocationID") as! String
        } else{
            return ""
        }
    }
    
    func saveJaberID(_ JaberID: String) {
        UserDefaults.standard.set(JaberID, forKey: "JaberID")
        UserDefaults.standard.synchronize()
    }
    
    func getJaberID() -> String {
        if UserDefaults.standard.object(forKey: "JaberID") != nil{
            return UserDefaults.standard.object(forKey: "JaberID") as! String
        } else {
            return ""
        }
    }
    
    func saveaddresssegue(_ presval: String) {
        UserDefaults.standard.set(presval, forKey: "PressAddaddress")
        UserDefaults.standard.synchronize()
    }
    
    func getaddresssegue() -> String {
        if UserDefaults.standard.object(forKey: "PressAddaddress") != nil {
            return UserDefaults.standard.object(forKey: "PressAddaddress") as! String
        } else{
            return ""
        }
    }
    
    func removeRotation( _ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect.init(origin:CGPoint(x: 10, y: 20), size:image.size ))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    
    func rotateImage(_ image: UIImage) -> UIImage {
        if (image.imageOrientation == UIImageOrientation.up ) {
            return image
        }
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy!
    }
    
    func saveLanguage(_ str:NSString){
        var tempStr = str
        if(tempStr.isEqual(to: "tr")){
            tempStr="ta"
        }else if(tempStr.isEqual(to: "en")){
            tempStr="en"
        }else if(tempStr.isEqual(to: "pt_BR")){
            tempStr="pt_BR"
        }
        UserDefaults.standard.set(tempStr, forKey: "LanguageName")
        UserDefaults.standard.synchronize()
    }
    
    func SetLanguageToApp(){
        let savedLang=UserDefaults.standard.object(forKey: "LanguageName") as! NSString
        if(savedLang == "ta"){
            Language_handler.setApplicationLanguage(Language_handler.TamilLanguageShortName)
        }else if(savedLang == "en") {
            Language_handler.setApplicationLanguage(Language_handler.EnglishUSLanguageShortName)
        }
    }
    
    func setLang(_ text:String)->String{
        return Language_handler.VJLocalizedString(text, comment: nil)
    }
    
    func convertIntToString(_ integer : Int) -> NSString {
        var str:NSString = NSString()
        str = "\(integer)" as NSString
        return str
    }
    
    func convertIntToJobStatus(_ integer : Int) -> NSString {
        var str:NSString = NSString()
        str = "\(integer)" as NSString
        if (str == "1") {
            str = "Accepted"
        }else if (str == "2") {
            str = "Ongoing"
        } else if (str == "4") {
            str = "Completed"
        } else if (str == "5") {
            str = "Cancelled"
        } else if (str == "6") {
            str = "Disputed"
        }
        return str
    }
    
    func convertFloatToString(_ floating : Float) -> NSString {
        var str:NSString = NSString()
        str = "\(floating)" as NSString
        return str
    }
    
    
    
    //MARK:- MFMessageComposeViewController Delegate
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func configuredMessageComposeViewController(_ message:String,number:String) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        // messageComposeVC.recipients = textMessageRecipients
        messageComposeVC.body = "\(message)"
        messageComposeVC.recipients = [number]
        
        return messageComposeVC
    }
    
    @objc func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - NSUserDefault Function
    
    func saveUserID(_ userID: String) {
        UserDefaults.standard.set(userID, forKey: "userID")
        UserDefaults.standard.synchronize()
    }
    
    func saveUserPasswd(_ Passwd: String) {
        UserDefaults.standard.set(Passwd, forKey: "Password")
        UserDefaults.standard.synchronize()
    }
    
    func getUserPasswd() -> String {
        if UserDefaults.standard.object(forKey: "Password") != nil {
            return UserDefaults.standard.object(forKey: "Password") as! String
        } else{
            return ""
        }
    }
    
    func getUserID() -> String {
        if UserDefaults.standard.object(forKey: "userID") != nil {
            return UserDefaults.standard.object(forKey: "userID") as! String
        }else {
            return ""
        }
    }
    
    func Check_userID() -> String {
        if UserDefaults.standard.object(forKey: "userID") != nil{
            return UserDefaults.standard.object(forKey: "userID") as! String
        } else{
            return ""
        }
    }
    
    func saveUserName(_ UserName: String) {
        UserDefaults.standard.set(UserName, forKey: "UserName")
        UserDefaults.standard.synchronize()
    }
    
    func getUserName() -> String {
        if UserDefaults.standard.object(forKey: "UserName") != nil{
            return UserDefaults.standard.object(forKey: "UserName") as! String
        } else {
            return ""
        }
    }
    
    func saveCountryCode(_ CountryCode: String) {
        UserDefaults.standard.set(CountryCode, forKey: "CountryCode")
        UserDefaults.standard.synchronize()
    }
    
    func getCountryCode() -> String {
        if UserDefaults.standard.object(forKey: "CountryCode")  != nil{
            return UserDefaults.standard.object(forKey: "CountryCode") as! String
        } else{
            return ""
        }
    }
    
    func saveMobileNum(_ MobileNum: String) {
        UserDefaults.standard.set(MobileNum, forKey: "MobileNum")
        UserDefaults.standard.synchronize()
    }
    
    func getMobileNum() -> String {
        if UserDefaults.standard.object(forKey: "MobileNum") != nil{
            return UserDefaults.standard.object(forKey: "MobileNum") as! String
        } else{
            return ""
        }
    }
    
    func saveEmailID(_ EmailID: String) {
        UserDefaults.standard.set(EmailID, forKey: "EmailID")
        UserDefaults.standard.synchronize()
    }
    
    func getEmailID() -> String {
        if UserDefaults.standard.object(forKey: "EmailID") != nil{
            return UserDefaults.standard.object(forKey: "EmailID") as! String
        } else{
            return ""
        }
    }
    
    func saveuserDP(_ userDP: String) {
        UserDefaults.standard.set(userDP, forKey: "userDP")
        UserDefaults.standard.synchronize()
    }
    
    func getuserDP() -> String {
        if UserDefaults.standard.object(forKey: "userDP") != nil {
            return UserDefaults.standard.object(forKey: "userDP") as! String
        } else{
            return ""
        }
    }
    
    func saveCategoryString(_ CategoryString: String) {
        UserDefaults.standard.set(CategoryString, forKey: "CategoryString")
        UserDefaults.standard.synchronize()
    }
    
    func getCategoryString() -> String {
        if UserDefaults.standard.object(forKey: "CategoryString") != nil {
            return UserDefaults.standard.object(forKey: "CategoryString") as! String
        } else{
            return ""
        }
    }
    
    func saveWalletAmt(_ WalletAmt: String) {
        UserDefaults.standard.set(WalletAmt, forKey: "WalletAmt")
        UserDefaults.standard.synchronize()
    }
    
    func getWalletAmt() -> String {
        if UserDefaults.standard.object(forKey: "WalletAmt") != nil{
            return UserDefaults.standard.object(forKey: "WalletAmt") as! String
        } else{
            return ""
        }
    }
    
    func saveCurrencyCode(_ CurrencyCode: String) {
        UserDefaults.standard.set(CurrencyCode, forKey: "CurrencyCode")
        UserDefaults.standard.synchronize()
    }
    
    func getCurrencyCode() -> String {
        if UserDefaults.standard.object(forKey: "CurrencyCode") != nil{
            return UserDefaults.standard.object(forKey: "CurrencyCode") as! String
        }else{
            return ""
        }
    }
    
    func saveCurrency(_ Currency: String) {
        UserDefaults.standard.set(Currency, forKey: "Currency")
        UserDefaults.standard.synchronize()
    }
    
    func getCurrency() -> String {
        if UserDefaults.standard.object(forKey: "Currency") != nil{
            return UserDefaults.standard.object(forKey: "Currency") as! String
        } else{
            return ""
        }
    }
    
    func saveJaberPassword(_ JaberPassword: String) {
        UserDefaults.standard.set(JaberPassword, forKey: "JaberPassword")
        UserDefaults.standard.synchronize()
    }
    
    func getJaberPassword() -> String? {
        if UserDefaults.standard.object(forKey: "JaberPassword") != nil{
            return UserDefaults.standard.object(forKey: "JaberPassword") as? String
        } else {
            return ""
        }
    }
    
    //MARK: - Color Coding
    
    func HeaderThemeColor()->UIColor{
        var HeaderColor:UIColor=UIColor()
        HeaderColor = UIColor(patternImage: UIImage(named:"TopImage")!)
        return HeaderColor
    }
    
    func ThemeColour()->UIColor {
        var Theme_Color:UIColor!=UIColor()
        Theme_Color=nil
        Theme_Color = UIColor(red:0.14, green:0.12, blue:0.13, alpha:0.8)
        return PlumberThemeColor
    }
    
    func LightRed()->UIColor{
        return UIColor(red:0.97, green:0.51, blue:0.02, alpha:0.5)
    }
    
    func DarkRed()->UIColor{
        var loadercolor:UIColor=LightRed()
        loadercolor=loadercolor.withAlphaComponent(1.0)
        return loadercolor
    }
    
    func PaleWhiteColour()->UIColor{
        return UIColor(red: 0.918, green: 0.914, blue: 0.914, alpha: 1)
    }
    
    func Lightgray()->UIColor{
        return UIColor(red:216.0/255.0, green:216.0/255.0 ,blue:216.0/255.0, alpha:1.0)
    }
    
    func buttomBGColor()->UIColor{
        return UIColor(red:255.0/255.0, green:106.0/255.0, blue:1.0/255.0, alpha:1.0)
    }
    
    func getAppLanguage() -> String {
    if  themes.CheckNullValue(UserDefaults.standard.object(forKey: "LanguageName"))! == ""
        {
            UserDefaults.standard.set("en", forKey: "LanguageName")
        }
        if UserDefaults.standard.object(forKey: "LanguageName") as! String == "en"{
            
            return UserDefaults.standard.object(forKey: "LanguageName") as! String
        } else if UserDefaults.standard.object(forKey: "LanguageName") as! String == "ta" {
            return UserDefaults.standard.object(forKey: "LanguageName") as! String
        }
        else{
            return "ta"
        }
    }
    func getAppLang() -> String {
        if UserDefaults.standard.object(forKey: "LanguageName") as! String == "en"{
            
            return UserDefaults.standard.object(forKey: "LanguageName") as! String
        } else if UserDefaults.standard.object(forKey: "LanguageName") as! String == "ta" {
            return "ta"
        }
        else{
            return "ta"
        }
    }
    
    func MakeAnimation(view : CSAnimationView, animation_type : String)
    {
        view.type = animation_type
        view.duration = 0.5
        view.delay = 0
        view.startCanvasAnimation()
    }
    
}

extension UINavigationController
{
    func pushViewController(withFlip controller: UIViewController, animated : Bool) {
       self.addPushAnimation(controller: controller, animated: animated)
    }
    func popViewControllerWithFlip(animated : Bool) {
        self.addPopAnimation(animated: animated)
    }
    
    func poptoViewControllerWithFlip(controller : UIViewController, animated : Bool) {
        self.addPopToViewAnimation(controller: controller, animated: animated)
    }
    
    func perfromSegueWithFlip(controller : UIViewController, animated : Bool)
    {
        self.addPushAnimation(controller: controller, animated: animated)
    }
    
    func addPushAnimation(controller : UIViewController, animated : Bool)
    {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromBottom;
        self.view.layer.add(transition, forKey: kCATransition)
        self.pushViewController(controller, animated: animated)
    }
    
    func addPopAnimation(animated : Bool) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        self.view.layer.add(transition, forKey:kCATransition)
        self.popViewController(animated: animated)
    }
    
    func addPopToViewAnimation(controller : UIViewController, animated : Bool) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        self.view.layer.add(transition, forKey:kCATransition)
        self.popToViewController(controller, animated: animated)
    }
}

extension UITableView {
    
     func reload() {
        self.reloadData()
        let cells = self.visibleCells
        let indexPaths = self.indexPathsForVisibleRows
        let size = UIScreen.main.bounds.size
        for i in cells {
            let cell = self.cellForRow(at: indexPaths![cells.index(of: i)!])
            cell?.transform = CGAffineTransform(translationX: -size.width, y: 0)
        }
        var index = 0
        for a in cells {
            let cell = self.cellForRow(at: indexPaths![cells.index(of: a)!])
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                cell?.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
            index += 1
        }
    }
}


