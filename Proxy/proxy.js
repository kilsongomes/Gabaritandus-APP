const express = require("express");
const cors = require("cors");
const { createProxyMiddleware } = require("http-proxy-middleware");

const app = express();

app.use(cors());

/**
 * 🔵 Backend principal (Educandus)
 */
app.use(
    "/api",
    createProxyMiddleware({
        target: "https://adrbackend.educandus.com.br",
        changeOrigin: true,
        secure: false,
        pathRewrite: {
            "^/api": "",
        },
    })
);

/**
 * 🟣 Backend de processamento de imagem (OMR)
 */
app.use(
    "/omr",
    createProxyMiddleware({
        target: "https://omr-fast-api-render.onrender.com",
        changeOrigin: true,
        secure: false,
        pathRewrite: {
            "^/omr": "",
        },
    })
);

app.listen(3000, () => {
    console.log("🚀 Proxy rodando:");
    console.log("👉 API: http://localhost:3000/api");
    console.log("👉 OMR: http://localhost:3000/omr");
});