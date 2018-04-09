//
//  DogesViewController.swift
//  LearningRealm
//
//  Created by Sandeep Bhandari on 4/9/18.
//  Copyright © 2018 Sandeep Bhandari. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxDataSources

class DogesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    var realmToken : NotificationToken! = nil
    var personInFocus : Person! = nil
    var dogsArray : BehaviorRelay<[DogsCustomSection]>! = nil
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "DogsTableViewCell", bundle: nil), forCellReuseIdentifier: "dogCell")
        self.tableView.allowsMultipleSelection = false
        
        let existingDogs = realm.objects(Dogs.self).filter("ownedBy.id == %@",personInFocus.id ?? "")
        let customSection = DogsCustomSection(items: Array(existingDogs))
        dogsArray = BehaviorRelay<[DogsCustomSection]>(value: [customSection])
        
        realmToken = realm.observe {[weak self] _,_ in
            guard let strongSelf = self else {
                return
            }
            let array = strongSelf.realm.objects(Dogs.self).filter("ownedBy.id == %@",strongSelf.personInFocus.id ?? "")
            var lastObject = strongSelf.dogsArray.value.last
            var existingArray = strongSelf.dogsArray.value
            let _ = existingArray.removeLast()
            
            lastObject?.items = Array(array)
            existingArray.append(lastObject!)
            strongSelf.dogsArray.accept(existingArray)
        }
        
        let dataSource = RxTableViewSectionedReloadDataSource<DogsCustomSection>(configureCell: {
            (dataSource,tableView,index,item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "dogCell") as! DogsTableViewCell
            cell.dogName.text = item.name ?? ""
            return cell
        },canEditRowAtIndexPath : {_,_ in
            return true
        })
        self.dogsArray.bind(to: self.tableView.rx.items(dataSource: dataSource)).disposed(by: self.disposeBag)
        
        self.tableView.rx.itemDeleted.subscribe(onNext: {[weak self] (indexPath) in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.realm.isInWriteTransaction {
                do {
                    try strongSelf.realm.write {
                        if let dogToDelete = strongSelf.dogsArray.value.last?.items[indexPath.row] {
                            
                            if let index = strongSelf.personInFocus.owns.index(of: dogToDelete) {
                                strongSelf.personInFocus.owns.remove(at: index)
                            }
                            strongSelf.realm.delete(dogToDelete)
                            try strongSelf.realm.commitWrite()
                        }
                    }
                }
                catch {
                    debugPrint(error)
                }
            }
        }).disposed(by: self.disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addDogs" {
            var destinationVC = segue.destination
            (destinationVC as! AddDogsViewController).personInFocus = self.personInFocus
        }
        
    }
}
