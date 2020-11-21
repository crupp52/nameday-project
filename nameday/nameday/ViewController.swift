//
//  ViewController.swift
//  weather-app
//
//  Created by Zuck Levente on 2020. 11. 20..
//  Copyright © 2020. Zuck Levente. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    var models = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestWeatherForLocation()
    }
    
    func requestWeatherForLocation() {
        let date = Date()
        let todayString = "\(date.getMonth())-\(date.getDay())"
        let tomorrowString = "\(Date.tomorrow.getMonth())-\(Date.tomorrow.getDay())"
        
        print(getNames(dateString: todayString))
    }
    
    func getNames(dateString: String) -> [String] {
        let url = "https://api.nevnapok.eu/nap/\(dateString)"
        
        var returnNames: [String] = []
        
        let group = DispatchGroup()
        
        group.enter()
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                print("Something went wrong.")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: Data(data), options: []) as? [String: Any] {
                    
                    if let names = json[dateString] as? [String] {
                        returnNames = names
                        
                        self.models.append(contentsOf: returnNames)
                        
                        DispatchQueue.main.async {
                            self.table.reloadData()
                            
                            self.table.tableHeaderView = self.createTableGeaderView()
                        }
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            group.leave()
            
        }).resume()
        
        group.wait()
        
        return returnNames
    }
    
    func createTableGeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: view.frame.size.width * 0.4))
        
        let dateLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width - 20, height: headerView.frame.size.height))
        
        let dayLabel = UILabel(frame: CGRect(x: 10, y: dateLabel.frame.size.height - 60, width: view.frame.size.width - 20, height: headerView.frame.size.height * 0.3))
        
        let date = Date()
        
        dateLabel.textAlignment = .center
        dateLabel.text = date.getCustomDateString()
        dateLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        
        dayLabel.textAlignment = .center
        dayLabel.text = date.getDayString()
        dayLabel.font = UIFont(name: "Helvetica-Bold", size: 20)
        
        headerView.addSubview(dateLabel)
        headerView.addSubview(dayLabel)
        
        return headerView
    }
    
    //Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let (name) = models[indexPath.row]
        
        cell.textLabel?.text = name
        
        return cell
    }
}

extension Date {
    func getCustomDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd."
        
        return dateFormatter.string(from: self)
    }
    
    func getDayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.string(from: self)
    }
    
    func getMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MM")
        
        return dateFormatter.string(from: self)
    }
    
    func getDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dd")
        
        return dateFormatter.string(from: self)
    }
    
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}
