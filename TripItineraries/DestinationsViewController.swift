//
//  DestinationsViewController.swift
//  TripItineraries
//
//  Created by MJ Orton on 4/23/24.
//


import UIKit

struct Continent {
    let name: String
    var countries: [Country]
    var isExpanded: Bool
}

struct Country {
    let name: String
    let regions: [Region]
    let pdfLink: String
    var isExpanded: Bool
}

struct Region {
    let name: String
    let pdfLink: String
}

class DestinationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var continents: [Continent] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        parseJSONData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }


    func parseJSONData() {
        if let path = Bundle.main.path(forResource: "PDFJSONData", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                if let continentsArray = json["continents"] as? [[String: Any]] {
                    for continentData in continentsArray {
                        if let continentName = continentData["location"] as? String,
                           let countriesArray = continentData["countries"] as? [[String: Any]] {
                            var countries: [Country] = []
                            for countryData in countriesArray {
                                if let countryName = countryData["location"] as? String {
                                    var regions: [Region] = []
                                    if let regionsArray = countryData["regions"] as? [[String: String]] {
                                        for regionData in regionsArray {
                                            if let regionName = regionData["location"],
                                               let pdfLink = regionData["pdfLink"] {
                                                regions.append(Region(name: regionName, pdfLink: pdfLink))
                                            }
                                        }
                                    }
                                    if let pdfLink = countryData["pdfLink"] as? String {
                                        countries.append(Country(name: countryName, regions: regions, pdfLink: pdfLink, isExpanded: false))
                                    } else {
                                        countries.append(Country(name: countryName, regions: regions, pdfLink: "", isExpanded: false))
                                    }
                                }
                            }
                            continents.append(Continent(name: continentName, countries: countries, isExpanded: false))
                        }
                    }
                }
                
                // Reload the table view data after parsing
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
//                print("Error loading or parsing JSON: \(error)")
            }
        }
    }

    func tableViewArrow(isExpanded: Bool) -> UIImageView {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 15/255, green: 55/255, blue: 84/255, alpha: 1) // Custom color 0f3754
        imageView.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        return imageView
    }

    func updateDisclosureIndicator(_ cell: UITableViewCell, isExpanded: Bool) {
        if let imageView = cell.accessoryView as? UIImageView {
            UIView.animate(withDuration: 0.25) {
                imageView.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            }
        }
    }
}

extension DestinationsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return continents.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let continent = continents[section]
        if continent.isExpanded {
            var count = continent.countries.count
            for country in continent.countries {
                if country.isExpanded {
                    count += country.regions.count
                }
            }
            return count + 1
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let continent = continents[indexPath.section]
        let textColor = UIColor(red: 15/255, green: 55/255, blue: 84/255, alpha: 1) // Custom color 0f3754
        let font = UIFont(name: "Trebuchet MS", size: 17) ?? UIFont.systemFont(ofSize: 17)
        let cellBackgroundColor = UIColor.white
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.white
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContinentCell", for: indexPath)
            cell.textLabel?.text = continent.name
            cell.textLabel?.textColor = textColor
            cell.textLabel?.font = font
            cell.backgroundColor = cellBackgroundColor
            cell.selectedBackgroundView = selectedBackgroundView
            cell.accessoryView = tableViewArrow(isExpanded: continent.isExpanded)
            return cell
        } else {
            var row = indexPath.row - 1
            for country in continent.countries {
                if row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
                    cell.textLabel?.text = country.name
                    cell.textLabel?.textColor = textColor
                    cell.textLabel?.font = font
                    cell.backgroundColor = cellBackgroundColor
                    cell.selectedBackgroundView = selectedBackgroundView
                    cell.accessoryView = country.regions.isEmpty ? nil : tableViewArrow(isExpanded: country.isExpanded)
                    return cell
                }
                row -= 1
                if country.isExpanded {
                    if row < country.regions.count {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "RegionCell", for: indexPath)
                        cell.textLabel?.text = country.regions[row].name
                        cell.textLabel?.textColor = textColor
                        cell.textLabel?.font = font
                        cell.backgroundColor = cellBackgroundColor
                        cell.selectedBackgroundView = selectedBackgroundView
                        cell.accessoryView = nil
                        return cell
                    }
                    row -= country.regions.count
                }
            }
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let continent = continents[indexPath.section]
        if indexPath.row == 0 {
            if continent.isExpanded {
                // Collapse the continent and reset all expanded countries
                continents[indexPath.section].isExpanded = false
                for i in 0..<continents[indexPath.section].countries.count {
                    continents[indexPath.section].countries[i].isExpanded = false
                }
            } else {
                // Expand the continent
                continents[indexPath.section].isExpanded = true
            }
            tableView.reloadSections([indexPath.section], with: .automatic)
        } else {
            var row = indexPath.row - 1
            for countryIndex in 0..<continent.countries.count {
                let country = continent.countries[countryIndex]
                if row == 0 {
                    if !country.regions.isEmpty {
                        continents[indexPath.section].countries[countryIndex].isExpanded.toggle()
                        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                    } else if let pdfLink = URL(string: country.pdfLink) {
                        performSegue(withIdentifier: "ShowPDF", sender: pdfLink)
                    }
                    return
                }
                row -= 1
                if country.isExpanded {
                    if row < country.regions.count {
                        let region = country.regions[row]
                        if let pdfLink = URL(string: region.pdfLink) {
                            performSegue(withIdentifier: "ShowPDF", sender: pdfLink)
                        }
                        return
                    }
                    row -= country.regions.count
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPDF",
           let pdfViewController = segue.destination as? PDFViewController,
           let pdfLink = sender as? URL {
            pdfViewController.pdfURL = pdfLink
            pdfViewController.username = "mjorton22"
            pdfViewController.password = "mo3om21"
        }
    }
}
