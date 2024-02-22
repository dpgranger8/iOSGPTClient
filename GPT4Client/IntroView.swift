//
//  IntroView.swift
//  GPT4Client
//
//  Created by David Granger on 2/22/24.
//

import SwiftUI

struct IntroView: View {
    @AppStorage ("whichModel") var whichModel: OpenAIModel = .GPT4
    @AppStorage ("OpenAIAPIKey") var key: String = ""
    @AppStorage ("isChatShowing") var isChatShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("iOS ChatGPT Client")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 50)
                    Text("Save $20 a month in GPT-4 subscription fees!")
                        .padding(.bottom, 130)
                        .font(.footnote)
                    VStack(spacing: 20) {
                        Text("Paste your OpenAI API key here:")
                            .fontWeight(.semibold)
                        TextField("API Key", text: $key)
                            .textFieldStyle(OvalBlueTextFieldStyle())
                        Text("This key is not shared, it is only stored on device")
                            .font(.footnote)
                    }
                    .padding(.bottom, 50)
                    WhichModelPicker(textColorWhite: true, alignmentCenter: true)
                        .padding(.bottom, 50)
                    Button {
                        isChatShowing = true
                    } label: {
                        Text("Go")
                            .frame(maxWidth: .infinity)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 10)
            .navigationDestination(isPresented: $isChatShowing) {
                ChatView(messageManager: LegacyMessageManager())
            }
            .background(LinearGradient(colors: [.black, .black, .black, .black, .blue.opacity(0.5)], startPoint: .top, endPoint: .bottom))
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    IntroView()
}
