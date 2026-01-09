const admin = require("firebase-admin");

/**
 * Envia uma notificação para todos os usuários com notificações habilitadas.
 */
async function sendNotification(title, body) {
  const usersSnap = await admin.firestore()
    .collection("users")
    .where("notificationsEnabled", "==", true)
    .get();

  const tokens = usersSnap.docs
    .map(doc => doc.data().fcmToken)
    .filter(token => token != null && token !== "");

  if (tokens.length === 0) {
    console.log("Nenhum dispositivo registrado para receber notificações.");
    return;
  }

  const message = {
    notification: { title, body },
    tokens: tokens,
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`Sucesso: ${response.successCount} notificações enviadas.`);
  } catch (error) {
    console.error("Erro ao enviar notificações:", error);
  }
}

module.exports = { sendNotification };
