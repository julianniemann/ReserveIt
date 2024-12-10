//
//  FireUser.swift
//  ReserveIt
//
//  Created by Julian Niemann on 08.07.24.
//

import Foundation

struct FireUser: Codable {
    let id: String
    let email: String
    let nickname: String
    let registeredAt: Date
    var phoneNumber: String?
    var address: String?
}
