//
//  DataViewController.swift
//  Test
//
//  Created by usuario on 20/06/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var titleToolbar: UINavigationItem!
    @IBOutlet weak var NewMessage: UILabel!
    @IBOutlet weak var emptyMessagge: UILabel!
    @IBOutlet weak var messagges: UILabel!
    @IBOutlet weak var messageTab: UITabBarItem!
    
    let provider = MessageProvider()
    var resultadosMensaje: [MessageObj]=[]
    @IBOutlet weak var tableV: UITableView!
    var cell:HeroesCell?
    var id_formato:String = ""
    var premiunAccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle: Bundle = Bundle(for: MessageCell.self)
        let nib = UINib(nibName: "CellMessage", bundle: bundle)
        tableV.register(nib, forCellReuseIdentifier: "CellMessage")
        
        self.tableV.separatorStyle = .none
        self.tableV.dataSource = self
        self.tableV.delegate = self
        self.tableV.estimatedRowHeight=70
        self.tableV.rowHeight = UITableViewAutomaticDimension
        self.tableV.allowsSelection = false
        self.tableV.tableFooterView = UIView()
        
        premiun()
        if(premiunAccess == true){
            if(Utils.isConnectedToNetwork()){
                mensajes()
            }else{
                tableV.makeToast(Utils.LPLocalizedString(key: "Problemas de internet", comment: ""))
            }
            
        }else{
            alertPremiun()
        }
        initLabels()
    }
    
    func initLabels(){
        titleToolbar.title = Utils.LPLocalizedString(key: "MENSAJES", comment: "")
        NewMessage.text = Utils.LPLocalizedString(key: "Nuevo", comment: "")
        emptyMessagge.text = Utils.LPLocalizedString(key: "Vaciar", comment: "")
        messagges.text =  Utils.LPLocalizedString(key: "MENSAJES", comment: "")
    }
    
    func premiun(){
        
        if PrefererenceManager.getSession() != nil{
            let session = PrefererenceManager.getSession()
            if(session != ""){
                premiunAccess =  true
            }
        }
    }
    
    func alertPremiun(){
        
        let alertController = UIAlertController(title: Utils.LPLocalizedString(key: "titlePremiun", comment: ""), message: Utils.LPLocalizedString(key: "premiunStr", comment: ""), preferredStyle: .alert)
        alertController.view.tintColor = Utils.getColor(hex: "01A9DB", opacity: CGFloat(1.0))
        // Create the actions
        let okAction = UIAlertAction(title: Utils.LPLocalizedString(key: "Acceder", comment: ""), style: UIAlertActionStyle.default) {
            
            
            UIAlertAction in
            NSLog("OK Pressed")
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: LoginController.self))
            let vc = storyboard.instantiateViewController(withIdentifier: "loginContent") as! LoginController
            self.present(vc, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: Utils.LPLocalizedString(key: "Cancelar", comment: ""), style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("Cancel Pressed")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "tab_home")
            self.present(vc, animated: true, completion: nil)
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func mensajes(){
        
        let data = provider.listMessage()
        self.getData(response: data as NSData)
    }
    
    func getData(response:NSData){
        do{
            let json = try JSONSerialization.jsonObject(with: response as Data, options: .allowFragments) as! [String:AnyObject]
            
            let results = json["data"] as! [[String:AnyObject]]
            
            for result in results{
                let mensaje = result["mensaje"] as! String
                let asunto = result["asunto"] as! String
                let urlImage = result["imagen"] as! String
                let id = result["id"] as! String
                let fecha = result["fecha"] as! String
                let nombre = result["nombre"] as! String
                let tipo = result["tipo"] as! String
                //var img:UIImage? = nil
                //                let urlImg = URL(string: urlImage)
                //                do{
                //                    let data = try Data(contentsOf: urlImg!)
                //                    img = UIImage(data: data)!
                //                }catch{
                //                }
                
                let res:MessageObj = MessageObj.init(id:id, mensaje: mensaje, asunto: asunto, urlImage:urlImage, fecha:fecha, nombre:nombre, tipo:tipo)
                
                resultadosMensaje.append(res)
            }
            DispatchQueue.main.async {
                self.tableV.isHidden = false
                self.tableV.reloadData()
            }
        }catch{
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // SHOW = indexPath.row
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultadosMensaje.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
        
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        cell = self.tableV.dequeueReusableCell(withIdentifier: "CellMessage") as? MessageCell
        
        let item: MessageObj = resultadosMensaje[(indexPath as NSIndexPath).row]
        
        cell!.asuntoLabel.text = item.asunto
        cell!.mensajeLabel.text = item.mensaje
        //        let urlImage = URL(string: item.urlImage)
        //        do{
        //            let data = try Data(contentsOf: urlImage!)
        //            cell!.imageHome?.image = UIImage(data: data)
        //        }catch{
        //        }
        //cell!.imageHome?.image = item.img
        cell!.imageHome?.image = Utils.getImage(item.urlImage)
        
        let tapCell = UITapGestureRecognizer(target: self, action: #selector(MessageController.cellClick(_:)))
        cell!.mainView.tag = (indexPath as NSIndexPath).row
        cell!.mainView.addGestureRecognizer(tapCell)
        cell!.mainView.isUserInteractionEnabled = true
        
        //cambia la imagen
        if item.tipo == ConstantsApp.TipoMensajeEnum.Enviada.rawValue{
            cell!.imageTipo.image = UIImage(named: "email_green_arrow")
        }else{
            cell!.imageTipo.image = UIImage(named: "email_red_arrow")
        }
        
        //evento click para eliminar
        cell!.btnTrash.tag = indexPath.row
        cell!.btnTrash.addTarget(self, action: #selector(MessageController.checkClick(sender:)), for: UIControlEvents.touchUpInside)
        
        return self.cell!
    }
    
    @objc func checkClick(sender:UIButton){
        
        let messageObj = resultadosMensaje[sender.tag]
        
        alertConfirmTrash(messageObj: messageObj)
        
    }
    
    @IBAction func cellClick(_ sender:AnyObject){
        
        let messageObj = resultadosMensaje[sender.view!.tag] as? MessageObj
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: MessageDetailController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "MessageDetail") as! MessageDetailController
        vc.messageObj = messageObj
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func newClick(_ sender:AnyObject){
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: MessageCreateController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "MessageCreate") as! MessageCreateController
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func vaciarClick(_ sender:AnyObject){
        let provider = MessageProvider()
        _ = provider.deleteMessageAll()
        self.resultadosMensaje.removeAll()
        self.tableV.reloadData()
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "tab_home")
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //mensaje emergente de confirmacion de eliminacion
    func alertConfirmTrash(messageObj:MessageObj){
        
        let message = Utils.LPLocalizedString(key: "¿Esta seguro de eliminar este mensaje?", comment: "")
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.view.tintColor = Utils.getColor(hex: "01A9DB", opacity: CGFloat(1.0))
        // Create the actions
        let okAction = UIAlertAction(title: Utils.LPLocalizedString(key: "Aceptar", comment: ""), style: UIAlertActionStyle.default) {
            
            UIAlertAction in
            NSLog("OK Pressed")
            
            let provider = MessageProvider()
            _ = provider.deleteMessage(messageObj: messageObj)
            
            self.resultadosMensaje.removeAll()
            self.mensajes()
        }
        let cancelAction = UIAlertAction(title: Utils.LPLocalizedString(key: "Cancelar", comment: ""), style: UIAlertActionStyle.default) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
}


