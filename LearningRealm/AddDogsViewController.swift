//
//  AddDogsViewController.swift
//  LearningRealm
//
//  Created by Sandeep Bhandari on 4/9/18.
//  Copyright © 2018 Sandeep Bhandari. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import RealmSwift

class AddDogsViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    let disposeBag = DisposeBag()
    var validatorAction : Action<Void,Bool>! = nil
    var addDogsAction : CocoaAction! = nil
    var personInFocus : Person! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validatorAction = Action<Void,Bool> {
            return Single<Bool>.create(subscribe: { (single) -> Disposable in
                if self.name.text?.count ?? 0 > 0 && self.age.text?.count ?? 0 > 0 {
                    single(.success(true))
                }
                else {
                    single(.success(false))
                }
                return Disposables.create()
            })
        }
        
        addDogsAction = CocoaAction(workFactory: {[weak self] _ in
            guard let strongSelf = self else {
                return Observable.empty()
            }
            return Single<Void>.create(subscribe: { (single) -> Disposable in
                let name = strongSelf.name.text ?? ""
                let age = strongSelf.age.text ?? ""
                let id = strongSelf.id.text ?? ""
                
                let someDog = Dogs()
                someDog.name = name
                someDog.age = RealmOptional<Int>(Int(age) ?? 0)
                someDog.ownedBy = strongSelf.personInFocus
                someDog.id = id
                
                let realm = try! Realm()
                do {
                    try realm.write({
                        realm.create(Dogs.self, value: someDog, update: true)
                        if let addedDog = realm.object(ofType: Dogs.self, forPrimaryKey: someDog.id ?? ""),
                            let personInRealm =  realm.object(ofType: Person.self, forPrimaryKey: strongSelf.personInFocus.id ?? ""){
                            if !personInRealm.owns.contains(addedDog) {
                                personInRealm.owns.append(addedDog)
                            }
                        }
                        single(.success(Void()))
                    })
                }
                catch {
                    debugPrint(error)
                    single(.error(error))
                }
                return Disposables.create()
            }).asObservable()
        })
        
        self.name.rx.bind(to: validatorAction, controlEvent: self.name.rx.controlEvent(UIControlEvents.editingDidEnd)){ (textField) -> Void in
            return Void()
        }
        
        self.age.rx.bind(to: validatorAction, controlEvent: self.age.rx.controlEvent(UIControlEvents.editingDidEnd)) { (textField) -> Void in
            return Void()
        }
        
        submitButton.rx.action = addDogsAction
        addDogsAction.elements.asObservable().subscribe(onNext : { _ in
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: self.disposeBag)
        
        validatorAction.elements
            .asObservable()
            .startWith(false)
            .asDriver(onErrorJustReturn: false)
            .drive(self.submitButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
