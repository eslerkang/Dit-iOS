//
//  Todo.swift
//  Dit
//
//  Created by 강태준 on 2022/09/06.
//

import Foundation


struct TodoEntity {
    let text: String
    var isDone: Bool
    let createdAt: Date
    let uuid: UUID
    var updatedAt: Date
}
