//
//  APIResponse.swift
//  LastestFinance
//
//  Created by WEI-TSUNG CHENG on 2024/4/23.
//

import Foundation

struct APIResponse: Codable {
    
    var data: [FinanceProduct]
    var type : String
    
    private enum CodingKeys: String, CodingKey {
        case data, type
    }
}

struct FinanceProduct : Codable{
    
    public var p: Float
    private enum CodingKeys: String, CodingKey {
        case p
    }
}
