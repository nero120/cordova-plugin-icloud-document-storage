@objc(iCloudDocStorage) class iCloudDocStorage : CDVPlugin {
    var pluginResult: CDVPluginResult?
    var ubiquitousContainerID: String?
    var ubiquitousContainerURL: URL?
    
    // initUbiquitousContainer: Checks user is signed into iCloud and initialises the desired ubiquitous container.
    @objc(initUbiquitousContainer:)
    func initUbiquitousContainer(command: CDVInvokedUrlCommand) {
        self.ubiquitousContainerID = command.arguments[0] as? String
        
        // If user is not signed into iCloud, return error
        if ((FileManager.default.ubiquityIdentityToken) == nil) {
            self.commandDelegate!.send(
                CDVPluginResult(
                    status: CDVCommandStatus_ERROR
                ),
                callbackId: command.callbackId
            )
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Initialise and store the ubiquitous container url
            self.ubiquitousContainerURL = self.getUbiquitousContainerURL(self.ubiquitousContainerID)
            
            if (self.ubiquitousContainerURL != nil) {
                NSLog((self.ubiquitousContainerURL?.absoluteString)!)
                
                self.pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK
                )
            }
            else {
                self.pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR
                )
            }
            
            self.commandDelegate!.send(
                self.pluginResult,
                callbackId: command.callbackId
            )
        }
    }
    
    
    // syncToCloud: Sends the file at the given local URL to the ubiquitous container for syncing to iCloud.
    @objc(syncToCloud:)
    func syncToCloud(command: CDVInvokedUrlCommand) {
        // Get the file to sync's url
        let fileURLArg = command.arguments[0] as? String
        
        if (fileURLArg != nil) {
            NSLog(fileURLArg!)
            
            // Convert fileUrl to URL
            let fileURL = URL.init(string: fileURLArg!)
            
            DispatchQueue.global(qos: .userInitiated).async {
                // Initialise and store the ubiquitous container url if necessary
                if (self.ubiquitousContainerURL == nil) {
                    self.ubiquitousContainerURL = self.getUbiquitousContainerURL(self.ubiquitousContainerID)
                }
                
                // Get the destination URL of the file within the iCloud ubiquitous container
                let fileUrlInUbiquitousContainer = self.ubiquitousContainerURL?
                    .appendingPathComponent("Documents")
                    .appendingPathComponent((fileURL?.lastPathComponent)!)
                
                do {
                    // Tell iOS to move the file to the ubiquitous container and sync to iCloud
                    try FileManager.default.setUbiquitous(
                        true,
                        itemAt: fileURL!,
                        destinationURL: fileUrlInUbiquitousContainer!)
                    
                    self.pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_OK
                    )
                }
                catch {
                    self.pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR
                    )
                }
                
                self.commandDelegate!.send(
                    self.pluginResult,
                    callbackId: command.callbackId
                )
            }
        }
        else {
            self.commandDelegate!.send(
                CDVPluginResult(
                    status: CDVCommandStatus_OK
                ),
                callbackId: command.callbackId
            )
        }
    }
    
    
    // getUbiquitousContainerURL: Initialises the ubiquitous container at the given container ID (or default if nil) and returns it's local URL.
    private func getUbiquitousContainerURL(_ containerId: String?) -> URL {
        return FileManager.default.url(forUbiquityContainerIdentifier: containerId)!
    }
}
