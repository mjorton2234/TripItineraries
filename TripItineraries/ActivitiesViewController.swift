//
//  ActivitiesViewController.swift
//  TripItineraries
//
//  Created by MJ Orton on 4/23/24.
//

import UIKit

struct Activity {
    let name: String
    var locations: [Location]
    var isExpanded: Bool = false
}

struct Location {
    let name: String
    let pdfLink: String?
}

class ActivitiesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var activities: [Activity] = []

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
                    var pdfLocations: [String: String] = [:]
                    for continentData in continentsArray {
                        if let countriesArray = continentData["countries"] as? [[String: Any]] {
                            for countryData in countriesArray {
                                if let countryName = countryData["location"] as? String,
                                   let pdfLink = countryData["pdfLink"] as? String {
                                    pdfLocations[countryName.trimmingCharacters(in: .whitespacesAndNewlines)] = pdfLink
                                }
                                if let regionsArray = countryData["regions"] as? [[String: Any]] {
                                    for regionData in regionsArray {
                                        if let regionName = regionData["location"] as? String,
                                           let pdfLink = regionData["pdfLink"] as? String {
                                            pdfLocations[regionName.trimmingCharacters(in: .whitespacesAndNewlines)] = pdfLink
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if let activitiesPath = Bundle.main.path(forResource: "ActivitiesJSONData", ofType: "json") {
                        let activitiesData = try Data(contentsOf: URL(fileURLWithPath: activitiesPath))
                        let activitiesJSON = try JSONSerialization.jsonObject(with: activitiesData, options: []) as! [String: Any]
                        if let activitiesArray = activitiesJSON["activities"] as? [[String: Any]] {
                            for activityData in activitiesArray {
                                if let activityName = activityData["activity"] as? String,
                                   let locationNames = activityData["locations"] as? [String] {
                                    var locations: [Location] = []
                                    for locationName in locationNames {
                                        // Preserve whitespace
                                        let trimmedLocationName = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        let pdfLink = pdfLocations[trimmedLocationName]
                                        locations.append(Location(name: locationName, pdfLink: pdfLink)) // Use original locationName
                                    }
                                    activities.append(Activity(name: activityName, locations: locations))
                                }
                            }
                        }
                    }

                    // Reload the table view data after parsing
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }

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

    func updateTableViewArrow(_ cell: UITableViewCell, isExpanded: Bool) {
        if let imageView = cell.accessoryView as? UIImageView {
            UIView.animate(withDuration: 0.25) {
                imageView.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            }
        }
    }
}

extension ActivitiesViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return activities.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let activity = activities[section]
        return activity.isExpanded ? activity.locations.count + 1 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let activity = activities[indexPath.section]
        let textColor = UIColor(red: 15/255, green: 55/255, blue: 84/255, alpha: 1) // Custom color 0f3754
        let font = UIFont(name: "Trebuchet MS", size: 17) ?? UIFont.systemFont(ofSize: 17)
        let cellBackgroundColor = UIColor.white
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.white

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)
            cell.textLabel?.text = activity.name
            cell.textLabel?.textColor = textColor
            cell.textLabel?.font = font
            cell.backgroundColor = cellBackgroundColor
            cell.selectedBackgroundView = selectedBackgroundView
            cell.accessoryView = tableViewArrow(isExpanded: activity.isExpanded)
            return cell
        } else {
            let location = activity.locations[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
            cell.textLabel?.text = location.name
            cell.textLabel?.textColor = textColor
            cell.textLabel?.font = font
            cell.backgroundColor = cellBackgroundColor
            cell.selectedBackgroundView = selectedBackgroundView

            if let pdfLink = location.pdfLink {
                cell.detailTextLabel?.text = "PDF available"
                cell.detailTextLabel?.textColor = textColor
            } else {
                cell.detailTextLabel?.text = "No PDF available"
                cell.detailTextLabel?.textColor = .gray
            }

            cell.accessoryView = nil
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the cell immediately

        let activity = activities[indexPath.section]
        if indexPath.row == 0 {
            activities[indexPath.section].isExpanded.toggle()
            tableView.reloadSections([indexPath.section], with: .automatic)
        } else {
            let location = activity.locations[indexPath.row - 1]
            if let pdfLink = location.pdfLink,
               let pdfURL = URL(string: pdfLink) {
                performSegue(withIdentifier: "ShowPDF", sender: pdfURL)
            } else {
//                print("No PDF link available for location: \(location.name)")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPDF",
           let pdfViewController = segue.destination as? PDFViewController,
           let pdfURL = sender as? URL {
            pdfViewController.pdfURL = pdfURL
            pdfViewController.username = "mjorton22"
            pdfViewController.password = "mo3om21"
        }
    }
}
