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
    let themes = ["Shopping","Social Media","Glücksspiel","18+ Inhalte"]
    
    @State private var status = "Aktiv"
    let statusOptions = ["Aktiv","Inaktiv"]
    
    @State private var related1 = ""
    @State private var related2 = ""
    @State private var related3 = ""
    
    @State private var notify = true
    
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.2, blue: 0.25),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            
            ScrollView {
                
                VStack(spacing: 24) {
                    
                    header
                    
                    formCard
                    
                    addButton
                }
                .padding()
            }
        }
    }
    
    
    
    
    var header: some View {
        
        HStack {
            
            Image(systemName: "nosign")
                .font(.title2)
            
            Text("Domain blockieren")
                .font(.title2.bold())
        }
        .foregroundColor(.white)
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        )
    }
    
    
    var formCard: some View {
        
        VStack(alignment: .leading, spacing: 22) {
            
            labeledTextField(
                title: "Domain:",
                placeholder: "temu.com",
                text: $domain
            )
            
            
            labeledPicker(
                title: "Thema:",
                selection: $theme,
                options: themes
            )
            
            
            labeledPicker(
                title: "Status:",
                selection: $status,
                options: statusOptions
            )
            
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text("Zugehörige Domains:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                glassTextField("share.temu.com", text: $related1)
                glassTextField("app.temu.com", text: $related2)
                glassTextField("optional", text: $related3)
            }
            
            
            Toggle("Benachrichtigung bei Anfrage:", isOn: $notify)
                .tint(Color(red: 0.2, green: 0.6, blue: 1))
                .foregroundColor(.white)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        )
    }
    
    
    var addButton: some View {
        
        Button {
            
        } label: {
            
            Text("hinzufügen")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical,14)
                .padding(.horizontal,60)
                .background(
                    Capsule()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.2)
                )
        }
    }
    
    
    
    
    func labeledTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            
            Text(title)
                .foregroundColor(.white)
                .frame(width: 130, alignment: .leading)
            
            glassTextField(placeholder, text: text)
        }
    }
    
    
    func labeledPicker(title: String, selection: Binding<String>, options: [String]) -> some View {
        
        HStack {
            Text(title)
                .foregroundColor(.white)
                .frame(width: 130, alignment: .leading)
            
            Picker("", selection: selection) {
                ForEach(options, id: \.self) {
                    Text($0)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .padding(.vertical,8)
            .padding(.horizontal,14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.12))
            )
            .foregroundColor(.white)
        }
    }
    
    
    func glassTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding(.vertical,10)
            .padding(.horizontal,12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.12))
            )
            .foregroundColor(.white)
            .tint(.white)
    }
}
