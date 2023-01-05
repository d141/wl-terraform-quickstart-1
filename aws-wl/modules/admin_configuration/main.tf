// Admin configuration
// Prevent exporting notebooks, uploading data through UI, using web terminal, and downloading results by default

resource "databricks_workspace_conf" "just_config_map" {
    custom_config = {
        "enableExportNotebook": "false", 
        "enableUploadDataUis": "false", 
        "enableWebTerminal": "false", 
        "enableResultsDownloading" = "false"
    }
}