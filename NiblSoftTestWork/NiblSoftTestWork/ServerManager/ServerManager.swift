

import UIKit
import Alamofire
import SwiftyJSON

class ServerManager: NSObject {
    
    static let shared = ServerManager()
    let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    typealias Completion = (Bool, JSON, String) -> ()
    

    //MARK: - Get
    
    func getWheather(by cityName: String, completion: @escaping Completion) {
        
//        let params:Parameters = ["q":cityName]
//        let headers: HTTPHeaders = ["APPID":"481049b4986036725a19b593fc763de9"]
        
        Alamofire.request(baseUrl + "?q=\(cityName)&APPID=481049b4986036725a19b593fc763de9", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).response {
            response in
            
           self.responseHandler(response: response, completion: completion)
        }
    }
    
    func getWeatherByLocation(lat:Double,lon:Double, completion: @escaping Completion){
        Alamofire.request(baseUrl + "?lat=\(lat)&lon=\(lon)&APPID=481049b4986036725a19b593fc763de9", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).response{
            response in
            
            self.responseHandler(response: response, completion: completion)
            print(lat)
            print(lon)
        }
        
    }
    
    
    //MARK: - ResponseHandler

    func responseHandler(response: DefaultDataResponse, completion: @escaping Completion){
        let status = response.response?.statusCode
        let data = response.data
        if let status = status {
            if status == 200 || status == 201{
                if let data = data {
                    let json =  JSON(data: data)
                    completion(true, json, "")
                } else {
                    completion(true, [], "")
                }
            } else if status >= 500 {
                completion(false, "", "Сервер не работает")
            } else{
                
                if let data = data {
                    let json =  JSON(data: data)
                    print(json)
                    if let message = json["detail"].string{
                        completion(false, json, message)
                    } else {
                        completion(false, json, "Unknown error")
                    }
                }
                completion(false, [], "Unknown error")
            }
        }
    }
}

