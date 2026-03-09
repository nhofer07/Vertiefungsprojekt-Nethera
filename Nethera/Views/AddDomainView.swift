//
//  DomainBlockView.swift
//  Nethera
//
//  Created by Deniz Bernecker on 08.03.26.
//

import Foundation

import SwiftUI

struct AddDomainView: View {
    
    @State private var domain = ""
    @State private var theme = "Shopping"
    @State private var status = "Aktiv"
    @State private var related1 = ""
    @State private var notify = true
    @State private var buttonPressed = false
    
    let themes = ["Shopping","Social Media","Glücksspiel","18+ Inhalte"]
    let statusOptions = ["Aktiv","Inaktiv"]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.05, green: 0.2, blue: 0.25), .black],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    
                    HStack {
                        Image(systemName: "shield.slash")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                        Text("Domain blockieren")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.08))
                        .blur(radius: 2)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5))
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Domain")
                                .foregroundColor(.white)
                                .font(.subheadline.bold())
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.white.opacity(0.7))
                                TextField("temu.com", text: $domain)
                                    .foregroundColor(.white)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.08))
                                .blur(radius: 1))
                        }
                        
                        HStack(spacing: 12) {
                            PickerField(title: "Thema", selection: $theme, options: themes, icon: "tag")
                                .frame(maxWidth: .infinity)
                            PickerField(title: "Status", selection: $status, options: statusOptions, icon: "circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Zugehörige Domain")
                                .foregroundColor(.white)
                                .font(.headline)
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.white.opacity(0.7))
                                TextField("share.temu.com", text: $related1)
                                    .foregroundColor(.white)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.08))
                                .blur(radius: 1))
                        }
                        
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.white.opacity(0.7))
                                TextField("share.temu.com", text: $related1)
                                    .foregroundColor(.white)
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.08))
                                .blur(radius: 1))
                        }
                        
                        Toggle("Benachrichtigung bei Anfrage", isOn: $notify)
                            .tint(.blue)
                            .foregroundColor(.white)
                        
                    }
                    .padding(25)
                    .background(RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.08))
                        .blur(radius: 2)
                        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6))
                    
                    Button {
                        buttonPressed.toggle()
                    } label: {
                        Text("Hinzufügen")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(RoundedRectangle(cornerRadius: 25)
                                .fill(Color.blue.opacity(0.3))
                                .shadow(color: Color.blue.opacity(buttonPressed ? 0.5 : 0.3), radius: buttonPressed ? 12 : 6, x: 0, y: buttonPressed ? 6 : 4))
                    }
                    
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
            }
        }
    }
}

// Wiederverwendbare Picker-Komponente
struct PickerField: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundColor(.white)
                .font(.subheadline.bold())
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                
                Picker("", selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .labelsHidden()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.08))
                .blur(radius: 1))
        }
    }
}

#Preview {
    AddDomainView()
}
