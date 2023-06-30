//
//  InfoAirPressure.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 13/12/2022.
//

import SwiftUI
import WeatherKit

struct InfoAirPressure: View {
    
    var index: Int
    var weather: Weather
    @Binding var weekdayArray: [String]
    
    @EnvironmentObject var dateSettings : DateSettings
    
    @EnvironmentObject var currentWeather: CurrentWeather

    @State private var text1 : String = String(localized: "Rapid and significant changes in air pressure are used to predict weather changes. Falling pressure can mean, for example, that rain or snow is in store, while rising pressure can mean better weather. Air pressure is also called atmospheric pressure.")
    
    @State private var text : String = ""
    
    @State private var airPressureArray : [Double] = Array(repeating: Double(), count: 24)
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(String(localized: "Daily overview"))
                .fontWeight(.bold)
            
            TextField("", text: $text, axis: .vertical)
                .lineLimit(10)
                .textFieldStyle(.roundedBorder)
                .disabled(true)
            
            Text(String(localized: "About air pressure"))
                .fontWeight(.bold)
            
            TextField("", text: $text1, axis: .vertical)
                .lineLimit(10)
                .textFieldStyle(.roundedBorder)
                .disabled(true)
            
            Spacer()
        }
        .font(.subheadline)
        .frame(width: UIDevice.isIpad ? 490 : 350,
               height: UIDevice.isIpad ? 300 : 300)
        .onChange(of: index) { oldIndex, index in
            ///
            /// Finner airPressureArray:
            ///
            airPressureArray.removeAll()
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
                         [Double]) = FindDataFromMenu(info: "InfoAirPressure change index",
                                                      weather: weather,
                                                      date: dateSettings.dates[index],
                                                      option: .airPressure,
                                                      option1: .number12)
            
            airPressureArray = value.0
            
            /// Bygger opp værmeldingen:
            ///
            text = Forecast(index: index,
                            weather: weather,
                            airPressureArray: airPressureArray,
                            weekdayArray: weekdayArray,
                            date: currentWeather.date)
        }
        .task {
            ///
            /// Finner airPressureArray:
            ///
            airPressureArray.removeAll()
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
                         [Double]) = FindDataFromMenu(info: "InfoAirPressure .task",
                                                      weather: weather,
                                                      date: dateSettings.dates[index],
                                                      option: .airPressure,
                                                      option1: .number12)
            
            airPressureArray = value.0
            
            ///
            /// Bygger opp værmeldingen:
            ///
            text = Forecast(index: index,
                            weather: weather,
                            airPressureArray: airPressureArray,
                            weekdayArray: weekdayArray,
                            date: currentWeather.date)
        }
    }
}

/// Bygger opp værmeldingen:
///

private func Forecast(index: Int,
                      weather: Weather,
                      airPressureArray: [Double],
                      weekdayArray: [String],
                      date: Date) -> String {
    
    var text = ""
    var weekDay = ""
    
    if index == 0 {
        
        text = text + String(localized: "Now it is ")
        text = text + "\(FormatDateToString(date: date, format: ("EEEE d. MMMM HH:mm"))) " + String(localized: " and ")
        text = text + String(localized: "the airpressure is now ")
        text = text + "\(Int((weather.currentWeather.pressure.value).rounded())) hPa"
        text = text + String(localized: " and ")
        text = text + "\(weather.currentWeather.pressureTrend.description.firstLowercased). "
        text = text + String(localized: "Today the airpressure will be ")
        text = text + "\(Int(FindAverageArray(array: airPressureArray).rounded())) hPa "
        text = text + String(localized: " in average, and the lowest measured pressure will be ")
        text = text + "\(Int(airPressureArray.min()!.rounded())) hPa."
    } else {
        text = String(localized: "On ")
        weekDay = TranslateDay(index: index, weekdayArray: weekdayArray)
        text = text + weekDay
        text = text + String(localized: " the airpressure will be ")
        text = text + "\(Int(FindAverageArray(array: airPressureArray).rounded())) hPa "
        text = text + String(localized: " in average, and the lowest measured pressure will be ")
        text = text + "\(Int(airPressureArray.min()!.rounded())) hPa."
    }
    
    return text
}
