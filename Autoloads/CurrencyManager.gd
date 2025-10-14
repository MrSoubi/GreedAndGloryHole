extends Node

signal currency_changed(new_value: float)

# Gestion simple de la monnaie avec méthodes publiques
var currency: float :
    get: return currency
    set(value):
        if currency != value:
            currency = value
            emit_signal("currency_changed", currency)