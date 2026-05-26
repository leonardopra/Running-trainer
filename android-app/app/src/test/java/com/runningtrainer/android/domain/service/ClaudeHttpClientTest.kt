package com.runningtrainer.android.domain.service

import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkConstructor
import io.mockk.unmockkConstructor
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.net.HttpURLConnection
import java.net.URL

class ClaudeHttpClientTest {

    @After
    fun tearDown() {
        unmockkConstructor(URL::class)
    }

    private fun setupMockConnection(statusCode: Int): HttpURLConnection {
        mockkConstructor(URL::class)
        val mockConn = mockk<HttpURLConnection>(relaxed = true)
        every { anyConstructed<URL>().openConnection() } returns mockConn
        every { mockConn.responseCode } returns statusCode
        return mockConn
    }

    @Test
    fun `call throws ClaudeApiException with isAuthError true on HTTP 401`() = runTest {
        setupMockConnection(401)
        val client = ClaudeHttpClient()

        var caught: ClaudeApiException? = null
        try {
            client.call("api-key", ClaudeRequest("prompt"))
        } catch (e: ClaudeApiException) {
            caught = e
        }

        assertNotNull(caught)
        assertTrue(caught!!.isAuthError)
    }

    @Test
    fun `call throws ClaudeApiException without isAuthError on HTTP 500`() = runTest {
        setupMockConnection(500)
        val client = ClaudeHttpClient()

        var caught: ClaudeApiException? = null
        try {
            client.call("api-key", ClaudeRequest("prompt"))
        } catch (e: ClaudeApiException) {
            caught = e
        }

        assertNotNull(caught)
        assertFalse(caught!!.isAuthError)
    }
}
