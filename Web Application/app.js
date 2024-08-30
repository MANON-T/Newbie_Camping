const express = require('express')
const path = require('path')
const app = express()
const router = require('./routes/myroute')
const port = 3000
const session = require('express-session');

const sessionConfig = {
    secret: 'secret',
    resave: true, // บันทึก session ทุกครั้งที่มีการร้องขอ
    saveUninitialized: true, // บันทึก session ทุกครั้งที่มีการร้องขอ โดยไม่คำนึงว่า session จะมีข้อมูลหรือไม่
    maxAge: 3600,
};

app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'ejs')
app.use(express.static(path.join(__dirname, 'public')))
app.use(express.urlencoded({ extended: true }))
app.use(session(sessionConfig));
app.use(express.json());
app.use(router)

app.listen(port, () => console.log(`Example app listening on port ${port}!`))