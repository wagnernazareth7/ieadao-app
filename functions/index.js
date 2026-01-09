const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Inicializa o Admin SDK apenas uma vez no topo
if (admin.apps.length === 0) {
  admin.initializeApp();
}

const { sendNotification } = require("./notifications/event_reminder");

/**
 * Cloud Function agendada: Verifica eventos diariamente às 08:00
 * Timezone ajustado para África/Maputo
 */
exports.eventReminder = functions.pubsub
  .schedule("every day 08:00")
  .timeZone("Africa/Maputo")
  .onRun(async (context) => {
    const now = new Date();

    // Busca eventos na coleção correta
    const eventsSnap = await admin.firestore()
      .collection("eventos")
      .get();

    if (eventsSnap.empty) {
      console.log("Nenhum evento encontrado para processar.");
      return null;
    }

    for (const doc of eventsSnap.docs) {
      const event = doc.data();
      
      // Validação de segurança para evitar crashes se a data for nula
      if (!event.data) continue;

      // O Firestore armazena datas como objetos Timestamp
      const eventDate = event.data.toDate();
      
      // Cálculo da diferença de dias
      const diffTime = eventDate - now;
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

      // Lógica de notificação: 3 dias antes, 1 dia antes ou no dia (0)
      if ([3, 1, 0].includes(diffDays)) {
        let label = diffDays === 0 ? "hoje!" : `em ${diffDays} dia(s)`;
        
        await sendNotification(
          "Lembrete de Evento",
          `O evento "${event.titulo}" acontece ${label}. Não falte!`
        );
      }
    }
    return null;
  });
