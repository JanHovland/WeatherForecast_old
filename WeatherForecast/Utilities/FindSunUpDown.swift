//
//  FindSunUpDown.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 07/12/2022.
//

import Foundation

///
/// https://api.met.no/weatherapi/sunrise/2.0/.json?lat=58.6173&lon=5.6449&date=2022-12-06&offset=+01:00&days=10
///

func FindSunUpDown(url: String,
                   offset: String,
                   days: Int) async -> (String, [String], [String]) {
    
    var sunRise: [String] = Array(repeating: "", count: 10)
    var sunSet: [String] = Array(repeating: "", count: 10)
    var errors : String = ""
    var count : Int = 0
    var timeRise : String = ""
    var timeSet : String = ""
    var lat: String = ""
    var lon: String = ""

    let date = FormatDateToString(date: Date(), format: "yyyy-MM-dd")
    if latitude != nil {
        lat = "\(latitude!)"
    } else {
        lat = "\(58.618050)" /// Varhaug
    }
    if longitude != nil {
        lon = "\(longitude!)"
    } else {
        lon = "\(5.655520)"  /// Varhaug
    }
    let urlString = url + "lat=" + lat + "&lon=" + lon + "&date=" + date + "&offset=" + offset + "&days=" + String(days)
    let url = URL(string: urlString)
    ///
    ///
    /// https://api.met.no/weatherapi/sunrise/2.0/.json?lat=58.6173&lon=5.6449&date=2023-03-01&offset=+01:00&days=10
    /// https://api.met.no/weatherapi/sunrise/2.0/.json?lat=-27.4689682&lon=153.0234991&date=2023-03-01&offset=+10:00&days=10
    ///
    /// Viser kun for en dag: 
    /// https://api.met.no/weatherapi/sunrise/3.0/sun?lat=58.617383&lon=5.64511&date=2023-06-29&offset=+02:00
    ///
    if let url {
        do {
            let urlSession = URLSession.shared
            let (jsonData, _) = try await urlSession.data(from: url)
            let metApi = try JSONDecoder().decode(MetApi.self, from: jsonData)
            
            count = metApi.location!.time!.count
            
            sunRise = []
            sunSet = []
            /// Av en eller annen grunn kommer det en eksta dag med i Json returen:
            ///
            if count == 11 {
                count = count - 1
                for i in 0..<count {
                    let timeUp = (metApi.location!.time![i].sunrise?.time)!
                    let timeDown = (metApi.location!.time![i].sunset?.time)!
                    /// Resetter:
                    ///
                    timeRise = ""
                    timeSet = ""
                    /// Sender kun HH:mm ;
                    ///
                    for j in 11...15 {
                        timeRise = timeRise + timeUp[j]
                        timeSet = timeSet + timeDown[j]
                    }
                    /// Uppdaterer sunRise og sunSet:
                    ///
                    sunRise.append(timeRise)
                    sunSet.append(timeSet)

                }
            }
        } catch {
            errors = "\(error)"
        }
    }
    return (errors, sunRise, sunSet)
}
