//
//  Languagehandler.swift
//  Plumbal
//
//  Created by Casperon Tech on 10/12/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit
let Language_Notification:String="VJLanguageDidChage"

class Languagehandler:NSObject {
    var LocalisedString:Bundle=Bundle()
    
    
    
    let EnglishGBLanguageShortName:String="en-GB"
    let EnglishUSLanguageShortName:String="en"
    let FrenchLanguageShortName:String="fr"
    let SpanishLanguageShortName:String="es"
    let ItalianLanguageShortName:String="it"
    let TamilLanguageShortName : String = "ta"

    let JapaneseLanguageShortName:String="ja"

    let KoreanLanguageShortName:String="ko"
    let ChineseLanguageShortName:String="zh"
    
    let TurkishLanguageShortName:String="tr"
    
    let EnglishGBLanguageLongName:String="English(UK)"
    let EnglishUSLanguageLongName:String="English(US"
    let FrenchLanguageLongName:String="French"
    let SpanishLanguageLongName:String="Spanish"
    let ItalianLanguageLongName:String="Italian"

    let JapaneseLanguageLongName:String="Japenese"
    let KoreanLanguageLongName:String="한국어"
    let TamilLanguageLongName : String = "Tamil"

    let ChineseLanguageLongName:String="中国的"
    let TurkishLanguageLongName:String="Turkish"


    var  _languagesLong:NSArray!=NSArray()

     var _localizedBundle:Bundle!=Bundle()
    func localizedBundle()->Bundle
    {
        if(_localizedBundle == nil)
        {
        _localizedBundle=Bundle(path: Bundle.main.path(forResource: "\(ApplicationLanguage())", ofType: "lproj")!)!
        }
        return _localizedBundle

    }
    
    func ApplicationLanguage()->String
    {
         let languages:NSArray=UserDefaults.standard.object(forKey: "AppleLanguages") as! NSArray
        return languages.firstObject as! String

    }
    
    
    func setApplicationLanguage(_ language:String){
 
    let oldLanguage: String = ApplicationLanguage()
        
        print("\(oldLanguage)....\(ApplicationLanguage())")
//    if (oldLanguage.isEqualToString(language) == false)
//    {
    UserDefaults.standard.set([language], forKey: "AppleLanguages")
    UserDefaults.standard.synchronize()
        _localizedBundle=Bundle(path: Bundle.main.path(forResource: "\(ApplicationLanguage())", ofType: "lproj")!)!
    NotificationCenter.default.post(name: Notification.Name(rawValue: Language_Notification), object: nil, userInfo: nil)
//    }
    }
    
  func applicationLanguagesLong()->NSArray
  {
    if _languagesLong == nil {
   _languagesLong = [ChineseLanguageLongName, EnglishGBLanguageLongName, EnglishUSLanguageLongName, FrenchLanguageLongName, KoreanLanguageLongName, ItalianLanguageLongName, SpanishLanguageLongName, TurkishLanguageLongName]
    }
    return _languagesLong
    }

    
    func VJLocalizedString(_ key:String!,comment:String!)->String
{
    
    print("\(localizedBundle())")
    return  localizedBundle().localizedString(forKey: key, value: "", table: nil)
    }
    
    func shortLanguageToLong(_ shortLanguage:String)->String
    {
        
        if(shortLanguage.isEqual(EnglishGBLanguageLongName))
        {
            return EnglishGBLanguageLongName;

        }
        if(shortLanguage.isEqual(EnglishUSLanguageShortName))
        {
            return EnglishUSLanguageShortName;
            
        }

        if(shortLanguage.isEqual(EnglishGBLanguageShortName))
        {
            return EnglishGBLanguageLongName;
            
        }

        if(shortLanguage.isEqual(ChineseLanguageShortName))
        {
            return ChineseLanguageShortName;
            
        }

        if(shortLanguage.isEqual(FrenchLanguageShortName))
        {
            return FrenchLanguageShortName;
            
        }

        if(shortLanguage.isEqual(KoreanLanguageShortName))
        {
            return KoreanLanguageShortName;
            
        }

        if(shortLanguage.isEqual(ItalianLanguageShortName))
        {
            return ItalianLanguageShortName;
            
        }

        if(shortLanguage.isEqual(SpanishLanguageShortName))
        {
            return SpanishLanguageShortName;
            
        }
        if(shortLanguage.isEqual(TamilLanguageLongName))
        {
            return TamilLanguageLongName;
            
        }

        else
        {
            
            return ""
            
        }

        
    }
    
    

}
