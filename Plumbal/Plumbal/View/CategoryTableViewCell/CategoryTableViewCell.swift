//
//  CategoryTableViewCell.swift
//  Plumbal
//
//  Created by Casperon Tech on 05/10/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet var Checkmark_Image_View: UIImageView!
    @IBOutlet var Category_ImageView: UIImageView!
    
    
//    @IBOutlet var Category_Wrapper: UIView!
    
    @IBOutlet var TitleLabel: UILabel!
    
    
     

    
     override func awakeFromNib() {
        super.awakeFromNib()
        
        
//        Category_Wrapper.clipsToBounds=true
        
         // Initialization code
    }
    
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    


}
