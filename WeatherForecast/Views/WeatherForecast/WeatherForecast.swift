//
//  WeatherForecastMain.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 20/07/2022.
//

/// https://www.youtube.com/watch?v=PAPgcSpSpcs

import SwiftUI
import CoreLocation
import WeatherKit
import CloudKit

// For å kunne bruke WeatherKit :

// Gå til "Info"
// Legg til ny Key: Privacy - Location When In Use Description Privacy
// Legg til ny Key: Privacy - Location Always and When In Use Usage Description
// Gå til "Signing & Capabilities" Legg til Capabilities legg til "WeatherKit"

// Gå til deceloper.apple.com og velg Certificates, Identifier & Profiles
// Under "Identifier" : Finn aktuell applicasjon og klikk på denne
// Sjekk at WeatherKit er valgt i både "Capabilities" og "App Services"
// Dette kan ta opptil 30 minutter

///
/// https://word-brain.net/no/rev/id-507.html
///
/// https://blog.prototypr.io/ios-16-for-product-designers-and-design-engineers-38b5f8408481
///
/// https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-environmentobject-to-share-data-between-views
///
/// https://www.andyibanez.com/posts/using-corelocation-with-swiftui/
///
/// https://useyourloaf.com/blog/xcode-13-missing-info.plist/
///
/// https://swiftuirecipes.com/blog/file-tree-with-expanding-list-in-swiftui
///
struct WeatherForecast: View {
    
    ///
    /// case intern                 /// Starte opp WeatherForecast() locationManager.currentLocation
    /// case selection            /// Starte opp WeatherForecast() fra WeatherForecastSelectPlace()
    ///
    
    
    /// @Enviroment(\.presentationMode) will be deprecated, use this instead: @Enviroment(\.dismiss) var dismissScreen and you will call it in the action of your button as a function, like this: dismissScreen().
    
    
    var expShowDismissButton: Bool = false
    var expOption: EnumType = .intern
    var extPlaceName: String = ""
    var extCountryName: String = ""
    var extLatitude: Double = 0.00
    var extLongitude: Double = 0.00
    var extOffsetString: String = ""
    var extOffsetSec: Int = 0
    
    let weatherService = WeatherService.shared
    
    @StateObject var currentWeather = CurrentWeather()
    @StateObject var locationViewModel = LocationViewModel()
    @Environment(\.dismiss) var dismissScreen
    
    @State private var weather : Weather?
    @State private var geoRecord = GeoRecord()
    @State private var opacityIndicator: Double = 1.00
    ///
    /// Inneholder soloppgang og solnedgang for 10 dager:
    ///
    @State private var sunRises: [String] = Array(repeating: "", count: 10)
    @State private var sunSets: [String] = Array(repeating: "", count: 10)
    
    @State private var message: LocalizedStringKey = ""
    @State private var title: LocalizedStringKey = ""
    @State private var showAlert: Bool = false
    
    @State private var array: [Double] = Array(repeating: Double(), count: 24)
    
    @State private var persist: Bool = true
    
    var body: some View {
        VStack {
            ActivityIndicator(opacity: $opacityIndicator)
                .offset(y: UIDevice.isIpad ? -375 : -325)
            if let weather {
                if UIDevice.isIpad {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            VStack {
                                Text(placeName.count > 0 ? placeName : "No placeName")
                                    .font(.system(size: 40, weight: .light))
                                Text(countryName.count > 0 ? countryName : "No countryName")
                            }
                            ZStack {
                                Image(systemName: "ellipsis.circle")
                                    .renderingMode(.original)
                                    .font(.system(size: 30, weight: .light))
                                    .contextMenu {
                                        ///
                                        /// Frisk opp:
                                        ///
                                        Button (action: {
                                            Task.init {
                                                await Refresh()
                                            }
                                        }, label: {
                                            HStack {
                                                Text("Refresh")
                                                Image(systemName: "arrow.uturn.right.circle")
                                            }
                                        })
                                        ///
                                        /// Lagre lokalt sted:
                                        ///
                                        Button (action: {
                                            Task.init {
                                                ///
                                                /// Begynner på lagringen:
                                                ///
                                                let place = Place(place: localPlaceName,
                                                                  flag: localFlag,
                                                                  country: localCountry,
                                                                  lon: localLongitude,
                                                                  lat: localLatitude,
                                                                  offsetSec: localOffsetSec,
                                                                  offsetString: localOffsetString)
                                                let value: (Bool, LocalizedStringKey)
                                                value = await SaveNewPlace(place)
                                                if value.0 == true {
                                                    title = "Save local place"
                                                    message = value.1
                                                    showAlert.toggle()
                                                } else {
                                                    ///
                                                    /// Stedet ble ikke lagret:
                                                    ///
                                                    title = "Save local place"
                                                    message = value.1
                                                    showAlert.toggle()
                                                }
                                            }
                                        }, label: {
                                            HStack {
                                                Text("Save local place")
                                                Image(systemName: "externaldrive.connected.to.line.below")
                                            }
                                        })
                                        ///
                                        /// Lukke været for valgt sted::
                                        ///
                                        if expShowDismissButton == true {
                                            Button (action: {
                                                Task.init {
                                                    dismissScreen()
                                                }
                                            }, label: {
                                                HStack {
                                                    Text("Dismiss weather in '\(extPlaceName)'")
                                                    Image(systemName: "x.circle")
                                                }
                                            })
                                        }
                                    }
                            }
                            .offset(x:  350,
                                    y:  -54.0)
                            WeatherForecastDetail(weather: weather, geoRecord: geoRecord)
                            HourOverview(weather: weather,
                                         sunRises: $sunRises,
                                         sunSets: $sunSets)
                            Group {
                                HStack (spacing: 8) {
                                    ///
                                    /// Viser vindretning og hastighet:
                                    ///
                                    WindView(weather: weather)
                                    ///
                                    /// Viser føles som:
                                    ///
                                    FeelsLike()
                                    ///
                                    /// Viser luftfuktighet:
                                    ///
                                    Humidity()
                                    ///
                                    /// Viser sikten:
                                    ///
                                    Visibility(weather: weather)
                                }
                                HStack (spacing: 8) {
                                    ///
                                    /// Viser Uv indeksen:
                                    ///
                                    UvIndex(weather: weather)
                                    ///
                                    /// Viser regn de forrige 24 timene:
                                    ///
                                    Precipitation24h(weather: weather)
                                    ///
                                    /// Viser solen:
                                    ///
                                    Sun(weather: weather,
                                        sunRises: $sunRises,
                                        sunSets: $sunSets)
                                    ///
                                    /// Viser lufttrykket:
                                    ///
                                    AirPressure(weather: weather)
                                }
                            }
                            ///
                            /// Viser oversikt pr. dag:
                            ///
                            DayOverview(weather: weather,
                                        sunRises: $sunRises,
                                        sunSets: $sunSets)
                            ///
                            /// Viser historikken for været:
                            ///
                            WeatherHistoryEurope(weather: weather)
                        }
                        .frame(width: 1200)
                    }
                } else if UIDevice.isiPhone {
                    ScrollView (.vertical, showsIndicators: false) {
                        VStack {
                            VStack {
                                Text(placeName.count > 0 ? placeName : "No placeName")
                                    .font(.system(size: 40, weight: .light))
                                Text(countryName.count > 0 ? countryName : "No countryName")
                            }
                            ZStack {
                                Image(systemName: "ellipsis.circle")
                                    .renderingMode(.original)
                                    .font(.system(size: 30, weight: .light))
                                    .offset(x:  170,
                                            y:  -55)
                                    .contextMenu {
                                        ///
                                        /// Frisk opp:
                                        ///
                                        Button (action: {
                                            Task.init {
                                                await Refresh()
                                            }
                                        }, label: {
                                            HStack {
                                                Text("Refresh")
                                                Image(systemName: "arrow.uturn.right.circle")
                                            }
                                        })
                                        ///
                                        /// Lagre lokalt sted:
                                        ///
                                        Button (action: {
                                            Task.init {
                                                ///
                                                /// Begynner på lagringen:
                                                ///
                                                let place = Place(place: localPlaceName,
                                                                  flag: localFlag,
                                                                  country: localCountry,
                                                                  lon: localLongitude,
                                                                  lat: localLatitude,
                                                                  offsetSec: localOffsetSec,
                                                                  offsetString: localOffsetString)
                                                let value: (Bool, LocalizedStringKey)
                                                value = await SaveNewPlace(place)
                                                if value.0 == true {
                                                    title = "Save local place"
                                                    message = value.1
                                                    showAlert.toggle()
                                                } else {
                                                    ///
                                                    /// Stedet ble ikke lagret:
                                                    ///
                                                    title = "Save local place"
                                                    message = value.1
                                                    showAlert.toggle()
                                                }
                                            }
                                        }, label: {
                                            HStack {
                                                Text("Save local place")
                                                Image(systemName: "externaldrive.connected.to.line.below")
                                            }
                                        })
                                        ///
                                        /// Lukke været for valgt sted::
                                        ///
                                        if expShowDismissButton == true {
                                            Button (action: {
                                                Task.init {
                                                    dismissScreen()
                                                }
                                            }, label: {
                                                HStack {
                                                    Text("Dismiss weather in '\(extPlaceName)'")
                                                    Image(systemName: "x.circle")
                                                }
                                            })
                                        }
                                        
                                    }
                            }
                            WeatherForecastDetail(weather: weather, geoRecord: geoRecord)
                            HourOverview(weather: weather,
                                         sunRises: $sunRises,
                                         sunSets: $sunSets)
                            
                            Group {
                                HStack (spacing: 8) {
                                    ///
                                    /// Viser vindretning og hastighet:
                                    ///
                                    WindView(weather: weather)
                                    ///
                                    /// Viser føles som:
                                    ///
                                    FeelsLike()
                                }
                                
                                HStack (spacing: 8) {
                                    ///
                                    /// Viser luftfuktighet:
                                    ///
                                    Humidity()
                                    ///
                                    /// Viser sikten:
                                    ///
                                    Visibility(weather: weather)
                                }
                            }
                            
                            Group {
                                HStack (spacing: 8) {
                                    ///
                                    /// Viser Uv indeksen:
                                    ///
                                    UvIndex(weather: weather)
                                    ///
                                    /// Viser regn de forrige 24 timene:
                                    ///
                                    Precipitation24h(weather: weather)
                                }
                                
                                HStack (spacing: 8) {
                                    ///
                                    /// Viser solen:
                                    ///
                                    Sun(weather: weather,
                                        sunRises: $sunRises,
                                        sunSets: $sunSets)
                                    ///
                                    /// Viser lufttrykket:
                                    ///
                                    AirPressure(weather: weather)
                                }
                            }
                            ///
                            /// Viser oversikt pr. dag:
                            ///
                            DayOverview(weather: weather,
                                        sunRises: $sunRises,
                                        sunSets: $sunSets)
                            ///
                            /// Viser historikken for været:
                            ///
                            WeatherHistoryEurope(weather: weather)
                        }
                    }
                }
                Spacer()
            }
        }
        .alert(title, isPresented: $showAlert) {
        }
    message: {
        Text(message)
    }
    .navigationBarTitleDisplayMode(.inline)
        ///
        /// SwiftUI gives us equivalents to UIKit’s viewDidAppear() and viewDidDisappear() in the form of onAppear() and onDisappear().
        ///
    .onAppear {
        Task.init {
            ///
            /// Sjekker innstillingene:
            ///
            let key1 = UserDefaults.standard.object(forKey: "KeyOpenCage") as? String ?? ""
            let urlOpenCage1 = UserDefaults.standard.object(forKey: "UrlOpenCage") as? String ?? ""
            let urlMetNo1 = UserDefaults.standard.object(forKey: "UrlMetNo") as? String ?? ""
            
            if key1 == "" || urlOpenCage1 == "" || urlMetNo1 == "" {
                title = "Missing data in one or more of the Settings.\n"
                message = "Select Settings and enter the missing values."
                showAlert.toggle()
            } else {
                ///
                /// Sjekker om internet er tilkoplet:
                ///
                var value : (Bool, LocalizedStringKey)
                value = ConnectToInternet()
                if value.0 == false {
                    title = value.1
                    message = "No Internet connection for this device."
                    showAlert.toggle()
                    ///
                    /// Lagger inn en forsinkelse på 10 sekunder:
                    ///
                    sleep(10)
                }
                ///
                /// Kaller opp refresh()
                ///
                await Refresh()
            }
        }
    }
    .environmentObject(currentWeather)
    .environmentObject(locationViewModel)
    }
    ///
    /// Rutine for oppfriskning:
    ///
    func Refresh() async {
        ///
        /// Starter visning av indicatoren :
        ///
        opacityIndicator = 1.0
        if expOption == .selection {
            ///
            /// Oppdaterer placeName, latitude og longitude:
            ///
            latitude = extLatitude
            longitude = extLongitude
            placeName = extPlaceName
            countryName = TranslateCountry(country: extCountryName)
            offsetString = AdjustOffset(extOffsetString)
        } else {
            ///
            /// Finner currentLocation:
            ///
            let value1: (Double, Double, String, String, Int, Date, String, Double, Double, Double, Bool, String, String)
            value1 = await FindCurrentLocation(locationViewModel)
            latitude = value1.0
            longitude = value1.1
            placeName = value1.2
            countryName = TranslateCountry(country: value1.12)
            offsetString = value1.3
            offsetSec = value1.4
            ///
            /// Tar vare på de locale variable:
            ///
            localLatitude = value1.0
            localLongitude = value1.1
            localPlaceName = value1.2
            localOffsetString = value1.3
            localOffsetSec = value1.4
            localDate = value1.5
            localCondition = value1.6
            localTemperature = value1.7
            localLowTemperature = value1.8
            localHighTemperature = value1.9
            localIsDaylight = value1.10
            localFlag = value1.11
            localCountry = TranslateCountry(country: value1.12)
            ///
            /// Sjekker om det kommer koordinater fra FindCurrentLocation:
            ///
            if latitude == 0.00 && longitude == 0.00 {
                persist = false
                title = "Missing coordinates from FindCurrentLocation()"
                message = "No coordinates found.\n\nPlease note that this alert will only show for a few seconds and then the App will automatically shut down."
                showAlert.toggle()
                ///
                /// Lukker denne meldingen etter 10 sekunder:
                ///
                dismissAlert(seconds: 10)
            }
        }
        if persist == true {
            ///
            /// Finner hourForecast:
            ///
            let startDate = Date().setTime(hour: 0, min: 0, sec: 0)
            let endDate = (Calendar.current.date(byAdding: .day, value: 11, to: startDate ?? Date())!).setTime(hour: 0, min: 0, sec: 0)
            
            let location = CLLocation(latitude: latitude ?? 0.00, longitude: longitude ?? 0.00)
            
            do {
                hourForecast = try await WeatherService.shared.weather(for: location,
                                                                       including: .hourly(startDate: startDate!,
                                                                                          endDate: endDate!))
            } catch {
                debugPrint(error)
                title = "Error finding 'hourForecast'.\n\nExit the app."
                message = ServerResponse(error: error.localizedDescription)
                showAlert.toggle()
            }
            ///
            /// Sjekker om hourForecast ikke er tom:
            ///
            if hourForecast?.isEmpty == true {
                persist = false
                title = "Find the hourForecast data"
                message = "The hourForecast is empty.\n\nPlease note that this alert will only show for a few seconds and then the App will automatically shut down."
                showAlert.toggle()
                ///
                /// Lukker denne meldingen etter 10 sekunder:
                ///
                dismissAlert(seconds: 10)
            }
            ///
            /// Går bare videre dersom persist er true:
            ///
            if persist == true {
                ///
                /// Finner soloppgang og solnedgang:
                ///
                let url = UserDefaults.standard.object(forKey: "UrlMetNo") as? String ?? ""
                let value : (String, [String], [String]) =
                await FindSunUpDown(url: url,
                                    offset: offsetString,
                                    days: 10)
                if value.0.isEmpty {
                    sunRises = value.1
                    sunSets = value.2
                }
                else {
                    sunRises.removeAll()
                    sunSets.removeAll()
                }
                ///
                /// Gir melding og avslutter appen dersom sola data er tom :
                ///
                if sunRises.isEmpty == true || sunSets.isEmpty == true {
                    persist = false
                    title = "Find data for the the Sun"
                    message = "The Sun data is empty.\n\nPlease note that this alert will only show for a few seconds and then the App will automatically be shut down."
                    showAlert.toggle()
                    ///
                    /// Lukker denne meldingen etter 10 sekunder:
                    ///
//                    dismissAlert(seconds: 10)
                }
                ///
                /// Går bare videre dersom persist er true:
                ///
                if persist == true {
                    ///
                    /// Resetter weather og oppdaterer currentWearher:
                    ///
                    weather = nil
                    do {
                        self.weather = try await weatherService.weather(for: location)
                        if let weather {
                            ///
                            /// Oppdaterer currentWeather:
                            ///
                            currentWeather.date = weather.currentWeather.date
                            currentWeather.hour = Int(FormatDateToString(date: currentWeather.date, format: ("HH")))!
                            currentWeather.cloudCover = weather.currentWeather.cloudCover
                            currentWeather.condition = weather.currentWeather.condition.description
                            currentWeather.symbolName = weather.currentWeather.symbolName
                            currentWeather.dewPoint = weather.currentWeather.dewPoint.value
                            currentWeather.humidity = weather.currentWeather.humidity
                            currentWeather.pressure = weather.currentWeather.pressure.value
                            currentWeather.isDaylight = weather.currentWeather.isDaylight
                            currentWeather.temperature = weather.currentWeather.temperature.value
                            currentWeather.apparentTemperature = weather.currentWeather.apparentTemperature.value
                            currentWeather.uvIndex = weather.currentWeather.uvIndex.value
                            currentWeather.visibility = weather.currentWeather.visibility.value
                            currentWeather.windSpeed = weather.currentWeather.wind.speed.value
                            currentWeather.windGust = weather.currentWeather.wind.gust?.value ?? 0.00
                            currentWeather.windDirection = weather.currentWeather.wind.direction.value
                        }
                        ///
                        /// Gir feilmelding og avslutter hvis weather == nil:
                        ///
                        else {
                            persist = false
                            title = "Find the weather data"
                            message = "The weather is empty.\n\nPlease note that this alert will only show for a few seconds and then the App will automatically shut down."
                            showAlert.toggle()
                            ///
                            /// Lukker denne meldingen etter 10 sekunder:
                            ///
                            dismissAlert(seconds: 10)
                        }
                    } catch {
                        debugPrint(error)
                        title = "Error finding 'weather'"
                        message = ServerResponse(error: error.localizedDescription)
                    }
                }
                ///
                /// Skjuler ActivityIndicator:
                ///
                opacityIndicator = 0.0
            }
        }
    }
    
   func dismissAlert(seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            WeatherForecastApp().exitApp()
            showAlert = false
        }
    }
    
}

/// https://stackoverflow.com/questions/74711487/check-if-string-is-not-nil-or-not-empty-using-swift-5
