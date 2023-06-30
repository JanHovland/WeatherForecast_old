//
//  DayDetailChart.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 09/11/2022.
//

import SwiftUI
import WeatherKit
import Charts

///
/// https://swdevnotes.com/swift/2022/customise-a-line-chart-with-swiftui-charts-in-ios-16/
/// https://blckbirds.com/post/charts-in-swiftui-part-1-bar-chart/
/// https://swdevnotes.com/swift/2022/customise-a-line-chart-with-swiftui-charts-in-ios-16/
/// https://trailingclosure.com/recreating-the-strava-activity-graph/
/// https://stackoverflow.com/questions/74893856/swiftui-charts-how-to-put-an-annotation-at-the-top-of-a-chart-and-have-a-line
/// https://stackoverflow.com/questions/74100355/barmark-drawing-on-top-of-y-axis
/// https://swiftuirecipes.com/companion
/// https://medium.com/devtechie/align-charts-mark-style-with-chart-plot-area-in-swiftui-4-and-charts-framework-9bf91163ede5
///

struct DayDetailChart: View {
    
    @Binding var rainFalls: [RainFall]
    @Binding var dayArray: [Double]
    @Binding var dayDetailHide: Bool
             var option: EnumType
    @Binding var dateArray: [Date]
    @Binding var index : Int
    @Binding var selectedValue : SelectedValue
    @Binding var weekdayArray : [String]
    @Binding var windInfo: [WindInfo]
    @Binding var tempInfo: [Temperature]
    @Binding var gustInfo: [Double]
    @Binding var weatherIcon: [WeatherIcon]
    let weather: Weather
    @Binding var feltTempArray: [FeltTemp]
    @Binding var opacity: Double
    @Binding var dewPointArray: [Double]
    @Binding var colorsForeground : [Color]
    @Binding var colorsForegroundStandard : [Color]
    @Binding var colorsBackground : [Color]
    @Binding var colorsBackgroundStandard : [Color]

    @EnvironmentObject var currentWeather: CurrentWeather
    @EnvironmentObject var dateSettings : DateSettings
    
    @State private var frameWidth: CGFloat = 0.00
    @State private var frameHeight: CGFloat = 0.00
    @State private var leading: CGFloat = 0.00
    @State private var xPos: CGFloat = 0.00
    @State private var xPosMin: CGFloat = 0.00
    @State private var xPosMax: CGFloat = 0.00
    @State private var divisor: CGFloat = 0.00
    @State private var padding: CGFloat = 0.00

    @State private var indexPointMark: Int = 0
    
    @State private var show : Bool = false
    
    @State private var hourIconArray : [String] = Array(repeating: String(), count: 24)
    
    ///
    /// Temperatur:
    ///
    @State private var tempMin: Int = 0
    @State private var tempMax: Int = 0
    @State private var tempMinIndex: Int = 0
    @State private var tempMaxIndex: Int = 0
    ///
    /// Vind:
    ///
    @State private var windMin: Int = 0
    @State private var windMax: Int = 0
    @State private var windMinIndex: Int = 0
    @State private var windMaxIndex: Int = 0
    ///
    /// Føles som:
    ///
    @State private var feelslikeMin: Int = 0
    @State private var feelslikeMax: Int = 0
    @State private var feelslikeMinIndex: Int = 0
    @State private var feelslikeMaxIndex: Int = 0
    ///
    /// Luftfuktighet:
    ///
    @State private var humidityMin: Int = 0
    @State private var humidityMax: Int = 0
    @State private var humidityMinIndex: Int = 0
    @State private var humidityMaxIndex: Int = 0
    ///
    /// Nedbør
    ///
    @State private var precipitationMax: Double = 0.00
    @State private var precipitationMinIndex: Int = 0
    @State private var precipitationMaxIndex: Int = 0
    ///
    /// Sikt:
    ///
    @State private var visabilityMin: Int = 0
    @State private var visabilityMax : Int = 0
    @State private var visabilityMinIndex: Int = 0
    @State private var visabilityMaxIndex: Int = 0
    ///
    /// Annet:
    ///
    @State private var otherMin: Int = 0
    @State private var otherMax : Int = 0
    @State private var otherMinIndex: Int = 0
    @State private var otherMaxIndex: Int = 0

    @State private var array: [Double] = Array(repeating: Double(), count: 24)

    var body: some View {
        let curColor = Color(.systemCyan)
        ///
        /// curGradient brukes på .foregroundStyle(curGradient)
        ///
        VStack (alignment: .center) {
            /// Viser de forskjellige Chart:
            ///
            VStack {
                if option == .precipitation {
                    /// Gesture in BarMark:
                    /// https://blckbirds.com/post/charts-in-swiftui-part-1-bar-chart/
                    ///
                    /// https://mobile.blog/2022/07/04/an-adventure-with-swift-charts/
                    ///
                    ///https://www.devtechie.com/community/public/posts/154033-new-in-swiftui-4-charts-bar-chart
                    ///
                    /// Velger fargerekkefølgen:
                    ///
                    let markColors : [Color] = [.blue, .cyan, .indigo, .primary, .orange]
                    Chart {
                        ForEach(rainFalls, id: \.type) { rainFall in
                            ForEach(rainFall.data , id: \.amount) {
                                let idx = $0.index
                                BarMark (
                                    x: .value("Index", $0.index),
                                    y: .value("Amount", $0.amount)
                                )
                                /// Her ser det ut som om det er en feil med annotation:
                                ///    kan ikke legge inn logikk om idx == MaxIndex eller MinIndex.
                                ///
                                .annotation {
                                    VStack {
                                        Text(idx == precipitationMaxIndex && precipitationMax > 0.00 ? "H" : "")
                                    }
                                    .font(.caption2).fontWeight(.bold)
                                    .opacity(0.50)
                                }
                            }
                            .foregroundStyle(by: .value("Type", rainFall.type))
                        }

                        /// RuleMark  lager en linje på y-verdien == 0:
                        ///
                        if dayArray.max()! == 0 {
                            RuleMark(y: .value("No precipitation", 0))
                                .annotation(position: .overlay, alignment: .center) {
                                    VStack {
                                        if index == 0 {
                                            Text(String(localized: "No precipitation to day."))
                                        } else {
                                            Text(String(localized: "No precipitation this day."))
                                        }
                                    }
                                    .font(.body)
                                    .padding(10)
                                    /// Tranparent bakgrunn == .opacity(1.0) :
                                    ///
                                    .opacity(1.0)
                                }
                        }
                        /// Markerer den tidligere delen av dagen:
                        ///
                        if index == 0 && dayArray.max()! != 0.00 {
                            RectangleMark (xStart: .value("Range Start", -1),
                                           xEnd: .value("Range End", currentWeather.hour)
                            )
                            .foregroundStyle(.black.opacity(0.7))
                        }
                    }
                    .chartForegroundStyleScale(range: markColors)
                    .frame(width: frameWidth, height: frameHeight)
                    .padding(.leading, 10)
                    .chartXScale(domain: 0...23)
                    .chartYAxisLabel(showUnit(option: option),
                                     position: .automatic,
                                     spacing: 10)
                    .offset(y: UIDevice.isIpad ? 0 : -5)
                    .overlay {
                        if show {
                            ///
                            /// Viser en loddrett linje med "selectedValue" på toppen:
                            ///
                            DayDetailShowSelection(option: option,
                                                   xPos: xPos,
                                                   selectedValue: selectedValue)
                        }
                    }
                    ///
                    /// Dette er entry point for gesture når en bruker BarMark:
                    ///
                    .gesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { touch in
                                show = true
                                opacity = 0.00
                                dayDetailHide = false
                                xPos = touch.location.x
                                if xPos <= xPosMax && xPos >= xPosMin {
                                    show = true
                                    opacity = 0.00
                                    let indexPM = Int(xPos / divisor)
                                    if indexPM > 23 {
                                        indexPointMark = 23
                                    } else {
                                        indexPointMark = Int(xPos / divisor)
                                    }
                                    selectedValue.icon = ""
                                    selectedValue.value1 = "\(dayArray[indexPointMark])\(showUnit(option: option))"
                                    selectedValue.value2 = ""
                                    selectedValue.value3 = ""
                                    selectedValue.time = IndexToHour(index: indexPointMark)
                                }
                            }
                            .onEnded { touch in
                                show = false
                                opacity = 1.00
                                dayDetailHide = false
                                selectedValue.icon = ""
                                selectedValue.value1 = ""
                                selectedValue.value2 = ""
                                selectedValue.value3 = ""
                                selectedValue.time = ""
                                /// Setter PointMark tilbake til tidspunktet på dagen:
                                ///
                                indexPointMark = IndexPointMarkFromHour()
                            }

                        )

                }
                else {
                    let markColors1: [Color] = [.blue, .cyan.opacity(0.25)]
                    Chart {
                        if option == .wind {
                            ForEach(windInfo, id: \.type) { windInfo in
                                ForEach(windInfo.data , id: \.amount) {
                                    LineMark (
                                        x: .value("Index", $0.index),
                                        y: .value("Amount", $0.amount)
                                    )
                                }
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(by: .value("Type", windInfo.type))
                                .lineStyle(StrokeStyle(lineWidth: 3))
                            }
                            ///
                            ///
                            /// Markerer minste "L" og høyeste "H"
                            ///
                            PointMark(x: .value("Index", windMinIndex),
                                      y: .value("Amount", windMin))
                            .symbol(.circle)
                            .annotation(position: .top) {
                                Text("L")
                                    .font(.footnote.weight(.bold))
                                    .opacity(0.50)
                            }
                            PointMark(x: .value("Index", windMaxIndex),
                                      y: .value("Amount", windMax))
                            .symbol(.circle)
                            .annotation(position: .top) {
                                Text("H")
                                    .font(.footnote.weight(.bold))
                                    .opacity(0.50)
                            }
                        } else if option == .temperature {
                            ForEach(tempInfo, id: \.type) { tempInfo in
                                ForEach(tempInfo.data , id: \.temp) {
                                    LineMark (
                                        x: .value("Index", $0.index),
                                        y: .value("Amount", $0.temp)
                                    )
                                }
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(by: .value("Type", tempInfo.type))
                                .lineStyle(StrokeStyle(lineWidth: 3))
                            }
                            ///
                            /// Markerer minste "L" og høyeste "H"
                            ///
                            PointMark(x: .value("Index", tempMinIndex),
                                      y: .value("Amount", tempMin))
                            .symbol(.circle)
                            .annotation(position: .top) {
                                Text("L")
                                    .font(.footnote.weight(.bold))
                                    .opacity(0.50)
                            }
                            PointMark(x: .value("Index", tempMaxIndex),
                                      y: .value("Amount", tempMax))
                            .symbol(.circle)
                            .annotation(position: .top) {
                                Text("H")
                                    .font(.footnote.weight(.bold))
                                    .opacity(0.50)
                            }
                        } else if option == .feelsLike {
                            ForEach(feltTempArray, id: \.type) { feltTemp in
                                ForEach(feltTemp.data , id: \.temp) {
                                    LineMark (
                                        x: .value("Index", $0.index),
                                        y: .value("Amount", $0.temp)
                                    )
                                }
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(by: .value("Type", feltTemp.type))
                                .lineStyle(StrokeStyle(lineWidth: 3))
                            }
                            ///
                            /// Markerer minste "L" og høyeste "H"
                            ///
                            PointMark(x: .value("Index", feelslikeMinIndex),
                                      y: .value("Amount", feelslikeMin))
                            .symbol(.circle)
                            .annotation(position: .top) {
                                Text("L")
                                    .font(.footnote.weight(.bold))
                                    .opacity(0.50)
                            }
                            PointMark(x: .value("Index", feelslikeMaxIndex),
                                      y: .value("Amount", feelslikeMax))
                            .symbol(.circle)
                            .annotation(position: .top) {
                                Text("H")
                                    .font(.footnote.weight(.bold))
                                    .opacity(0.50)
                            }
                        } else {
                            ForEach(dayArray.indices, id: \.self) { index in
                                LineMark(x: .value("Index", index),
                                         y: .value("Temp", dayArray[index]))
                                .interpolationMethod(.catmullRom)
                                .foregroundStyle(curColor)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                            }
                            if option == .visability
                                || option == .airPressure
                                || option == .humidity {
                                ///
                                /// Markerer minste "L" og høyeste "H"
                                ///
                                PointMark(x: .value("Index", otherMinIndex),
                                          y: .value("Amount", otherMin))
                                .symbol(.circle)
                                .annotation(position: .top) {
                                    Text("L")
                                        .font(.footnote.weight(.bold))
                                        .opacity(0.50)
                                }
                                PointMark(x: .value("Index", otherMaxIndex),
                                          y: .value("Amount", otherMax))
                                .symbol(.circle)
                                .annotation(position: .top) {
                                    Text("H")
                                        .font(.footnote.weight(.bold))
                                        .opacity(0.50)
                                }
                            } else if option == .uvIndex {
                                if otherMax > 0 {
                                    ///
                                    /// Markerer minste "L" og høyeste "H"
                                    ///
                                    PointMark(x: .value("Index", otherMinIndex),
                                              y: .value("Amount", otherMin))
                                    .symbol(.circle)
                                    .annotation(position: .top) {
                                        Text("L")
                                            .font(.footnote.weight(.bold))
                                            .opacity(0.50)
                                    }
                                    PointMark(x: .value("Index", otherMaxIndex),
                                              y: .value("Amount", otherMax))
                                    .symbol(.circle)
                                    .annotation(position: .top) {
                                        Text("H")
                                            .font(.footnote.weight(.bold))
                                            .opacity(0.50)
                                    }
                                }
                            }
                        }
                        ///
                        /// Markerer verdien på kurven ved DragGesture:
                        /// Har valgt å kommentere dette bort:
                        ///
                        //  if show {
                        //     PointMark(x: .value("index", indexPointMark),
                        //               y: .value("value", dayArray[indexPointMark]))
                        //  }
                        ///
                        /// Markerer den tidligere delen av dagen:
                        ///
                        RectangleMark (xStart: .value("Range Start", 0),
                                       xEnd: .value("Range End", index == 0 ? currentWeather.hour : 0)
                        )
                        .foregroundStyle(.black.opacity(0.35))
                    }
                    ///
                    /// .chartXScale gjør at Chart får en liten spacing mellom hvert element:
                    ///
                    .chartForegroundStyleScale(range: markColors1)
                    .frame(width: frameWidth, height: frameHeight)
                    .chartXScale(domain: 0...23)
                    ///
                    /// Endrer y aksen for:
                    ///     . uvIndex,
                    ///     . airPressure,
                    ///
                    .modifier(DayDetailChartYaxis(option: option))
                    .chartYAxisLabel(showUnit(option: option),
                                     position: .automatic,
                                     spacing: 10)
                    .foregroundColor(.primary)
                    .padding(.leading, index == 0 ? 10 : 20)
                    .overlay {
                        if show {
                            ///
                            /// Viser en loddrett linje med "selectedValue" på toppen:
                            ///
                            DayDetailShowSelection(option: option,
                                                   xPos: xPos,
                                                   selectedValue: selectedValue)
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { touch in
                                show = true
                                opacity = 0.00
                                dayDetailHide = false
                                xPos = touch.location.x
                                if xPos <= xPosMax && xPos >= xPosMin {
                                    show = true
                                    opacity = 0.00
                                    let indexPM = Int(xPos / divisor)
                                    if indexPM > 23 {
                                        indexPointMark = 23
                                    } else {
                                        indexPointMark = Int(xPos / divisor)
                                    }
                                    ///
                                    /// Oppdaterer selectedValue:
                                    ///
                                    if option == .uvIndex {
                                        if Int(dayArray[indexPointMark]) < 3 {
                                            selectedValue.icon = ""
                                            let a1 = String(localized: "Low lewel")
                                            let a2 = "\(Int(dayArray[indexPointMark]))\(showUnit(option: option))"
                                            selectedValue.value1 = a2
                                            selectedValue.value2 = a1
                                            selectedValue.value3 = ""
                                            selectedValue.time = IndexToHour(index: indexPointMark)
                                        } else {
                                            selectedValue.icon = ""
                                            let b1 = String(localized: "High lewel")
                                            let b2 = "\(Int(dayArray[indexPointMark]))\(showUnit(option: option))"
                                            selectedValue.value1 = b2
                                            selectedValue.value2 = b1
                                            selectedValue.value3 = ""
                                            selectedValue.time = IndexToHour(index: indexPointMark)
                                        }
                                    } else if option == .wind {
                                        selectedValue.icon = ""
                                        let deg = windInfo[0].data[IndexPointMarkFromHour()].direction
                                        let c1 = WindDirection(degree: deg, option: .shortDirection)
                                        let c2 = "\(Int(dayArray[indexPointMark]))"
                                        selectedValue.value1 = c2
                                        selectedValue.value2 = c1
                                        selectedValue.value3 = showUnit(option: option)
                                        selectedValue.time = IndexToHour(index: indexPointMark)
                                    } else if option == .feelsLike {
                                        selectedValue.icon = ""
                                        let d1 = "\(Int(dayArray[indexPointMark]))\(showUnit(option: option))"
                                        selectedValue.value1 = d1
                                        selectedValue.value2 = ""
                                        selectedValue.value3 = ""
                                        selectedValue.time = IndexToHour(index: indexPointMark)
                                    } else if option == .humidity {
                                        ///
                                        /// Finner dewPointArray:
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
                                                    [Double]) =  FindDataFromMenu(info: "DayDetailChart.humidity",
                                                                                  weather: weather,
                                                                                  date: dateSettings.dates[index],
                                                                                  option: option,
                                                                                  option1: .number24)
                                        dewPointArray = value.10
                                        selectedValue.icon = ""
                                        let e1 = "\(Int(dayArray[indexPointMark]))\(showUnit(option: option))"
                                        selectedValue.value1 = e1
                                        selectedValue.value2 = String(localized: "Dew point:")
                                        if dewPointArray.isEmpty == false {
                                            let e2 = "\(Int(dewPointArray[indexPointMark]))\(showUnit(option: .dewPoint))"
                                            selectedValue.value3 = e2
                                        } else {
                                            selectedValue.value3 = ""
                                        }
                                        selectedValue.time = IndexToHour(index: indexPointMark)
                                    } else if option == .temperature {
                                        selectedValue.icon = hourIconArray[indexPointMark]
                                        selectedValue.value1 = "\(Int(dayArray[indexPointMark]))\(showUnit(option: option))"
                                        selectedValue.value2 = ""
                                        selectedValue.value3 = ""
                                        selectedValue.time = IndexToHour(index: indexPointMark)
                                    } else if option == .visability {
                                        selectedValue.icon = ""
                                        selectedValue.value1 = "\(Int(dayArray[indexPointMark]))\(showUnit(option: option))"
                                        selectedValue.value2 = ""
                                        selectedValue.value3 = ""
                                        selectedValue.time = IndexToHour(index: indexPointMark)
                                    } else if option == .airPressure {
                                        selectedValue.icon = ""
                                        selectedValue.value1 = "\(Int(dayArray[indexPointMark]))\(showUnit(option: option))"
                                        selectedValue.value2 = ""
                                        selectedValue.value3 = ""
                                        selectedValue.time = IndexToHour(index: indexPointMark)
                                    } else if option == .precipitation {
                                        selectedValue.icon = ""
                                        selectedValue.value1 = "\(Int(dayArray[indexPointMark]))\(showUnit(option: option))"
                                        selectedValue.value2 = ""
                                        selectedValue.value3 = ""
                                        selectedValue.time = IndexToHour(index: indexPointMark)
                                    } else {
                                        selectedValue.icon = ""
                                        selectedValue.value1 = ""
                                        selectedValue.value2 = ""
                                        selectedValue.value3 = ""
                                        selectedValue.time = IndexToHour(index: indexPointMark)
                                    }
                                } else {
                                    show = false
                                    opacity = 1.00
                                    dayDetailHide = false
                                    selectedValue.icon = ""
                                    selectedValue.value1 = ""
                                    selectedValue.value2 = ""
                                    selectedValue.value3 = ""
                                    selectedValue.time = ""
                                }
                            }
                            .onEnded { touch in
                                show = false
                                opacity = 1.00
                                dayDetailHide = false
                                selectedValue.icon = ""
                                selectedValue.value1 = ""
                                selectedValue.value2 = ""
                                selectedValue.value3 = ""
                                selectedValue.time = ""
                                /// Setter PointMark tilbake til tidspunktet på dagen:
                                ///
                                indexPointMark = IndexPointMarkFromHour()
                            }
                    ) /// Slutten av gesture
                }
                /// Viser utvidet informasjon om været:
                ///
                VStack (alignment: .leading) {
                    DayDetailInfo(weather: weather,
                                  option: option,
                                  index: index,
                                  dayArray: $dayArray,
                                  weekdayArray: $weekdayArray,
                                  windInfo: $windInfo,
                                  tempInfo: $tempInfo,
                                  weatherIcon: $weatherIcon)
                }
                .offset(y: UIDevice.isIpad ? 10 : 10)
            }
            ///
            /// Her er en gesture som ligger på VStack og ikke på ChartView:
            /// Denne endrer index :
            ///
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.location.x > value.startLocation.x {
                            index = index + 1
                            if index > 9 {
                                index = 9
                            }
                        } else if value.location.x < value.startLocation.x {
                            index = index - 1
                            if index < 0 {
                                index = 0
                            }
                        } else {
                            index = index
                        }
                        
                        colorsForeground = updateForegroundColors(index: index,
                                                                  colorsForegroundStandard: colorsForegroundStandard,
                                                                  foregroundColor: Color(.black),
                                                                  foregroundColorIndex1: Color(.black))
                        ///
                        /// Resetter og oppdater bakgrunnen for aktuell indeks:
                        ///
                        colorsBackground = updateBackgroundColors(index: index,
                                                                  colorsBackgroundStandard: colorsBackgroundStandard,
                                                                  backGroundColor: .primary,
                                                                  backgroundColorIndex1: Color(.systemMint))
                    }
            )
            ///
            /// offset er forskjellig for .humidity og de andre option:
            ///
            .modifier(DayDetailChartOffsetViewModifier(option: option))
            Spacer()
        }
        .task {
            /// Resetter selectedValue fra gesture i DayDetailChart():
            ///
            selectedValue.icon = ""
            selectedValue.value1 = ""
            selectedValue.value2 = ""
            selectedValue.value3 = ""
            selectedValue.time = ""
            /// Oppdaterer bredden avhengig av on iPhone eller iPad:
            ///
            if UIDevice.isIpad {
                frameWidth = 500
                frameHeight = 150
                leading = 60
                xPosMin = 3
                xPosMax = 485
                divisor = xPosMax / 24
                padding = -290
                indexPointMark = IndexPointMarkFromHour()
            } else {
                frameWidth = 350
                frameHeight = 200
                leading = 40
                xPosMin = 3
                xPosMax = 334
                divisor = xPosMax / 24
                padding = -250
                indexPointMark = IndexPointMarkFromHour()
            }
            ///
            /// Her kan det kun komme option ==  .temperature og index == 0:
            ///
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
                         [Double]) = FindDataFromMenu(info: "DayDetailChart.task",
                                                      weather: weather,
                                                      date: dateSettings.dates[index],
                                                      option: option,
                                                      option1: .number24)
            
            ///
            /// Legg merkr til at hourIconArray er et array på 24 elenter
            /// Derfor må option1: .number24 benyttes
            ///
            hourIconArray = value.2
            if option == .temperature {
                tempInfo = value.5
                array.removeAll()
                for i in 0..<$tempInfo[tempType].data.count {
                    array.append(tempInfo[tempType].data[i].temp)
                }
                tempMin = Int(array.min()!.rounded())
                tempMax = Int(array.max()!.rounded())
                tempMinIndex = array.firstIndex(of: array.min()!)!
                tempMaxIndex = array.firstIndex(of: array.max()!)!
            }
        }
        .onChange(of: option) { oldOption, option in
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
                         [Double]) = FindDataFromMenu(info: "DayDetailChart change option",
                                                      weather: weather,
                                                      date: dateSettings.dates[index],
                                                      option: option,
                                                      option1: .number24)
            ///
            /// Legg merkr til at hourIconArray er et array på 24 elenter
            /// Derfor må option1: .number24 benyttes
            ///
            hourIconArray = value.2
            if option == .temperature {
                tempInfo = value.5
                array.removeAll()
                for i in 0..<$tempInfo[tempType].data.count {
                    array.append(tempInfo[tempType].data[i].temp)
                }
                tempMin = Int(array.min()!.rounded())
                tempMax = Int(array.max()!.rounded())
                tempMinIndex = array.firstIndex(of: array.min()!)!
                tempMaxIndex = array.firstIndex(of: array.max()!)!
            } else if option == .wind {
                windInfo = value.4
                array.removeAll()
                for i in 0..<windInfo[windType].data.count {
                    array.append(windInfo[windType].data[i].amount)
                }
                windMin = Int(array.min()!.rounded())
                windMax = Int(array.max()!.rounded())
                windMinIndex = array.firstIndex(of: array.min()!)!
                windMaxIndex = array.firstIndex(of: array.max()!)!
            } else if option == .feelsLike {
                feltTempArray = value.9
                array.removeAll()
                for i in 0..<feltTempArray[tempType].data.count {
                    array.append(feltTempArray[tempType].data[i].temp)
                }
                feelslikeMin = Int(array.min()!.rounded())
                feelslikeMax = Int(array.max()!.rounded())
                feelslikeMinIndex = array.firstIndex(of: array.min()!)!
                feelslikeMaxIndex = array.firstIndex(of: array.max()!)!
            } else if option == .precipitation {
                array.removeAll()
                array = value.0
                ///
                /// Finn den høyeste verdien:
                ///
                precipitationMax = array.max()!
                ///
                /// Finn den siste indexen som inneholder den høyeste verdien:
                ///
                precipitationMaxIndex = array.lastIndex(of: array.max()!)!
            } else {
                array.removeAll()
                array = value.0
                otherMin = Int(array.min()!.rounded())
                otherMax = Int(array.max()!.rounded())
                otherMinIndex = array.firstIndex(of: array.min()!)!
                otherMaxIndex = array.firstIndex(of: array.max()!)!
            }
        }
        .onChange(of: index) { oldIndex, index in
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
                         [Double]) = FindDataFromMenu(info: "DayDetailChart change index",
                                                      weather: weather,
                                                      date: dateSettings.dates[index],
                                                      option: option,
                                                      option1: .number24)
            ///
            /// Legg merkr til at hourIconArray er et array på 24 elenter
            /// Derfor må option1: .number24 benyttes
            ///
            hourIconArray = value.2
            if option == .temperature {
                tempInfo = value.5
                array.removeAll()
                for i in 0..<tempInfo[tempType].data.count {
                    array.append(tempInfo[tempType].data[i].temp)
                }
                tempMin = Int(array.min()!.rounded())
                tempMax = Int(array.max()!.rounded())
                tempMinIndex = array.firstIndex(of: array.min()!)!
                tempMaxIndex = array.firstIndex(of: array.max()!)!
            } else if option == .wind {
                windInfo = value.4
                array.removeAll()
                for i in 0..<windInfo[windType].data.count {
                    array.append(windInfo[windType].data[i].amount)
                }
                windMin = Int(array.min()!.rounded())
                windMax = Int(array.max()!.rounded())
                windMinIndex = array.firstIndex(of: array.min()!)!
                windMaxIndex = array.firstIndex(of: array.max()!)!
            } else if option == .feelsLike {
                feltTempArray = value.9
                array.removeAll()
                for i in 0..<feltTempArray[tempType].data.count {
                    array.append(feltTempArray[tempType].data[i].temp)
                }
                feelslikeMin = Int(array.min()!.rounded())
                feelslikeMax = Int(array.max()!.rounded())
                feelslikeMinIndex = array.firstIndex(of: array.min()!)!
                feelslikeMaxIndex = array.firstIndex(of: array.max()!)!
            } else if option == .precipitation {
                array.removeAll()
                array = value.0
                ///
                /// Finn den høyeste verdien:
                ///
                precipitationMax = array.max()!
                ///
                /// Finn den siste indexen som inneholder den høyeste verdien:
                ///
                precipitationMaxIndex = array.lastIndex(of: array.max()!)!
            } else {
                array.removeAll()
                array = value.0
                otherMin = Int(array.min()!.rounded())
                otherMax = Int(array.max()!.rounded())
                otherMinIndex = array.firstIndex(of: array.min()!)!
                otherMaxIndex = array.firstIndex(of: array.max()!)!
            }
        }
    }
}
