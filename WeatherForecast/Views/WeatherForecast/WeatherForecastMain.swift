//
//  WeatherForecast.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 28/09/2022.
//

import SwiftUI
import WeatherKit

/// Definerer globale variabler:
///

var windType: Int = 0
var gustType: Int = 1

var tempType: Int = 0
var appearentType: Int = 1

var uvIconType: Int = 0
var windIconType: Int = 1
var humidityIconType: Int = 2
var visibilityIconType: Int = 3
var airpressureIconType: Int = 4

///
/// Oppretter latitude,  longitude, plceName, offsetString og offsetSec  som globale varabler:
///
var latitude: Double?
var longitude: Double?
var placeName: String = ""
var countryName: String = ""
var offsetString: String = ""
var offsetSec: Int = 0
var dst: Int = 0                        /// Day Saving Time = Sommertid
var zoneName: String = ""               ///  "Europe/Oslo"
var zoneShortName: String = ""          ///  "CEST

///
/// Oppretter hourForcast
///
var hourForecast: Forecast<HourWeather>?

///
/// Lokale variabler for current Position:
///
var localLatitude: Double = 0.00
var localLongitude: Double = 0.00
var localPlaceName: String = ""
var localOffsetString: String = ""
var localOffsetSec: Int = 0

var localDate: Date = Date()
var localCondition: String = ""
var localTemperature: Double = 0.00
var localLowTemperature: Double = 0.00
var localHighTemperature: Double = 0.00
var localIsDaylight: Bool = false
var localFlag: String = ""
var localCountry: String = ""

///
/// Lokale variabler for valgt sted:
///
var placeLatitude: Double = 0.00
var placeLongitude: Double = 0.00
var placeOffsetString: String = ""
var placeOffsetSec: Int = 0

var placeDate: Date = Date()
var placeCondition: String = ""
var placeTemperature: Double = 0.00
var placeLowTemperature: Double = 0.00
var placeHighTemperature: Double = 0.00
var placeIsDaylight: Bool = false
var placeFlag: String = ""
var placeCountry: String = ""

private var sidebar: some View {
    ///
    /// Ipad:
    ///
    NavigationView {
        List {
            NavigationLink(destination: WeatherForecast(expShowDismissButton: false,
                                                        expOption: .intern,
                                                        extPlaceName: placeName,
                                                        extCountryName: countryName,
                                                        extLatitude: latitude ?? 0.00,
                                                        extLongitude: longitude ?? 0.00))
            {
                Label("Local weatherForecast", systemImage: "cloud.sun.rain.fill")
            }
            NavigationLink(destination: SettingView()) {
                Label("Setting", systemImage: "gear")
            }
            NavigationLink(destination: ToDoView()) {
                Label("To do", systemImage: "square.and.pencil.circle.fill")
            }
            NavigationLink(destination: WeatherForecastSelectPlace()) {
                Label("Select place", systemImage: "list.bullet")
            }
            NavigationLink(destination: InformationView()) {
                Label("Information", systemImage: "info.circle")
            }
        }
        WeatherForecast(expShowDismissButton: false,
                        expOption: .intern,
                        extPlaceName: placeName,
                        extCountryName: countryName,
                        extLatitude: latitude ?? 0.00,
                        extLongitude: longitude ?? 0.00)
    }
}

private var tabview: some View {
    ///
    /// iPhone;
    ///
    TabView {
        WeatherForecast(expShowDismissButton: false,
                        expOption: .intern,
                        extPlaceName: placeName,
                        extCountryName: countryName,
                        extLatitude: latitude ?? 0.00,
                        extLongitude: longitude ?? 0.00)
        .tabItem {
                Label("Local weatherForecast", systemImage: "cloud.sun.rain.fill")
            }
        SettingView()
            .tabItem {
                Label("Setting", systemImage: "gear")
            }
        ToDoView()
            .tabItem {
                Label("To do", systemImage: "square.and.pencil.circle.fill")
            }
        WeatherForecastSelectPlace()
            .tabItem {
                Label("Select place iPhone", systemImage: "list.bullet")
            }
        InformationView()
            .tabItem {
                Label("Information", systemImage: "info.circle")
            }

    }
}

struct WeatherForecastMain: View {
    ///
    /// Finner aktuell enhet:
    ///
    var body: some View {
        if UIDevice.isIpad {
            sidebar
                .task {
                    ///
                    /// Finn latitude og longitude ved oppstart:
                    ///
                    latitude = nil              // 58.61730433715967     Varhaug
                    longitude = nil             //  5.644919460720766    Varhaug
                }
        } else {
            tabview
                .task {
                    ///
                    /// Finn latitude og longitude ved oppstart:
                    ///
                    latitude = nil              // 58.61730433715967     Varhaug
                    longitude = nil             //  5.644919460720766    Varhaug
                }
        }
    }
    
}
