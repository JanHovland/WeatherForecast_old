//
//  SunRiseOrSet.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 22/02/2023.
//

// import Foundation
import SwiftUI

struct SunRiseOrSet: View {
    
    let option: EnumType
    let date: Date
    let sunTime: [String]
    
    var body: some View {
        
        let start = Date()
        let end = date
        
        let idx = daysBetween(start: start, end: end)
        
        let sTime = sunTime[idx]
        let index = sTime.index(sTime.startIndex, offsetBy: 2)
        let hourDate = FormatDateToString(date: date, format: "HH")
        let hourSun = String(sunTime[idx].prefix(upTo: index))
        
        if hourDate == hourSun {
            VStack {
                Text(FormatDateToString(date: date, format: "d MMM"))
                    .foregroundColor(.mint)
                    .font(.footnote)
                    .offset(y: UIDevice.isIpad ? -6.50 : -6.50)
                Text(sunTime[idx])
                    .font(.footnote)
                    .offset(y: UIDevice.isIpad ? -6.50 : -6.50)
                VStack {
                    if option == .sunrise {
                        Image(systemName: "sunrise")
                        Text("Sunrise")
                            .font(.footnote)
                            .offset(y: UIDevice.isIpad ? 10 : 10)
                    } else if option == .sunset {
                        Image(systemName: "sunset")
                        Text("Sunset")
                            .font(.footnote)
                            .offset(y: UIDevice.isIpad ? 10 : 10)
                    }
                }
                .offset(y: UIDevice.isIpad ? -6.5 : -6.5)
                Spacer()
            }
        }
    }
}



