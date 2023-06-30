//
//  DayDetailDayDataView.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 01/11/2022.
//

import SwiftUI
import WeatherKit

struct DayDetailDayDataView: View {
    
    let weather: Weather
    let option: EnumType
    @Binding var arrayDayIcons: [String]
    @Binding var dateArray: [Date]
    @Binding var index: Int
    @Binding var colorsForeground : [Color]
    @Binding var colorsForegroundStandard : [Color]
    @Binding var colorsBackground : [Color]
    @Binding var colorsBackgroundStandard : [Color]
    @Binding var dayDetailHide : Bool
    @Binding var selectedValue : SelectedValue
    @Binding var dayArray : [Double]
    @Binding var rainFalls :  [RainFall]
    @Binding var weekdayArray: [String]
    @Binding var windInfo: [WindInfo]
    @Binding var tempInfo: [Temperature]
    @Binding var gustInfo: [Double]
    @Binding var weatherIcon: [WeatherIcon]
    @Binding var feltTempArray: [FeltTemp]
    @Binding var opacity: Double
    @Binding var dewPointArray: [Double]

    @State private var width: CGFloat = 0.00
    @State private var height: CGFloat = 0.00
    @State private var bottom: CGFloat = 0.00
    
    @State private var option1: EnumType = .number12
    
    var body: some View {
        VStack (alignment: .center) {
            /// 
            /// https://swdevnotes.com/swift/2021/add-axes-to-bar-chart-swiftui/
            /// Viser Chart for Temperatur:
            ///
            DayDetailChart(rainFalls : $rainFalls,
                           dayArray: $dayArray,
                           dayDetailHide: $dayDetailHide,
                           option: option,
                           dateArray: $dateArray,
                           index: $index,
                           selectedValue: $selectedValue,
                           weekdayArray: $weekdayArray,
                           windInfo: $windInfo,
                           tempInfo: $tempInfo,
                           gustInfo: $gustInfo,
                           weatherIcon: $weatherIcon,
                           weather: weather,
                           feltTempArray: $feltTempArray,
                           opacity: $opacity,
                           dewPointArray: $dewPointArray,
                           colorsForeground : $colorsForeground,
                           colorsForegroundStandard : $colorsForegroundStandard,
                           colorsBackground : $colorsBackground,
                           colorsBackgroundStandard : $colorsBackgroundStandard)
              /// Oppdaterer dayArray ved en endring fra menuen:
            ///
            .onChange(of: option) { oldOption, option in
                /// Resetter selectedValue fra gesture i DayDetailChart():
                ///
                selectedValue.icon = ""
                selectedValue.value1 = ""
                selectedValue.value2 = ""
                selectedValue.value3 = ""
                selectedValue.time = ""
                let value: ([Double],
                            [String],
                            [String],
                            [RainFall],
                            [WindInfo],
                            [Temperature],
                            [Double],
                            [WeatherIcon],
                            [Double],
                            [FeltTemp],
                            [Double]) = FindDataFromMenu(info: "DayDetailDayDataView() change option",
                                                         weather: weather,
                                                         date: dateArray[index],
                                                         option: option,
                                                         option1: option1)
                dayArray = value.0
                rainFalls = value.3
                windInfo = value.4
                tempInfo = value.5
                gustInfo = value.6
                weatherIcon = value.7
                feltTempArray = value.9
            }
            .onChange(of: index) { oldIndex, index in
                /// Resetter selectedValue fra gesture i DayDetailChart():
                ///
                selectedValue.icon = ""
                selectedValue.value1 = ""
                selectedValue.value2 = ""
                selectedValue.value3 = ""
                selectedValue.time = ""
                let value: ([Double],
                            [String],
                            [String],
                            [RainFall],
                            [WindInfo],
                            [Temperature],
                            [Double],
                            [WeatherIcon],
                            [Double],
                            [FeltTemp],
                            [Double]) =  FindDataFromMenu(info: "DayDetailDayDataView() change index",
                                                          weather: weather,
                                                          date: dateArray[index],
                                                          option: option,
                                                          option1: option1)
                dayArray = value.0
                rainFalls = value.3
                windInfo = value.4
                tempInfo = value.5
                gustInfo = value.6
                weatherIcon = value.7
                feltTempArray = value.9
            }
        }
        .task {
            /// Setter opp spacing og padding for iPhone og iPad:
            ///
            if UIDevice.isIpad {
                width =  505
                height = 400 // 600 // 400
                bottom = 5
            } else {
                width = 355
                height = 360
                bottom = 110
            }
            /// Finner data for valgt meny punkt ved oppstart av DayDetailDayDataView
            ///
            let value: ([Double],
                        [String],
                        [String],
                        [RainFall],
                        [WindInfo],
                        [Temperature],
                        [Double],
                        [WeatherIcon],
                        [Double],
                        [FeltTemp],
                        [Double]) =  FindDataFromMenu(info: "DayDetailDayDataView() .task",
                                                      weather: weather,
                                                      date: dateArray[index],
                                                      option: option,
                                                      option1: option1)
            dayArray = value.0
            rainFalls = value.3
            windInfo = value.4
            tempInfo = value.5
            gustInfo = value.6
            weatherIcon = value.7
            feltTempArray = value.9
        }
        .frame(width: width, height: height)
    }
}
