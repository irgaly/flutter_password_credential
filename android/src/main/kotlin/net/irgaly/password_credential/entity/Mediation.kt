package net.irgaly.password_credential.entity

import kotlinx.serialization.Serializable

@Serializable
enum class Mediation {
    Silent,
    Optional,
    Required
}

fun mediationFrom(name: String): Mediation? {
    return Mediation.values().firstOrNull { it.name == name }
}

