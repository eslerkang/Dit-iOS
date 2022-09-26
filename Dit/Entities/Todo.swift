//
//  Todo.swift
//  Dit
//
//  Created by 강태준 on 2022/09/06.
//

import Foundation


struct Todo: Codable {
    let text: String
    var isDone: Bool
    let createdAt: Date
    var updatedAt: Date
    let userId: String
    let uuid: String
}
