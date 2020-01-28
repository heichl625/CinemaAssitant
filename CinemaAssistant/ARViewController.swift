//
//  ARViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 17/1/2020.
//  Copyright © 2020 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import ARKit

class ARViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        // Do any additional setup after loading the view.
        
        let node = SCNNode()
        node.geometry = SCNBox(width: 10, height: 5.6, length: 0, chamferRadius: 0)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.position = SCNVector3(0, 0, -10)
        self.sceneView.scene.rootNode.addChildNode(node)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
