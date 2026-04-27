## Inicializar o projeto em desenvolvimento
1. Identificar o IP da maquina que vai rodar o proxy -> (ipconfig ou ip a)
2. Alterar o ip do arquivo config.dart
    ```
    const String mobileIp = "172.16.0.105";
    ```
3. Executar o Proxy.
4. Executar projeto em web:
    ```
    flutter run -d web-server --web-hostname 0.0.0.0  --web-port 8080
    ```
5. Executar projeto em outros dispositivos:
    ```
    flutter run
    ```