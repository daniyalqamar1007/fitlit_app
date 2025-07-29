"use client"

import { useRef, useState, useEffect, memo } from "react"
import { View, Text, TouchableOpacity, StyleSheet, Dimensions, ActivityIndicator, Alert } from "react-native"
import Modal from "react-native-modal"
import { WebView } from "react-native-webview"
import Icon from "react-native-vector-icons/Feather"
import { BlurView } from "expo-blur"
import * as Haptics from "expo-haptics"
import { colors, spacing, typography } from "../theme"
import { MetaPersonConfig } from "../config/metaperson"

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get("window")

interface MetaPersonModalProps {
  visible: boolean
  onAvatarCreated: (url: string) => void
  onClose: () => void
}

const MetaPersonModal = memo(({ visible, onAvatarCreated, onClose }: MetaPersonModalProps) => {
  const webViewRef = useRef<WebView>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [isAuthenticated, setIsAuthenticated] = useState(false)

  // Reset state when modal opens
  useEffect(() => {
    if (visible) {
      setIsLoading(true)
      setError(null)
      setIsAuthenticated(false)
    }
  }, [visible])

  // Inject MetaPerson JavaScript interface - exactly like Android version
  const injectedJavaScript = `
    (function() {
      // MetaPerson JavaScript Interface - matches Android WebAppInterface
      window.metapersonJsApi = {
        showToast: function(message) {
          window.ReactNativeWebView.postMessage(JSON.stringify({
            type: 'toast',
            message: message
          }));
        }
      };

      // Message handler - exactly like Android prepareJsApi()
      function onWindowMessage(evt) {
        if (evt.type === 'message') { 
          if (evt.data?.source === 'metaperson_creator') { 
            let data = evt.data; 
            let evtName = data?.eventName; 
            
            // Send to React Native
            window.ReactNativeWebView.postMessage(JSON.stringify({
              type: 'metaperson_event',
              eventName: evtName,
              data: data
            }));
            
            if (evtName === 'mobile_loaded') { 
              onMobileLoaded(evt, data); 
            } else if (evtName === 'model_exported') { 
              window.metapersonJsApi.showToast(evt.data.url);
            }
          } 
        } 
      }

      function onMobileLoaded(evt, data) {
        // Authentication message - matches Android exactly
        let authenticationMessage = {
          'eventName': 'authenticate',
          'clientId': '${MetaPersonConfig.CLIENT_ID}',
          'clientSecret': '${MetaPersonConfig.CLIENT_SECRET}',
          'exportTemplateCode': '',
        };
        evt.source.postMessage(authenticationMessage, '*');
        
        // Export parameters - matches Android exactly
        let exportParametersMessage = {
          'eventName': 'set_export_parameters',
          'format': 'glb',
          'lod': 1,
          'textureProfile': '2K.png'
        };
        evt.source.postMessage(exportParametersMessage, '*');
      }

      // Add event listener when DOM is ready
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
          window.addEventListener('message', onWindowMessage);
        });
      } else {
        window.addEventListener('message', onWindowMessage);
      }
    })();
    true; // Required for injected JavaScript
  `

  const handleMessage = (event: any) => {
    try {
      const data = JSON.parse(event.nativeEvent.data)

      switch (data.type) {
        case "metaperson_event":
          handleMetaPersonEvent(data.eventName, data.data)
          break
        case "toast":
          handleToast(data.message)
          break
        default:
          console.log("Unknown message type:", data.type)
      }
    } catch (err) {
      console.error("Error parsing WebView message:", err)
    }
  }

  const handleMetaPersonEvent = (eventName: string, data: any) => {
    console.log("MetaPerson Event:", eventName, data)

    switch (eventName) {
      case "mobile_loaded":
        setIsLoading(false)
        setIsAuthenticated(true)
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)
        break

      case "model_exported":
        if (data.url) {
          console.log("Avatar exported:", data.url)
          onAvatarCreated(data.url)
          Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success)
        }
        break

      case "authentication_failed":
        setError("Authentication failed. Please check your MetaPerson credentials.")
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error)
        break

      case "export_failed":
        setError("Failed to export avatar. Please try again.")
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error)
        break

      case "error":
        setError(data.message || "An error occurred while creating your avatar.")
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error)
        break

      default:
        console.log("Unhandled MetaPerson event:", eventName)
    }
  }

  const handleToast = (message: string) => {
    console.log("MetaPerson Toast:", message)

    // Show native alert for avatar export URL (like Android toast)
    if (message.includes("http")) {
      Alert.alert("Avatar Created Successfully!", `Your avatar has been exported and is ready to use.`, [
        { text: "OK", style: "default" },
      ])
    }
  }

  const handleError = (syntheticEvent: any) => {
    const { nativeEvent } = syntheticEvent
    console.error("WebView error:", nativeEvent)
    setError("Failed to load MetaPerson Creator. Please check your internet connection.")
    setIsLoading(false)
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error)
  }

  const handleLoadEnd = () => {
    console.log("WebView loaded successfully")
    // Don't set loading to false here - wait for mobile_loaded event
  }

  const handleLoadStart = () => {
    console.log("WebView loading started")
    setIsLoading(true)
    setError(null)
  }

  const handleRetry = () => {
    setError(null)
    setIsLoading(true)
    setIsAuthenticated(false)
    webViewRef.current?.reload()
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium)
  }

  const handleClose = () => {
    setIsLoading(true)
    setError(null)
    setIsAuthenticated(false)
    onClose()
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)
  }

  return (
    <Modal
      isVisible={visible}
      style={styles.modal}
      animationIn="slideInUp"
      animationOut="slideOutDown"
      backdropOpacity={0.7}
      onBackdropPress={handleClose}
      onBackButtonPress={handleClose}
      avoidKeyboard={true}
    >
      <BlurView intensity={20} style={styles.container}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Create Your Avatar</Text>
          <View style={styles.headerRight}>
            {isAuthenticated && (
              <View style={styles.statusIndicator}>
                <View style={styles.statusDot} />
                <Text style={styles.statusText}>Connected</Text>
              </View>
            )}
            <TouchableOpacity style={styles.closeButton} onPress={handleClose} activeOpacity={0.8}>
              <Icon name="x" size={24} color={colors.textSecondary} />
            </TouchableOpacity>
          </View>
        </View>

        {/* Content */}
        <View style={styles.content}>
          {error ? (
            <View style={styles.errorContainer}>
              <Icon name="alert-circle" size={48} color={colors.error} />
              <Text style={styles.errorTitle}>Oops! Something went wrong</Text>
              <Text style={styles.errorText}>{error}</Text>
              <TouchableOpacity style={styles.retryButton} onPress={handleRetry} activeOpacity={0.8}>
                <Icon name="refresh-cw" size={16} color={colors.white} />
                <Text style={styles.retryButtonText}>Try Again</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <>
              {isLoading && (
                <View style={styles.loadingContainer}>
                  <ActivityIndicator size="large" color={colors.primary} />
                  <Text style={styles.loadingText}>Loading MetaPerson Creator...</Text>
                  <Text style={styles.loadingSubtext}>This may take a few moments</Text>
                </View>
              )}

              <WebView
                ref={webViewRef}
                source={{ uri: MetaPersonConfig.WEBAPP_URL }}
                style={[styles.webView, isLoading && styles.hidden]}
                onMessage={handleMessage}
                onError={handleError}
                onLoadEnd={handleLoadEnd}
                onLoadStart={handleLoadStart}
                injectedJavaScript={injectedJavaScript}
                javaScriptEnabled={true}
                domStorageEnabled={true}
                allowsInlineMediaPlayback={true}
                mediaPlaybackRequiresUserAction={false}
                allowsFullscreenVideo={true}
                allowsBackForwardNavigationGestures={false}
                bounces={false}
                scrollEnabled={true}
                startInLoadingState={true}
                mixedContentMode="compatibility"
                thirdPartyCookiesEnabled={true}
                sharedCookiesEnabled={true}
                userAgent="FitLit-Mobile/1.0"
              />
            </>
          )}
        </View>

        {/* Instructions */}
        {!error && (
          <View style={styles.instructions}>
            <View style={styles.instructionRow}>
              <Icon name="camera" size={16} color={colors.primary} />
              <Text style={styles.instructionsText}>Take a selfie or choose from templates</Text>
            </View>
            <View style={styles.instructionRow}>
              <Icon name="edit-3" size={16} color={colors.primary} />
              <Text style={styles.instructionsText}>Customize your avatar's appearance</Text>
            </View>
            <View style={styles.instructionRow}>
              <Icon name="download" size={16} color={colors.primary} />
              <Text style={styles.instructionsText}>Export when you're happy with the result</Text>
            </View>
          </View>
        )}
      </BlurView>
    </Modal>
  )
})

const styles = StyleSheet.create({
  modal: {
    margin: 0,
    justifyContent: "flex-end",
  },
  container: {
    height: SCREEN_HEIGHT * 0.95,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    overflow: "hidden",
    backgroundColor: "rgba(255, 255, 255, 0.95)",
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  title: {
    fontSize: typography.h2.fontSize,
    fontWeight: typography.h2.fontWeight as any,
    color: colors.primary,
  },
  headerRight: {
    flexDirection: "row",
    alignItems: "center",
  },
  statusIndicator: {
    flexDirection: "row",
    alignItems: "center",
    marginRight: spacing.md,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: colors.success,
    marginRight: spacing.xs,
  },
  statusText: {
    fontSize: typography.caption.fontSize,
    color: colors.success,
    fontWeight: "600",
  },
  closeButton: {
    padding: spacing.sm,
  },
  content: {
    flex: 1,
    position: "relative",
  },
  webView: {
    flex: 1,
    backgroundColor: colors.white,
  },
  hidden: {
    opacity: 0,
  },
  loadingContainer: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: colors.white,
  },
  loadingText: {
    marginTop: spacing.md,
    fontSize: typography.body.fontSize,
    color: colors.textPrimary,
    fontWeight: "600",
  },
  loadingSubtext: {
    marginTop: spacing.xs,
    fontSize: typography.caption.fontSize,
    color: colors.textSecondary,
  },
  errorContainer: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    paddingHorizontal: spacing.lg,
  },
  errorTitle: {
    fontSize: typography.h3.fontSize,
    fontWeight: typography.h3.fontWeight as any,
    color: colors.textPrimary,
    marginTop: spacing.md,
    marginBottom: spacing.sm,
  },
  errorText: {
    fontSize: typography.body.fontSize,
    color: colors.error,
    textAlign: "center",
    marginBottom: spacing.lg,
    lineHeight: 22,
  },
  retryButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: colors.primary,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderRadius: 12,
  },
  retryButtonText: {
    color: colors.white,
    fontSize: typography.button.fontSize,
    fontWeight: typography.button.fontWeight as any,
    marginLeft: spacing.xs,
  },
  instructions: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    backgroundColor: colors.primaryLight,
    borderTopWidth: 1,
    borderTopColor: colors.border,
  },
  instructionRow: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: spacing.sm,
  },
  instructionsText: {
    fontSize: typography.caption.fontSize,
    color: colors.primary,
    marginLeft: spacing.sm,
    flex: 1,
  },
})

export default MetaPersonModal
