import { defineStore } from 'pinia';
import apiClient from '../api/client';

export const usePeriodItemsStore = defineStore('periodItems', {
    state: () => ({
        periodItems: [],
        loading: false,
        error: null,
    }),

    getters: {
        getPeriodItemById: (state) => (id) => {
            return state.periodItems.find(pi => pi.id === id);
        },
        getPeriodItemsByPeriodDepartment: (state) => (periodDepartmentId) => {
            return state.periodItems.filter(pi => pi.period_department_id === periodDepartmentId);
        },
    },

    actions: {
        async updatePeriodItem(id, data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.put(`/period-items/${id}`, data);
                const index = this.periodItems.findIndex(pi => pi.id === id);
                if (index !== -1) {
                    this.periodItems[index] = response.data.data;
                } else {
                    this.periodItems.push(response.data.data);
                }
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при обновлении дня периода';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async toggleEmployee(periodItemId, employeeId) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.post(`/period-items/${periodItemId}/toggle-employee`, {
                    employee_id: employeeId,
                });
                const index = this.periodItems.findIndex(pi => pi.id === periodItemId);
                if (index !== -1) {
                    this.periodItems[index] = response.data.data;
                }
                return response.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при изменении сотрудника';
                throw error;
            } finally {
                this.loading = false;
            }
        },
    },
});

