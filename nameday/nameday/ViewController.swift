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
    
    var actualDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeGestures(gesture:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeGestures(gesture:)))
        swipeRight.direction = .right
        
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)
        
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getContent()
    }
    
    func getContent() {
        let todayString = "\(actualDate.getMonth())-\(actualDate.getDay())"
        getNames(dateString: todayString)
    }
    
    func getNames(dateString: String) {
        let url = "https://api.nevnapok.eu/nap/\(dateString)"
        
        var returnNames: [String] = []
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                print("Something went wrong.")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: Data(data), options: []) as? [String: Any] {
                    
                    if let names = json[dateString] as? [String] {
                        returnNames = names
                        
                        self.models.removeAll()
                        self.models.append(contentsOf: returnNames)
                        
                        DispatchQueue.main.async {
                            self.table.tableHeaderView = self.createTableGeaderView()
                            self.table.reloadData()
                        }
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }).resume()
    }
    
    func createTableGeaderView() -> UIView {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: view.frame.size.width * 0.4))
        
        let dateLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width - 20, height: headerView.frame.size.height))
        
        let dayLabel = UILabel(frame: CGRect(x: 10, y: dateLabel.frame.size.height - 60, width: view.frame.size.width - 20, height: headerView.frame.size.height * 0.3))
        
        dateLabel.textAlignment = .center
        dateLabel.text = actualDate.getCustomDateString()
        dateLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        
        dayLabel.textAlignment = .center
        dayLabel.text = actualDate.getDayString()
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
    
    func incrementDate() {
        var dateComponent = DateComponents()
        dateComponent.day = 1
        
        actualDate = Calendar.current.date(byAdding: dateComponent, to: actualDate)!
    }
    
    func decrementDate() {
        var dateComponent = DateComponents()
        dateComponent.day = -1
        
        actualDate = Calendar.current.date(byAdding: dateComponent, to: actualDate)!
    }
    
    @objc func handleSwipeGestures(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            incrementDate()
            getContent()
            self.table.leftToRightAnimation()
            self.view.setNeedsDisplay()
        }else if gesture.direction == .right {
            decrementDate()
            getContent()
            self.table.rightToLeftAnimation()
            self.view.setNeedsDisplay()
        }
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
}

extension UIView {
    func leftToRightAnimation(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition object
        let leftToRightTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided
        if let delegate: AnyObject = completionDelegate {
            leftToRightTransition.delegate = delegate as? CAAnimationDelegate
        }
        
        leftToRightTransition.type = CATransitionType.push
        leftToRightTransition.subtype = CATransitionSubtype.fromRight
        leftToRightTransition.duration = duration
        leftToRightTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        leftToRightTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(leftToRightTransition, forKey: "leftToRightTransition")
    }
    
    func rightToLeftAnimation(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition object
        let rightToLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided
        if let delegate: AnyObject = completionDelegate {
            rightToLeftTransition.delegate = delegate as? CAAnimationDelegate
        }
        
        rightToLeftTransition.type = CATransitionType.push
        rightToLeftTransition.subtype = CATransitionSubtype.fromLeft
        rightToLeftTransition.duration = duration
        rightToLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        rightToLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(rightToLeftTransition, forKey: "rightToLeftTransition")
    }
}
