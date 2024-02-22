//
//  WhichModelPicker.swift
//  GPT4Client
//
//  Created by David Granger on 2/22/24.
//

import SwiftUI

enum GPTButtonStyle: Int, CaseIterable {
    case tortoise
    case hare
}

struct WhichModelPicker: View {
    @AppStorage ("whichModel") var whichModel: OpenAIModel = .GPT35
    @Environment(\.colorScheme) var colorScheme
    var textColorWhite: Bool
    var alignmentCenter: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                pickerButtonView(style: .hare, isSelected: whichModel == .GPT35)
                pickerButtonView(style: .tortoise, isSelected: whichModel == .GPT4)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(colorScheme == .dark ? .white : .gray, lineWidth: 1.5)
            )
            .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 12)))
            .frame(maxWidth: .infinity, alignment: alignmentCenter == false ? .leading : .center)
            if whichModel == .GPT35 {
                Text("Recommended - Fastest model\nwith greater context capability.")
                    .foregroundColor(textColorWhite == true ? .white : .black)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 15)
            } else {
                Text("Slower model, great for tasks that\nrequire creativity. Expect long response times.")
                    .foregroundColor(textColorWhite == true ? .white : .black)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 15)
            }
        }
    }
    
    func pickerButtonView(style: GPTButtonStyle, isSelected: Bool) -> some View {
        Button {
            withAnimation {
                if whichModel == .GPT4 {
                    whichModel = .GPT35
                } else {
                    whichModel = .GPT4
                }
                let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
                impactRigid.impactOccurred()
            }
        } label: {
            HStack(spacing: 2) {
                Image(systemName: style == .hare ? "hare.fill" : "tortoise.fill")
                    .fontWeight(.medium)
                    .font(.caption2)
                Text(style == .hare ? "GPT - 3.5" : "GPT - 4")
                    .fontWeight(.medium)
                    .frame(height: 30)
                    .font(.title3)
                    .textCase(.none)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 10)
        .disabled(isSelected)
        .foregroundColor(isSelected ? .white : .gray)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ?
                      (style == .hare ? .green : .purple) : .clear)
        )
    }
}
