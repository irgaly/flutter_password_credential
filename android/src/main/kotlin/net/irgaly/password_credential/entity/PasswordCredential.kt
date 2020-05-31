package net.irgaly.password_credential.entity

data class PasswordCredential (
        val id: String,
        val password: String,
        val name: String?,
        val iconUrl: String?
)
