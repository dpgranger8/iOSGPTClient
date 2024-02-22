//
//  ChatView.swift
//  AIGames
//
//  Created by David Granger on 7/26/23.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var messageManager: LegacyMessageManager
    @FocusState private var textFieldFocused: Bool
    @State private var chevronRotation: Double = 0
    @State private var showingTrashAlert = false
    @State private var scrollDangIt: Bool = false
    
    init(messageManager: LegacyMessageManager) {
        self.messageManager = messageManager
    }
    
    var body: some View {
        VStack (spacing: 0) {
            Spacer()
                .frame(height: 7)
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(messageManager.messages, id: \.id) { message in
                        messageView(message: message)
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.setValue(message.content, forPasteboardType: "public.plain-text")
                                }) {
                                    Text("Copy")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                    }
                    if messageManager.messages.count > 1 && messageManager.timerDoesRepeat {
                        HStack {
                            DotLoadingView()
                                .frame(width: 60)
                                .padding()
                            Spacer()
                        }
                    }
                    Text("  ")
                        .id(1)
                }
                .onChange(of: textFieldFocused) {
                    scrollDangIt.toggle()
                }
                .onChange(of: scrollDangIt) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(1, anchor: .bottomTrailing)
                        }
                    }
                }
            }
            HStack(alignment: textFieldFocused ? .bottom : .center, spacing: 10) {
                TextField("Ask me anything...", text: $messageManager.currentInput, axis: .vertical)
                    .focused($textFieldFocused)
                    .textFieldStyle(OvalTextFieldStyle())
                    .onChange(of: textFieldFocused) { oldValue, newValue in
                        withAnimation(.spring()) {
                            chevronRotation = newValue ? 180 : 0
                        }
                    }
                HStack(spacing: 0) {
                    SendButton
                    ChevronButton
                    Spacer()
                        .frame(width: 10)
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0))
            .background(.thinMaterial)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    if messageManager.messagesBuffer.count >= 2 {
                        showingTrashAlert = true
                    }
                } label: {
                    Image(systemName: "trash")
                }
                .alert(isPresented: $showingTrashAlert) {
                    Alert(title: Text("Delete"), message: Text("Delete your current conversation?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete")) {
                        trashUnwantedMessages()
                    })
                }
            }
        }
        .navigationTitle("Chat")
    }
    
    func trashUnwantedMessages() {
        messageManager.cancelCurrentStream()
        messageManager.messagesBuffer.removeAll()
        messageManager.messages.removeAll()
    }
    
    func messageView(message: Message) -> some View {
        HStack {
            if message.role == .user {
                Spacer()
                    .frame(width: 12)
                Spacer()
                Text(message.content)
                    .defaultMessageMod()
                Spacer()
                    .frame(width: 12)
            }
            if message.role == .assistant {
                Spacer()
                    .frame(width: 12)
                Text(message.content)
                    .padding(12)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Bubble(chat: false))
                Spacer()
                Spacer()
                    .frame(width: 12)
            }
        }
        .padding(.top, 3)
        .padding(.bottom, 3)
    }
    
    @ViewBuilder
    private var SendButton: some View {
        Button {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            messageManager.sendMessage()
            textFieldFocused = false
            messageManager.currentInput = ""
        } label: {
            Image(systemName: "paperplane.fill")
                .imageScale(.large)
        }
        .aspectRatio(contentMode: .fill)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(.blue)
        .controlSize(.regular)
        .disabled(messageManager.currentInput.isEmpty)
    }
    
    @ViewBuilder
    private var ChevronButton: some View {
        if textFieldFocused {
            Button {
                withAnimation(.spring()) {
                    textFieldFocused.toggle()
                }
                scrollDangIt.toggle()
            } label: {
                Image(systemName: "chevron.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(0.45)
                    .foregroundColor(.blue)
                    .frame(width: 45, height: 35)
            }
            .offset(x: 4)
        }
    }
}

extension View {
    func defaultMessageMod() -> some View {
        self.modifier(DefaultMessageMod())
    }
}

struct Bubble: Shape {
    var chat: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topRight, .topLeft, chat ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 17, height: 17))
        
        return Path(path.cgPath)
    }
}

struct DefaultMessageMod: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Bubble(chat: true))
    }
}

struct DotLoadingView: View {
    @State private var showCircle1 = false
    @State private var showCircle2 = false
    @State private var showCircle3 = false
    
    var body: some View {
        HStack {
            Circle()
                .opacity(showCircle1 ? 1 : 0.1)
            Circle()
                .opacity(showCircle2 ? 1 : 0.1)
            Circle()
                .opacity(showCircle3 ? 1 : 0.1)
        }
        .foregroundColor(.blue)
        .onAppear { performAnimation() }
    }
    
    func performAnimation() {
        let animation = Animation.linear(duration: 0.35)
        withAnimation(animation) {
            self.showCircle1 = true
            self.showCircle3 = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(animation) {
                self.showCircle2 = true
                self.showCircle1 = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(animation) {
                self.showCircle2 = false
                self.showCircle3 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
            self.performAnimation()
        }
    }
}

#Preview {
    ChatView(messageManager: LegacyMessageManager())
}

struct OvalTextFieldStyle: TextFieldStyle {
    @FocusState private var textFieldFocused: Bool
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color.gray.opacity(0.10))
            .cornerRadius(20)
            .focused($textFieldFocused)
            .onTapGesture {
                textFieldFocused = true
            }
    }
}

struct OvalBlueTextFieldStyle: TextFieldStyle {
    @FocusState private var textFieldFocused: Bool
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(LinearGradient(colors: [.blue.opacity(0.15), .blue.opacity(0.35)], startPoint: .top, endPoint: .bottom))
            .cornerRadius(20)
            .focused($textFieldFocused)
            .onTapGesture {
                textFieldFocused = true
            }
    }
}
