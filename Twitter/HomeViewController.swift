//
//  HomeViewController.swift
//  Twitter
//
//  Created by Dan on 1/3/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    var tweetArray = [NSDictionary]()
    var refresher = UIRefreshControl()
    var numberOfTweets: Int!
    
    @IBOutlet var tweetTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberOfTweets = 20
        self.loadTweetTable()
        
        refresher.addTarget(self, action: #selector(loadTweetTable), for: .valueChanged)
        self.tweetTable.refreshControl = refresher
    }
    
    @objc func loadTweetTable(){
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParameters: [String:Any] = ["count" : numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: myParameters, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tweetTable.reloadData()
            self.refresher.endRefreshing()
            
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    @objc func loadMoreTweet(){
        numberOfTweets = numberOfTweets + 20
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParameters: [String:Any] = ["count": numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: myParameters, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tweetTable.reloadData()
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tweetTable.dequeueReusableCell(withIdentifier: "tweetcell", for: indexPath) as! TweetCellTableViewCell
        cell.tweetTextLabel.text = tweetArray[indexPath.row]["text"] as? String
        
        cell.timeLabel.text = getRelativeTime(timeString: (tweetArray[indexPath.row]["created_at"] as? String)!)
        
        let user = tweetArray[indexPath.row]["user"] as? NSDictionary
        cell.tweetAuthorLabel.text = user?["name"] as? String
        
        let imageUrl = URL(string: (user?["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.tweetImage.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        UserDefaults.standard.set(false, forKey: "alreadyLoggedIn")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweet()
        }
    }
    
    func getRelativeTime(timeString: String) -> String{
        let time: Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        time = dateFormatter.date(from: timeString)!
        return time.timeAgoDisplay()
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        if secondsAgo < minute {
            return "\(secondsAgo) sec ago"
        } else if secondsAgo < hour {
            return "\(secondsAgo / minute) min ago"
        } else if secondsAgo < day {
            return "\(secondsAgo / hour) hr ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) day(s) ago"
        }
        return "\(secondsAgo / week) week(s) ago"
    }
}
