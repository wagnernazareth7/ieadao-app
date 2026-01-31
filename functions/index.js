const functions = require("firebase-functions");
const admin = require("firebase-admin");

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const { sendNotification } = require("./notifications/event_reminder");

/**
 * GATILHO DE LIVE: Envia notificação push quando o culto online começa
 */
exports.onLiveStreamStart = functions.firestore
  .document("live_stream/config")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Só dispara se 'isLive' mudou de FALSE para TRUE
    if (!before.isLive && after.isLive) {
      const title = "🔴 ESTAMOS AO VIVO!";
      const body = after.title || "O culto em direto acabou de começar. Clique para assistir!";
      
      console.log("Iniciando disparo de notificação de Live...");
      await sendNotification(title, body);
    }
    
    return null;
  });

/**
 * Cloud Function agendada: Lembrete de Eventos
 */
exports.eventReminder = functions.pubsub
  .schedule("every day 08:00")
  .timeZone("Africa/Maputo")
  .onRun(async (context) => {
    const now = new Date();
    const eventsSnap = await admin.firestore().collection("eventos").get();

    if (eventsSnap.empty) return null;

    for (const doc of eventsSnap.docs) {
      const event = doc.data();
      if (!event.data) continue;

      const eventDate = event.data.toDate();
      const diffTime = eventDate - now;
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

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
