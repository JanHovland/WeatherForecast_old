//
//  DayDetail.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 02/11/2022.
//

import SwiftUI

//
//  DayDetail.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 17/10/2022.
//

import SwiftUI
import WeatherKit

struct DayDetail: View {
    
    let weather : Weather
    @Binding var dateSelected : String
    @Binding var dayDetailHide : Bool
    @Binding var sunRises : [String]
    @Binding var sunSets : [String]
    
    ///
    /// https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-dark-mode
    ///  Her finnes det  bruk av @Environment(\.colorScheme) var colorScheme
    ///
    ///
    /// https://developer.apple.com/forums/thread/680109
    /// For å kunne benytte dateArry[index] må hele dateArray initialiseres.
    /// Er det aktuelt med antall lik 10 må dateArray initialiseres med 10 verdier.
    ///
    /// Der hvor dateSettings = DateSettings() endres,  settes:
    ///     @StateObject var dateSettings = DateSettings() og
    ///     .environmentObject(dateSettings)
    ///
    /// Der hvor dateSettings skal brujkes ettes :
    ///     @EnvironmentObject var dateSettings : DateSettings
    ///
    
    @StateObject var dateSettings = DateSettings()
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currentWeather: CurrentWeather
    
    @State private var dateArray : [String] = Array(repeating: "", count: 10)
    @State private var dateDateArray: [Date] = Array(repeating: Date(), count: 10)
    @State private var weekdayArray : [String] = Array(repeating: "", count: 10)
    @State private var colorsBackground : [Color] = Array(repeating: Color(.systemBackground), count: 10)
    @State private var colorsBackgroundStandard: [Color] = Array(repeating: Color(.systemBackground), count: 10)
    @State private var arrayDayIcons : [String] = Array(repeating: String(), count: 12)
    
    @State private var hourIconArray : [String] = Array(repeating: String(), count: 24)
    
    ///
    /// Her kan man ikke benytte Color(.primary), men må benytte Color(.white).
    /// noe som skyldes at 'CGColor' has no member 'primary'
    ///
    /// Vær oppmerksom på at i light mode vises ikke .white på hvit bakgrunn,
    ///
    @State private var colorsForeground : [Color] = [Color(.systemMint),
                                                     Color(.white),
                                                     Color(.white),
                                                     Color(.white),
                                                     Color(.white),
                                                     Color(.white),
                                                     Color(.white),
                                                     Color(.white),
                                                     Color(.white),
                                                     Color(.white)]
    
    ///
    /// Her kan man ikke benytte Color(.primary), men må benytte Color(.white).
    /// noe som skyldes at 'CGColor' has no member 'primary'
    ///
    @State private var colorsForegroundStandard : [Color] = [Color(.systemMint),
                                                             Color(.white),
                                                             Color(.white),
                                                             Color(.white),
                                                             Color(.white),
                                                             Color(.white),
                                                             Color(.white),
                                                             Color(.white),
                                                             Color(.white),
                                                             Color(.white)]
    
    @State private var menuSystemName : String = "thermometer.medium"
    @State private var menuTitle = String(localized:  "Temperature")
    
    @State private var option: EnumType = .temperature
    @State private var option1: EnumType = .number12
    
    @State private var selectedValue: SelectedValue = SelectedValue()
    
    @State private var dayArray: [Double] = Array(repeating: Double(), count: 10)
    @State private var rainFalls: [RainFall] = []
    @State private var windInfo: [WindInfo] = []
    @State private var tempInfo: [Temperature] = []
    @State private var gustInfo: [Double] = []
    @State private var weatherIcon: [WeatherIcon] = []
    @State private var feltTempArray: [FeltTemp] = []
    
    @State private var index : Int = 0
    
    @State private var uvIndexArray: [String] = Array(repeating: String(), count: 12)
    @State private var windArray: [String] = Array(repeating: String(), count: 12)
    @State private var humidityArray: [String] = Array(repeating: String(), count: 12)
    @State private var visabilityArray:[String] = Array(repeating: String(), count: 12)
    @State private var airpressureArray:[String] = Array(repeating: String(), count: 12)
    
    @State private var message: LocalizedStringKey = ""
    @State private var title: LocalizedStringKey = ""
    @State private var showAlert: Bool = false
    
    @State private var opacity: Double = 1.00
    
    @State private var dewPointArray: [Double] = Array(repeating: Double(), count: 24)
    
    var body: some View {
        NavigationStack {
            ScrollView (showsIndicators: false) {
                VStack (alignment: .leading) {
                    ///
                    /// Viser menyvalget og knapp for avslutning:
                    ///
                   
                    if UIDevice.current.model == "iPhone" {
                        HStack (alignment: .center) {
                            Spacer()
                            Image(systemName: menuSystemName)
                                .font(.body)
                            Text(menuTitle)
                            ///
                            /// Fonten skaleres automatisk ned til 65%
                            ///
                                .minimumScaleFactor(0.65)
                            Spacer()
                        }
                        .padding(.top, 10)
                    } else if UIDevice.current.model ==  "iPad" {
                        HStack (alignment: .center) {
                            HStack (alignment: .center) {
                                Image(systemName: menuSystemName)
                                    .font(.body)
                                Text(menuTitle)
                                ///
                                /// Fonten skaleres automatisk ned til 65%
                                ///
                                    .minimumScaleFactor(0.65)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal, 200)
                    }
                    VStack {
                        Button {
                            ///
                            /// Rutine for å avslutte DayDetail():
                            ///
                            Task.init {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Image(systemName: "x.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                    }
                   .offset(x: UIDevice.isIpad ? 485 : 337,
                            y: UIDevice.isIpad ? -25 : -24)
                    ///
                    /// Viser ukedag og dato:
                    ///
                    HStack (spacing: UIDevice.isIpad ? 18 : 2.0) {
                        ForEach(Array(dateArray.enumerated()), id: \.element) { idx, element in
                            VStack {
                                Text(weekdayArray[idx])
                                    .font(.system(size: UIDevice.isIpad ? 17 : 12, weight: .bold))
                                    .offset(y: 10)
                                Text(element.description)
                                    .padding(8)
                                    .font(.system(size: UIDevice.isIpad ? 17 : 12, weight: .regular))
                                    .foregroundColor(colorsForeground[idx])
                                    .background(colorsBackground[idx])
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        ///
                                        /// Resetter og oppdater forgrunnen for aktuell indeks:
                                        ///
                                        colorsForeground = updateForegroundColors(index: idx,
                                                                                  colorsForegroundStandard: colorsForegroundStandard,
                                                                                  foregroundColor: Color(.black),
                                                                                  foregroundColorIndex1: Color(.black))
                                        ///
                                        /// Resetter og oppdater bakgrunnen for aktuell indeks:
                                        ///
                                        colorsBackground = updateBackgroundColors(index: idx,
                                                                                  colorsBackgroundStandard: colorsBackgroundStandard,
                                                                                  backGroundColor: .primary,
                                                                                  backgroundColorIndex1: Color(.systemMint))
                                        ///
                                        /// Tar vare på index:
                                        ///
                                        index = idx
                                        /// Finner dagens høyeste og laveste temperatur:
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
                                                     [Double]) = FindDataFromMenu(info: "DayDetail .onTapGesture ",
                                                                                  weather: weather,
                                                                                  date: dateSettings.dates[index],
                                                                                  option: .temperature,
                                                                                  option1: option1)
                                        arrayDayIcons = value.1
                                        hourIconArray = value.2
                                        windInfo = value.4
                                        tempInfo = value.5
                                        gustInfo = value.6
                                        weatherIcon = value.7
                                        feltTempArray = value.9
                                    }
                            }
                            .padding(.leading, UIDevice.isIpad ? 0 : 5)
                        }
                    }
                    .padding(.trailing, UIDevice.isIpad ? 60 : 0)
                    ///
                    ///Viser temperaturen akkurat nå avhengig av index:
                    ///
                    VStack (alignment: .center) {
                        ///
                        /// Viser riktig dato:
                        ///
                        Text(GetTimeFromDay(date: currentWeather.date.adding(days: index), format: "EEEE d. MMMM yyyy"))
                    }
                    .padding(.leading, UIDevice.isIpad ? 170 : 97.5)
                    .padding(.top, 2)
                    ///
                    /// Viser meny og kort værinformasjon:
                    ///
                    DayDetailMenuDataView(weather: weather,
                                          index: $index,
                                          menuSystemName: $menuSystemName,
                                          menuTitle: $menuTitle,
                                          arrayDayIcons: $arrayDayIcons,
                                          opacity: $opacity)
                    ///
                    /// Markere natt og dag og image rekken for aktuell dag:
                    ///
                    VStack (alignment: .leading) {
                        ///
                        /// Viser natt og dag:
                        ///
                        SunDayAndNight(xMax: UIDevice.isIpad ? 490 : 352,
                                       index : index,
                                       sunRises: $sunRises,
                                       sunSets: $sunSets)
                        .padding(.bottom, 10)
                        .padding(.top, 5)
                        ///
                        /// Viser image rekken:
                        ///
                        DayDetailHourIcons(option: MenuTitleToOption(menuTitle: menuTitle),
                                           iconArray: $hourIconArray,
                                           uvIndexArray: $uvIndexArray,
                                           windArray: $windArray,
                                           humidityArray: $humidityArray,
                                           visabilityArray: $visabilityArray,
                                           airpressureArray: $airpressureArray)
                    }
                    .offset(x: UIDevice.isIpad ? 0 : 0,
                            y: UIDevice.isIpad ? -115 : -115)
                    ZStack {
                        ///
                        /// Viser data for aktuell option:
                        ///
                        DayDetailDayDataView(weather: weather,
                                             option: MenuTitleToOption(menuTitle: menuTitle),
                                             arrayDayIcons: $arrayDayIcons,
                                             dateArray: $dateSettings.dates,
                                             index: $index,
                                             colorsForeground: $colorsForeground,
                                             colorsForegroundStandard: $colorsForegroundStandard,
                                             colorsBackground: $colorsBackground,
                                             colorsBackgroundStandard: $colorsBackgroundStandard,
                                             dayDetailHide: $dayDetailHide,
                                             selectedValue: $selectedValue,
                                             dayArray: $dayArray,
                                             rainFalls: $rainFalls,
                                             weekdayArray: $weekdayArray,
                                             windInfo: $windInfo,
                                             tempInfo: $tempInfo,
                                             gustInfo: $gustInfo,
                                             weatherIcon: $weatherIcon,
                                             feltTempArray: $feltTempArray,
                                             opacity: $opacity,
                                             dewPointArray: $dewPointArray)
                    }
                    .offset(x: UIDevice.isIpad ?   0 :   0,
                            y: UIDevice.isIpad ? 250 : 150)
                    ///
                    /// Måtte lage en viewModifier "OffsetView" for å skille .offset for skille
                    /// mellom .humidity hvor høyden på Chart() er mindre enn de andre opsjonene.
                    ///
                    .modifier(DayDetailOffsetViewModifier(option: MenuTitleToOption(menuTitle: menuTitle)))
                }
                Spacer()
            }
            .padding(.leading, UIDevice.isIpad ? -27.5 : 20)
        }
        .onChange(of: index) { oldIndex, index in
            ///
            /// Oppdaterer weatherIcon:
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
                        [Double]) =  FindDataFromMenu(info: "DayDetail change index",
                                                      weather: weather,
                                                      date: dateSettings.dates[index],
                                                      option: .wind,
                                                      option1: option1)
            weatherIcon = value.7
            ///
            /// Oppdaterer uvIndexArray:
            ///
            uvIndexArray.removeAll()
            for i in 0..<weatherIcon[uvIconType].data.count {
                uvIndexArray.append(weatherIcon[uvIconType].data[i].icon)
            }
            ///
            /// Oppdaterer windArray:
            ///
            windArray.removeAll()
            for i in 0..<weatherIcon[windIconType].data.count {
                windArray.append(weatherIcon[windIconType].data[i].icon)
            }
            ///
            /// Oppdaterer humidityArray:
            ///
            humidityArray.removeAll()
            for i in 0..<weatherIcon[humidityIconType].data.count {
                humidityArray.append(weatherIcon[humidityIconType].data[i].icon)
            }
            ///
            /// Oppdaterer visabilityArray:
            ///
            visabilityArray.removeAll()
            for i in 0..<weatherIcon[visibilityIconType].data.count {
                visabilityArray.append(weatherIcon[visibilityIconType].data[i].icon)
            }
            ///
            /// Oppdaterer airpressureArray:
            ///
            airpressureArray.removeAll()
            for i in 0..<weatherIcon[airpressureIconType].data.count {
                airpressureArray.append(weatherIcon[airpressureIconType].data[i].icon)
            }
        }
        .task {
            ///
            /// Oppdaterer weatherIcon:
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
                        [Double]) =  FindDataFromMenu(info: "DayDetail.task",
                                                      weather: weather,
                                                      date: dateSettings.dates[index],
                                                      option: .wind,
                                                      option1: option1)
            weatherIcon = value.7

            ///
            /// Oppdaterer uvIndexArray:
            ///
            uvIndexArray.removeAll()
            for i in 0..<weatherIcon[uvIconType].data.count {
                uvIndexArray.append(weatherIcon[uvIconType].data[i].icon)
            }
            ///
            /// Oppdaterer windArray:
            ///
            windArray.removeAll()
            for i in 0..<weatherIcon[windIconType].data.count {
                windArray.append(weatherIcon[windIconType].data[i].icon)
            }
            ///
            /// Oppdaterer humidityArray:
            ///
            humidityArray.removeAll()
            for i in 0..<weatherIcon[humidityIconType].data.count {
                humidityArray.append(weatherIcon[humidityIconType].data[i].icon)
            }
            ///
            /// Oppdaterer visabilityArray:
            ///
            visabilityArray.removeAll()
            for i in 0..<weatherIcon[visibilityIconType].data.count {
                visabilityArray.append(weatherIcon[visibilityIconType].data[i].icon)
            }
            ///
            /// Oppdaterer airpressureArray:
            ///
            airpressureArray.removeAll()
            for i in 0..<weatherIcon[airpressureIconType].data.count {
                airpressureArray.append(weatherIcon[airpressureIconType].data[i].icon)
            }
            ///
            /// Resetter selectedValue fra gesture i DayDetailChart():
            ///
            selectedValue.icon  = ""
            selectedValue.value1  = ""
            selectedValue.value2  = ""
            ///
            /// Oppretter dateArray ut fra weather:
            ///
            
            let value2: ([String], [Date], [String])
            value2 = createDateArray(format: UIDevice.isIpad ? "E" : "EEEEEE")
            dateArray = value2.0
            dateDateArray = value2.1
            weekdayArray = value2.2
            ///
            /// Sletter innholdet i dateSetting.dates:
            ///
            dateSettings.dates.removeAll()
            dateSettings.index = 0
            ///
            /// Oppdaterer dateSetting.dates:
            ///
            var date: Date = Date().setTime(hour: 0, min: 0, sec: 0) ?? Date()
            
            for i in 0..<10 {
                date = DateAddDay(day: i).setTime(hour: 0, min: 0, sec: 0)!
                dateSettings.index = i
                dateSettings.dates.append(date)
            }
            if dateArray.contains(dateSelected) {
                ///
                /// Finn valgt index i dateArray:
                ///
                dateSettings.index = dateArray.firstIndex(of: dateSelected)!
                index = dateSettings.index
                
            } else {
                ///
                /// Ser ut som det er tilfeldig om dateArray.contains(dateSelected) er false
                /// Velger derfor å kommentere bort :showAlert.toggle()
                ///
                ///
                /// Gir feilmelding dersom dateSelected ikke finnes i dateArray:
                ///
                title = "'dateSelected' value == \(dateSelected)"
                message = "Value == \(dateSelected) is not part of the 'dateArray'."
//                showAlert.toggle()
            }
            if weekdayArray.count < 10 {
                title = "Number of elements in 'weekdayArray'"
                message = "Number of elements in 'weekdayArray' should be 10"
                showAlert.toggle()
            }
            ///
            /// Resetter colors og oppdater forgrunnen for index = 0:
            ///
            colorsForeground = updateForegroundColors(index: dateSettings.index,
                                                      colorsForegroundStandard: colorsForegroundStandard,
                                                      foregroundColor: Color(.black),
                                                      foregroundColorIndex1: Color(.black))
            ///
            /// Resetter colors og oppdater bakgrunnen for index = 0:
            ///
            colorsBackground = updateBackgroundColors(index: dateSettings.index,
                                                      colorsBackgroundStandard: colorsBackgroundStandard,
                                                      backGroundColor: .primary,
                                                      backgroundColorIndex1: Color(.systemMint))
            let value1 : ([Double],
                          [String],
                          [String],
                          [RainFall],
                          [WindInfo],
                          [Temperature],
                          [Double],
                          [WeatherIcon],
                          [Double],
                          [FeltTemp],
                          [Double]) = FindDataFromMenu(info: "DayDetail .task",
                                                       weather: weather,
                                                       date: dateSettings.dates[index],
                                                       option: .temperature,
                                                       option1: option1)
            arrayDayIcons = value1.1
            hourIconArray = value1.2
            windInfo = value1.4
            tempInfo = value1.5
            gustInfo = value1.6
            weatherIcon = value1.7
            feltTempArray = value1.9
        }
        ///
        /// Der hvor det gjøres en oppdatering av et environmentObject
        /// må dette legges inn for å oppdatere dataene.
        ///
        .environmentObject(dateSettings)
        .alert(title, isPresented: $showAlert) {
        }
        message: {
           Text(message)
        }
    }
}


