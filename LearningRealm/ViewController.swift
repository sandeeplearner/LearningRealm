//
//  ViewController.swift
//  LearningRealm
//
//  Created by Sandeep Bhandari on 4/7/18.
//  Copyright © 2018 Sandeep Bhandari. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    var realm : Realm! = nil
    var realmToken : NotificationToken! = nil
    @IBOutlet weak var tableView: UITableView!
    var peopleArray : BehaviorRelay<[PersonsCustomSection]>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        self.tableView.register(UINib(nibName: "PersonTableViewCell", bundle: nil), forCellReuseIdentifier: "personCell")
        
        let existingPeople = realm.objects(Person.self)
        let customSection = PersonsCustomSection(items: Array(existingPeople))
        peopleArray = BehaviorRelay<[PersonsCustomSection]>(value: [customSection])
        
        realmToken = realm.observe {[weak self] _,_ in
            guard let strongSelf = self else {
                return
            }
            let array = strongSelf.realm.objects(Person.self)
            var lastObject = strongSelf.peopleArray.value.last
            var existingArray = strongSelf.peopleArray.value
            let _ = existingArray.removeLast()
            
            lastObject?.items = Array(array)
            existingArray.append(lastObject!)
            strongSelf.peopleArray.accept(existingArray)
        }
        
        self.tableView.delegate = self
        let dataSource = RxTableViewSectionedReloadDataSource<PersonsCustomSection>(configureCell: {
            (dataSource,tableView,index,item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "personCell") as! PersonTableViewCell
            (cell ).nameLabel.text = item.fullName
            cell.numberOfDogsLabel.text = "\(item.owns.count) Dogs"
            cell.phoneNumberLabel.text = item.phoneNumber!
            return cell
        },canEditRowAtIndexPath : {_,_ in
            return true
        })
        self.peopleArray.bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: self.disposeBag)
        
        self.tableView.rx.itemDeleted.subscribe(onNext: {[weak self] (indexPath) in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.realm.isInWriteTransaction {
                if let personToDelete = strongSelf.peopleArray.value.last?.items[indexPath.row] {
                    personToDelete.cascadeDeleteObject()
                }
            }
        }).disposed(by: self.disposeBag)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    deinit {
        realmToken.invalidate()
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let person = Person()
        person.firstName = "Sandeep"
        person.lastName = "Bhandari"
        person.age = 20
        person.id = "1"
        
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(person)
            }
        }
        catch {
            debugPrint(error)
        }
    }
    
    @IBAction func getTapped(_ sender: Any) {
        //        let realm = try! Realm()
        //        let people = realm.objects(Person.self).filter("firstName = 'Sandeep'")
        //        realm.beginWrite()
        //        people[0].age = 25
        //        try! realm.commitWrite()
        //        personInFocus.onNext([personOfInterest])
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDogs" {
            let destinationVC = segue.destination as! DogesViewController
            destinationVC.personInFocus = sender as! Person
        }
        else {
            let destinationVC = segue.destination
            destinationVC.preferredContentSize = CGSize(width: 375, height: 250)
            let controller = destinationVC.popoverPresentationController
            controller?.sourceView = self.view
            controller?.sourceRect = CGRect(x:self.view.bounds.midX, y: self.view.bounds.midY,width: 375,height: 250)
        }
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let person = self.peopleArray.value.last?.items[indexPath.row] {
            self.performSegue(withIdentifier: "showDogs", sender: person)
        }
    }
}

