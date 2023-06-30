//
//  UvIndexHeading.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 06/11/2022.
//

import SwiftUI

struct UvIndexHeading: View {
    var body: some View {
        HStack {
            Image(systemName: "sun.max.fill")
                .foregroundColor(.primary)
                .font(Font.headline.weight(.regular))
            Text("UV-INDEX")
                .font(.system(size: 15, weight: .bold))
        }
        .opacity(0.50)
        .padding(.leading, -40)
    }
}

