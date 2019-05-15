//
//  IntentViewController.swift
//  SoupUI
//
//  Created by CXY on 2019/5/13.
//  Copyright © 2019 cxy. All rights reserved.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var soupImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        if let intent = interaction.intent as? OrderSoupIntent {
            orderLabel.text = "点\(intent.quantity!)份\(intent.soup!)?"
            let intentImage = intent.image(forParameterNamed: \OrderSoupIntent.image)
    
            intentImage?.fetchUIImage { [weak self] (image) in
                DispatchQueue.main.async {
                    self?.soupImageView?.image = image
                }
            }
        }
        completion(true, parameters, self.desiredSize)
    }
    
    var desiredSize: CGSize {
        var size = self.extensionContext!.hostedViewMaximumAllowedSize
        size.height = 100
        return size
    }
    
}
