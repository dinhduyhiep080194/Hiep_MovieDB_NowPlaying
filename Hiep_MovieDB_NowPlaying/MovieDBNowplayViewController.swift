//
//  MovieDBNowplayViewController.swift
//  Hiep_MovieDB_NowPlaying
//
//  Created by cntt17 on 5/13/17.
//  Copyright © 2017 cntt17. All rights reserved.
//

import UIKit

class Downloader {
    
    class func downloadImageWithURL(_ url:String) -> UIImage! {
        
        let data = try? Data(contentsOf: URL(string: url)!)
        return UIImage(data: data!)
    }
}

class MovieDBNowplayViewController: UITableViewController {
    
    let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    var dataTask: URLSessionDataTask?
    
    var movies: [Movie] = {
        return MovieList.movies()
    }()
    
    var queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMovie()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = movies[indexPath.row].title
        cell.detailTextLabel?.text = movies[indexPath.row].overview
        
        return cell
    }
    
     /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func loadMovie() {
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=f2eddf92e8482430aceb071df36d3e69&language=en-US&page=1")
        
        dataTask = defaultSession.dataTask(with: url! as URL) {
            data, response, error in
            
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
                            
                            // Get the results array
                            if let array: AnyObject = response["results"] {
                                for movieDictonary in array as! [AnyObject] {
                                    if let movieDictonary = movieDictonary as? [String: AnyObject], let title = movieDictonary["title"] as? String {
                                        // Parse the search result
                                        let poster = movieDictonary["poster_path"] as? String
                                        let overview = movieDictonary["overview"] as? String
                                        let adult = movieDictonary["adult"] as? String
                                        let genre_ids = movieDictonary["genre_ids"] as? String
                                        let releaseDate = movieDictonary["release_date"] as? String
                                        let original_language = movieDictonary["original_language"] as? String
                                        let popularity = movieDictonary["popularity"] as? String
                                        self.movies.append(Movie(title: title, poster: poster, overview: overview, releaseDate: releaseDate, adult: adult, genre_ids: genre_ids, original_language: original_language, popularity: popularity))
                                    } else {
                                        print("Not a dictionary")
                                    }
                                }
                            } else {
                                print("Results key not found in dictionary")
                            }
                        } else {
                            print("JSON Error")
                        }
                    } catch let error as NSError {
                        print("Error parsing results: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView.setContentOffset(CGPoint.zero, animated: false)
                    }
                    
                }
            }
        }
        
        dataTask?.resume()
    }
    
    
}
