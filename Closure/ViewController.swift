//
//  ViewController.swift
//  Closure
//
//  Created by Минайдар  Максат on 10/27/20.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var users = [Data]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "second", for: indexPath) as! SecondCell
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "first", for: indexPath) as! FirstCell
            setupImage(URLString: users[indexPath.row].avatar ?? "", imageView: cell.userImage)
            cell.userName.text = users[indexPath.row].firstName
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 304
        }
        return UITableView.automaticDimension
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.getUsers() { users in
        }
        
        hideKeyboardWhenTappedAround()
        
    }
    
    func setupImage(URLString: String, imageView: UIImageView) {
        let url = URL(string: URLString)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Images are not found \(error!)")
                return
            }
            guard let data = data else { return }
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    
    func getUsers(completion: @escaping ([Data]) -> Void) {
        Alamofire.request("https://reqres.in/api/users", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<UsersResponse>) in
            if let result = response.result.value {
                self.users = result.data ?? []
                self.tableView.reloadData()
                completion(self.users)
            }
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class FirstCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
}

class SecondCell: UITableViewCell {
    
    @IBAction func postTapped(_ sender: UIButton) {
        guard let url = URL(string: "https://reqres.in/api/users") else { return }
        let parameters = [
            "Name: ": FieldName.text ?? "",
            "Position: ": FieldPosition.text ?? ""
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            }
            catch {
                print(error)
            }
        }.resume()
    }
    
    @IBOutlet weak var FieldName: UITextField!
    @IBOutlet weak var FieldPosition: UITextField!
}

