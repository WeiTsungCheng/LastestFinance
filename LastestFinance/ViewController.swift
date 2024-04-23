

import UIKit
import Combine

class ViewController: UIViewController {
    
    let webService = WebSocketService()
    
    @IBOutlet var priceLabel: UILabel!
    
    @IBAction func start(_ sender: UIButton) {
        start()
    }
    
    @IBAction func end(_ sender: UIButton) {
        end()
    }
    
    @IBAction func sendPing(_ sender: UIButton) {
        sendPing()
    }
    
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webService.$price
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                self.priceLabel.text = text
                
            }
            .store(in: &cancellable)
    }
    
    
    func start() {
        webService.connect()
        webService.sendMessage()
    }
    
    func end() {
        webService.disConnect()
        webService.price = "0.0"
    }
    
    func sendPing() {
        webService.sendPing()
    }
}


