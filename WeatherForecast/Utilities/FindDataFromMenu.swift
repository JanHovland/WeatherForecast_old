//
//  FindDataFromMenu.swift
//  WeatherForecast
//
//  Created by Jan Hovland on 04/11/2022.
//

import SwiftUI
import WeatherKit


func FindDataFromMenu(info: String,
                      weather: Weather,
                      date: Date,
                      option: EnumType,
                      option1: EnumType) -> ([Double],
                                             [String],
                                             [String],
                                             [RainFall],
                                             [WindInfo],
                                             [Temperature],
                                             [Double],
                                             [WeatherIcon],
                                             [Double],
                                             [FeltTemp],
                                             [Double])  {
    
    var array : [Double] = Array(repeating: Double(), count: 24)
    var arrayDayIcons : [String] = Array(repeating: String(), count: 10)
    var arrayHourIcons : [String] = Array(repeating: String(), count: 24)
    var hourIconArray : [String] = Array(repeating: String(), count: 24)
    var windInfoArray : [WindInfo] = Array(repeating: WindInfo(), count: 24)
    var tempInfoArray : [Temperature] = Array(repeating: Temperature(), count: 24)
    var gustInfoArray : [Double] = Array(repeating: Double(), count: 24)
    var weatherIconArray: [WeatherIcon] = Array(repeating: WeatherIcon(), count: 24)
    var snowArray: [Double] = Array(repeating: Double(), count: 24)
    var feltTempArray: [FeltTemp] = Array(repeating: FeltTemp(), count: 24)
    var dewPointArray: [Double] = Array(repeating: Double(), count: 24)
    var hailData : [Data] = []
    var mixedData : [Data] = []
    var rainData : [Data] = []
    var sleetData : [Data] = []
    var snowData : [Data] = []
    var windSpeedData : [DataWind] = []
    var windGustData : [DataWind] = []

    var tempData: [TempData] = []
    var appearentData: [TempData] = []
    
    var feltTempData: [FeltTempData] = []
    var appearentTempData: [FeltTempData] = []

    var iconData: [IconData] = []
    var windData: [IconData] = []
    var humidityData: [IconData] = []
    var visibilityData: [IconData] = []
    var airpressureData: [IconData] = []

    var rainFall  = RainFall()
    var rainFalls : [RainFall] = []
    var weatherIcon = WeatherIcon()
    
    var tempInfo = Temperature()
    var gustInfo : Double = 0.00
    
    var windInfo = WindInfo()
    
    var feltTemp = FeltTemp()

    rainFalls.removeAll()
    let value : (Date,Date) = DateRange(date: date)
    
    array.removeAll()
    arrayDayIcons.removeAll()
    arrayHourIcons.removeAll()
    hourIconArray.removeAll()
    
    hailData.removeAll()
    mixedData.removeAll()
    rainData.removeAll()
    sleetData.removeAll()
    snowData.removeAll()
    windSpeedData.removeAll()
    windGustData.removeAll()
    
    iconData.removeAll()
    windData.removeAll()
    humidityData.removeAll()
    visibilityData.removeAll()
    airpressureData.removeAll()

    rainFalls.removeAll()
    tempInfoArray.removeAll()
    windInfoArray.removeAll()
    gustInfoArray.removeAll()
    weatherIconArray.removeAll()
    snowArray.removeAll()
    feltTempArray.removeAll()
    dewPointArray.removeAll()
    
    switch option {
        
    case .temperature :
        var i: Int = 0
        var data = TempData()
        hourForecast!.forEach  {
            if $0.date >= value.0 &&
                $0.date < value.1 {
                array.append($0.temperature.value)
                arrayHourIcons.append($0.symbolName)
                ///
                /// Oppdaterer vanlig temperatur:
                ///
                data = TempData()
                data.index = i
                data.temp = $0.temperature.value
                data.gust = $0.wind.gust!.value * 1000 / 3600
                data.wind = $0.wind.speed.value * 1000 / 3600
                data.condition = WeatherTranslateType(type: $0.condition.description)
                tempData.append(data)
                ///
                /// Oppdaterer følt  temperatur:
                ///
                data = TempData()
                data.index = i
                data.temp = $0.apparentTemperature.value
                data.gust = $0.wind.gust!.value * 1000 / 3600
                data.wind = $0.wind.speed.value * 1000 / 3600
                data.condition = WeatherTranslateType(type: $0.condition.description)
                appearentData.append(data)
                i = i + 1
            }
        }
        ///
        /// Oppdaterer tempInfoArray:
        ///
        tempInfo.type = String(localized: "Temperature")
        tempInfo.data = tempData
        tempInfoArray.append(tempInfo)
        
        tempInfo.type = String(localized: "Appearent temperature")
        tempInfo.data = appearentData
        tempInfoArray.append(tempInfo)
        
        weather.dailyForecast.forEach  {
            arrayDayIcons.append($0.symbolName)
        }
        arrayHourIcons = reduceArrayAmount(fromArray:arrayHourIcons, option: option1)
        
        return (array, arrayDayIcons, arrayHourIcons, rainFalls, windInfoArray, tempInfoArray, gustInfoArray, weatherIconArray, snowArray, feltTempArray, dewPointArray)
        
    case .uvIndex :
        var i: Int = 0
        var data = IconData()
        hourForecast!.forEach  {
            if $0.date >= value.0 &&
                $0.date < value.1 {
                array.append(Double($0.uvIndex.value))
                arrayHourIcons.append($0.symbolName)
                ///
                /// Oppdaterer iconData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\($0.uvIndex.value)")
                if option1 == .number24 {
                    iconData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        iconData.append(data)
                    }
                }
                ///
                /// Oppdaterer windData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\($0.wind.direction.value)")
                if option1 == .number24 {
                    windData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        windData.append(data)
                    }
                }
                ///
                /// Oppdaterer humidityData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\(Int($0.humidity * 100))")
                if option1 == .number24 {
                    humidityData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        humidityData.append(data)
                    }
                }
                ///
                ///  Oppdaterer visibilityData:
                ///
                data = IconData()
                data.index = i
                data.icon = "\(Int($0.visibility.value / 1000.0.rounded()))"
                if option1 == .number24 {
                    visibilityData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        visibilityData.append(data)
                    }
                }
                ///
                /// Oppdaterer airpressureData:
                ///
                data = IconData()
                data.index = i
                let trend = $0.pressureTrend.description
                if trend == "Fallende" {
                    data.icon = "arrow.down.to.line.compact"
                } else if trend == "Uendret" {
                    data.icon = "equal"
                } else {
                    data.icon = "arrow.up.to.line.compact"
                }
                if option1 == .number24 {
                    airpressureData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        airpressureData.append(data)
                    }
                }

                i = i + 1
            }
        }
        ///
        /// Oppdaterer weatherIconArray
        ///
        weatherIcon.type = uvIconType
        weatherIcon.data = iconData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = windIconType
        weatherIcon.data = windData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = humidityIconType
        weatherIcon.data = humidityData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = visibilityIconType
        weatherIcon.data = visibilityData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = airpressureIconType
        weatherIcon.data = airpressureData
        weatherIconArray.append(weatherIcon)
        
        weather.dailyForecast.forEach  {
            arrayDayIcons.append($0.symbolName)
        }
        arrayHourIcons = reduceArrayAmount(fromArray:arrayHourIcons, option: option1)
        return (array, arrayDayIcons, arrayHourIcons, rainFalls, windInfoArray, tempInfoArray, gustInfoArray, weatherIconArray, snowArray, feltTempArray, dewPointArray)
        
    case .wind :
        var i: Int = 0
        var data = DataWind()
        var data1 = IconData()
        hourForecast!.forEach  {
            if $0.date >= value.0 &&
                $0.date < value.1 {
                ///
                /// Oppdaterer vindhastigheten:
                ///
                array.append($0.wind.speed.value  * 1000 / 3600)
                data = DataWind()
                ///
                /// Oppdaterer windInfoArray:
                ///
                data.index = i
                data.amount = $0.wind.speed.value * 1000 / 3600
                data.direction = $0.wind.direction.value
                windSpeedData.append(data)
                
                data = DataWind()
                data.index = i
                data.amount = $0.wind.gust!.value * 1000 / 3600
                data.direction = 0.00
                windGustData.append(data)
                ///
                /// Oppdaterer gustInfoArray:
                ///
                if ($0.wind.gust == nil) {
                    gustInfo = 0.00
                } else {
                    gustInfo = $0.wind.gust!.value * 1000 / 3600
                }
                gustInfoArray.append(gustInfo)
                arrayHourIcons.append($0.symbolName)
                
                ///
                /// Oppdaterer iconData:
                ///
                data1 = IconData()
                data1.index = i
                data1.icon = String("\($0.uvIndex.value)")
                if option1 == .number24 {
                    iconData.append(data1)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        iconData.append(data1)
                    }
                }
                ///
                /// Oppdaterer windData:
                ///
                data1 = IconData()
                data1.index = i
                data1.icon = String("\($0.wind.direction.value)")
                if option1 == .number24 {
                    windData.append(data1)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        windData.append(data1)
                    }
                }
                ///
                /// Oppdaterer humidityData:
                ///
                data1 = IconData()
                data1.index = i
                data1.icon = String("\(Int($0.humidity * 100))")
                if option1 == .number24 {
                    humidityData.append(data1)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        humidityData.append(data1)
                    }
                }
                ///
                ///  Oppdaterer visibilityData:
                ///
                data1 = IconData()
                data1.index = i
                data1.icon = "\(Int($0.visibility.value / 1000.0.rounded()))"
                if option1 == .number24 {
                    visibilityData.append(data1)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        visibilityData.append(data1)
                    }
                }
                ///
                /// Oppdaterer airpressureData:
                ///
                data1 = IconData()
                data1.index = i
                let trend = $0.pressureTrend.description
                if trend == "Fallende" {
                    data1.icon = "arrow.down.to.line.compact"
                } else if trend == "Uendret" {
                    data1.icon = "equal"
                } else {
                    data1.icon = "arrow.up.to.line.compact"
                }
                if option1 == .number24 {
                    airpressureData.append(data1)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        airpressureData.append(data1)
                    }
                }

                i = i + 1
            }
        }
        ///
        /// Oppdaterer windInfoArray:
        ///
        windInfo.type = String(localized: "WindSpeed")
        windInfo.data = windSpeedData
        windInfoArray.append(windInfo)
        windInfo.type = String(localized: "GustSpeed")
        windInfo.data = windGustData
        windInfoArray.append(windInfo)
        
        ///
        /// Oppdaterer weatherIconArray
        ///
        weatherIcon.type = uvIconType
        weatherIcon.data = iconData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = windIconType
        weatherIcon.data = windData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = humidityIconType
        weatherIcon.data = humidityData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = visibilityIconType
        weatherIcon.data = visibilityData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = airpressureIconType
        weatherIcon.data = airpressureData
        weatherIconArray.append(weatherIcon)
        
        ///
        /// Oppdaterer arrayDayIcons:
        ///
        weather.dailyForecast.forEach  {
            arrayDayIcons.append($0.symbolName)
        }
        arrayHourIcons = reduceArrayAmount(fromArray:arrayHourIcons, option: option1)
        
        return (array, arrayDayIcons, arrayHourIcons, rainFalls, windInfoArray, tempInfoArray, gustInfoArray, weatherIconArray, snowArray, feltTempArray, dewPointArray)
        
    case .precipitation :
        var i: Int = 0
        var data = Data()
        hourForecast!.forEach  {
            if $0.date >= value.0 &&
                $0.date < value.1 {
                array.append($0.precipitationAmount.value)
                ///  if precificationValue > 0.00 sette denne inn i f.eks regnArray  og 0.00 i de andre arrayene :
                ///
                data.index = i
                if $0.precipitation == .snow {
                    ///
                    /// 1 millimeter nedbør = 1 centimeter snø .
                    ///
                    data.amount = $0.precipitationAmount.value == 0.00 ? 0.00 : $0.precipitationAmount.value // * 10.0
                    snowArray.append(data.amount)
                } else {
                   data.amount = $0.precipitationAmount.value == 0.00 ? 0.00 : $0.precipitationAmount.value
                    snowArray.append(0.00)
                }
                if data.amount == 0.00 {
                    hailData.append(data)
                    mixedData.append(data)
                    rainData.append(data)
                    sleetData.append(data)
                    snowData.append(data)
                } else {
                    if $0.precipitation == .hail {
                        hailData.append(data)
                        data.index = i
                        data.amount = 0.00
                        mixedData.append(data)
                        rainData.append(data)
                        sleetData.append(data)
                        snowData.append(data)
                    } else if $0.precipitation == .mixed {
                        mixedData.append(data)
                        data.index = i
                        data.amount = 0.00
                        hailData.append(data)
                        rainData.append(data)
                        sleetData.append(data)
                        snowData.append(data)
                    } else if $0.precipitation == .rain {
                        rainData.append(data)
                        data.index = i
                        data.amount = 0.00
                        hailData.append(data)
                        mixedData.append(data)
                        sleetData.append(data)
                        snowData.append(data)
                    } else if $0.precipitation == .sleet {
                        sleetData.append(data)
                        data.index = i
                        data.amount = 0.00
                        hailData.append(data)
                        mixedData.append(data)
                        rainData.append(data)
                        snowData.append(data)
                    } else if $0.precipitation == .snow {
                        snowData.append(data)
                        data.index = i
                        data.amount = 0.00
                        hailData.append(data)
                        mixedData.append(data)
                        rainData.append(data)
                        sleetData.append(data)
                    }
                }
                i = i + 1
            }
        }
        weather.dailyForecast.forEach  {
            arrayDayIcons.append($0.symbolName)
        }
        
        /// Oppdaterer serialsData:
        ///
        rainFall.type = String(localized: ".Rain")
        rainFall.data = rainData
        rainFalls.append(rainFall)

        rainFall.type = String(localized: "Sleet")
        rainFall.data = sleetData
        rainFalls.append(rainFall)

        rainFall.type = String(localized: "Mixed")
        rainFall.data = mixedData
        rainFalls.append(rainFall)
        
        rainFall.type = String(localized: "Snow")
        rainFall.data = snowData
        rainFalls.append(rainFall)

        rainFall.type = String(localized: "Hail")
        rainFall.data = hailData
        rainFalls.append(rainFall)
        
        arrayHourIcons = reduceArrayAmount(fromArray:arrayHourIcons, option: option1)
        return (array, arrayDayIcons, arrayHourIcons, rainFalls, windInfoArray, tempInfoArray, gustInfoArray, weatherIconArray, snowArray, feltTempArray, dewPointArray)
        
    case .feelsLike :
        var i: Int = 0
        var data = FeltTempData()
        hourForecast!.forEach  {
            if $0.date >= value.0 &&
                $0.date < value.1 {
                array.append($0.apparentTemperature.value)
                arrayHourIcons.append($0.symbolName)
                ///
                /// Oppdaterer vanlig temperatur:
                ///
                data = FeltTempData()
                data.index = i
                data.temp = $0.temperature.value
                data.gust = $0.wind.gust!.value * 1000 / 3600
                data.wind = $0.wind.speed.value * 1000 / 3600
                data.condition = WeatherTranslateType(type: $0.condition.description)
                feltTempData.append(data)
                ///
                /// Oppdaterer følt  temperatur:
                ///
                data = FeltTempData()
                data.index = i
                data.temp = $0.apparentTemperature.value
                data.gust = $0.wind.gust!.value * 1000 / 3600
                data.wind = $0.wind.speed.value * 1000 / 3600
                data.condition = WeatherTranslateType(type: $0.condition.description)
                appearentTempData.append(data)
                i = i + 1
            }
        }
        ///
        /// Oppdaterer feltTempArray:
        ///
        feltTemp.type = String(localized: "Appearent temperature")
        feltTemp.data = appearentTempData
        feltTempArray.append(feltTemp)
        
        feltTemp.type = String(localized: "Temperature")
        feltTemp.data = feltTempData
        feltTempArray.append(feltTemp)
        
        weather.dailyForecast.forEach  {
            arrayDayIcons.append($0.symbolName)
        }
        arrayHourIcons = reduceArrayAmount(fromArray:arrayHourIcons, option: option1)
        return (array, arrayDayIcons, arrayHourIcons, rainFalls, windInfoArray, tempInfoArray, gustInfoArray, weatherIconArray, snowArray, feltTempArray, dewPointArray)
        
    case .humidity :
        var i: Int = 0
        var data = IconData()
        hourForecast!.forEach  {
            if $0.date >= value.0 &&
                $0.date < value.1 {
                array.append($0.humidity * 100)
                ///
                /// Opdaterer dewPoint:
                /// 
                dewPointArray.append($0.dewPoint.value)
                arrayHourIcons.append($0.symbolName)
                ///
                /// Oppdaterer iconData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\($0.uvIndex.value)")
                if option1 == .number24 {
                    iconData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        iconData.append(data)
                    }
                }
                ///
                /// Oppdaterer windData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\($0.wind.direction.value)")
                if option1 == .number24 {
                    windData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        windData.append(data)
                    }
                }
                ///
                /// Oppdaterer humidityData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\(Int($0.humidity * 100))")
                if option1 == .number24 {
                    humidityData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        humidityData.append(data)
                    }
                }
                ///
                ///  Oppdaterer visibilityData:
                ///
                data = IconData()
                data.index = i
                data.icon = "\(Int($0.visibility.value / 1000.0.rounded()))"
                if option1 == .number24 {
                    visibilityData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        visibilityData.append(data)
                    }
                }
                ///
                /// Oppdaterer airpressureData:
                ///
                data = IconData()
                data.index = i
                let trend = $0.pressureTrend.description
                if trend == "Fallende" {
                    data.icon = "arrow.down.to.line.compact"
                } else if trend == "Uendret" {
                    data.icon = "equal"
                } else {
                    data.icon = "arrow.up.to.line.compact"
                }
                if option1 == .number24 {
                    airpressureData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        airpressureData.append(data)
                    }
                }

                i = i + 1
                
            }
        }
        
        ///
        /// Oppdaterer weatherIconArray
        ///
        weatherIcon.type = uvIconType
        weatherIcon.data = iconData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = windIconType
        weatherIcon.data = windData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = humidityIconType
        weatherIcon.data = humidityData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = visibilityIconType
        weatherIcon.data = visibilityData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = airpressureIconType
        weatherIcon.data = airpressureData
        weatherIconArray.append(weatherIcon)

        weather.dailyForecast.forEach  {
            arrayDayIcons.append($0.symbolName)
        }
        arrayHourIcons = reduceArrayAmount(fromArray:arrayHourIcons, option: option1)
        return (array, arrayDayIcons, arrayHourIcons, rainFalls, windInfoArray, tempInfoArray, gustInfoArray, weatherIconArray, snowArray, feltTempArray, dewPointArray)
        
    case .visability :
        var i: Int = 0
        var data = IconData()
        hourForecast!.forEach  {
            if $0.date >= value.0 &&
                $0.date < value.1 {
                array.append($0.visibility.value / 1000.0)
                arrayHourIcons.append($0.symbolName)
                ///
                /// Oppdaterer iconData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\($0.uvIndex.value)")
                if option1 == .number24 {
                    iconData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        iconData.append(data)
                    }
                }
                ///
                /// Oppdaterer windData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\($0.wind.direction.value)")
                if option1 == .number24 {
                    windData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        windData.append(data)
                    }
                }
                ///
                /// Oppdaterer humidityData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\(Int($0.humidity * 100))")
                if option1 == .number24 {
                    humidityData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        humidityData.append(data)
                    }
                }
                ///
                ///  Oppdaterer visibilityData:
                ///
                data = IconData()
                data.index = i
                data.icon = "\(Int($0.visibility.value / 1000.0.rounded()))"
                if option1 == .number24 {
                    visibilityData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        visibilityData.append(data)
                    }
                }
                ///
                /// Oppdaterer airpressureData:
                ///
                data = IconData()
                data.index = i
                let trend = $0.pressureTrend.description
                if trend == "Fallende" {
                    data.icon = "arrow.down.to.line.compact"
                } else if trend == "Uendret" {
                    data.icon = "equal"
                } else {
                    data.icon = "arrow.up.to.line.compact"
                }
                if option1 == .number24 {
                    airpressureData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        airpressureData.append(data)
                    }
                }

                i = i + 1
                
            }
        }
        weather.dailyForecast.forEach  {
            arrayDayIcons.append($0.symbolName)
        }
        
        ///
        /// Oppdaterer weatherIconArray
        ///
        weatherIcon.type = uvIconType
        weatherIcon.data = iconData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = windIconType
        weatherIcon.data = windData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = humidityIconType
        weatherIcon.data = humidityData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = visibilityIconType
        weatherIcon.data = visibilityData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = airpressureIconType
        weatherIcon.data = airpressureData
        weatherIconArray.append(weatherIcon)
        
        arrayHourIcons = reduceArrayAmount(fromArray:arrayHourIcons, option: option1)
        return (array, arrayDayIcons, arrayHourIcons, rainFalls, windInfoArray, tempInfoArray, gustInfoArray, weatherIconArray, snowArray, feltTempArray, dewPointArray)
        
    case .airPressure :
        var i: Int = 0
        var data = IconData()
        hourForecast!.forEach  {
            if $0.date >= value.0 &&
                $0.date < value.1 {
                array.append($0.pressure.value)
                arrayHourIcons.append($0.symbolName)
 
                ///
                /// Oppdaterer iconData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\($0.uvIndex.value)")
                if option1 == .number24 {
                    iconData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        iconData.append(data)
                    }
                }
                ///
                /// Oppdaterer windData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\($0.wind.direction.value)")
                if option1 == .number24 {
                    windData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        windData.append(data)
                    }
                }
                ///
                /// Oppdaterer humidityData:
                ///
                data = IconData()
                data.index = i
                data.icon = String("\(Int($0.humidity * 100))")
                if option1 == .number24 {
                    humidityData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        humidityData.append(data)
                    }
                }
                ///
                ///  Oppdaterer visibilityData:
                ///
                data = IconData()
                data.index = i
                data.icon = "\(Int($0.visibility.value / 1000.0.rounded()))"
                if option1 == .number24 {
                    visibilityData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        visibilityData.append(data)
                    }
                }
                ///
                /// Oppdaterer airpressureData:
                ///
                data = IconData()
                data.index = i
                let trend = $0.pressureTrend.description
                if trend == "Fallende" {
                    data.icon = "arrow.down.to.line.compact"
                } else if trend == "Uendret" {
                    data.icon = "equal"
                } else {
                    data.icon = "arrow.up.to.line.compact"
                }
                if option1 == .number24 {
                    airpressureData.append(data)
                } else if option1 == .number12 {
                    if i % 2 == 0 {
                        airpressureData.append(data)
                    }
                }

                i = i + 1
                
            }
        }
        weather.dailyForecast.forEach  {
            arrayDayIcons.append($0.symbolName)
        }
        
        ///
        /// Oppdaterer weatherIconArray
        ///
        weatherIcon.type = uvIconType
        weatherIcon.data = iconData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = windIconType
        weatherIcon.data = windData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = humidityIconType
        weatherIcon.data = humidityData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = visibilityIconType
        weatherIcon.data = visibilityData
        weatherIconArray.append(weatherIcon)

        weatherIcon.type = airpressureIconType
        weatherIcon.data = airpressureData
        weatherIconArray.append(weatherIcon)
        
        arrayHourIcons = reduceArrayAmount(fromArray:arrayHourIcons, option: option1)
        return (array, arrayDayIcons, arrayHourIcons, rainFalls, windInfoArray, tempInfoArray, gustInfoArray, weatherIconArray, snowArray, feltTempArray, dewPointArray)
        
    default :
        return ([Double()], [String()], [String()], [RainFall](), [WindInfo](), [Temperature](), [Double](), [WeatherIcon](), [Double()], [FeltTemp](), [Double()])
    }
    
}

func reduceArrayAmount (fromArray: [String], option: EnumType) -> [String] {

    var i : Int = 0
    var toArray: [String] = []
    toArray.removeAll()
    if option == .number24 {
        toArray = fromArray
    } else {
        for icon in fromArray {
            if (i % 2 == 0) {
                toArray.append(icon)
            }
            i = i + 1
        }
    }
    return toArray
}
