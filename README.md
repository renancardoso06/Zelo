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

## APIs usadas

- ViaCEP pra preencher o endereço automaticamente quando digita o CEP na tela de agendamento
- OpenMeteo pra mostrar a temperatura na home (não precisa de API key)
- Google Maps na tela de mapa - pra rodar precisa colocar uma API key no AndroidManifest.xml (onde tá escrito SUA_GOOGLE_MAPS_API_KEY_AQUI)
- Firebase Cloud Messaging pra simular notificação push - deixamos comentado no main.dart porque não configuramos o projeto no Firebase console, mas o código de notification_service.dart já tá pronto

## obs

os dados dos prestadores (nome, foto, avaliação etc) são mockados em lib/models/models.dart, não tem backend de verdade ainda.
