//
//  UserEntity.swift
//  Dit
//
//  Created by 강태준 on 2022/09/26.
//

import Foundation

struct UserEntity: Codable {
    var displayname: String
    var id: String
    var createdAt: Date
    var isActive: Bool
    var updatedAt: Date
}
