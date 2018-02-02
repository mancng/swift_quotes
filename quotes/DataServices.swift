//
//  DataServices.swift
//  quotes
//
//  Created by Rachel Ng on 1/30/18.
//  Copyright © 2018 Rachel Ng. All rights reserved.
//

import Foundation

struct User {
    static var userName = ""
    static var userEmail = ""
}

struct Quote {
    var quotedBy: String!
    var message: String!
    var posterName: String!
    var posterEmail: String!
    var updatedAt: Int!
    var idKey: String!
}
