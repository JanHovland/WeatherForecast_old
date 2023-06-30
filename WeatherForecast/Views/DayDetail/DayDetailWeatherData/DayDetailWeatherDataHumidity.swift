//
//  DayDetailWeatherDataHumidity.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 29/12/2022.
//

import SwiftUI
import WeatherKit

struct DayDetailWeatherDataHumidity: View {
    
    let weather : Weather
    @Binding var menuTitle: String
    @Binding var index: Int
    
    @EnvironmentObject var dateSettings : DateSettings

    @State private var dataArray: [Double] = Array(repeating: Double(), count: 24)

    var body: some View {
        if menuTitle == "Luftfuktighet" {
            VStack {
                if index == 0 {
                    VStack {
                        VStack {
                            let humidity = Double(weather.currentWeather.humidity.description)! * 100.0
                            Text("\(Int(humidity)) %")
                                .font(.title)
                                .offset(x: UIDevice.isIpad ? -32 : -20)
                        }
                        VStack {
                            HStack (spacing: 4) {
                                Text(String(localized: "The dew point: "))
                                let dewPoint = weather.currentWeather.dewPoint.value
                                Text("\(Int(dewPoint.rounded()))º")
                            }
                            .font(.subheadline)
                            .opacity(0.5)
                            .offset(x: UIDevice.isIpad ? -5 : 5)
                        }
                    }
                } else {
                    VStack {
                        VStack {
                            Text("\(Int(FindAverageArray(array: dataArray).rounded())) %")
                                .font(.title)
                                .offset(x: UIDevice.isIpad ? -20 : 15)
                        }
                        VStack {
                            Text(String(localized: "Average"))
                                .font(.subheadline)
                                .opacity(0.5)
                        }
                    }
                     
                }
            }
            ///
            /// Oppdaterer dataArray ved ending av index:
            ///
            .onChange(of: index) { oldIndex, index in
                ///
                /// Resetter dataArray:
                ///
                dataArray.removeAll()
                let value : ([Double],
                             [String],
                             [String],
                             [RainFall],
                             [WindInfo],
                             [Temperature],
                             [Double],
                             [WeatherIcon],
                             [Double],
                             [FeltTemp],
                             [Double]) = FindDataFromMenu(info: "DayDetailWeatherDataHumidity change index",
                                                          weather: weather,
                                                          date: dateSettings.dates[index],
                                                          option: .humidity,
                                                          option1: .number12)
                dataArray = value.0
            }
            ///
            /// Finner dataArray ved oppstarten:
            ///
            .task {
                ///
                /// Resetter dataArray:
                ///
                dataArray.removeAll()
                let value : ([Double],
                             [String],
                             [String],
                             [RainFall],
                             [WindInfo],
                             [Temperature],
                             [Double],
                             [WeatherIcon],
                             [Double],
                             [FeltTemp],
                             [Double]) = FindDataFromMenu(info: "DayDetailWeatherDataHumidity .task",
                                                          weather: weather,
                                                          date: dateSettings.dates[index],
                                                          option: .humidity,
                                                          option1: .number12)
                dataArray = value.0
            }
        }
    }
}

