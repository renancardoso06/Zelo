# Zelo

App de marketplace de serviços domésticos (faxina, cuidador, manutenção etc), feito pra Fase 4 da FIAP.

Renan Cardoso da Costa - RM 557918
Victor Vieira Borges - RM 557922

## rodando o projeto

flutter pub get
flutter run

precisa ter um emulador aberto ou celular conectado. testamos no Android, não chegamos a testar no iOS.

## telas

login, home, busca, perfil do prestador, agendar serviço, meus pedidos e mapa.

navegação é por rotas nomeadas (named routes), estado fica no Provider, e os pedidos/login ficam salvos no SharedPreferences pra não perder quando fecha o app.

## integração com o backend (zelo-backend)

Login, cadastro e a lista de pedidos agora conversam de verdade com o backend Spring Boot (repositório `zelo-backend`), em vez de dados mockados.

- `lib/services/api_client.dart` — cliente HTTP central (`ApiClient`). Resolve a base URL automaticamente (`http://10.0.2.2:8080` no emulador Android, `http://localhost:8080` em desktop/web/iOS), injeta o header `Authorization: Bearer {token}` em toda chamada autenticada (token lido do `SharedPreferences`) e converte qualquer erro HTTP (400 de validação, 401, 403, 404, 422, 500 — conforme o `GlobalExceptionHandler` do backend) numa `ApiException` com mensagem pronta pra mostrar na tela. Pra apontar pra outro endereço sem mudar código: `flutter run --dart-define=API_BASE_URL=http://SEU_IP:8080`.
- `lib/models/usuario.dart` e `lib/models/pedido.dart` — modelos que espelham os DTOs reais do backend (`UsuarioResponseDTO`, `PedidoResponseDTO`, `ServicoResponseDTO`).
- `lib/providers/app_provider.dart` — `login()` e `registrar()` chamam `POST /auth/login` e `POST /auth/registrar` de verdade e salvam o token + usuário retornado no `SharedPreferences`; `fetchPedidos()` chama `GET /pedidos` com o token salvo (força logout automático se der 401).
- `lib/screens/login_screen.dart` — cadastro agora pede os campos que o backend exige (nome, tipo Cliente/Prestador, e-mail, senha, telefone e endereço opcionais) e mostra os erros reais da API (ex: e-mail já cadastrado, senha curta, credenciais inválidas) num snackbar.
- `lib/screens/orders_screen.dart` — a tela "Meus Pedidos" chama `GET /pedidos` de verdade, com loading, erro (com botão "tentar novamente") e lista vazia. Como o backend ainda não tem endpoint de criação de pedido conectado ao fluxo de agendamento do app, os agendamentos feitos pela tela "Agendar Serviço" (que ainda usam dados mockados dos prestadores) continuam aparecendo numa seção separada "Agendamentos (demo local)" no topo da tela — é por ali que o AI Logistics Extension (tracking) continua acessível, exatamente como antes.

Pra testar: suba o `zelo-backend` (`http://localhost:8080`, sem contexto/prefixo) antes de rodar o app.

## outras APIs usadas

- ViaCEP pra preencher o endereço automaticamente quando digita o CEP na tela de agendamento
- OpenMeteo pra mostrar a temperatura na home (não precisa de API key)
- Google Maps na tela de mapa - pra rodar precisa colocar uma API key no AndroidManifest.xml (onde tá escrito SUA_GOOGLE_MAPS_API_KEY_AQUI)
- Firebase Cloud Messaging pra simular notificação push - deixamos comentado no main.dart porque não configuramos o projeto no Firebase console, mas o código de notification_service.dart já tá pronto

## AI Logistics Extension (camada de IA — demo)

A tela **Acompanhamento em Tempo Real** (`lib/screens/tracking_screen.dart`) demonstra a experiência de usuário completa da camada de IA Logistics do Zelo.

O que aparece na tela:
- Card do prestador com badge "IA ativa"
- Placeholder visual de mapa (sem Google Maps SDK por enquanto — aguardando API key)
- Stepper de 5 etapas animado: Aceite → A caminho → Chegou → Em execução → Concluído
- Card de ETA que atualiza conforme a etapa avança
- Banner de notificação que desliza do topo quando a IA detecta atraso no trânsito e recalcula o ETA (ponto central da demo)
- Painel "Motor de IA" com métricas: trânsito atual, score de pontualidade, confiança do ETA e latência de inferência

**Importante:** todos os dados exibidos vêm de um Timer local simulado — não há chamadas reais. O backend completo (endpoint FastAPI de inferência, modelo treinado no SageMaker, streaming via WebSocket e notificações push via Firebase FCM) está em desenvolvimento conforme o cronograma do projeto.

Para acessar a tela, abra um pedido com status "Confirmado" ou "Em andamento" na tela de Pedidos e toque em **Acompanhar em tempo real**.

## obs

login, cadastro e a lista de pedidos já usam o backend de verdade (ver seção acima). os dados dos prestadores (nome, foto, avaliação etc), a busca e o agendamento continuam mockados em lib/models/models.dart — ainda não tem endpoint de prestadores/serviços conectado no app.
