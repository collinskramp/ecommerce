import io from 'socket.io-client'

export const overrideStyle = {
    display : 'flex', 
    margin : '0 auto',
    height: '24px',
    justifyContent : 'center',
    alignItems : 'center'
}

// Auto-detect socket URL
const getSocketURL = () => {
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        return 'http://localhost:5001'
    }
    return `http://${window.location.hostname}:5001`
}

export const socket = io(getSocketURL())