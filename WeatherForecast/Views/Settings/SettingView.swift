//
//  SettingView.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 28/09/2022.
//

import SwiftUI

struct SettingView: View {
    
    @ObservedObject var userSettings = UserSettings()
    
    var body: some View {
        VStack {
            HStack {
                Text("Setting")
                    .font(.largeTitle).fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 30)
            Form {
                Section(header: Text("Key for OpenCage")) {
                    TextField("Key for OpenCage", text: $userSettings.keyOpenCage)
                        .font(.footnote)
                }
                Section(header: Text("Url for OpenCage")) {
                    TextField("Url for OpenCage", text: $userSettings.urlOpenCage)
                        .font(.footnote)
                }
                Section(header: Text("Url for Met.no")) {
                    TextField("Url for Met.no", text: $userSettings.urlMetNo)
                        .font(.footnote)
                }
                Section(header: Text("SHOW WEATHER FOR PLACES IN CLOUDKIT")) {
                    Toggle("Show weather for places in CloudKit", isOn: $userSettings.showWeather)
                        .font(.footnote)
                }
            }
            .keyboardType(.asciiCapable)
        }
    }
}

