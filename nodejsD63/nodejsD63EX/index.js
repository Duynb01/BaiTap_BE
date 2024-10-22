const express = require('express')
const bodyParser = require('body-parser')
const app = express()
app.use(bodyParser.json())
const port = 3000

const data = {
    "categories": [
        {
            "id": 1,
            "name": "Category 1",
            "short_name": "c1",
            "order_num": 1
        },
        {
            "id": 2,
            "name": "Category 2",
            "short_name": "c2",
            "order_num": 2
        }
    ],
    "products": [
        {
            "id": 1,
            "name": "Product 1",
            "category_id": 1,
            "order_num": 1
        },
        {
            "id": 2,
            "name": "Product 2",
            "category_id": 1,
            "order_num": 2
        },
        {
            "id": 3,
            "name": "Product 3",
            "category_id": 2,
            "order_num": 1
        }
    ]
}

let router = ['categories', 'products']

// get all

app.get(`/data/:string`, (req, res) => {
    const {string} = req.params
    if (router.includes(string)) {
        return res.send(data[`${string}`])
    }
})

// get one

app.get('/data/categories/:id', (req, res) => {
    const {id} = req.params
    res.send(data.categories.find(category => category.id === Number(id)))
})
app.get('/data/products/:id', (req, res) => {
    const {id} = req.params
    res.send(data.products.find(product => product.id === Number(id)))
})

// create one

app.post('/data/:string', (req, res)=>{
    const {string} = req.params
    const newItem = {...req.body, id: 999} // Hiện tại đang fix cứng id
    if(router.includes(string)){
        data[`${string}`].push(newItem)
    }
    return res.send(newItem)
})

// update

app.patch('/data/:string/:id', (req, res) => {
    const {string, id} = req.params
    const {name, order_num, short_name, category_id} = req.body
    if (router.includes(string)) {
        const itemOld = data[`${string}`].find(item => item.id === Number(id))
        if (name) itemOld.name = name;
        if (order_num) itemOld.order_num = order_num;
        if (short_name) itemOld.short_name = short_name;
        if (category_id) itemOld.category_id = category_id;
        return res.send(itemOld)
    }
})

// delete

app.delete('/data/:string/:id', (req, res)=>{
    const {string, id} = req.params
    if (router.includes(string)) {
        const indexItem = data[`${string}`].findIndex(item => item.id === Number(id))
        data[`${string}`].splice(indexItem,1)
        return res.send({msg: 'User have been deleted'})
    }
    res.send('Error! Not Found')
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})