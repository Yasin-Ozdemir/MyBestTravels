//
//  TravelsNames.swift
//  MyBestTravels
//
//  Created by Yasin Özdemir on 27.02.2023.
//

import UIKit
import CoreData
class TravelsNames: UIViewController,UITableViewDelegate,UITableViewDataSource{

   
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButton))
        
        getData()
        
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name:NSNotification.Name(rawValue:"Save Success"), object: nil)
        tableView.reloadData()
    }

    
    // Diziler Veri Tabanından Verileri Çekme
    @objc func getData(){
        nameArray.removeAll()
        idArray.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let contex = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Travel")
        
        do{
            var results = try contex.fetch(fetchRequest)
            for result in results as! [NSManagedObject]{
                if let name = result.value(forKey: "name") as? String{
                    nameArray.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID {
                    idArray.append(id)
                }
            }
            tableView.reloadData()
            
        }catch{print("Fetch Error")}
    }
    
    
    @objc func addButton(){
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            var detailsVC = segue.destination as! DetailsVC
            detailsVC.name = nameArray[index]
            detailsVC.id = idArray[index]
        }
    }

    

}
