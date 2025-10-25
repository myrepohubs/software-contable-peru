## Título: Feat(Mobile): Login MVP

### Descripción
Este PR añade la app móvil base con Expo y una pantalla de Login que autentica contra la API y guarda el token en `expo-secure-store`.

### Checklist de Cambios
- [ ] Proyecto Expo `mobile-app` creado (TypeScript)
- [ ] Configuración de axios y `API_BASE_URL`
- [ ] Pantalla `LoginScreen.tsx` (autenticación + almacenamiento seguro)
- [ ] Manejo de errores de credenciales y de red

### Instrucciones para pruebas (emulador o dispositivo)
1. Configura la URL de la API en `src/lib/api.ts`:
   - Emulador Android: `http://10.0.2.2:<PUERTO>`
   - Dispositivo físico: `http://IP_LOCAL_PC:<PUERTO>`
2. En `mobile-app`, ejecuta `npx expo start`.
3. Abre la app en:
   - Emulador Android (tecla 'a' en la consola de Expo)
   - Dispositivo físico con Expo Go (escanea el QR)
4. Ingresa credenciales válidas y confirma que se guarda el token.
5. Prueba credenciales inválidas y verifica el mensaje de error.
6. (Opcional) Reinicia la app y verifica persistencia del token si aplica.

### Checklist de Aceptación (QA)
- [ ] Login exitoso guarda token en `expo-secure-store`.
- [ ] Mensaje de error claro ante credenciales inválidas.
- [ ] Manejo de error de red (API caída o URL incorrecta).
- [ ] Configuración correcta de `API_BASE_URL` (emulador vs. dispositivo).
- [ ] Probado en:
  - [ ] Emulador Android
  - [ ] Dispositivo físico con Expo Go
