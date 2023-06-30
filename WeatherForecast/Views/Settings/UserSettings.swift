//
//  File.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 28/09/2022.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    
    @Published var keyOpenCage: String {
        didSet {
            UserDefaults.standard.set(keyOpenCage, forKey: "KeyOpenCage")
        }
    }
    
    @Published var urlOpenCage: String {
        didSet {
            UserDefaults.standard.set(urlOpenCage, forKey: "UrlOpenCage")
        }
    }
    
    @Published var urlMetNo: String {
        didSet {
            UserDefaults.standard.set(urlMetNo, forKey: "UrlMetNo")
        }
    }
    
    @Published var showWeather: Bool {
        didSet {
            UserDefaults.standard.set(showWeather, forKey: "ShowWeather")
        }
    }
    
    init() {
        self.keyOpenCage = UserDefaults.standard.object(forKey: "KeyOpenCage") as? String ?? ""
        self.urlOpenCage = UserDefaults.standard.object(forKey: "UrlOpenCage") as? String ?? ""
        self.urlMetNo = UserDefaults.standard.object(forKey: "UrlMetNo") as? String ?? ""
        self.showWeather = UserDefaults.standard.object(forKey: "ShowWeather") as? Bool ?? false
    }
    
}
