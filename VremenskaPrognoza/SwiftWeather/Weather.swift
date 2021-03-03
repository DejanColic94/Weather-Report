// Dejan Colic
// 2013/0260
// Fon Jun 2019. Beograd

import Foundation
import CoreLocation

// Model podataka koji se sastoji iz 3 polja
// Kasnije cemo JSON response da konvertujemo u objekat tipa Weather

struct Weather {
    let summary:String
    let icon:String
    let temperature:Double
    
    // Slucajevi greske kod serijalizacije
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    // Serijalizacija - konvertovanje JSON objekta u dictionary
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("nema podataka o vremenu")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("nema ikonice")}
        
        guard let temperature = json["temperatureMax"] as? Double else {throw SerializationError.missing("nema podataka o temperaturi")}
        
        // Inicijalizacija polja
        
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
        
    }
    
    // Definisemo  URL koji gadjamo koji se sastoji od basePath i koordinata
    // U basePath ide url u formi koja je definisana na sajtu koji gadjamo i tajni kljuc
    
    static let basePath = "https://api.darksky.net/forecast/24d252c956ff26b5604431952c7d1f83/"
    
    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()) {
        
        // basePath + koordinate + HTTP Query parametri
        
        let url = basePath + "\(location.latitude),\(location.longitude)?lang=sr&units=si"
        let request = URLRequest(url: URL(string: url)!)
        
        
        // Completion handler u kome radimo sa rezultatima requst-a
        // escaping, asihrono
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                
                // 1. radimo serijalizaciju, pretvaramo JSON u dictionary
                // 2. Pristupamo "daily" kljucu u JSON response-u
                // 3. Pristupamo nizu "data"
                // 4. Iteriramo kroz niz dictonary-ja i kreiramo objekat tipa Weather
                // 5. Ubacujemo vrednost na kraj niza (append)
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                        
                    }
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(forecastArray)
                
            }
            
            
        }
        
        // Metoda za startovanje task-a
        
        task.resume()
        
        
        
        
        
        
        
        
        
    }
    
    
}
