//
//  MessageManager.swift
//  AIGames
//
//  Created by David Granger on 7/20/23.
//

import Foundation
import Alamofire

class LegacyMessageManager: ObservableObject {
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: timerDoesRepeat) { _ in
            self.messages = self.messagesBuffer
        }
    }
    
    var messagesBuffer: [Message] = []
    var timerDoesRepeat: Bool = true
    @Published var messages: [Message] = []
    @Published var currentInput: String = ""
    var currentStreamRequest: DataStreamRequest?
    
    static var shared = LegacyMessageManager()
    let openAIService = OpenAIService()
    
    func cancelCurrentStream() {
        currentStreamRequest?.cancel()
        currentStreamRequest = nil
    }
    
    func sendMessage() {
        timerDoesRepeat = true
        
        if currentInput != "" {
            let newMessage = Message(id: UUID().uuidString, role: .user, content: currentInput, createdAt: Date())
            messagesBuffer.append(newMessage)
        }
        
        let streamRequest = openAIService.sendStreamMessage(messages: messagesBuffer)
        self.currentStreamRequest = streamRequest
        streamRequest.responseStreamString { [weak self] stream in
            guard let self = self else {return}
            guard streamRequest == currentStreamRequest else { return }
            
            switch stream.event {
            case .stream(let response):
                switch response {
                case .success(let string):
                    let streamResponse = parseStreamData(string)
                    streamResponse.forEach { newMessageResponse in
                        guard let messageContent = newMessageResponse.choices.first?.delta.content else {
                            return
                        }
                        guard let existingMessageIndex = self.messagesBuffer.lastIndex(where: {$0.id == newMessageResponse.id}) else {
                            let newMessage = Message(id: newMessageResponse.id, role: .assistant, content: messageContent, createdAt: Date())
                            self.messagesBuffer.append(newMessage)
                            return
                        }
                        let newMessage = Message(id: newMessageResponse.id, role: .assistant, content: self.messagesBuffer[existingMessageIndex].content + messageContent, createdAt: Date())
                        self.messagesBuffer[existingMessageIndex] = newMessage
                    }
                case .failure(_):
                    print("Something Failed")
                }
            case .complete(_):
                print("COMPLETE")
                timerDoesRepeat = false
                self.messages = self.messagesBuffer
            }
        }
    }
    
    func parseStreamData(_ data: String) -> [ChatStreamCompletionResponse] {
        let decoder = JSONDecoder()
        let responseStrings = data.split(separator: "data:").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)}).filter({!$0.isEmpty})
        
        return responseStrings.compactMap { jsonString in
            guard let jsonData = jsonString.data(using: .utf8), let streamResponse = try? decoder.decode(ChatStreamCompletionResponse.self, from: jsonData) else {
                return nil
            }
            return streamResponse
        }
    }
}

public struct ChatStreamCompletionResponse: Codable {
    let id: String
    let choices: [ChatStreamChoice]
}

struct ChatStreamChoice: Codable {
    let delta: ChatStreamContent
}

struct ChatStreamContent: Codable {
    let content: String
}

