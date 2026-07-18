extends Node
signal schimba_poza_mouse(textura: Texture2D)

# Adăugăm linia asta ca să salvăm poza curentă în memorie
var textura_salvata: Texture2D = null

var cladiri = []
