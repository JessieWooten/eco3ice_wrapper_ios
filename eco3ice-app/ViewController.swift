//
//  ViewController.swift
//  eco3ice-app
//
//  Created by Jessie Wooten on 10/9/17.
//  Copyright © 2017 Franke. All rights reserved.
//
import UIKit
import Swifter


var appIP = ""

var selectedUnitIP = ""

var unitList:Array = [String]()

var ecoParam = ""

struct defaultsKeys {
    static let imperial = "false"
    static let locale = "en"
}


class ViewController: UIViewController, UIWebViewDelegate {
    let reachability = Reachability()!
    
    @IBOutlet weak var webView: UIWebView!
    //var reachability:Reachability?
    
    //private var server: HttpServer?
    

    
    override func viewWillAppear(_ animated: Bool) {
        self.webView.delegate = self
        loadHTMLFromBundle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.scrollView.bounces = false;
        //adds window.app functions to browser
        let windowJs = "window.app={scanBle:function(){window.location=\"scanble://#\"},sendCommand:function(n){window.location=\"sendcommand://\"+n},getDevices:function(){window.location=\"getdevices://#\"},connect:function(n){window.location=\"connect://\"+n},disconnect:function(){window.location=\"disconnect://#\"},getdata:function(){window.location=\"getdata://#\"},inApp:function(){return!0},sendCallback:function(n){window.location=\"sendCallback://\"+n},isConnected:function(){return!0},orderParts:function(n){window.location=\"order://\"+n},reqLocalLogs:function(){window.location=\"reqlocallogs://\"},deleteFile:function(n,o){void 0!=o?window.location=\"deletefile://\"+n+\"--\"+o:window.location=\"deletefile://\"+n},reqContents:function(n,o){window.location=\"reqcontents://\"+n+\"--\"+o},saveLog:function(n,o){window.location=\"saveLog://\"+n+\"--\"+o},userData:function(n,o){window.location=\"userdata://\"+n+\"--\"+o},reqUserData:function(){window.location=\"requserdata://#\"}};"
        _ = webView.stringByEvaluatingJavaScript(from: windowJs)
        
        do {
            let server = demoServer(Bundle.main.resourcePath!)
            server["/response/:params"] = { r in   // HttpRequest object.
                let callback = r.params[":params"]?.removingPercentEncoding ?? ""
                print( "This is the callback: \(callback)" )
                DispatchQueue.main.async {
                    self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].dataUpdate('\(callback)')")
                }
                return HttpResponse.raw(200, "OK", ["XXX-Custom-Header": "value"], { (writer) in
                    try writer.write([UInt8]("Thanks".utf8))
                })
            };
            try server.start(80)
            //self.server = server
        } catch {
            print("Server start error: \(error)")
        }
        
        //Check for Wifi connection
        getWiFiAddress();
        
        //Monitor for disconnect from wifi
        reachability.whenReachable = { _ in
            DispatchQueue.main.async {
                print("Wifi is connected")
                self.getWiFiAddress()
            }
        }
        reachability.whenUnreachable = { _ in
            DispatchQueue.main.async {
                print("Wifi Disconnected")
                self.getWiFiAddress()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(getWiFiAddress), name: Notification.Name.reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch { print("couldn't start Notifier:(")}
    }
    
// ||** FUNCTION DECLARATIONS **||
    
    
//LOADS USER PREFS FOR MEASUMENTS AND LOCALE
    func loadPreferences() {
        let defaults = UserDefaults.standard
        if let imperial = defaults.string(forKey: defaultsKeys.imperial) {
            self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].imperial = " + imperial);
            print("imperial loaded")
        }
        if let locale = defaults.string(forKey: defaultsKeys.locale) {
            self.webView.stringByEvaluatingJavaScript(from: "window.vue.$i18n.locale = '" + locale + "'");
            print("locale loaded: ", "window.$i18n.locale = '" + locale + "'") // Another String Value
        }
    }
    
// LOADS JS APP
    func loadHTMLFromBundle() {
        let url = Bundle.main.url( forResource: "index", withExtension: "html", subdirectory: "eco3ice-beta1")
        let urlRequest:URLRequest = URLRequest(url: url!)
        self.webView.loadRequest(urlRequest)
    }
    
// Sets IP address of WiFi interface (en0) to appIP variable
    func getWiFiAddress() {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { print("ifaddr failed"); return }
        guard let firstAddr = ifaddr else { print("firstAddr failed"); return }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 interface
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        //if ip was found
        if address != nil {
            //if there hasnt been an ip set for app yet, set appIP to the found ip
            if appIP == "" {
                appIP = address!;
                print("appIP = ", appIP)
            }else{
                //if ip has been set for app, check if it has changed since last check.
                if appIP != address {
                    //alert user that ip has changed
                    self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].connectOpened = false;")
                    self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].ipChanged = true;")
                    appIP = address!;
                }
            }
        }else{
            //try again in 8 seconds
            print("address was nil")
            self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].connectOpened = false;")
            self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].connectToWifi = true;")
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: {
                self.getWiFiAddress()
            })
        appIP = ""
        }
    }
    
// turn unitList to string that can be passed into js call
    func unitListToJSString(array: Array<Any>) -> String {
        let str = array.description;
        let removeOpenBracket = str.replacingOccurrences(of: "[\"", with: "");
        let removeCloseBracket = removeOpenBracket.replacingOccurrences(of: "\"]", with: "");
        let removeOpenBrace = removeCloseBracket.replacingOccurrences(of: "\"{", with: "{");
        let removeCloseBrace = removeOpenBrace.replacingOccurrences(of: "}\"", with: "}");
        return removeCloseBrace
    }

//replaces opening and closing brackets in string
    func replaceBrackets(str:String , replaceWith: String) -> String {
        let openRepl = str.replacingOccurrences(of: "\\[", with: replaceWith, options: .regularExpression);
        let closeRepl = openRepl.replacingOccurrences(of: "\\]", with: replaceWith, options: .regularExpression);
        return closeRepl;
    }
    
    
//Send command to Ecoice unit
    func sendCommand(command: String) {
        let unitUrl = "http://" + selectedUnitIP + ":80/command?ipaddr=" + appIP + "&command=" + command
        print("send command to: \(unitUrl)")
        var request = URLRequest(url: URL(string: unitUrl)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            print("Entered the completionHandler")
            }.resume()
    }
    
//Removes command name Capacity commands
    func stripCommand(command:String) -> String {
        let indexStartOfText = command.index(command.startIndex, offsetBy: 14)
        return command.substring(from: indexStartOfText)
    }
// Removes "Rename:' and command name from Rename commands
    func stripRenameCommand(command:String) -> String {
        let indexStartOfText = command.index(command.startIndex, offsetBy: 14)
        let nameCommand = command.substring(from: indexStartOfText)
        let nameIndex = nameCommand.index(nameCommand.startIndex, offsetBy: 7)
        let name = nameCommand.substring(from: nameIndex)
        return name
    }
    
//Handle JS requests
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.url?.scheme{
            switch (scheme)
            {
                case "sendcommand":
                    getWiFiAddress()
                    if appIP != "" {
                        //let withParam = String(describing: request).removingPercentEncoding;
                        //print("request before: ", withParam!)
                        //print("request: ", withParam!)
                        if let command = request.url?.host {
                            NSLog("'Send Command' command received: \(scheme), \(command)")
                            if command == "capacity" {
                                //print("|||Capacity|||: ", String(describing: request))
                                let withParam = String(describing: request);
                                let param = String(stripCommand(command: withParam));
                                print("|||CAPACITY|||: ", param!)
                                let unitUrl = "http://" + selectedUnitIP + ":80/command?ipaddr=" + appIP + "&command=" + param!
                                print("send command to: \(unitUrl)")
                                var request = URLRequest(url: URL(string: unitUrl)!)
                                //print("REQUEST: ")
                                request.httpMethod = "GET"
                                let session = URLSession.shared
                                session.dataTask(with: request) {data, response, err in
                                    print("Entered the completionHandler")
                                }.resume()
                            }else if command == "rename" {
                                let withParam = String(describing: request);
                                print(withParam)
                                let param = String(stripRenameCommand(command: withParam));
                                print("|||RENAME|||: ", param!)
                                let unitUrl = "http://" + selectedUnitIP + ":80/rename?name=" + param!
                                print("send command to: \(unitUrl)")
                                var request = URLRequest(url: URL(string: unitUrl)!)
                                //print("REQUEST: ")
                                request.httpMethod = "GET"
                                let session = URLSession.shared
                                session.dataTask(with: request) {data, response, err in
                                    print("Entered the completionHandler")
                                    }.resume()
                            }else{
                                sendCommand(command: command)                        }
                        }else {
                            NSLog("'Send Command' failed: \(request)")
                        }
                    }else {self.getWiFiAddress()}
                
                case "order":
                    if let url = request.url?.host{
                        let strUrl =  String(url)
                        let orderReq = "http://" + strUrl!
                        UIApplication.shared.openURL(URL(string: orderReq)!)
                    }
                
                
                case "connect":
                    if let macAddress = request.url?.host {
                        //print( type( macAddress))
                        selectedUnitIP = String(macAddress);
                        self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].dataUpdate('connected')")
                        //sendcommand(dr)
                        NSLog("Connect command received: \(scheme), mac: \(macAddress)", "selectedUnitIp: \(selectedUnitIP)")
                        
                    } else {
                        NSLog("'Connect' command failed: \(request)")
                    }
                
                case "disconnect":
                    //clear global string
                    selectedUnitIP = ""
                    NSLog("Disconnect command received: \(scheme)" + " | Selected Unit Ip: \(selectedUnitIP)")
                
                
//                case "appCallback":
//                    if let callback = request.url?.host {
//                        webView.stringByEvaluatingJavaScript(from: "dataUpdate(\(callback)")
//                    }
                
                case "getdevices": break
                
                case "scanble":
                    // http://192.168.11.4/
                    getWiFiAddress()
                    if (appIP != ""){
                        NSLog("Scan for Ble command received: \(scheme)")
                        var IPRoot = appIP.components(separatedBy: ".")
                        let group = DispatchGroup()
                        unitList = []
                
                        //loop through all ip's on network
                        for i in 0...255 {
                            group.enter()
                            DispatchQueue.global().async {
                                IPRoot[3] = String(i)
                                let reqIP = IPRoot.joined(separator: ".")
                                let reqPort = "http://" + reqIP + ":80/info"
                                let scanRequest = URL(string: reqPort)
                                //print(reqPort)
                        
                                //start url session with timeout
                                let configuration = URLSessionConfiguration.default
                                configuration.timeoutIntervalForRequest = TimeInterval(10)
                                configuration.timeoutIntervalForResource = TimeInterval(10)
                                let session = URLSession.shared
                                session.dataTask(with: scanRequest!) { (data, response, error) in
                                    if data != nil { //if data is returned
                                        let dataCheck = String(data: data!, encoding: .utf8)
                                        
                                        //convert to string and check if 'name' is present
                                        if dataCheck!.range(of: "name") != nil && dataCheck!.range(of: "mac") != nil {
                                            var json = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:String]
                                            json!["mac"] = reqIP //add ip to json object as 'mac'
                                    
                                            //convert dictionary to string and replace [] with {}
                                            let deviceStr = String(describing: json!.description)
                                            let deviceRepl = deviceStr.replacingOccurrences(of: "\\[", with: "{", options: .regularExpression)
                                            let device = deviceRepl.replacingOccurrences(of: "\\]", with: "}", options: .regularExpression)
                                            unitList.append(device)
                                    
                                            // Pass unitList to js 'new_device' callback
                                            DispatchQueue.main.async {
                                                let unitListStr = self.unitListToJSString(array: unitList)
                                                self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].dataUpdate('new_device:[" + unitListStr + "]')")
                                                print("Units Array in loop \(i): ", unitList  )
                                            }
                                        }
                                    }
                                    }.resume()
                                group.leave()
                            }
                        }
                    }else{
                        self.getWiFiAddress()
                    }
                
                case "userdata":
                    if let arr = request.url?.host?.components(separatedBy: "--") {
                        let defaults = UserDefaults.standard
                        if arr[0] == "imperial" {
                            defaults.set(arr[1], forKey: defaultsKeys.imperial)
                            print("imperial set: ", arr[0], " | ", arr[1])
                        }
                        else if arr[0] == "locale" {
                            defaults.set(arr[1], forKey: defaultsKeys.locale)
                            print("locale set: ", arr[0]," | ", arr[1])
                        }else {
                            print("Data could not be saved: ", arr)
                        }
                    }
                
                case "requserdata":
                    //Load in imperial and locale settings
                    loadPreferences();
                    print("user data requested")
                
                case "savelog":
                    if let arr = request.url?.host?.components(separatedBy: "--") {
                        let log = arr[1];
                        let dirName = arr[0].removingPercentEncoding;
                        var isDir: ObjCBool = ObjCBool(false);
                        let str = log.removingPercentEncoding
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd_HH_mm_ss"
                        let documentsPath1 = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                        let logsPath = documentsPath1.appendingPathComponent("logs")
                        //change selectedUnitIp to name and replace spaces with undesecores
                        let machPath = logsPath?.appendingPathComponent(dirName!.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil))
                        let datePath = machPath?.appendingPathComponent(formatter.string(from: Date()));
                        //check for logs directory
                        if FileManager.default.fileExists(atPath: logsPath!.path, isDirectory:&isDir) {
                            
                        } else {
                            do {
                                try FileManager.default.createDirectory(atPath: logsPath!.path, withIntermediateDirectories: true, attributes: nil)
                            } catch let error as NSError {
                                NSLog("Unable to create logs directory \(error.debugDescription)")
                            }
                        }
                        //check for connected machine directory
                        if FileManager.default.fileExists(atPath: machPath!.path, isDirectory:&isDir) {
                            
                        } else {
                            do {
                                try FileManager.default.createDirectory(atPath: machPath!.path, withIntermediateDirectories: true, attributes: nil)
                            } catch let error as NSError {
                                NSLog("Unable to create machine directory \(error.debugDescription)")
                            }
                        }
                        
                        //save data to file
                        FileManager.default.createFile(atPath: datePath!.path, contents: str?.data(using: .utf8)!, attributes: nil)
                        NSLog("done saving . . . ")
                        self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].dataUpdate('log_saved')")
                        
                    }
                
            case "deletefile":
                print("delete file: ", request.url!.host!)
                //if deleteFile() has a second argument...
                if request.url?.host!.range(of:"--") != nil {
                    let arr = request.url?.host?.components(separatedBy: "--")
                    let dir = arr![0].removingPercentEncoding;
                    let file = arr![1].removingPercentEncoding;
                    let rootPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]);
                    let logsPath = rootPath.appendingPathComponent("logs/" + dir! + "/" + file!);
                    
                    do {
                        try FileManager.default.removeItem(at: logsPath!)
                        self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].dataUpdate('log_deleted')");
                        //self.webView.stringByEvaluatingJavaScript(from: "console.log("+strData!+")");
                    } catch {print("File could not be deleted:(")}
                }else{
                    //if only one argument was passed to deleteFile()
                    let dir = request.url?.host?.removingPercentEncoding;
                    let rootPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]);
                    let logsPath = rootPath.appendingPathComponent("logs/" + dir!);
                    
                    do {
                        try FileManager.default.removeItem(at: logsPath!)
                        self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].dataUpdate('log_deleted')");
                        //self.webView.stringByEvaluatingJavaScript(from: "console.log("+strData!+")");
                    } catch {print("Directory could not be deleted:(", logsPath!)}
                }
                
                
                case "reqlocallogs":
                    let rootPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]);
                    let logsPath = rootPath.appendingPathComponent("logs");
                    var localArray = [[String]]();
                    
                    do {
                        let files = try FileManager.default.contentsOfDirectory(atPath: logsPath!.path);
                        let data = try JSONSerialization.data(withJSONObject: files, options: JSONSerialization.WritingOptions(rawValue: 0));
                        let strData = String(data: data,encoding:.utf8);
                        let directories = replaceBrackets(str: strData!, replaceWith: "")
                        print("Directories: ", directories)

                        if directories != "" {
                            let dirArray = directories.components(separatedBy: ",")
                            for dir in dirArray {
                                //print(dir)
                                let logDir = "logs/" + dir.replacingOccurrences(of: "\"", with: "");
                                let rootPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]);
                                let logsPath = rootPath.appendingPathComponent(logDir);
                                do {
                                    let files = try FileManager.default.contentsOfDirectory(atPath: logsPath!.path);
                                    let data = try JSONSerialization.data(withJSONObject: files, options: JSONSerialization.WritingOptions(rawValue: 0));
                                    let strData = String(data: data,encoding:.utf8);
                                    let arr:Array = [dir.replacingOccurrences(of: "\"", with: ""), strData!]
                                    //print("StrData: ", strData!, "arr: ", arr)
                                    localArray.append(arr)
                                    
                                } catch {}
                            }
                            //print("Local array: ", localArray)
                            let localLogs = String(localArray.description);
                            //remove extra quotes and backslashes to pass to js
                            let a = localLogs?.replacingOccurrences(of: "\"[", with: "[");
                            let b = a?.replacingOccurrences(of: "]\"", with: "]");
                            let jsLocalLogs = b?.replacingOccurrences(of: "\\", with: "");
                            print("js local logs: ", jsLocalLogs!)
                        
                            self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].dataUpdate('local_logs:" + jsLocalLogs! + "')");
                        }else{
                            print("directories empty")
                            self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].dataUpdate('local_logs:[]')");
                        }
                    } catch {}
                    
                
                case "reqcontents":
                    //test case
                    let rootPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]);
                    let logsPath = rootPath.appendingPathComponent("logs/"+(request.url?.host?.replacingOccurrences(of: "--", with: "/"))!);
                    print("logsPath: ", logsPath!)
                    
                        let files = FileManager.default.contents(atPath: logsPath!.path);
                        //print(files);
                        //print(logsPath!.path);
                        //let data = try JSONSerialization.data(withJSONObject: files, options: JSONSerialization.WritingOptions(rawValue: 0));
                        let strData = String( data: files!,encoding:.utf8)
                        let encodedLog = strData?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    print("encoded: ", encodedLog!)
                       self.webView.stringByEvaluatingJavaScript(from: "window.vue.$children[0].dataUpdate('loc_log_file_data:"+encodedLog!+"')");
                       //self.webView.stringByEvaluatingJavaScript(from: "console.log("+strData!+")");
                
                
                default:
                    NSLog("Did not fit a case: \(request)")
            }
        }
        return true
    }

}

