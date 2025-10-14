import axios from "axios";

// Get backend URL from environment or auto-detect
const getBackendURL = () => {
    // If we're on localhost, use localhost backend
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        return 'http://localhost:5001'
    }
    // Otherwise use the same host as frontend but port 5001
    return `http://${window.location.hostname}:5001`
}

const api = axios.create({
    baseURL : `${getBackendURL()}/api`
})

export default api