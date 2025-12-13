import { defineStore } from 'pinia';
import apiClient from '../api/client';

export const usePagesStore = defineStore('pages', {
    state: () => ({
        pages: [],
        currentPage: null,
        loading: false,
        error: null,
    }),

    getters: {
        getPageById: (state) => (id) => {
            return state.pages.find(page => page.id === id);
        },
    },

    actions: {
        async fetchPages() {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.get('/pages');
                this.pages = response.data;
            } catch (error) {
                this.error = error.message || 'Ошибка при загрузке страниц';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async fetchPage(id) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.get(`/pages/${id}`);
                this.currentPage = response.data;
                // Обновляем страницу в списке
                const index = this.pages.findIndex(p => p.id === id);
                if (index !== -1) {
                    this.pages[index] = response.data;
                } else {
                    this.pages.push(response.data);
                }
                return response.data;
            } catch (error) {
                this.error = error.message || 'Ошибка при загрузке страницы';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async createPage(data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.post('/pages', data);
                this.pages.push(response.data.data);
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при создании страницы';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async updatePage(id, data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.put(`/pages/${id}`, data);
                const index = this.pages.findIndex(p => p.id === id);
                if (index !== -1) {
                    this.pages[index] = response.data.data;
                }
                if (this.currentPage?.id === id) {
                    this.currentPage = response.data.data;
                }
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при обновлении страницы';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async deletePage(id) {
            this.loading = true;
            this.error = null;
            try {
                await apiClient.delete(`/pages/${id}`);
                this.pages = this.pages.filter(p => p.id !== id);
                if (this.currentPage?.id === id) {
                    this.currentPage = null;
                }
            } catch (error) {
                this.error = error.message || 'Ошибка при удалении страницы';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        setCurrentPage(page) {
            this.currentPage = page;
        },
    },
});

