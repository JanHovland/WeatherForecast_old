//
//  DayOverview.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 15/10/2022.
//

///
/// Har funnet en feil ved :
///     * @State private var index : Int  gir:
///     ** The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressins.
///
///     ** @State private var index : Int = 0 er OK
///

import SwiftUI
import WeatherKit

///
/// https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-environmentobject-to-share-data-between-views
///

struct DayOverview: View {
    let weather : Weather
    @Binding var sunRises : [String]
    @Binding var sunSets : [String]
   
    @StateObject var dateSettings = DateSettings()
    
    @State private var currentDate = Date()
    @State private var dateComponent = DateComponents()
    @State private var futureDate = Date()
    @State private var offsetDay = 2
    @State private var offsetHour = -1
    
    @State private var widthDevice = 0
    
    @State private var spacing : CGFloat = 0
    @State private var frameWidth : CGFloat = 0
    @State private var frameHeight : CGFloat = 0
    @State private var paddingTop : CGFloat = 0
    @State private var paddingLeading : CGFloat = 0
    
    @State private var detailView : Bool = false
    @State private var dayDetailHide: Bool = true

    @State private var dateString = ""
    @State private var symbolString = ""
    @State private var dateSelected = ""

    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading) {
                if UIDevice.isIpad {
                    Text("DAILY FORECAST")
                        .font(.body)
                } else {
                    Text("DAILY FORECAST")
                        .font(.footnote)
                }
            }
            .opacity(0.50)
            .padding(.leading,6)
            .padding(.top,10)
            .padding(.bottom, -5)
            
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(weather.dailyForecast, id: \.date) { dayItem in
                        VStack (spacing: spacing) {
                            Text(FormatDateToString(date: dayItem.date, format: "E d MMM"))
                                .foregroundColor(.cyan)
                            ///
                            /// Viser symbolName:
                            ///
                            Image(systemName: "\(dayItem.symbolName)")
                                .environment(\.symbolVariants, .fill)
                                .symbolRenderingMode(.multicolor)
                                .foregroundStyle(.primary)
                                .font(.title3)
                                .padding(.top, -10)
                            ///
                            /// Viser temperaturen akkurat nå for den første datoen og de neste dagene:
                            ///
                            Text("\(Int(dayItem.highTemperature.value.rounded()))º")
                                .font(.caption)
                                .padding(.top, -5)
                        }
                        .padding(7)
                        .sheet(isPresented: $detailView, content: {
                            DayDetail(weather: weather,
                                      dateSelected: $dateSelected,
                                      dayDetailHide: $dayDetailHide,
                                      sunRises: $sunRises,
                                      sunSets: $sunSets)
                            .frame(width: frameWidth, height: frameHeight)
                            .padding(.top, paddingTop)
                            .padding(.leading, paddingLeading)
                            .clearModalBackground()
                        })
                        .onTapGesture {
                            /// Task.init starter hver gang ved hvert .onTapGesture:
                            ///
                            Task.init {
                                dateString = dayItem.date.formatted()
                                symbolString = dayItem.symbolName
                                ///
                                /// Må finne aktuelt valg:
                                ///
                                dateSelected = FormatDateToString(date: dayItem.date, format: "d")
                                detailView.toggle()
                            }
                        }
                    }
                    .listStyle(.sidebar)
                }
            }
        }
        .task {
            ///
            /// Oppdaterer bredden avhengig av on iPhone eller iPad:
            ///
            if UIDevice.isIpad {
                widthDevice = 790
                frameWidth = 640
                frameHeight = 550
                paddingTop = 60
                paddingLeading = 210
                spacing = 10
            } else {
                widthDevice = 390
                frameWidth = 390
                frameHeight = 730
                paddingTop = 0
                paddingLeading = 0
                spacing = 10
            }
        }
        .frame(width: CGFloat(widthDevice))
        .modifier(DayDetailBackground(dayLight: weather.currentWeather.isDaylight))
    }
}

