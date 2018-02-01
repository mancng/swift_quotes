//
//  DataServices.swift
//  quotes
//
//  Created by Rachel Ng on 1/30/18.
//  Copyright © 2018 Rachel Ng. All rights reserved.
//

import Foundation

class User {
    var userName: String!
    var userEmail: String!
}

struct Quote {
    var quotedBy: String!
    var message: String!
    var posterName: String!
    var posterEmail: String!
    var updatedAt: Int!
}
