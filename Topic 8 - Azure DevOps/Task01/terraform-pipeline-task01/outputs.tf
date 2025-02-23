output "uploaded_files" {
  description = "List of files uploaded to the container"
  value       = [for file in azurerm_storage_blob.files : file.name]
}