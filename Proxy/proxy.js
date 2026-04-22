const express = require("express");
const cors = require("cors");
const { createProxyMiddleware } = require("http-proxy-middleware");
const https = require("https");
const http = require("http");

const app = express();

app.use(cors());
app.use(express.json());

// Rota direta para login usando http nativo
app.post("/login-api", (req, res) => {
    console.log("\n📥 POST /login-api");
    console.log("   Body:", req.body);

    const postData = JSON.stringify(req.body);

    const options = {
        hostname: "back.educandus.com.br",
        port: 443,
        path: "/api/login",
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Content-Length": Buffer.byteLength(postData),
        },
        rejectUnauthorized: false, // Ignora erro de certificado
    };

    const proxyReq = https.request(options, (proxyRes) => {
        console.log(`   ✅ Status: ${proxyRes.statusCode}`);

        let data = "";
        proxyRes.on("data", (chunk) => {
            data += chunk;
        });

        proxyRes.on("end", () => {
            console.log(`   📦 Response: ${data.substring(0, 200)}`);
            res.status(proxyRes.statusCode).send(data);
        });
    });

    proxyReq.on("error", (error) => {
        console.error("   ❌ Erro:", error.message);
        res.status(500).json({ error: error.message });
    });

    proxyReq.write(postData);
    proxyReq.end();
});

// Proxy para as demais rotas
app.use("/api", createProxyMiddleware({
    target: "https://adrbackend.educandus.com.br",
    changeOrigin: true,
    secure: false,
    pathRewrite: {
        "^/api": "",
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`   🔄 API request para: ${proxyReq.path}`);
    },
}));

app.use("/omr", createProxyMiddleware({
    target: "https://omr-fast-api-render.onrender.com",
    changeOrigin: true,
    secure: false,
    pathRewrite: {
        "^/omr": "",
    },
    onProxyReq: (proxyReq, req, res) => {
        console.log(`   🔄 OMR request para: ${proxyReq.path}`);
    },
}));

const PORT = 3000;
app.listen(PORT, "0.0.0.0", () => {
    console.log("\n🚀 Proxy rodando:");
    console.log(`📍 Login: http://localhost:${PORT}/login-api`);
    console.log(`📍 API:   http://localhost:${PORT}/api`);
    console.log(`📍 OMR:   http://localhost:${PORT}/omr`);
    console.log(`\n📱 Mobile: SEU_IP:${PORT}\n`);
});