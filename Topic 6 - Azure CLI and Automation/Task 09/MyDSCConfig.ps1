configuration MyDSCConfig {
    # Import the required DSC resources
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost" {
        # Ensure the Web-Server (IIS) feature is installed
        WindowsFeature WebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        # Ensure the configuration file exists with predefined content
        File ConfigFile {
            Ensure          = "Present"
            DestinationPath = "C:\inetpub\wwwroot\config.xml"
            Contents        = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <appSettings>
        <add key="Setting1" value="Value1" />
    </appSettings>
</configuration>
"@
            DependsOn       = "[WindowsFeature]WebServer"
        }

        # Ensure the w3svc service is always running
        Service W3SVC {
            Name        = "W3SVC"
            Ensure      = "Present"
            State       = "Running"
            DependsOn   = "[WindowsFeature]WebServer"
        }
    }
}