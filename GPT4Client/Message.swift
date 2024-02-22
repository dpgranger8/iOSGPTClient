//
//  Message.swift
//  AIGames
//
//  Created by David Granger on 7/20/23.
//

import Foundation
import SwiftUI

enum MsgStatus: CaseIterable, Codable {
    case complete
    case incomplete
}

struct Message: Codable, Identifiable, Equatable, Hashable {
    var id: String
    var role: SenderRole
    var content: String
    var createdAt: Date
    var status: MsgStatus?
    var hasBeenSummarized: Bool?
}

enum SenderRole: String, Codable {
    case system
    case user
    case assistant
}
