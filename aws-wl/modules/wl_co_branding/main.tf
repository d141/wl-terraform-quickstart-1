// WL Co-Branding Configuration

resource "databricks_workspace_conf" "just_config_map" {
    custom_config = {
        "sidebarLogoActive": var.sidebarLogoActive, 
        "sidebarLogoInactive": var.sidebarLogoInactive, 
        "sidebarLogoText": var.sidebarLogoText, 

        "homePageWelcomeMessage": var.homePageWelcomeMessage, 
        "homePageLogo": var.homePageLogo, 
        "homePageLogoWidth": var.homePageLogoWidth,  

        "productName": var.productName, 
        "loginLogo": var.loginLogo, 
        "loginLogoWidth":var.loginLogoWidth,

        "customReferences": file("${path.module}/customReferences.json")
    }
}