## Inicializar o projeto
1. Executar o proxy
2. Rodar no PC:
    ```
    flutter run 
    ```
3.  Testar no celular:

    É necessário mudar os arquivos exam_service e api_config e trocar o endereço de localhost para o IP da suamaquina.
    ```
     flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
     ```
    
    Depois vá no celular e digite o IP da maquina com a porta 8080, ex:172.16.0.105:8080
