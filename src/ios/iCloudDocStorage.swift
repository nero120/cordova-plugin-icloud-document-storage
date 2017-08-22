@objc(iCloudDocStorage) class iCloudDocStorage : CDVPlugin {
    var ubiquitousContainerURL: URL?
    
    @objc(initUbiquitousContainer:)
    func initUbiquitousContainer(command: CDVInvokedUrlCommand) {
        DispatchQueue.global(qos: .userInitiated).async {
            let containerId = command.arguments[0] as? String
            var pluginResult: CDVPluginResult
            
            // Initialise and store the ubiquitous container url
            self.ubiquitousContainerURL = self.getUbiquitousContainerURL(containerId)
            
            if (self.ubiquitousContainerURL != nil) {
                NSLog((self.ubiquitousContainerURL?.absoluteString)!)
                
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK
                )
            }
            else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR
                )
            }
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        }
    }
    
    @objc(syncToCloud:)
    func syncToCloud(command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult?
        
        // Get the file to sync's url
        let fileURLArg = command.arguments[0] as? String
        
        if (fileURLArg != nil) {
            NSLog(fileURLArg!)
            
            // Convert fileUrl to URL
            let fileURL = URL.init(string: fileURLArg!)
            
            DispatchQueue.global(qos: .userInitiated).async {
                // Initialise and store the ubiquitous container url if necessary
                if (self.ubiquitousContainerURL == nil) {
                    self.ubiquitousContainerURL = self.getUbiquitousContainerURL(nil)
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
                    
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_OK
                    )
                }
                catch {
                    pluginResult = CDVPluginResult(
                        status: CDVCommandStatus_ERROR
                    )
                }
                
                self.commandDelegate!.send(
                    pluginResult,
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
    
    private func getUbiquitousContainerURL(_ containerId: String?) -> URL {
        return FileManager.default.url(forUbiquityContainerIdentifier: containerId)!
    }
}