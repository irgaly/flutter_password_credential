package net.irgaly.password_credential.entity

import kotlinx.serialization.Serializable

@Serializable
data class PasswordCredential (
        val id: String,
        val password: String,
        val name: String?,
        val iconUrl: String?
)
