import { defineStore } from 'pinia';
import apiClient from '../api/client';

export const useDepartmentsStore = defineStore('departments', {
    state: () => ({
        departments: [],
        loading: false,
        error: null,
    }),

    getters: {
        getDepartmentById: (state) => (id) => {
            return state.departments.find(dep => dep.id === id);
        },
    },

    actions: {
        async fetchDepartments() {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.get('/departments');
                this.departments = response.data;
            } catch (error) {
                this.error = error.message || 'Ошибка при загрузке отделов';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async fetchDepartment(id) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.get(`/departments/${id}`);
                const index = this.departments.findIndex(d => d.id === id);
                if (index !== -1) {
                    this.departments[index] = response.data;
                } else {
                    this.departments.push(response.data);
                }
                return response.data;
            } catch (error) {
                this.error = error.message || 'Ошибка при загрузке отдела';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async createDepartment(data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.post('/departments', data);
                this.departments.push(response.data.data);
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при создании отдела';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async updateDepartment(id, data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.put(`/departments/${id}`, data);
                const index = this.departments.findIndex(d => d.id === id);
                if (index !== -1) {
                    this.departments[index] = response.data.data;
                }
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при обновлении отдела';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async deleteDepartment(id) {
            this.loading = true;
            this.error = null;
            try {
                await apiClient.delete(`/departments/${id}`);
                this.departments = this.departments.filter(d => d.id !== id);
            } catch (error) {
                this.error = error.message || 'Ошибка при удалении отдела';
                throw error;
            } finally {
                this.loading = false;
            }
        },
    },
});

