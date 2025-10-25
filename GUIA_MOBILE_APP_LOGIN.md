# Guía de Desarrollo - Login de App Móvil (Expo + React Native)

Esta guía documenta los pasos ya automatizados por el script y cómo probar el login.

## 1) Rama de trabajo
- Rama creada: feat/mobile-app-login

## 2) Proyecto Expo
- Carpeta: mobile-app
- Dependencias instaladas:
  - axios
  - expo-secure-store

## 3) Archivos generados
- mobile-app/src/lib/api.ts (API_BASE_URL = 192.168.1.12:8080)
- mobile-app/src/screens/LoginScreen.tsx
- mobile-app/App.tsx

## 4) Probar la app
Desde la carpeta "mobile-app":
```bash
cd mobile-app
npx expo start
```

- Emulador Android: presiona "a"
- Expo Go (celular en misma red): escanea el QR

Si tu backend corre en tu PC:
- Emulador Android: usa http://10.0.2.2:<PUERTO>
- Dispositivo físico: usa la IP local de tu PC (por ejemplo, http://192.168.1.10:<PUERTO>)

## 5) Commit y Push
Este script ya realizó:
```
git add mobile-app .github/PULL_REQUEST_TEMPLATE_MOBILE_LOGIN.md GUIA_MOBILE_APP_LOGIN.md
git commit -m "feat(mobile): Initialize Expo app with login (axios + secure-store) and docs"
git push -u origin feat/mobile-app-login
```

## 6) Pull Request
Crea el PR en GitHub y usa la plantilla generada en .github.
