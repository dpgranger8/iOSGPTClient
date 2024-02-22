//
//  OpenAIService.swift
//  AIGames
//
//  Created by David Granger on 7/20/23.
//

import Foundation
import Alamofire
import UIKit
import SwiftUI

class OpenAIService {
    private let endpointURL = "https://api.openai.com/v1"
    @AppStorage ("whichModel") var whichModel: OpenAIModel = .GPT4
    @AppStorage ("OpenAIAPIKey") var key: String = ""
    
    enum WhichEndpoint: String {
        case completions = "/chat/completions"
        case dalle = "/images/generations"
        case moderations = "/moderations"
        case speech = "/audio/speech"
    }
    
    enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
    }
    
    //Initialize reusable decoder and session
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    //let db: Firestore
    let session = URLSession.shared
    static let shared = OpenAIService()
    
    enum APIError: String, Error, LocalizedError {
        case invalidResponse
        case wasNot200
        case imageDataMissing
    }
    
    func sendStreamMessage(messages: [Message]) -> DataStreamRequest {
        let openAIMessages = messages.map({OpenAIChatMessage(role: $0.role, content: $0.content)})
        let body = OpenAIChatBody(model: whichModel, messages: openAIMessages, stream: true)
        let headers: HTTPHeaders = ["Authorization": "Bearer \(key)"]
        return AF.streamRequest(endpointURL + WhichEndpoint.completions.rawValue, method: .post, parameters: body, encoder: .json, headers: headers)
    }
}

enum OpenAIModel: String, Codable, CaseIterable {
    case GPT35 = "gpt-3.5-turbo-1106"
    case GPT354K = "gpt-3.5-turbo"
    case GPT4 = "gpt-4-1106-preview"
}

struct OpenAIChatBody: Codable {
    let model: OpenAIModel
    let messages: [OpenAIChatMessage]
    let stream: Bool
}

struct OpenAIChatMessage: Codable {
    let role: SenderRole
    let content: String
}

struct OpenAIChatResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChatChoice]
    let usage: Usage
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

struct OpenAIChatChoice: Codable {
    let message: OpenAIChatMessage
}
