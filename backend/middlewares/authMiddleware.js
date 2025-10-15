const jwt = require('jsonwebtoken');

module.exports.authMiddleware = async(req, res, next) =>{
    const {accessToken} = req.cookies

    if (!accessToken) {
        return res.status(409).json({ error : 'Please Login First'})
    } else {
        try {
            const deCodeToken = await jwt.verify(accessToken,process.env.SECRET)
            req.role = deCodeToken.role
            req.id = deCodeToken.id
            req.userId = deCodeToken.id  // Add userId for consistency
            
            // Add safety check
            if (!req.id) {
                return res.status(401).json({ error: 'Invalid user session' })
            }
            
            next()            
        } catch (error) {
            console.log('Auth middleware error:', error.message)
            return res.status(409).json({ error : 'Please Login'})
        }        
    }

}