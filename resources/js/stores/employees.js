import { defineStore } from 'pinia';
import apiClient from '../api/client';

export const useEmployeesStore = defineStore('employees', {
    state: () => ({
        employees: [],
        loading: false,
        error: null,
    }),

    getters: {
        getEmployeeById: (state) => (id) => {
            return state.employees.find(emp => emp.id === id);
        },
        getEmployeesByDepartment: (state) => (departmentId) => {
            return state.employees.filter(emp => emp.department_id === departmentId);
        },
    },

    actions: {
        async fetchEmployees() {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.get('/employees');
                this.employees = response.data;
            } catch (error) {
                this.error = error.message || 'Ошибка при загрузке сотрудников';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async fetchEmployee(id) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.get(`/employees/${id}`);
                const index = this.employees.findIndex(e => e.id === id);
                if (index !== -1) {
                    this.employees[index] = response.data;
                } else {
                    this.employees.push(response.data);
                }
                return response.data;
            } catch (error) {
                this.error = error.message || 'Ошибка при загрузке сотрудника';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async createEmployee(data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.post('/employees', data);
                this.employees.push(response.data.data);
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при создании сотрудника';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async updateEmployee(id, data) {
            this.loading = true;
            this.error = null;
            try {
                const response = await apiClient.put(`/employees/${id}`, data);
                const index = this.employees.findIndex(e => e.id === id);
                if (index !== -1) {
                    this.employees[index] = response.data.data;
                }
                return response.data.data;
            } catch (error) {
                this.error = error.errors || error.message || 'Ошибка при обновлении сотрудника';
                throw error;
            } finally {
                this.loading = false;
            }
        },

        async deleteEmployee(id) {
            this.loading = true;
            this.error = null;
            try {
                await apiClient.delete(`/employees/${id}`);
                this.employees = this.employees.filter(e => e.id !== id);
            } catch (error) {
                this.error = error.message || 'Ошибка при удалении сотрудника';
                throw error;
            } finally {
                this.loading = false;
            }
        },
    },
});

