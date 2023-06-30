//
//  InfoWind.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 12/12/2022.
//

import SwiftUI

struct InfoWind : View {

    var index: Int
    @Binding var dayArray : [Double]
    @Binding var windInfo : [WindInfo]
    @Binding var weekdayArray: [String]

    @State private var text : String = String(localized: "The wind speed is calculated based on the average over a short period of time. Gusts are sudden changes in wind strength above the average speed. A gust usually lasts less than 20 seconds.")

    @State private var text1 : String = "" // String(localized: "The wind ")
    @EnvironmentObject var currentWeather: CurrentWeather

    var body: some View {
        VStack (alignment: .leading) {

            Text(String(localized: "Daily overview"))
                .fontWeight(.bold)

            TextField("", text: $text1, axis: .vertical)
                .lineLimit(10)
                .textFieldStyle(.roundedBorder)
                .disabled(true)

            Text(String(localized: "About wind speed and gusts"))
                .fontWeight(.bold)

            TextField("", text: $text, axis: .vertical)
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
            /// Bygger opp værmeldingen:
            ///
            text1 = Forecast(index: index,
                             dayArray: dayArray,
                             weekdayArray: weekdayArray,
                             windInfo: windInfo,
                             date: currentWeather.date)
        }
        .task {
            ///
            /// Bygger opp værmeldingen:
            ///
            text1 = Forecast(index: index,
                             dayArray: dayArray,
                             weekdayArray: weekdayArray,
                             windInfo: windInfo,
                             date: currentWeather.date)
        }
    }
}

/// Bygger opp værmeldingen:
///

private func Forecast(index: Int,
                      dayArray: [Double],
                      weekdayArray: [String],
                      windInfo: [WindInfo],
                      date: Date) -> String {

    var text : String = ""
    var weekDay: String = ""

    let minWindSpeed  = WindInfoValues(windInfo: windInfo,
                                       option: .windSpeed,
                                       option1: .min)

    let maxWindSpeed  = WindInfoValues(windInfo: windInfo,
                                       option: .windSpeed,
                                       option1: .max)

    let maxGustSpeed  = WindInfoValues(windInfo: windInfo,
                                       option: .gustSpeed,
                                       option1: .max)
    
    if index == 0 {
        text = String(localized: "Now it is ")
        text = text + "\(FormatDateToString(date: date, format: ("EEEE d. MMMM HH:mm")))"
        text = text + String(localized: " and the wind is now blowing")
        /// Legger inn vindstyrken nå :
        ///
        text = text + " \(Int(windInfo[windType].data[IndexPointMarkFromHour()].amount.rounded()))" + " m/s"
        /// Legger inn vindretningen :
        ///
        text = text + String(localized: " from")
        text = text + WindDirection(windInfo: windInfo,
                                    option: .longDirection)
        text = text + "."
        text = text + String(localized: " To day it will blow from ")
        text = text + "\(Int(minWindSpeed.rounded()))"
        text = text + String(localized: " to ")
        text = text + "\(Int(maxWindSpeed.rounded()))"
        text = text + " m/s"
        /// Legger inn vindkast :
        ///
        text = text + String(localized: " with gust up to ")
        text = text + "\(Int(maxGustSpeed.rounded()))"
        text = text + " m/s."
    } else {
        text = String(localized: "On ")
        weekDay = TranslateDay(index: index, weekdayArray: weekdayArray)
        text = text + weekDay
        text = text + String(localized: " it will be blowing from ")
        /// Legger inn vindstyrken:
        ///
        text = text + "\(Int(minWindSpeed.rounded()))"
        text = text + String(localized: " to ")
        text = text + "\(Int(maxWindSpeed.rounded()))"
        text = text + " m/s"
        /// Legger inn vindkast :
        ///
        text = text + String(localized: " with gust up to ")
        text = text + "\(Int(maxGustSpeed.rounded()))"
        text = text + " m/s."
    }

    return text
}

private func WindInfoValues(windInfo: [WindInfo], option : EnumType, option1 : EnumType) -> Double {

    /// option  = windSpeed eller gustSpeed
    /// option1 = min eller max

    var value : Double = 0.00
    var array : [Double] = []

    array.removeAll()

    if option == .windSpeed {
        for i in 0..<windInfo[windType].data.count {
            array.append(windInfo[windType].data[i].amount)
        }
    }
    
    if option == .gustSpeed {
        for i in 0..<windInfo[gustType].data.count {
            array.append(windInfo[gustType].data[i].amount)
        }
    }

    if option1 == .min {
        value = array.min()!
    } else if option1 == .max {
        value = array.max()!
    }

    return value
}

private func WindDirection(windInfo: [WindInfo], option: EnumType) -> String {
    var direction : String = ""
    var deg : Double = 0.00

    deg = windInfo[0].data[IndexPointMarkFromHour()].direction

    direction = ""

    if option == .shortDirection {
        if deg < 11.25 || deg > 348.75 {
            direction = String(localized: "N")
        } else if deg < 22.50 {
            direction =  String(localized: "NNE")
        } else if deg < 67.5 {
            direction =  String(localized: "ENE")
        } else if deg < 90.0 {
            direction =  String(localized: "E")
        } else if deg < 112.5 {
            direction =  String(localized: "ESE")
        } else if deg < 135.00 {
            direction =  String(localized: "SE")
        } else if deg < 157.5 {
            direction =  String(localized: "SSE")
        } else if deg < 180.00 {
            direction =  String(localized: "S")
        } else if deg < 202.50 {
            direction =  String(localized: "SSW")
        } else if deg < 225.00 {
            direction =  String(localized: "SW")
        } else if deg < 247.50 {
            direction =  String(localized: "WSW")
        } else if deg < 270.00 {
            direction =  String(localized: "W")
        } else if deg < 292.50 {
            direction =  String(localized: "WNW")
        } else if deg < 315.00 {
            direction =  String(localized: "NW")
        } else {
            direction =  String(localized: "NNW")
        }
    } else if option == .longDirection {
        if deg < 11.25 || deg > 348.75 {
            direction = String(localized: "north")
        } else if deg < 22.50 {
            direction =  String(localized: "north-northeast")
        } else if deg < 67.5 {
            direction =  String(localized: "east-northeast")
        } else if deg < 90.0 {
            direction =  String(localized: "east")
        } else if deg < 112.5 {
            direction =  String(localized: "east-southeast")
        } else if deg < 135.00 {
            direction =  String(localized: "southeast")
        } else if deg < 157.5 {
            direction =  String(localized: "south-southeast")
        } else if deg < 180.00 {
            direction =  String(localized: "south")
        } else if deg < 202.50 {
            direction =  String(localized: "south-southwest")
        } else if deg < 225.00 {
            direction =  String(localized: "southwest")
        } else if deg < 247.50 {
            direction =  String(localized: "west-southwest")
        } else if deg < 270.00 {
            direction =  String(localized: "west")
        } else if deg < 292.50 {
            direction =  String(localized: "west-northwest")
        } else if deg < 315.00 {
            direction =  String(localized: "northwest")
        } else {
            direction =  String(localized: "north-northwest")
        }    }

    return direction

}

/*
 
 
 Forkortelse    Beskrivelse     Min.        Middel      Maks.
 
 N              nord            348,75      0           11,25
 NNØ            nord-nordøst    11,25       22,5        33,75
 ØNØ            øst-nordøst     56,25       67,5        78,75
 Ø              øst             78,75       90          101,25
 ØSØ            øst-sørøst      101,25      112,5       123,75
 SØ             sørøst          123,75      135         146,25
 SSØ            sør-sørøst      146,25      157,5       168,75
 S              sør             168,75      180         191,25
 SSV            sør-sørvest     191,25      202,5       213,75
 SV             sørvest         213,75      225         236,25
 VSV            vest-sørvest    236,25      247,5       258,75
 V              vest            258,75      270         281,25
 VNV            vest-nordvest   281,25      292,5       303,75
 NV             nordvest        303,75      315         326,25
 NNV            nord-nordvest   326,25      337,5       348,75


 
 */
