//
//  MovieViewController.swift
//  Flickster
//
//  Created by David Hill on 1/31/17.
//  Copyright © 2017 David Hill. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    
    var Endpoint: String!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
        
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)

        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data
            {
                
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    
                    self.tableView.reloadData()
                    
                }
            }
        }
        task.resume()

        

        let refreshControl = UIRefreshControl()
        
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl: )), for: UIControlEvents.valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
        
    
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let movies = movies
        {
         return movies.count
        }
        
        else
        {
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier:  "MovieCell" , for: indexPath) as! MovieCell
        
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseURL = "https://image.tmdb.org/t/p/w500"
        
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        
        if let posterPath = movie["poster_path"] as? String
        {
            let imageURL = URL(string: baseURL + posterPath)
            cell.posterView.setImageWith(imageURL!)
        }
        
        
        return cell
    
    }
 
    
    func refreshControlAction(refreshControl: UIRefreshControl)
    {
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        if let url = URL(string: "https://api.themoviedb.org/3/movie/\(Endpoint)?api_key=\(apiKey)")
        {
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data
            {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                {
                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    
                    self.tableView.reloadData()
                    
                    refreshControl.endRefreshing()
                }
            }
        }
        task.resume()
        }
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let cell = sender as! UITableViewCell
        
        let indexPath = tableView.indexPath(for: cell)
        
        let movie = movies![(indexPath!.row)]
        
        let detailViewController = segue.destination as! DetailViewController
        
        detailViewController.movie = movie
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
