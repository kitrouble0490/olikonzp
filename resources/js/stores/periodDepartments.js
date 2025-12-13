import { defineStore } from 'pinia';
import apiClient from '../api/client';

export const usePeriodDepartmentsStore = defineStore('periodDepartments', {
    state: () => ({
        periodDepartments: [],
        loading: false,
        error: null,
    }),

    getters: {
        getPeriodDepartmentById: (state) => (id) => {
            return state.periodDepartments.find(pd => pd.id === id);
        },
        getPeriodDepartmentsByPeriod: (state) => (periodId) => {
            return state.periodDepartments.filter(pd => pd.period_id === periodId);
        },
    },

    actions: {
        async createPeriodDepartment(data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.post('/period-departments', data);
                this.periodDepartments.push(response.data.data);
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при добавлении отдела в период';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async updatePeriodDepartment(id, data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.put(`/period-departments/${id}`, data);
                const index = this.periodDepartments.findIndex(pd => pd.id === id);
                if (index !== -1) {
                    this.periodDepartments[index] = response.data.data;
                }
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при обновлении периода-отдела';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async deletePeriodDepartment(id) {
            this.loading = true;
            this.error = null;
            try {
                await apiClient.delete(`/period-departments/${id}`);
                this.periodDepartments = this.periodDepartments.filter(pd => pd.id !== id);
            } catch (error) {
                this.error = error.message || 'Ошибка при удалении отдела из периода';
                throw error;
            } finally {
                this.loading = false;
            }
        },
    },
});

