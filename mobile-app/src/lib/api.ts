import axios from 'axios';

const API_BASE_URL = '192.168.1.12:8080';

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
});
