import { ref } from 'vue';

export function useAlert() {
    const alert = ref({
        type: 'success',
        show: false,
        message: '',
    });

    const callAlert = (type, message) => {
        alert.value.type = type;
        alert.value.message = message;
        alert.value.show = true;
        setTimeout(() => {
            alert.value.show = false;
        }, 4000);
    };

    return {
        alert,
        callAlert,
    };
}

