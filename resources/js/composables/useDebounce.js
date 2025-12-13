import { ref, onUnmounted } from 'vue';

export function useDebounce(fn, delay = 3000) {
    let timeoutId = null;
    const isPending = ref(false);

    const debouncedFn = (...args) => {
        isPending.value = true;
        
        if (timeoutId) {
            clearTimeout(timeoutId);
        }

        timeoutId = setTimeout(() => {
            fn(...args);
            isPending.value = false;
            timeoutId = null;
        }, delay);
    };

    const cancel = () => {
        if (timeoutId) {
            clearTimeout(timeoutId);
            timeoutId = null;
            isPending.value = false;
        }
    };

    onUnmounted(() => {
        cancel();
    });

    return {
        debouncedFn,
        cancel,
        isPending,
    };
}

