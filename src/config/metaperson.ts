// MetaPerson Configuration - matches Android credentials.xml
export const MetaPersonConfig = {
  // Replace these with your actual MetaPerson credentials
  // Get them from: https://accounts.avatarsdk.com/developer/
  CLIENT_ID: "YOUR_CLIENT_ID_HERE", // Replace with your actual client ID
  CLIENT_SECRET: "YOUR_CLIENT_SECRET_HERE", // Replace with your actual client secret

  // MetaPerson Web App URL - matches Android
  WEBAPP_URL: "https://mobile.metaperson.avatarsdk.com/",

  // Export settings - matches Android WebUiActivity
  EXPORT_FORMAT: "glb",
  EXPORT_LOD: 1,
  EXPORT_TEXTURE_PROFILE: "2K.png",

  // Template settings
  EXPORT_TEMPLATE_CODE: "",

  // Timeout settings
  LOAD_TIMEOUT: 30000, // 30 seconds
  EXPORT_TIMEOUT: 60000, // 60 seconds
}

// Validation function
export const validateMetaPersonConfig = (): boolean => {
  if (
    MetaPersonConfig.CLIENT_ID === "YOUR_CLIENT_ID_HERE" ||
    MetaPersonConfig.CLIENT_SECRET === "YOUR_CLIENT_SECRET_HERE"
  ) {
    console.error("⚠️  MetaPerson credentials not configured!")
    console.error("Please update CLIENT_ID and CLIENT_SECRET in src/config/metaperson.ts")
    console.error("Get your credentials from: https://accounts.avatarsdk.com/developer/")
    return false
  }
  return true
}
