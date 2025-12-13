import { defineStore } from 'pinia';
import apiClient from '../api/client';

export const usePeriodsStore = defineStore('periods', {
    state: () => ({
        periods: [],
        months: {},
        loading: false,
        error: null,
    }),

    getters: {
        getPeriodById: (state) => (id) => {
            return state.periods.find(p => p.id === id);
        },
        getPeriodsByPage: (state) => (pageId) => {
            return state.periods.filter(p => p.page_id === pageId);
        },
    },

    actions: {
        async fetchMonths() {
            try {
                const response = await apiClient.get('/periods/months/list');
                this.months = response.data;
                return response.data;
            } catch (error) {
                this.error = error.message || 'Ошибка при загрузке месяцев';
                throw error;
            }
        },

        async fetchPeriods() {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.get('/periods');
                this.periods = response.data;
            } catch (error) {
                this.error = error.message || 'Ошибка при загрузке периодов';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async fetchPeriod(id) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.get(`/periods/${id}`);
                const index = this.periods.findIndex(p => p.id === id);
                if (index !== -1) {
                    this.periods[index] = response.data;
                } else {
                    this.periods.push(response.data);
                }
                return response.data;
            } catch (error) {
                this.error = error.message || 'Ошибка при загрузке периода';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async createPeriod(data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.post('/periods', data);
                this.periods.push(response.data.data);
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при создании периода';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async updatePeriod(id, data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.put(`/periods/${id}`, data);
                const index = this.periods.findIndex(p => p.id === id);
                if (index !== -1) {
                    this.periods[index] = response.data.data;
                }
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при обновлении периода';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async deletePeriod(id) {
            this.loading = true;
            this.error = null;
            try {
                await apiClient.delete(`/periods/${id}`);
                this.periods = this.periods.filter(p => p.id !== id);
            } catch (error) {
                this.error = error.message || 'Ошибка при удалении периода';
                throw error;
            } finally {
                this.loading = false;
            }
        },
    },
});

