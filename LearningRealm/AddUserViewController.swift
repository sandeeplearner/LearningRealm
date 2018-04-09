//
//  AddUserViewController.swift
//  LearningRealm
//
//  Created by Sandeep Bhandari on 4/8/18.
//  Copyright © 2018 Sandeep Bhandari. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import RealmSwift

class AddUserViewController: UIViewController {
    
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    let disposeBag = DisposeBag()
    var validatorAction : Action<Void,Bool>! = nil
    var addUserAction : CocoaAction! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validatorAction = Action<Void,Bool> {
            return Single<Bool>.create(subscribe: { (single) -> Disposable in
                if self.firstName.text?.count ?? 0 > 0 && self.lastName.text?.count ?? 0 > 0 && self.age.text?.count ?? 0 > 0 {
                    single(.success(true))
                }
                else {
                    single(.success(false))
                }
                return Disposables.create()
            })
        }
        
        addUserAction = CocoaAction(workFactory: {[weak self] _ in
            guard let strongSelf = self else {
                return Observable.empty()
            }
            return Single<Void>.create(subscribe: { (single) -> Disposable in
                let firstName = strongSelf.firstName.text ?? ""
                let lastName = strongSelf.lastName.text ?? ""
                let age = strongSelf.age.text ?? ""
                let id = strongSelf.id.text ?? ""
                
                let somePerson = Person()
                somePerson.firstName = firstName
                somePerson.lastName = lastName
                somePerson.age = Int(age) ?? 0
                somePerson.id = id
                
                let realm = try! Realm()
                do {
                    try realm.write({
                        realm.create(Person.self, value: somePerson, update: true)
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
        
        self.firstName.rx.bind(to: validatorAction, controlEvent: self.firstName.rx.controlEvent(UIControlEvents.editingDidEnd)){ (textField) -> Void in
            return Void()
        }
        
        self.lastName.rx.bind(to: validatorAction, controlEvent: self.lastName.rx.controlEvent(UIControlEvents.editingDidEnd)){ (textField) -> Void in
            return Void()
        }
        
        self.age.rx.bind(to: validatorAction, controlEvent: self.age.rx.controlEvent(UIControlEvents.editingDidEnd)) { (textField) -> Void in
            return Void()
        }
        
        submitButton.rx.action = addUserAction
        addUserAction.elements.asObservable().subscribe(onNext : { _ in
            self.dismiss(animated: true, completion: nil)
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
