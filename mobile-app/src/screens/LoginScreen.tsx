import React, { useState } from 'react';
import {
  View, Text, TextInput, Button, ActivityIndicator, StyleSheet, Alert
} from 'react-native';
import * as SecureStore from 'expo-secure-store';
import { api } from '../lib/api';

export default function LoginScreen() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleLogin = async () => {
    setLoading(true); setError(null);
    try {
      const res = await api.post('/api/v1/auth/login', { username, password });
      const token = res.data?.token;
      if (!token) throw new Error('No se recibió token.');
      await SecureStore.setItemAsync('authToken', token);
      Alert.alert('Login Exitoso');
      // TODO: Navegar a la pantalla principal (react-navigation)
      // navigation.navigate('Home');
    } catch (e: any) {
      const msg = e?.response?.data?.message || e?.message || 'Error al iniciar sesión';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Iniciar Sesión</Text>
      <TextInput
        style={styles.input}
        placeholder="Usuario o Email"
        autoCapitalize="none"
        value={username}
        onChangeText={setUsername}
      />
      <TextInput
        style={styles.input}
        placeholder="Contraseña"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      {error && <Text style={styles.error}>{error}</Text>}
      {loading ? <ActivityIndicator /> : <Button title="Ingresar" onPress={handleLogin} />}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, justifyContent: 'center' },
  title: { fontSize: 24, marginBottom: 20, fontWeight: 'bold' },
  input: { borderBottomWidth: 1, marginBottom: 16, padding: 8 },
  error: { color: 'red', marginBottom: 10 }
});
