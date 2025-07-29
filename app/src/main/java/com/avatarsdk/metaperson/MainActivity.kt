package com.avatarsdk.metaperson

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.avatarsdk.metaperson.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    
    companion object {
        private const val TAG = "MainActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        try {
            Log.d(TAG, "MainActivity onCreate started")
            
            binding = ActivityMainBinding.inflate(layoutInflater)
            setContentView(binding.root)

            binding.createButton.setOnClickListener {
                Log.d(TAG, "Create button clicked")
                openMetapersonCreator()
            }
            
            binding.mailButton.setOnClickListener {
                Log.d(TAG, "Mail button clicked")
                sendFeedbackEmail()
            }
            
            Log.d(TAG, "MainActivity onCreate completed successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error in MainActivity onCreate", e)
        }
    }

    private fun openMetapersonCreator() {
        try {
            val intent = Intent(this, WebUiActivity::class.java)
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening MetaPerson creator", e)
        }
    }
    
    private fun sendFeedbackEmail() {
        try {
            val emailIntent = Intent(Intent.ACTION_SENDTO).apply {
                data = Uri.parse("mailto:support@avatarsdk.com")
                putExtra(Intent.EXTRA_SUBJECT, "FitLit App Feedback")
            }
            
            if (emailIntent.resolveActivity(packageManager) != null) {
                startActivity(Intent.createChooser(emailIntent, "Send feedback"))
            } else {
                Log.w(TAG, "No email app available")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error sending feedback email", e)
        }
    }
}
