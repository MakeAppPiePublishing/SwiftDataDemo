//
//  UserPrefs.swift
//  SwiftDataDemo
//
//  Created by Steven Lipton on 6/14/23.
//

import Foundation
import SwiftData

@Model
class UserPref:Identifiable{
    var id:Int
    var hasPencil:Bool
    
    init(id:Int,hasPencil:Bool){
        self.id = id
        self.hasPencil = hasPencil
    }
}
