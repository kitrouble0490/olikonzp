import { defineStore } from 'pinia';
import apiClient from '../api/client';

export const useAuthStore = defineStore('auth', {
    state: () => ({
        user: null,
        authenticated: false,
        loading: false,
        error: null,
    }),

    getters: {
        isAuthenticated: (state) => state.authenticated && state.user !== null,
    },

    actions: {
        async login(login, password) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.post('/auth/login', {
                    login,
                    password,
                });
                
                if (response.data.success) {
                    this.user = response.data.user;
                    this.authenticated = true;
                    return true;
                }
                return false;
            } catch (error) {
                this.error = error.response?.data?.message || error.message || 'Ошибка при входе';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async logout() {
            this.loading = true;
            try {
                await apiClient.post('/auth/logout');
                this.user = null;
                this.authenticated = false;
            } catch (error) {
                console.error('Ошибка при выходе:', error);
            } finally {
                this.loading = false;
            }
        },

        async checkAuth() {
            try {
                const response = await apiClient.get('/auth/check');
                if (response.data.authenticated) {
                    this.user = response.data.user;
                    this.authenticated = true;
                    return true;
                } else {
                    this.user = null;
                    this.authenticated = false;
                    return false;
                }
            } catch (error) {
                this.user = null;
                this.authenticated = false;
                return false;
            }
        },
    },
});
