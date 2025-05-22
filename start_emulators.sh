#!/bin/bash

echo "🚀 Iniciando emuladores Firebase para desenvolvimento local..."

# Para os emuladores se já estiverem rodando
pkill -f "firebase"

# Aguarda um momento
sleep 2

# Inicia os emuladores
echo "📱 Iniciando Firebase Auth Emulator (porta 9099)..."
echo "🔥 Iniciando Firestore Emulator (porta 8080)..."

firebase emulators:start --only auth,firestore --project=demo-vidaplus

echo "✅ Emuladores iniciados!"
echo "🌐 Firebase Auth: http://localhost:9099"
echo "📄 Firestore: http://localhost:8080"
echo "🎛️  Firebase UI: http://localhost:4000" 