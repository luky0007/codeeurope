//
//  ViewController.swift
//  pl.ing.meetup
//
//  Created by Łukasz Beksa on 04/10/2019.
//  Copyright © 2019 Łukasz Beksa. All rights reserved.
//

import UIKit
import WebKit
import LocalAuthentication
import ContactsUI

class ViewController: UIViewController {
    var webView: WKWebView!
    
    override func viewDidLoad() {
       super.viewDidLoad()
         let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "test")
        userContentController.add(self, name: "share2")
        userContentController.add(self, name: "openContacts")
        userContentController.add(self, name: "login")
        
        let scriptSource = "document.body.style.backgroundColor = 'pink';"
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(script)

        config.userContentController = userContentController
        
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        //let testurl = "https://123e68c1-ea57-44a3-b993-16182ca30849.htmlpasta.com/"
        let testurl = "https://http.cat"
        if let url = URL(string: testurl){
            self.webView.load(URLRequest(url: url))
        }
        self.view.addSubview(webView)
        
    }
}

extension ViewController: WKScriptMessageHandler, CNContactPickerDelegate {
    
    private func evaluateJavascript(_ javascript: String) {
          webView.evaluateJavaScript(javascript) { (result, error) in
              if error != nil {
                print(result.debugDescription)
              }
              else{
                //do something
            }
          }
      }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "test", let test = message.body as? String {
            print(test)
            authenticateUser()
        }
        if message.name == "share", let address = message.body as? String {
            print(address)
            shareSomething(address)
        }
        if message.name == "openContacts" {
            openContacts()
        }
        if message.name == "login" {
            authenticateUser()
        }
    }
    
    func openContacts(){
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        contacts.forEach { contact in
            for number in contact.phoneNumbers {
                let phoneNumber = number.value
                print("number is = \(phoneNumber)")
                let str = String(format: "evalFunc('%@')", phoneNumber.stringValue)
                evaluateJavascript(str)
            }
        }
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
    
    
    func shareSomething(_ address:String){
        //checking the object and the link you want to share
        let linkToShare = [address]
        let activityController = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }

    func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Login?"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        print("evaluate javascript ... :)")
                        let str = String(format: "evalFunc('%@')", "LOGIN_OK")
                        self.evaluateJavascript(str)
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}



