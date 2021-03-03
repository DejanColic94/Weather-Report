// Dejan Colic
// 2013/0260
// Fon Jun 2019. Beograd

import UIKit
import CoreLocation

// klasa nasledjuje UISearchBarDelegate protokol da bi mogli da radimo sa search bar-om
class WeatherTableViewController: UITableViewController, UISearchBarDelegate {
    
    // outlet za search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // ovde stavljamo rezultate iz completion handlera
    var forecastData = [Weather]()
    
    // dodeljujemo delegat i postavljamo pocetnu vrednost na Beograd
    // to znaci da ce pri pokretanju aplikacije biti pokazana prognoza za grad Beograd
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        updateWeatherForLocation(location: "Beograd")
    }
    
    // resignFirstResponder sakriva tastaturu
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty {
            updateWeatherForLocation(location: locationString)
        }
        
    }
    
    // radimo sa core location klasom
    // importujemo CoreLocation
    // sad mozemo da zovemo geokoder
    func updateWeatherForLocation (location:String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                        
                        if let weatherData = results {
                            self.forecastData = weatherData
                            
                            // update user interface
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        }
                        
                    })
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // postavlja onoliko sekcija koliko imamo objekata u nizu forcastData
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return forecastData.count
    }
    // Svaka sekcija ima samo jedan red
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    // Popunjavamo sekciju datumom, od .day do date
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Calendar.current.date(byAdding: .day, value: section, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        
        return dateFormatter.string(from: date!)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // radiomo sa section ne sa row
        let weatherObject = forecastData[indexPath.section]
        
        cell.textLabel?.text = weatherObject.summary
        cell.detailTextLabel?.text = "\(Int(weatherObject.temperature)) °C"
        cell.imageView?.image = UIImage(named: weatherObject.icon)
        
        return cell
    }
    
    
    
}
